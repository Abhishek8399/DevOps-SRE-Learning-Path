package model

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"time"
)

const (
	LessonID        = "LES-0020"
	MaxRequestBytes = int64(4096)
	maxStateBytes   = int64(64 * 1024)
)

var (
	rootNamePattern  = regexp.MustCompile("^reliability-atlas-LES-0020\\.[a-f0-9]{32}$")
	operationPattern = regexp.MustCompile("^op-[a-z0-9]+(?:-[a-z0-9]+)*$")
	validCases       = map[string]bool{"guided": true, "independent": true}
	validViews       = map[string]bool{"contract": true, "runtime": true, "state": true, "outcome": true}
	allowedFiles     = map[string]bool{
		"baseline.json":     true,
		"case.json":         true,
		"receipt.json":      true,
		"verification.json": true,
	}
)

type requestWire struct {
	OperationID *string `json:"operation_id"`
	Concurrency *int    `json:"concurrency"`
	TimeoutMS   *int    `json:"timeout_ms"`
}

type Request struct {
	OperationID string `json:"operation_id"`
	Concurrency int    `json:"concurrency"`
	TimeoutMS   int    `json:"timeout_ms"`
}

type Baseline struct {
	Record            string `json:"record"`
	AcceptedJobs      int    `json:"accepted_jobs"`
	TerminalResults   int    `json:"terminal_results"`
	DuplicateReceipts int    `json:"duplicate_receipts"`
	Cancellation      string `json:"cancellation"`
	ConsumerReadback  string `json:"consumer_readback"`
	OperationSuccess  bool   `json:"operation_success"`
	Scope             string `json:"scope"`
}

type CaseSelection struct {
	Record string `json:"record"`
	Case   string `json:"case"`
}

type Receipt struct {
	SchemaVersion     int    `json:"schema_version"`
	LessonID          string `json:"lesson_id"`
	Case              string `json:"case"`
	OperationID       string `json:"operation_id"`
	IntentSHA256      string `json:"intent_sha256"`
	Outcome           string `json:"outcome"`
	ExpectedResults   int    `json:"expected_results"`
	TerminalResults   int    `json:"terminal_results"`
	DuplicateReceipts int    `json:"duplicate_receipts"`
	ConsumerReadback  string `json:"consumer_readback"`
	Scope             string `json:"scope"`
}

type Verification struct {
	SchemaVersion     int    `json:"schema_version"`
	LessonID          string `json:"lesson_id"`
	Case              string `json:"case"`
	OperationID       string `json:"operation_id"`
	ReceiptSHA256     string `json:"receipt_sha256"`
	OperationSuccess  bool   `json:"operation_success"`
	ExpectedResults   int    `json:"expected_results"`
	TerminalResults   int    `json:"terminal_results"`
	DuplicateReceipts int    `json:"duplicate_receipts"`
	ConsumerReadback  string `json:"consumer_readback"`
	Scope             string `json:"verification_scope"`
}

func DecodeRequest(r io.Reader) (Request, error) {
	data, err := io.ReadAll(io.LimitReader(r, MaxRequestBytes+1))
	if err != nil {
		return Request{}, fmt.Errorf("read request: %w", err)
	}
	if int64(len(data)) > MaxRequestBytes {
		return Request{}, fmt.Errorf("request exceeds %d bytes", MaxRequestBytes)
	}

	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()

	var wire requestWire
	if err := decoder.Decode(&wire); err != nil {
		return Request{}, fmt.Errorf("decode request: %w", err)
	}

	var trailing any
	err = decoder.Decode(&trailing)
	switch {
	case errors.Is(err, io.EOF):
	case err == nil:
		return Request{}, errors.New("decode request: trailing JSON value")
	default:
		return Request{}, fmt.Errorf("decode trailing data: %w", err)
	}

	if wire.OperationID == nil || wire.Concurrency == nil || wire.TimeoutMS == nil {
		return Request{}, errors.New("validate request: operation_id, concurrency, and timeout_ms are required")
	}

	request := Request{
		OperationID: strings.TrimSpace(*wire.OperationID),
		Concurrency: *wire.Concurrency,
		TimeoutMS:   *wire.TimeoutMS,
	}
	if !operationPattern.MatchString(request.OperationID) {
		return Request{}, errors.New("validate request: operation_id must use lowercase letters, digits, and hyphens after op-")
	}
	if request.Concurrency < 1 || request.Concurrency > 16 {
		return Request{}, errors.New("validate request: concurrency must be between 1 and 16")
	}
	if request.TimeoutMS < 100 || request.TimeoutMS > 30000 {
		return Request{}, errors.New("validate request: timeout_ms must be between 100 and 30000")
	}
	return request, nil
}

