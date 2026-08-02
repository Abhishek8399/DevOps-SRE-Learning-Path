package model

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"
)

const validFixture = `{"operation_id":"op-release-417","concurrency":4,"timeout_ms":2500}`

func TestDecodeRequest(t *testing.T) {
	t.Parallel()
	request, err := DecodeRequest(strings.NewReader(validFixture))
	if err != nil {
		t.Fatalf("DecodeRequest returned error: %v", err)
	}
	if request.OperationID != "op-release-417" || request.Concurrency != 4 || request.TimeoutMS != 2500 {
		t.Fatalf("unexpected request: %#v", request)
	}
}

func TestDecodeRequestRejectsInvalidBoundaries(t *testing.T) {
	t.Parallel()
	cases := map[string]string{
		"unknown field":     `{"operation_id":"op-x","concurrency":1,"timeout_ms":100,"retries":3}`,
		"missing field":     `{"operation_id":"op-x","concurrency":1}`,
		"wrong type":        `{"operation_id":"op-x","concurrency":"1","timeout_ms":100}`,
		"unsafe id":         `{"operation_id":"../../x","concurrency":1,"timeout_ms":100}`,
		"zero concurrency":  `{"operation_id":"op-x","concurrency":0,"timeout_ms":100}`,
		"large concurrency": `{"operation_id":"op-x","concurrency":17,"timeout_ms":100}`,
		"short timeout":     `{"operation_id":"op-x","concurrency":1,"timeout_ms":99}`,
		"trailing value":    validFixture + " {}",
	}
	for name, input := range cases {
		input := input
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if _, err := DecodeRequest(strings.NewReader(input)); err == nil {
				t.Fatalf("DecodeRequest accepted %q", input)
			}
		})
	}
}

func TestDecodeRequestRejectsOversize(t *testing.T) {
	t.Parallel()
	input := bytes.Repeat([]byte("x"), int(MaxRequestBytes)+1)
	if _, err := DecodeRequest(bytes.NewReader(input)); err == nil {
		t.Fatal("DecodeRequest accepted oversized input")
	}
}

func TestWaitForCancellation(t *testing.T) {
	t.Parallel()
	ctx, cancel := context.WithCancelCause(context.Background())
	expected := errors.New("controlled cancellation")
	cancel(expected)
	if err := WaitFor(ctx, time.Second); !errors.Is(err, expected) {
		t.Fatalf("WaitFor error = %v, want cancellation cause", err)
	}
}

func TestRecoverIdempotent(t *testing.T) {
	root := newLabRoot(t)
	if _, _, err := WriteBaseline(root); err != nil {
		t.Fatal(err)
	}
	if _, _, err := SelectCase(root, "guided"); err != nil {
		t.Fatal(err)
	}
	first, created, err := Recover(root, "guided")
	if err != nil {
		t.Fatal(err)
	}
	if !created {
		t.Fatal("first recovery did not create a receipt")
	}
	before, err := os.ReadFile(filepath.Join(root, "receipt.json"))
	if err != nil {
		t.Fatal(err)
	}
	second, created, err := Recover(root, "guided")
	if err != nil {
		t.Fatal(err)
	}
	if created {
		t.Fatal("second recovery created another receipt")
	}
	after, err := os.ReadFile(filepath.Join(root, "receipt.json"))
	if err != nil {
		t.Fatal(err)
	}
	if first != second || !bytes.Equal(before, after) {
		t.Fatal("idempotent recovery changed the receipt")
	}
}

func TestRecoverConcurrentCallersDoNotDuplicate(t *testing.T) {
	root := newLabRoot(t)
	if _, _, err := WriteBaseline(root); err != nil {
		t.Fatal(err)
	}
	if _, _, err := SelectCase(root, "independent"); err != nil {
		t.Fatal(err)
	}

	const callers = 8
	var group sync.WaitGroup
	group.Add(callers)
	results := make(chan error, callers)
	for i := 0; i < callers; i++ {
		go func() {
			defer group.Done()
			_, _, err := Recover(root, "independent")
			results <- err
		}()
	}
	group.Wait()
	close(results)

	successes := 0
	lockRefusals := 0
	for err := range results {
		switch {
		case err == nil:
			successes++
		case strings.Contains(err.Error(), "writer lock"):
			lockRefusals++
		default:
			t.Fatalf("unexpected concurrent recovery error: %v", err)
		}
	}
	if successes < 1 || successes+lockRefusals != callers {
		t.Fatalf("successes=%d lock_refusals=%d", successes, lockRefusals)
	}
	var receipt Receipt
	if err := readJSONFile(root, "receipt.json", &receipt); err != nil {
		t.Fatal(err)
	}
	if receipt.DuplicateReceipts != 0 {
		t.Fatalf("duplicate receipts = %d", receipt.DuplicateReceipts)
	}
}

