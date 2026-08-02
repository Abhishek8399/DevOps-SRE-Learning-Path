package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"

	"example.com/reliability-atlas/les0020/internal/model"
)

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

func run(args []string, stdout, stderr io.Writer) int {
	if len(args) == 0 {
		fmt.Fprintln(stderr, "usage: opsmodel baseline|select|scenario|observe|recover|verify|decode")
		return 2
	}

	var value any
	var err error
	switch args[0] {
	case "baseline":
		value, err = baselineCommand(args[1:], stderr)
	case "select":
		value, err = selectCommand(args[1:], stderr)
	case "scenario":
		value, err = scenarioCommand(args[1:], stderr)
	case "observe":
		value, err = observeCommand(args[1:], stderr)
	case "recover":
		value, err = recoverCommand(args[1:], stderr)
	case "verify":
		value, err = verifyCommand(args[1:], stderr)
	case "decode":
		value, err = decodeCommand(args[1:], stderr)
	default:
		fmt.Fprintf(stderr, "unknown command %q\n", args[0])
		return 2
	}
	if err != nil {
		fmt.Fprintf(stderr, "operation_error=%v\n", err)
		return 1
	}
	encoder := json.NewEncoder(stdout)
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(value); err != nil {
		fmt.Fprintf(stderr, "encode_error=%v\n", err)
		return 1
	}
	return 0
}

func baselineCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("baseline", stderr)
	root := flags.String("root", "", "registered lab root")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	value, created, err := model.WriteBaseline(*root)
	if err != nil {
		return nil, err
	}
	return map[string]any{"write": writeState(created), "evidence": value}, nil
}

func selectCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("select", stderr)
	root := flags.String("root", "", "registered lab root")
	caseName := flags.String("case", "", "guided or independent")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	value, created, err := model.SelectCase(*root, *caseName)
	if err != nil {
		return nil, err
	}
	return map[string]any{"write": writeState(created), "selection": value}, nil
}

func scenarioCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("scenario", stderr)
	caseName := flags.String("case", "", "guided or independent")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	return model.Scenario(*caseName)
}

func observeCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("observe", stderr)
	caseName := flags.String("case", "", "guided or independent")
	view := flags.String("view", "", "contract, runtime, state, or outcome")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	return model.Observation(*caseName, *view)
}

func recoverCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("recover", stderr)
	root := flags.String("root", "", "registered lab root")
	caseName := flags.String("case", "", "guided or independent")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	value, created, err := model.Recover(*root, *caseName)
	if err != nil {
		return nil, err
	}
	return map[string]any{"recovery": writeState(created), "receipt": value}, nil
}

func verifyCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("verify", stderr)
	root := flags.String("root", "", "registered lab root")
	caseName := flags.String("case", "", "guided or independent")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	value, created, err := model.Verify(*root, *caseName)
	if err != nil {
		return nil, err
	}
	return map[string]any{"verification": writeState(created), "evidence": value}, nil
}

func decodeCommand(args []string, stderr io.Writer) (any, error) {
	flags := newFlags("decode", stderr)
	input := flags.String("input", "", "one JSON request")
	if err := parseExact(flags, args); err != nil {
		return nil, err
	}
	return model.DecodeRequest(strings.NewReader(*input))
}

func newFlags(name string, stderr io.Writer) *flag.FlagSet {
	flags := flag.NewFlagSet(name, flag.ContinueOnError)
	flags.SetOutput(stderr)
	return flags
}

func parseExact(flags *flag.FlagSet, args []string) error {
	if err := flags.Parse(args); err != nil {
		return err
	}
	if flags.NArg() != 0 {
		return errors.New("unexpected positional arguments")
	}
	return nil
}

func writeState(created bool) string {
	if created {
		return "created"
	}
	return "already-complete"
}