func BaselineEvidence() Baseline {
	return Baseline{
		Record:            "baseline",
		AcceptedJobs:      3,
		TerminalResults:   3,
		DuplicateReceipts: 0,
		Cancellation:      "none",
		ConsumerReadback:  "valid",
		OperationSuccess:  true,
		Scope:             "deterministic_model_only",
	}
}

func Scenario(caseName string) (map[string]any, error) {
	if err := validateCase(caseName); err != nil {
		return nil, err
	}
	if caseName == "guided" {
		return map[string]any{
			"record":                "scenario_input",
			"case":                  "guided",
			"operation":             "publish_inventory",
			"operation_id":          "op-inventory-204",
			"accepted_jobs":         3,
			"reported_exit_code":    0,
			"reported_results":      2,
			"cancellation_observed": true,
			"network":               "deterministic_model_only",
		}, nil
	}
	return map[string]any{
		"record":                  "scenario_input",
		"case":                    "independent",
		"operation":               "set_network_policy_generation",
		"operation_id":            "op-network-417",
		"target":                  "edge-policy",
		"desired_generation":      42,
		"client_deadline_ms":      30000,
		"configured_max_attempts": 3,
		"request_write_started":   true,
		"response_received":       false,
		"local_phase":             "attempting",
		"network":                 "deterministic_model_only",
	}, nil
}

func Observation(caseName, view string) (map[string]any, error) {
	if err := validateCase(caseName); err != nil {
		return nil, err
	}
	if !validViews[view] {
		return nil, errors.New("view must be one of contract, runtime, state, outcome")
	}
	common := map[string]any{"record": "observation", "case": caseName, "view": view}
	var fields map[string]any
	if caseName == "guided" {
		fields = map[string]map[string]any{
			"contract": {
				"accepted_jobs": 3, "required_terminal_results": 3, "reported_terminal_results": 2,
				"success_requires_set_equality": true,
			},
			"runtime": {
				"collector_returned_on_first_error": true, "worker_send_waiting": 1,
				"result_send_observes_context": false, "coordinator_joined_workers": false,
			},
			"state": {
				"local_receipt_present": false, "candidate_published": true,
				"consumer_record_count": 2, "previous_good_retained": false,
			},
			"outcome": {
				"job_1": "committed", "job_2": "definite_no_effect_validation_rejection",
				"job_3": "committed_result_not_collected", "duplicate_effects": 0,
			},
		}[view]
	} else {
		fields = map[string]map[string]any{
			"contract": {
				"operation_id": "op-network-417", "intended_generation": 42,
				"success_requires_authority_readback": true,
			},
			"runtime": {
				"request_write_started": true, "response_received": false,
				"client_observation": "deadline_expired", "elapsed_ms": 30000,
			},
			"state": {
				"local_phase": "attempting", "local_receipt_present": false,
				"automatic_second_attempt_started": false, "state_owner": "modeled_policy_service",
			},
			"outcome": {
				"lookup_operation_id": "op-network-417", "authoritative_lookup": "found",
				"authoritative_state": "committed", "target_generation": 42,
				"service_attempt_count": 1, "duplicate_effects": 0,
			},
		}[view]
	}
	for key, value := range fields {
		common[key] = value
	}
	return common, nil
}

func WriteBaseline(root string) (Baseline, bool, error) {
	value := BaselineEvidence()
	created, err := writeJSONFile(root, "baseline.json", value)
	return value, created, err
}

func SelectCase(root, caseName string) (CaseSelection, bool, error) {
	if err := validateCase(caseName); err != nil {
		return CaseSelection{}, false, err
	}
	value := CaseSelection{Record: "case_selection", Case: caseName}
	created, err := writeJSONFile(root, "case.json", value)
	return value, created, err
}

func ReadCase(root string) (CaseSelection, error) {
	var value CaseSelection
	if err := readJSONFile(root, "case.json", &value); err != nil {
		return CaseSelection{}, err
	}
	if value.Record != "case_selection" {
		return CaseSelection{}, errors.New("case file record is invalid")
	}
	if err := validateCase(value.Case); err != nil {
		return CaseSelection{}, err
	}
	return value, nil
}

func Recover(root, caseName string) (Receipt, bool, error) {
	if err := validateCase(caseName); err != nil {
		return Receipt{}, false, err
	}
	selected, err := ReadCase(root)
	if err != nil {
		return Receipt{}, false, fmt.Errorf("read selected case: %w", err)
	}
	if selected.Case != caseName {
		return Receipt{}, false, errors.New("selected case does not match recovery request")
	}
	expected := receiptFor(caseName)
	created, err := writeJSONFile(root, "receipt.json", expected)
	if err != nil {
		return Receipt{}, false, err
	}
	return expected, created, nil
}