func TestVerifyIdempotent(t *testing.T) {
	root := newLabRoot(t)
	if _, _, err := WriteBaseline(root); err != nil {
		t.Fatal(err)
	}
	if _, _, err := SelectCase(root, "independent"); err != nil {
		t.Fatal(err)
	}
	if _, _, err := Recover(root, "independent"); err != nil {
		t.Fatal(err)
	}
	first, created, err := Verify(root, "independent")
	if err != nil || !created {
		t.Fatalf("first Verify created=%v err=%v", created, err)
	}
	second, created, err := Verify(root, "independent")
	if err != nil || created {
		t.Fatalf("second Verify created=%v err=%v", created, err)
	}
	if first != second || !first.OperationSuccess {
		t.Fatal("verification was not stable and successful")
	}
}

func TestReceiptConflictFailsClosed(t *testing.T) {
	root := newLabRoot(t)
	if _, _, err := WriteBaseline(root); err != nil {
		t.Fatal(err)
	}
	if _, _, err := SelectCase(root, "guided"); err != nil {
		t.Fatal(err)
	}
	conflict := receiptFor("guided")
	conflict.IntentSHA256 = strings.Repeat("0", 64)
	if _, err := writeJSONFile(root, "receipt.json", conflict); err != nil {
		t.Fatal(err)
	}
	if _, _, err := Recover(root, "guided"); err == nil {
		t.Fatal("Recover accepted a conflicting receipt")
	}
}

func TestIndependentScenarioContainsNoDerivedAnswer(t *testing.T) {
	t.Parallel()
	scenario, err := Scenario("independent")
	if err != nil {
		t.Fatal(err)
	}
	data, err := json.Marshal(scenario)
	if err != nil {
		t.Fatal(err)
	}
	lower := strings.ToLower(string(data))
	required := []string{"op-network-417", "client_deadline_ms", "request_write_started", "response_received"}
	for _, token := range required {
		if !strings.Contains(lower, token) {
			t.Fatalf("independent scenario lacks %q: %s", token, data)
		}
	}
	forbidden := []string{
		"authoritative", "committed", "no_effect", "diagnosis", "root_cause",
		"recovery", "retry_allowed", "answer_key", "duplicate_effects",
	}
	for _, token := range forbidden {
		if strings.Contains(lower, token) {
			t.Fatalf("independent scenario exposed %q: %s", token, data)
		}
	}
}

func TestSafeRootRejectsOrdinaryTemporaryDirectory(t *testing.T) {
	t.Parallel()
	root := t.TempDir()
	if _, err := safeRoot(root); err == nil {
		t.Fatal("safeRoot accepted a directory outside the lesson naming contract")
	}
}

func TestReadJSONFileRejectsOversizedState(t *testing.T) {
	root := newLabRoot(t)
	data, err := canonicalJSON(BaselineEvidence())
	if err != nil {
		t.Fatal(err)
	}
	data = append(data, bytes.Repeat([]byte(" "), int(maxStateBytes)-len(data)+1)...)
	if err := os.WriteFile(filepath.Join(root, "baseline.json"), data, 0o600); err != nil {
		t.Fatal(err)
	}
	var baseline Baseline
	if err := readJSONFile(root, "baseline.json", &baseline); err == nil {
		t.Fatal("readJSONFile accepted oversized state")
	}
}

func FuzzDecodeRequest(f *testing.F) {
	f.Add([]byte(validFixture))
	f.Add([]byte(`{"operation_id":"op-x","concurrency":1,"timeout_ms":100}`))
	f.Add([]byte(`{"operation_id":"op-x","concurrency":0,"timeout_ms":100}`))
	f.Fuzz(func(t *testing.T, input []byte) {
		_, _ = DecodeRequest(bytes.NewReader(input))
	})
}

func BenchmarkDecodeRequest(b *testing.B) {
	payload := []byte(validFixture)
	b.ReportAllocs()
	for i := 0; i < b.N; i++ {
		if _, err := DecodeRequest(bytes.NewReader(payload)); err != nil {
			b.Fatal(err)
		}
	}
}

func newLabRoot(t *testing.T) string {
	t.Helper()
	token := strings.Repeat("a", 24) + time.Now().Format("15040500")
	if len(token) > 32 {
		token = token[:32]
	}
	if len(token) < 32 {
		token += strings.Repeat("b", 32-len(token))
	}
	root := filepath.Join(os.TempDir(), "reliability-atlas-LES-0020."+token)
	if err := os.Mkdir(root, 0o700); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(root); err != nil {
			t.Errorf("remove test root: %v", err)
		}
	})
	return root
}