func Verify(root, caseName string) (Verification, bool, error) {
	if err := validateCase(caseName); err != nil {
		return Verification{}, false, err
	}
	expectedReceipt := receiptFor(caseName)
	var actual Receipt
	if err := readJSONFile(root, "receipt.json", &actual); err != nil {
		return Verification{}, false, fmt.Errorf("read receipt: %w", err)
	}
	if actual != expectedReceipt {
		return Verification{}, false, errors.New("receipt does not match the expected operation and intent")
	}
	receiptBytes, err := canonicalJSON(actual)
	if err != nil {
		return Verification{}, false, err
	}
	sum := sha256.Sum256(receiptBytes)
	value := Verification{
		SchemaVersion:     1,
		LessonID:          LessonID,
		Case:              caseName,
		OperationID:       actual.OperationID,
		ReceiptSHA256:     hex.EncodeToString(sum[:]),
		OperationSuccess:  true,
		ExpectedResults:   actual.ExpectedResults,
		TerminalResults:   actual.TerminalResults,
		DuplicateReceipts: actual.DuplicateReceipts,
		ConsumerReadback:  actual.ConsumerReadback,
		Scope:             "deterministic_model_only",
	}
	created, err := writeJSONFile(root, "verification.json", value)
	if err != nil {
		return Verification{}, false, err
	}
	return value, created, nil
}

func WaitFor(ctx context.Context, delay time.Duration) error {
	timer := time.NewTimer(delay)
	defer timer.Stop()
	select {
	case <-ctx.Done():
		return context.Cause(ctx)
	case <-timer.C:
		return nil
	}
}

func validateCase(caseName string) error {
	if !validCases[caseName] {
		return errors.New("case must be guided or independent")
	}
	return nil
}

func receiptFor(caseName string) Receipt {
	if caseName == "guided" {
		return Receipt{
			SchemaVersion: 1, LessonID: LessonID, Case: caseName,
			OperationID:  "op-inventory-204",
			IntentSHA256: "dc4adef9f65253c06b0a4291774bf92214f5d134e1b4bf8da9f78291e9345634",
			Outcome:      "reconciled_complete", ExpectedResults: 3, TerminalResults: 3,
			DuplicateReceipts: 0, ConsumerReadback: "valid", Scope: "deterministic_model_only",
		}
	}
	return Receipt{
		SchemaVersion: 1, LessonID: LessonID, Case: caseName,
		OperationID:  "op-network-417",
		IntentSHA256: "374121d9463143914c3f9cdde102116e316282689a0e13acaaf48e981d7084ca",
		Outcome:      "adopted_existing_commit", ExpectedResults: 1, TerminalResults: 1,
		DuplicateReceipts: 0, ConsumerReadback: "generation_42", Scope: "deterministic_model_only",
	}
}

func canonicalJSON(value any) ([]byte, error) {
	data, err := json.MarshalIndent(value, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("encode JSON: %w", err)
	}
	return append(data, '\n'), nil
}

func writeJSONFile(root, name string, value any) (bool, error) {
	if !allowedFiles[name] {
		return false, fmt.Errorf("file %q is not allowlisted", name)
	}
	canonicalRoot, err := safeRoot(root)
	if err != nil {
		return false, err
	}
	lockPath := filepath.Join(canonicalRoot, ".writer.lock")
	if err := os.Mkdir(lockPath, 0o700); err != nil {
		return false, fmt.Errorf("acquire writer lock: %w", err)
	}
	defer func() {
		_ = os.Remove(lockPath)
	}()

	data, err := canonicalJSON(value)
	if err != nil {
		return false, err
	}
	target := filepath.Join(canonicalRoot, name)
	if info, statErr := os.Lstat(target); statErr == nil {
		if info.Mode()&os.ModeSymlink != 0 || !info.Mode().IsRegular() {
			return false, fmt.Errorf("existing %s is not a regular file", name)
		}
		current, readErr := os.ReadFile(target)
		if readErr != nil {
			return false, fmt.Errorf("read existing %s: %w", name, readErr)
		}
		if bytes.Equal(current, data) {
			return false, nil
		}
		return false, fmt.Errorf("existing %s conflicts with requested content", name)
	} else if !errors.Is(statErr, os.ErrNotExist) {
		return false, fmt.Errorf("inspect %s: %w", name, statErr)
	}

	candidate, err := os.CreateTemp(canonicalRoot, "."+name+".*.tmp")
	if err != nil {
		return false, fmt.Errorf("create candidate for %s: %w", name, err)
	}
	candidateName := candidate.Name()
	closed := false
	defer func() {
		if !closed {
			_ = candidate.Close()
		}
		_ = os.Remove(candidateName)
	}()
	if err := candidate.Chmod(0o600); err != nil {
		return false, fmt.Errorf("set candidate mode: %w", err)
	}
	written, err := candidate.Write(data)
	if err != nil {
		return false, fmt.Errorf("write candidate: %w", err)
	}
	if written != len(data) {
		return false, io.ErrShortWrite
	}
	if err := candidate.Sync(); err != nil {
		return false, fmt.Errorf("sync candidate: %w", err)
	}
	if err := candidate.Close(); err != nil {
		return false, fmt.Errorf("close candidate: %w", err)
	}
	closed = true

	onDisk, err := os.ReadFile(candidateName)
	if err != nil {
		return false, fmt.Errorf("read back candidate: %w", err)
	}
	if !bytes.Equal(onDisk, data) {
		return false, errors.New("candidate readback differs from written bytes")
	}
	var check any
	if err := decodeStrict(bytes.NewReader(onDisk), &check); err != nil {
		return false, fmt.Errorf("validate candidate: %w", err)
	}
	if _, err := os.Lstat(target); err == nil {
		return false, fmt.Errorf("target %s appeared before publication", name)
	} else if !errors.Is(err, os.ErrNotExist) {
		return false, fmt.Errorf("recheck %s: %w", name, err)
	}
	if err := os.Rename(candidateName, target); err != nil {
		return false, fmt.Errorf("publish %s: %w", name, err)
	}
	return true, nil
}

func readJSONFile(root, name string, destination any) error {
	if !allowedFiles[name] {
		return fmt.Errorf("file %q is not allowlisted", name)
	}
	canonicalRoot, err := safeRoot(root)
	if err != nil {
		return err
	}
	target := filepath.Join(canonicalRoot, name)
	info, err := os.Lstat(target)
	if err != nil {
		return fmt.Errorf("inspect %s: %w", name, err)
	}
	if info.Mode()&os.ModeSymlink != 0 || !info.Mode().IsRegular() {
		return fmt.Errorf("%s is not a regular file", name)
	}
	file, err := os.Open(target)
	if err != nil {
		return fmt.Errorf("open %s: %w", name, err)
	}
	defer file.Close()
	data, err := io.ReadAll(io.LimitReader(file, maxStateBytes+1))
	if err != nil {
		return fmt.Errorf("read %s: %w", name, err)
	}
	if int64(len(data)) > maxStateBytes {
		return fmt.Errorf("%s exceeds %d bytes", name, maxStateBytes)
	}
	if err := decodeStrict(bytes.NewReader(data), destination); err != nil {
		return fmt.Errorf("decode %s: %w", name, err)
	}
	return nil
}

func decodeStrict(reader io.Reader, destination any) error {
	decoder := json.NewDecoder(reader)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(destination); err != nil {
		return err
	}
	var trailing any
	err := decoder.Decode(&trailing)
	if errors.Is(err, io.EOF) {
		return nil
	}
	if err == nil {
		return errors.New("trailing JSON value")
	}
	return err
}

func safeRoot(root string) (string, error) {
	if strings.TrimSpace(root) == "" {
		return "", errors.New("lab root is required")
	}
	absolute, err := filepath.Abs(root)
	if err != nil {
		return "", fmt.Errorf("resolve lab root: %w", err)
	}
	absolute = filepath.Clean(absolute)
	if !rootNamePattern.MatchString(filepath.Base(absolute)) {
		return "", errors.New("lab root name is outside the LES-0020 contract")
	}
	tempAbsolute, err := filepath.Abs(os.TempDir())
	if err != nil {
		return "", fmt.Errorf("resolve temporary directory: %w", err)
	}
	tempReal, err := filepath.EvalSymlinks(tempAbsolute)
	if err != nil {
		return "", fmt.Errorf("resolve temporary directory links: %w", err)
	}
	rootReal, err := filepath.EvalSymlinks(absolute)
	if err != nil {
		return "", fmt.Errorf("resolve lab root links: %w", err)
	}
	relative, err := filepath.Rel(tempReal, rootReal)
	if err != nil {
		return "", fmt.Errorf("compare lab root: %w", err)
	}
	if relative == "." || relative == ".." || strings.HasPrefix(relative, ".."+string(filepath.Separator)) || filepath.IsAbs(relative) {
		return "", errors.New("lab root is outside the current temporary directory")
	}
	if runtime.GOOS == "windows" {
		if !strings.EqualFold(filepath.Clean(rootReal), absolute) {
			return "", errors.New("lab root contains a reparse or canonical-path change")
		}
	} else if filepath.Clean(rootReal) != absolute {
		return "", errors.New("lab root contains a symbolic-link or canonical-path change")
	}
	info, err := os.Lstat(absolute)
	if err != nil {
		return "", fmt.Errorf("inspect lab root: %w", err)
	}
	if info.Mode()&os.ModeSymlink != 0 || !info.IsDir() {
		return "", errors.New("lab root is not a real directory")
	}
	return absolute, nil
}
