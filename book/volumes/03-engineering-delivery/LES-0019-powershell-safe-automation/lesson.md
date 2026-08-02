---
{
  "schemaVersion": 1,
  "kind": "lesson",
  "id": "LES-0019",
  "aliases": ["V03-L04", "powershell-safe-automation"],
  "curriculumIds": ["AUT-003"],
  "slug": "powershell-safe-automation",
  "route": "/book/engineering/powershell-safe-automation",
  "order": 4,
  "volume": "03-engineering-delivery",
  "title": "PowerShell safe operational automation: preserve objects, control effects, and prove outcomes",
  "summary": "Learn PowerShell as an operational programming environment rather than a bag of commands: preserve typed objects through pipelines, make error and native-process contracts explicit, validate parameters, quote and bind data safely, honor ShouldProcess, design idempotent and observable effects, protect credentials, test modules across editions, and verify the real postcondition before reporting success.",
  "domain": "engineering",
  "level": {"from": "foundation", "to": "advanced"},
  "estimatedMinutes": 480,
  "prerequisiteLessonIds": ["LES-0009", "LES-0017"],
  "prerequisiteCurriculumIds": ["SCM-001", "AUT-001"],
  "testedEnvironments": [
    {
      "platform": "Windows PowerShell",
      "version": "5.1.26100.8875 Desktop edition on Windows 11",
      "support": "required",
      "notes": "The required offline lab uses the already-installed non-elevated Windows PowerShell engine. It creates only ACL-protected current-user temporary state, contacts no network, requests no credential, and performs exact allowlisted cleanup."
    },
    {
      "platform": "Windows Subsystem for Linux (WSL 2) Ubuntu",
      "version": "Ubuntu 24.04 LTS invoking Windows PowerShell 5.1 through powershell.exe",
      "support": "supported",
      "notes": "Ubuntu performs the bridge invocation, but the lab process, identity, paths, access-control lists, temporary directory, and exit code belong to Windows. Native PowerShell 7 is not installed in the tested Ubuntu environment, and this lesson performs no networked installation."
    },
    {
      "platform": "PowerShell 7, CI runners, Windows servers, Linux servers, containers, Kubernetes, private cloud, and public cloud",
      "version": "cross-edition and provider-neutral concepts",
      "support": "concept-only",
      "notes": "The lesson identifies edition, operating-system, remoting, serialization, identity, module, controller, and state-owner differences. It does not configure remoting, install modules, use credentials, change a server, create a cloud resource, or claim Windows PowerShell 5.1 tests PowerShell 7 behavior."
    }
  ],
  "targetRoles": ["site-reliability-engineer", "devops-engineer", "platform-engineer", "production-engineer", "cloud-infrastructure-engineer", "release-engineer", "windows-systems-engineer", "security-engineer"],
  "learningObjectives": [
    "Trace a PowerShell invocation through engine discovery, parsing, parameter binding, object pipelines, effect boundaries, streams, verification, and process exit translation.",
    "Preserve .NET object types and properties until an intentional formatting or serialization boundary, and diagnose when text conversion destroys machine-readable meaning.",
    "Distinguish success output, ErrorRecord objects, nonterminating and terminating errors, exceptions, native exit codes, and semantic postconditions without treating any one signal as universal truth.",
    "Build advanced functions with strict mode, explicit parameters, validation attributes, stable output types, narrow error contracts, ShouldProcess, and caller-safe exit behavior.",
    "Pass data safely through PowerShell and native-process boundaries using deliberate quoting, arrays, splatting, executable identity checks, bounded streams, deadlines, and immediate status capture.",
    "Design idempotent and concurrency-safe operations using desired-state checks, stable operation identities, authoritative readback, conditional writes, bounded retry, reconciliation, and explicit ownership.",
    "Protect credentials and secrets across variables, arguments, streams, transcripts, remoting serialization, jobs, logs, and temporary files while preferring identity-based access and approved vaults.",
    "Package and test operational code as versioned modules with pure planning functions, narrow effect adapters, Pester tests, process-level contract tests, cross-edition matrices, observable outcomes, and safe rollback or compensation."
  ],
  "productionSignals": [
    "A script prints red errors yet continues and exits zero because the failing cmdlet emitted a nonterminating error that never entered catch.",
    "A pipeline works on the console but returns zero records after Out-String or Format-Table replaced typed objects with presentation data.",
    "A native executable returns nonzero, but the script runs another native command before reading LASTEXITCODE and reports the later status instead.",
    "The same script resolves a different executable, module, command type, or parameter set on an interactive workstation and on a CI runner.",
    "A retry duplicates a remote change because client timeout was treated as proof that the target did not commit.",
    "Parallel jobs or runspaces race on one file, registry key, API object, or checkpoint without a state owner, conditional version, lock, lease, or fence.",
    "A transcript, verbose message, exception, process argument, remoting payload, or serialized object contains a password, token, connection string, or private endpoint.",
    "WhatIf reports a safe plan while a nested function or external program still mutates state because the effect did not participate in ShouldProcess.",
    "A deserialized remoting object is treated as a live local object and a method call, type test, or freshness assumption fails.",
    "Automation duration, memory, process count, runspace count, log volume, retry traffic, or output cardinality grows faster than completed operations."
  ],
  "diagrams": [
    {
      "id": "LES-0019-DIA-001",
      "title": "A trustworthy PowerShell invocation crosses explicit contracts",
      "direction": "left-to-right",
      "boundaries": ["host and engine", "parser and parameter binder", "typed object pipeline", "effect adapter", "state owner", "readback verification", "streams and process exit"],
      "evidencePoints": ["PSVersionTable and executable path", "PSBoundParameters and types", "GetType and Get-Member", "target action deadline operation ID", "resource version or receipt", "promised postcondition", "ErrorRecord native status and final exit"],
      "textAlternative": "A host starts a particular PowerShell engine. The parser and binder turn source and arguments into typed parameters. Typed objects flow through planning code, an effect adapter crosses to the real state owner, readback checks the promised outcome, and separate streams plus a deliberate process exit report the result."
    },
    {
      "id": "LES-0019-DIA-002",
      "title": "Objects survive until a presentation or serialization boundary",
      "direction": "left-to-right",
      "boundaries": ["provider objects", "filter and project", "formatting system", "text sink", "serialization or remoting", "consumer contract"],
      "evidencePoints": ["type names and properties", "selected typed fields", "format metadata or strings", "rendered bytes", "deserialized type and depth", "schema and readback"],
      "textAlternative": "Provider objects retain types and properties through filters and projections. Format commands prepare presentation, text sinks render strings, and serialization creates a transport representation. A consumer receives only what that boundary preserves, so formatting must remain at the human-facing edge."
    },
    {
      "id": "LES-0019-DIA-003",
      "title": "PowerShell failure has several independent channels",
      "direction": "top-to-bottom",
      "boundaries": ["cmdlet emits ErrorRecord", "preference chooses continue or stop", "catch sees terminating flow", "native process returns integer", "automation classifies outcome", "state owner proves postcondition"],
      "evidencePoints": ["error stream and FullyQualifiedErrorId", "ErrorAction and ErrorActionPreference", "exception type and invocation info", "immediate LASTEXITCODE and bounded stderr", "stable result enum and final process exit", "receipt version and user-visible readback"],
      "textAlternative": "A cmdlet error record may continue or be promoted to terminating flow that catch can handle. A native process reports a separate integer status. The automation must translate both into a stable result, but only authoritative state and postcondition readback prove whether the operation succeeded."
    },
    {
      "id": "LES-0019-DIA-004",
      "title": "A safe mutation is a reconciled state machine",
      "direction": "cyclic",
      "boundaries": ["validate desired state", "persist logical intent", "compare authoritative state", "plan minimal change", "ShouldProcess decision", "bounded attempt", "unknown outcome reconciliation", "verify original operation"],
      "evidencePoints": ["typed request and authorization", "operation ID and intent digest", "resource version and current value", "target set and blast radius", "WhatIf or approval record", "deadline status and receipt", "query by stable identity", "postcondition and duplicate count"],
      "textAlternative": "The tool validates desired state, records one logical intent, reads the authoritative current state, plans the smallest change, asks ShouldProcess, performs one bounded attempt, reconciles any ambiguous outcome by the same identity, and verifies the original user operation before completing."
    },
    {
      "id": "LES-0019-DIA-005",
      "title": "Remoting changes identity, representation, and trust",
      "direction": "hierarchical",
      "boundaries": ["local caller", "transport and authentication", "remote endpoint configuration", "remote process identity", "serialized result", "second resource hop"],
      "evidencePoints": ["local engine and credential source", "protocol host certificate or Kerberos context", "allowed commands and language mode", "remote SID groups and privileges", "Deserialized type and retained properties", "delegation or fresh target identity"],
      "textAlternative": "A local caller authenticates through a transport to a configured endpoint. Code runs under a remote identity, results are serialized back rather than returned as live objects, and access to a third resource is a separate credential-delegation boundary."
    }
  ],
  "commands": [
    {
      "id": "LES-0019-CMD-001",
      "question": "Which PowerShell engine, host process, operating system, identity, and elevation state define this invocation?",
      "risk": "read-only",
      "command": "$PSVersionTable | Select-Object PSVersion,PSEdition,BuildVersion; Get-Process -Id $PID | Select-Object Id,ProcessName,Path; [Security.Principal.WindowsIdentity]::GetCurrent() | Select-Object Name,User; [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)",
      "runFrom": "The exact PowerShell process that will run the automation",
      "expectedBranches": [
        {"when": "The engine, edition, executable, identity, and non-elevated state match the supported runtime", "meaning": "The process baseline matches this lesson's declared lab boundary.", "nextEvidence": "Inspect command and module resolution before running operational code."},
        {"when": "Edition, path, user, or elevation differs", "meaning": "A foundational runtime or privilege assumption is false.", "nextEvidence": "Stop and select the reviewed process; do not compensate by weakening policy or adding privilege."}
      ],
      "proves": "Point-in-time identity of this PowerShell process and the displayed administrator-role result.",
      "doesNotProve": "Command resolution, module provenance, language mode, remote identity, authorization, or safe behavior of a script."
    },
    {
      "id": "LES-0019-CMD-002",
      "question": "What implementation will PowerShell invoke for a command name?",
      "risk": "read-only",
      "command": "Get-Command Get-ChildItem -All | Select-Object CommandType,Name,Version,Source,ModuleName,Definition",
      "runFrom": "The same session, module path, and working directory as the automation",
      "expectedBranches": [
        {"when": "The intended cmdlet or function appears first with expected source and version", "meaning": "Name resolution for this session matches the recorded expectation.", "nextEvidence": "Inspect its syntax and parameter metadata."},
        {"when": "An alias, function, script, application, or unexpected module shadows the intended command", "meaning": "Behavior can differ before business logic begins.", "nextEvidence": "Use a module-qualified command or approved absolute executable and investigate the unexpected definition."}
      ],
      "proves": "Candidates currently discoverable for the selected command name and their resolution metadata.",
      "doesNotProve": "File signature, module integrity, future resolution after module-path changes, or safety of invoking the command."
    },
    {
      "id": "LES-0019-CMD-003",
      "question": "Are pipeline elements still typed objects with the properties the next command needs?",
      "risk": "read-only",
      "command": "$item = Get-Item -LiteralPath .; $item.GetType().FullName; $item | Get-Member -MemberType Properties | Select-Object -First 6 Name,MemberType,Definition; $item | Select-Object FullName,Attributes",
      "runFrom": "A reviewed local directory; the command only reads that directory object",
      "expectedBranches": [
        {"when": "A filesystem object type and expected properties appear", "meaning": "Structured identity is present at this pipeline point.", "nextEvidence": "Keep filters and decisions before any Format, Out-String, or text sink."},
        {"when": "System.String, formatting data, or missing properties appear", "meaning": "An earlier boundary destroyed or changed the object contract.", "nextEvidence": "Move formatting to the final human-output edge and retest types."}
      ],
      "proves": "The runtime type and displayed member metadata of this sampled object.",
      "doesNotProve": "That every pipeline element has the same shape, that property values are fresh, or that later serialization preserves methods and depth."
    },
    {
      "id": "LES-0019-CMD-004",
      "question": "Which parameter accepts pipeline input and how will binding occur?",
      "risk": "read-only",
      "command": "@('LiteralPath','NewName') | ForEach-Object { Get-Help Rename-Item -Parameter $_ } | Select-Object Name,Type,Required,Position,PipelineInput,Aliases",
      "runFrom": "Any supported PowerShell session; this inspects local help metadata and does not rename anything",
      "expectedBranches": [
        {"when": "PipelineInput explicitly names by-value or by-property-name binding", "meaning": "The binder has a declared route for compatible input.", "nextEvidence": "Test representative typed input with WhatIf in a disposable location before mutation."},
        {"when": "Pipeline input is false or required properties/types do not match", "meaning": "The proposed pipeline relies on an unsupported binding assumption.", "nextEvidence": "Bind the parameter explicitly or project the exact documented property."}
      ],
      "proves": "Parameter metadata available to this engine and help installation.",
      "doesNotProve": "That a particular object binds as expected, that local help is current, or that the mutation is authorized."
    },
    {
      "id": "LES-0019-CMD-005",
      "question": "How does the parameter binder classify a synthetic argument without performing an effect?",
      "risk": "read-only",
      "command": "function Test-Binding { [CmdletBinding()] param([Parameter(ValueFromPipelineByPropertyName)][ValidateRange(1,5)][int]$Count) process { [pscustomobject]@{Count=$Count;Type=$Count.GetType().FullName} } }; [pscustomobject]@{Count='3'} | Test-Binding",
      "runFrom": "An isolated lesson session; the temporary function exists only in that process",
      "expectedBranches": [
        {"when": "Count 3 and System.Int32 appear", "meaning": "By-property-name binding found Count, converted its string representation, and range validation accepted it.", "nextEvidence": "Define whether conversion from text is permitted at the real boundary and test invalid, absent, repeated, and extreme inputs."},
        {"when": "ParameterBinding or validation error appears", "meaning": "The supplied property cannot satisfy the declared contract.", "nextEvidence": "Return a stable caller-safe validation failure before any effect."}
      ],
      "proves": "Binding and validation behavior for one synthetic object in this engine.",
      "doesNotProve": "Authorization, semantic correctness of 3, locale-independent conversion for other values, or production parameter-set selection."
    },
    {
      "id": "LES-0019-CMD-006",
      "question": "Will a nonterminating cmdlet error enter catch under the selected policy?",
      "risk": "read-only",
      "command": "try { Get-Item -LiteralPath (Join-Path $env:TEMP 'reliability-atlas-definitely-absent') -ErrorAction Stop; 'unreachable' } catch { [pscustomobject]@{Caught=$true;Exception=$_.Exception.GetType().FullName;ErrorId=$_.FullyQualifiedErrorId;Category=$_.CategoryInfo.Category} }",
      "runFrom": "A normal local session; choose only the fixed lesson pathname and confirm it is absent",
      "expectedBranches": [
        {"when": "Caught true with an item-not-found error record appears", "meaning": "ErrorAction Stop promoted this expected nonterminating error into terminating control flow for the try block.", "nextEvidence": "Translate this specific expected error to the automation's stable result without hiding unrelated defects."},
        {"when": "The object unexpectedly exists", "meaning": "The synthetic precondition is false.", "nextEvidence": "Choose another reviewed absent synthetic name; do not remove the unexpected object."}
      ],
      "proves": "Error promotion and catch behavior for this command, path, policy, and engine.",
      "doesNotProve": "That all errors are terminating, that catch handles native statuses, or that broad catch-and-continue is safe."
    },
    {
      "id": "LES-0019-CMD-007",
      "question": "What strict-mode and preference values influence this scope?",
      "risk": "read-only",
      "command": "& { Set-StrictMode -Version Latest; Get-Variable ErrorActionPreference,WarningPreference,VerbosePreference,InformationPreference,ConfirmPreference,WhatIfPreference | Select-Object Name,Value; $ExecutionContext.SessionState.LanguageMode }",
      "runFrom": "Any lesson session; the child script-block scope prevents strict mode from persisting in the caller after this command returns",
      "expectedBranches": [
        {"when": "Strict mode is accepted and declared preferences appear", "meaning": "The scope now refuses several ambiguous variable/property behaviors and exposes its stream policy.", "nextEvidence": "Test the exact error, native-process, and ShouldProcess paths; strict mode is not their replacement."},
        {"when": "Language mode or preference differs from the expected host", "meaning": "Policy or profile state may change available features and control flow.", "nextEvidence": "Record the host policy and run the supported test matrix rather than bypassing it."}
      ],
      "proves": "Displayed preference values and language mode in this scope after enabling strict mode.",
      "doesNotProve": "That all called modules inherit preferences, that native failures throw, or that the script is correct."
    },
    {
      "id": "LES-0019-CMD-008",
      "question": "What exit code did a synthetic native process return?",
      "risk": "read-only",
      "command": "& $env:ComSpec /d /c 'exit 7'; $nativeCode = $LASTEXITCODE; [pscustomobject]@{NativeExitCode=$nativeCode;PowerShellSuccess=($nativeCode -eq 0)}",
      "runFrom": "Windows PowerShell on the tested workstation; ComSpec must resolve to the reviewed Windows command processor",
      "expectedBranches": [
        {"when": "NativeExitCode is 7 and PowerShellSuccess is False", "meaning": "The native process reported failure and the wrapper captured it immediately.", "nextEvidence": "Map documented native codes to stable automation outcomes and preserve bounded stderr separately."},
        {"when": "The executable is absent or another value appears", "meaning": "The runtime or native-command assumption differs.", "nextEvidence": "Stop and inspect executable identity and its documented exit contract."}
      ],
      "proves": "The immediate exit status of this synthetic native process invocation.",
      "doesNotProve": "Why a real helper failed, whether it performed an effect, or that another native executable uses the same code meanings."
    },
    {
      "id": "LES-0019-CMD-009",
      "question": "Does a local PowerShell source file parse completely without executing it?",
      "risk": "read-only",
      "command": "$source = Join-Path $PWD 'tool.ps1'; $tokens=$null; $errors=$null; [Management.Automation.Language.Parser]::ParseFile($source,[ref]$tokens,[ref]$errors) | Out-Null; $errors | Select-Object Message,@{n='Line';e={$_.Extent.StartLineNumber}},@{n='Column';e={$_.Extent.StartColumnNumber}}",
      "runFrom": "A reviewed repository where tool.ps1 is the intended source; set only the local source name",
      "expectedBranches": [
        {"when": "No rows appear", "meaning": "This engine parsed the complete selected file without syntax errors.", "nextEvidence": "Run analyzer, unit, contract, and process-level behavior tests."},
        {"when": "Parser errors include lines and columns", "meaning": "The engine could not construct the script.", "nextEvidence": "Fix the first parser error and rerun without dot-sourcing or executing the file."}
      ],
      "proves": "Syntactic parsability of the selected bytes under this engine.",
      "doesNotProve": "Parameter correctness, module availability, runtime branch behavior, security, or safe effects."
    },
    {
      "id": "LES-0019-CMD-010",
      "question": "Does a proposed advanced function honor WhatIf at its mutation boundary?",
      "risk": "read-only",
      "command": "function Set-SyntheticState { [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Medium')] param([Parameter(Mandatory)][string]$Name) if($PSCmdlet.ShouldProcess($Name,'Set synthetic state')){'mutation-would-run'} }; Set-SyntheticState -Name 'lesson-only' -WhatIf",
      "runFrom": "An isolated lesson session; this function has no mutating implementation",
      "expectedBranches": [
        {"when": "A What if message appears and mutation-would-run does not", "meaning": "ShouldProcess returned false for this direct synthetic boundary.", "nextEvidence": "Add tests proving every real nested effect receives or implements the same decision."},
        {"when": "The mutation marker appears", "meaning": "The effect is outside the ShouldProcess guard.", "nextEvidence": "Move the guard immediately around the effect and fail the safety test."}
      ],
      "proves": "The direct synthetic function suppresses its guarded branch under WhatIf.",
      "doesNotProve": "That external programs, remote APIs, nested modules, or every code path honor WhatIf, or that real permissions and preconditions are valid."
    },
    {
      "id": "LES-0019-CMD-011",
      "question": "Which values survive a JSON serialization round trip and which type information changes?",
      "risk": "read-only",
      "command": "$before=[pscustomobject]@{Service='api';Count=[int]3;When=[datetime]'2026-08-02T00:00:00Z'}; $json=$before|ConvertTo-Json -Compress; $after=$json|ConvertFrom-Json; [pscustomobject]@{Json=$json;BeforeType=$before.GetType().FullName;CountType=$after.Count.GetType().FullName;WhenType=$after.When.GetType().FullName}",
      "runFrom": "Any supported lesson session; all values are synthetic and process-local",
      "expectedBranches": [
        {"when": "Count remains an integer-compatible .NET number while When returns as text in Windows PowerShell 5.1", "meaning": "JSON preserved a number but did not reconstruct the original DateTime object automatically.", "nextEvidence": "Validate a versioned schema and explicitly parse timestamps with an exact culture and offset policy."},
        {"when": "Types differ on another edition", "meaning": "Serialization behavior is part of the edition-specific contract.", "nextEvidence": "Record the engine and add a cross-edition contract test."}
      ],
      "proves": "The shown JSON and round-trip types for this synthetic object and engine.",
      "doesNotProve": "Schema validity, lossless arbitrary object transport, adequate depth, secret safety, or remoting behavior."
    },
    {
      "id": "LES-0019-CMD-012",
      "question": "Does the guarded offline lesson lab pass its lifecycle, refusal, interruption, and cleanup checks?",
      "risk": "mutating-bounded",
      "command": "powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File .\\verify.ps1",
      "runFrom": "book/labs/LES-0019-powershell-automation in a normal non-administrator Windows PowerShell process after reviewing the checked-in files",
      "expectedBranches": [
        {"when": "verification_passed=true and cleanup_proven=true appear", "meaning": "The checked deterministic cases and state guards passed in this environment and final registered state is absent.", "nextEvidence": "Submit independent reasoning separately; verifier success does not grade the diagnosis."},
        {"when": "A refusal or failure appears", "meaning": "A precondition, invariant, expected output, tamper defense, or cleanup proof failed.", "nextEvidence": "Preserve the first failure and any registered state; do not elevate, loosen ACLs, or delete recursively."}
      ],
      "proves": "The exact verifier assertions that ran and the cleanup absence check on this workstation.",
      "doesNotProve": "PowerShell mastery, real remoting or native-helper behavior, production safety, security certification, or cross-platform parity.",
      "cleanup": "The verifier invokes guarded exact cleanup. If interrupted, run .\\lab.ps1 cleanup and then .\\lab.ps1 check; stop if either refuses."
    }
  ],
  "labs": [
    {
      "id": "LES-0019-LAB-001",
      "title": "Diagnose typed-pipeline, error-stream, native-status, and false-success boundaries",
      "mode": "guided",
      "environment": "Non-elevated Windows PowerShell 5.1, launched natively or through WSL Ubuntu 24.04 powershell.exe interop",
      "timeMinutes": 80,
      "privilege": "Current normal Windows user only; an administrator token is refused",
      "network": "None; deterministic JSON model only",
      "changes": ["One transient exclusive current-SID setup lock under the Windows user temporary directory", "One current-SID state descriptor under that directory", "One random ACL-protected registered lesson directory under that same parent", "Small exact-name JSON lifecycle records inside the directory"],
      "abortConditions": ["The process is elevated", "An active, stale, or unexpected setup lock exists", "The temporary parent, descriptor, root-name pattern, owner, ACL, reparse-point check, sentinel, manifest, digest, or artifact allowlist differs", "Any unexpected file or lifecycle transition appears", "The checked-in model does not parse or match its recorded digest"],
      "recovery": "Explain the first failed contract and each independent failure before invoking modeled recovery; then verify the original operation and use the controller's exact cleanup. Never remove a discovered directory recursively.",
      "cleanupProof": "The setup owner releases its delete-on-close lease and the verifier proves the lock is absent; cleanup writes a resumable marker, removes only exact validated files, removes the exact empty registered root and descriptor, scans for exact-pattern orphans, and check proves state=absent.",
      "path": "book/labs/LES-0019-powershell-automation"
    },
    {
      "id": "LES-0019-LAB-002",
      "title": "Independent PowerShell operation diagnosis with answer-isolated raw scenario",
      "mode": "independent",
      "environment": "A clean non-elevated Windows PowerShell 5.1 process or the documented WSL-to-Windows bridge",
      "timeMinutes": 110,
      "privilege": "Current normal user; no Administrator, sudo, execution-policy mutation, module installation, remoting configuration, or credential access",
      "network": "None; raw independent inputs and deterministic derived observation views",
      "changes": ["The same guarded temporary state boundary", "A neutral active-case identifier", "Learner notes stored outside the lab-owned directory and never read by the verifier"],
      "abortConditions": ["Any guard refuses", "A prior case or unknown artifact exists", "The learner has not captured scenario and written predictions before derived observations", "A command would contact a remote system or require a real secret"],
      "recovery": "Classify object, binding, error, native-status, and state-owner evidence before deciding whether another effect is permitted; perform only modeled recovery, verify the original operation ID and duplicate count, then clean up.",
      "cleanupProof": "The normal-user verifier covers both cases, WhatIf, one-winner setup concurrency, stale-lock preservation, idempotent cleanup, unexpected-artifact refusal, model tamper, descriptor redirection, external-target preservation, simulated interruption resume, answer isolation, and final absence. Elevation refusal is separate reviewer evidence.",
      "path": "book/labs/LES-0019-powershell-automation"
    }
  ],
  "incidents": [
    {
      "id": "LES-0019-INC-001",
      "signal": "A maintenance script writes red errors for three servers, prints Completed, and the scheduled task records exit code 0 although two servers still have the old configuration.",
      "firstThought": "Red text, ErrorRecord flow, catch behavior, script exit, and target state are separate. Treat Completed and exit 0 as unverified until each intended target has a terminal result and authoritative readback.",
      "safePath": "Pause controller retries, preserve engine and module identity, parameters, target set, timestamps, error records, native statuses, operation IDs, scheduled-task history, and configuration readback; determine whether errors were nonterminating, classify each target as changed, unchanged, rejected, or unknown, reconcile unknown outcomes, recover a bounded cohort, and verify the original desired state.",
      "trap": "Adding a broad try/catch, setting ErrorActionPreference to SilentlyContinue, printing Success after the loop, or rerunning every server without knowing which effects already committed."
    },
    {
      "id": "LES-0019-INC-002",
      "signal": "A CI PowerShell step works on a developer laptop but fails on the runner: a command resolves to another module version, a native argument containing spaces splits differently, and the uploaded JSON contains formatted strings instead of objects.",
      "firstThought": "This is execution-environment and boundary drift, not one quoting typo. Establish engine, edition, command resolution, module provenance, parser/native argument semantics, working directory, encoding, and object type immediately before serialization.",
      "safePath": "Freeze the failing artifact, compare PSVersionTable, executable path, PSModulePath, Get-Command -All, loaded module versions, culture, language mode, cwd, native argument echo, pre-format object types, JSON schema, and process exit; reproduce in the pinned runner image, correct each boundary, canary the pipeline, and verify consumer readback.",
      "trap": "Changing quotes until one sample passes, installing the laptop's entire module directory on the runner, using Out-String before JSON export, or hiding stderr without preserving a bounded diagnostic."
    }
  ],
  "assessmentIds": ["ASM-0040", "ASM-0041", "ASM-0042"],
  "referenceIds": ["REF-0105", "REF-0106", "REF-0107", "REF-0108", "REF-0109", "REF-0110", "REF-0111", "REF-0112"],
  "contentStatus": "substantive-draft",
  "masteryBoundary": "publication-does-not-award-mastery",
  "lastReviewed": "2026-08-02",
  "reviewAfter": "2027-02-02",
  "limitations": [
    "The tested runtime is Windows PowerShell 5.1 because PowerShell 7 is absent locally. PowerShell 7, Linux-native pwsh, other hosts, constrained language mode, remoting transports, and module versions require their own test matrix.",
    "The required lab is a deterministic offline model. It does not start a real native helper, configure remoting, access a credential vault, contact an API, mutate a server, run a scheduled task, or prove distributed coordination.",
    "ACL checks reduce accidental or hostile path redirection in the tested Windows environment but do not constitute a formal filesystem security proof or defend against a fully compromised same-user process.",
    "WhatIf, strict mode, type annotations, execution policy, SecureString, try/catch, transcript capture, and tests are individual controls, not guarantees of authorization, idempotency, confidentiality, or correct outcomes.",
    "Capacity and concurrency examples teach mechanism and dimensional reasoning; production limits require measured workloads, dependency quotas, failure amplification, resource profiles, and safety margins.",
    "Publishing or completing this substantive draft does not award mastery; independent learner evidence and human review remain required."
  ]
}
---

# PowerShell safe operational automation: preserve objects, control effects, and prove outcomes

PowerShell can look deceptively friendly. A command reads almost like English, output becomes a neat table, and a pipeline appears to connect everything. That convenience is valuable, but it can hide the exact contracts an operator must understand. The table is not necessarily the data. Red text does not always stop execution. `catch` does not catch every error. A native program can fail without throwing. `-WhatIf` does not make arbitrary nested code safe. A remoting result is commonly a serialized copy, not the live object that existed on the remote machine.

The durable mental model is this:

> PowerShell is an object-oriented automation runtime with several output streams, a parameter-binding engine, access to native processes, and explicit effect boundaries. Trust it when you have made those contracts observable and verified the promised state.

This chapter is a substantive draft, not a mastery award. It begins with the locally available Windows PowerShell 5.1 engine and continuously separates facts that transfer to PowerShell 7 from details that require new evidence.

## What you see and first thought

Imagine an overnight patch-assessment script. The task history says `0x0`, the console ends with `Completed`, and a dashboard says the job was green. Yet three machines did not publish an assessment. The transcript contains red lines between normal output.

When you see that, do not begin with, "PowerShell is broken," and do not immediately add `try/catch`. Start with five separate questions:

1. **What exact engine ran?** Windows PowerShell 5.1 and PowerShell 7 are related but not identical. The host, edition, operating system, module path, working directory, language mode, profile, and identity affect behavior.
2. **What kind of thing flowed?** Was it a typed object, a string, formatting metadata, a deserialized remoting copy, or bytes from a native process?
3. **Which failure channel spoke?** Was it a nonterminating `ErrorRecord`, a terminating PowerShell exception, a native integer exit status, a timeout with unknown remote outcome, or a failed business postcondition?
4. **Who owns truth?** The local script owns its variables. The remote service owns whether a change committed. The scheduled-task controller owns its retry. A log line owns none of those states.
5. **What did success promise?** Exit zero should correspond to a documented postcondition, such as every authorized target having one verified terminal result. "The last statement ran" is not that promise.

Here is the first-response card:

```text
STOP REPLAY
  Preserve engine, code, parameters, operation IDs, streams, statuses, and target state.

SEPARATE CHANNELS
  objects | formatting/text | ErrorRecord | exception | native exit | remote state

LOCATE OWNER
  local process | controller | filesystem | remote API | user-visible operation

CLASSIFY EACH TARGET
  committed | absent | rejected | unknown | duplicate | not attempted

RECOVER BOUNDEDLY
  one reviewed cohort, one owner, one budget, one abort threshold

VERIFY THE PROMISE
  authoritative readback plus original operation ID, not console color
```

If a timeout followed a mutation request, outcome is **unknown** until the state owner proves committed or absent. If a cmdlet emitted a nonterminating error, execution may have continued by design. If a pipeline reached `Out-String`, later property filters are operating on text. These are mechanisms, not opinions.

## Terms before commands

**PowerShell engine.** Everyday meaning: the program interpreting the script. Precise meaning: a particular `powershell.exe` or `pwsh` runtime with an edition, version, .NET runtime, parser, binder, module loader, and platform behavior. On call: record `$PSVersionTable`, executable path, language mode, identity, and module resolution before comparing two runs.

**Host.** Everyday meaning: the application around the engine. Precise meaning: a program such as ConsoleHost, Windows Terminal, an integrated development environment, a scheduled task, or a CI agent that embeds or launches PowerShell and provides user-interface behavior. On call: host prompts, profile loading, stream rendering, and input availability can differ even when the engine version matches.

**Cmdlet.** Pronounced "command-let." It is a PowerShell command implemented against the PowerShell runtime, normally consuming and producing .NET objects and using common parameters. A cmdlet can emit recoverable nonterminating errors. On call: inspect its module, version, parameter metadata, and documented output type instead of reasoning only from displayed text.

**Advanced function.** A PowerShell function with `[CmdletBinding()]` or parameter attributes that participates in cmdlet-like binding and common parameters. It can implement `ShouldProcess`, validation, and deliberate stream behavior. Advanced does not mean safe automatically; it means the function has a richer contract surface.

**Object.** A value with a .NET type, properties, and sometimes methods. A process object has an identifier property whose value is numeric; a file object has a full path and attributes. The displayed table is a view of selected properties, not the object itself. On call: use `.GetType()` and `Get-Member` immediately before a decision or serialization boundary.

**Extended Type System (ETS).** PowerShell's adaptation layer over .NET objects. It can expose native properties, adapted properties, aliases, script properties, and type data in a consistent shell experience. On call: a convenient property may come from type data or adaptation and may not survive JSON, remoting, or another edition.

**Pipeline.** A sequence of commands where PowerShell passes objects from the success stream of one command to bind parameters of the next. This is not merely text connected by a pipe character. The binder first considers compatible input by value, then by property name according to declared metadata. On call: prove input type, output type, cardinality, and binding route.

**Enumeration.** PowerShell commonly unwraps a collection written to the pipeline and sends its elements individually. A function that intended to return one collection may therefore produce many pipeline records. `Write-Output -NoEnumerate` or a unary comma changes enumeration, but the caller may enumerate later. On call: state whether the contract is "one collection" or "a stream of items" and test zero, one, and many.

**Formatting boundary.** `Format-Table` and `Format-List` produce formatting instructions intended for the display system. `Out-String` renders text. They belong at the final human-facing edge. If formatting happens before filtering, sorting, JSON conversion, or export, machine-readable properties are lost or replaced. On call: move formatting last and inspect types on both sides.

**Serialization.** Converting an object graph into a transport or storage representation such as JSON or remoting XML. Serialization preserves only declared data to some depth and cannot generally preserve live methods, handles, credentials, or freshness. On call: use a versioned schema, bounded depth, explicit timestamp and enum rules, and validate after round trip.

**Stream.** A logical channel emitted by PowerShell. Stream 1 is success output, 2 error, 3 warning, 4 verbose, 5 debug, and 6 information. Progress is presented separately. Streams can be redirected or merged, which changes what a caller receives. On call: decide which channel belongs to machine data, human diagnostics, and durable logs. Never mix commentary into a JSON success stream.

**ErrorRecord.** PowerShell's structured description of an error. It contains an exception plus category, fully qualified error identifier, invocation information, target object, and other context. Red rendering is only one host view. On call: preserve allowlisted fields, classify the error, and redact targets or messages that can contain secrets.

**Nonterminating error.** A failure reported for an item while the command or pipeline may continue. It normally writes an `ErrorRecord` but does not enter `catch`. `-ErrorAction Stop` can promote many such errors into terminating flow for that command. On call: define whether partial processing is supported and ensure the final status represents it.

**Terminating error.** A failure that stops a statement or script scope and can be handled by `try/catch`. A parse error can stop the script before execution. `throw` produces terminating control flow. On call: catch expected types narrowly, retain the cause, and do not convert an internal defect into success.

**Preference variable.** A scoped variable such as `$ErrorActionPreference`, `$VerbosePreference`, or `$ConfirmPreference` that influences default engine behavior. A common parameter on one command can override the corresponding preference. On call: record effective values, but do not assume every nested module inherits them identically.

**Strict mode.** `Set-StrictMode` makes several ambiguous language behaviors fail, including many uninitialized-variable and missing-property uses. It catches defects earlier. It does not validate external input, make nonterminating errors throw universally, translate native exit codes, or verify effects.

**Parameter binder.** The engine component that chooses a parameter set, maps named or positional arguments, accepts pipeline input, converts types, and runs validation attributes before the function body. On call: a `ParameterBindingException` can indicate contract mismatch, not dependency failure.

**Splatting.** Passing a hashtable of named PowerShell parameters or an array of positional arguments with `@`. Splatting reduces fragile string construction for PowerShell commands. It does not itself validate values or solve every native executable quoting rule.

**Native command.** An executable outside the PowerShell command model. It receives platform-specific command-line arguments and returns an integer process status. Its stdout and stderr are byte or text streams, not native PowerShell objects. On call: establish executable identity, argument vector intent, encoding, deadline, stream bounds, process-tree behavior, and documented exit codes.

**`$LASTEXITCODE`.** The automatic variable containing the status of the most recently completed native program or a script that explicitly exits under documented invocation rules. It is volatile: another native command overwrites it. Capture it immediately. It does not explain whether a remote mutation committed.

**`$?`.** A Boolean describing the success state of the immediately preceding operation under edition-specific semantics. It is convenient interactively and fragile as a durable automation contract. Capture the specific error or native code instead, translate once, and verify state.

**Postcondition.** The externally observable statement that must be true for the operation to be successful. Examples: exactly 20 intended hosts have a terminal receipt, or the resource version reflects the desired configuration. On call: verify this at the owner instead of using absence of exceptions as proof.

**`ShouldProcess`.** The PowerShell protocol behind `-WhatIf` and `-Confirm`. An advanced function declares support and calls `$PSCmdlet.ShouldProcess` immediately around each mutation. It returns whether that mutation should proceed. It is not a transaction, authorization service, remote dry run, or guarantee that nested code participates.

**Idempotency.** Repeating one logical operation has no additional effect beyond the intended result. "Set replicas to 4" can be idempotent when the owner applies desired state conditionally. "Add 2 replicas" is not. On call: preserve one logical operation identity and reconcile ambiguous attempts.

**Concurrency.** Multiple invocations, runspaces, jobs, scheduled tasks, or controllers overlap. Process-local variables do not coordinate a shared state owner. On call: use conditional versions, transactions, locks with proved ownership, leases with fencing, or an authoritative queue according to the owner.

**Remoting.** Running PowerShell code through a configured remote endpoint and receiving serialized results. Authentication, authorization, endpoint capability, remote process identity, network transport, serialization, and second-hop access are distinct boundaries. On call: record both local and remote evidence and assume secrets and objects cross a trust boundary.

**Credential and secret.** A credential asserts identity; a secret is sensitive material used to authenticate or encrypt. `[PSCredential]` and `SecureString` help avoid some plain-text handling but are not permission or leak-proof containers. On call: prefer workload identity, retrieve secrets late from an approved vault, avoid arguments and transcripts, and rotate after exposure.

**Transcript.** A host-oriented session record produced by `Start-Transcript`. It is useful evidence but not a complete structured audit trail and may capture sensitive data. Not every host or native byte stream is represented as expected. On call: use purpose-built structured logs and treat transcripts as sensitive supplemental evidence.

**Module.** A versioned unit that exports commands and can include a manifest, script module, binary assembly, types, formats, and private helpers. On call: pin provenance and compatible editions, export narrowly, avoid stateful import side effects, and test the installed artifact rather than only source files.

## Architecture map

The first diagram shows the whole invocation. Read it from left to right and ask what evidence exists at every arrow.

```text
[scheduler / operator / CI]
            |
            | executable + arguments + environment + identity
            v
[host process] --> [PowerShell engine + edition + language mode]
                              |
                              | parse + choose parameter set + bind + validate
                              v
                     [typed request object]
                              |
                       pure plan / no effects
                              v
                     [operation intent]
                              |
              ShouldProcess + authorization + deadline
                              v
                     [effect adapter]
                              |
             native process / filesystem / API / remoting
                              v
                      [state owner]
                              |
          receipt + resource version + authoritative readback
                              v
                 [postcondition verifier]
                              |
        success objects | ErrorRecords | diagnostics | exit code
```

The key connectivity is not the pipe symbol. It is the chain of contracts:

- The launcher chooses a process and passes strings, environment variables, a working directory, and an identity.
- The parser understands PowerShell syntax. The binder turns caller values into declared parameters and may convert types.
- The core should build a plan from typed data without changing the world.
- An effect adapter is the small piece allowed to touch a file, process, API, or endpoint.
- The state owner decides what actually committed.
- Verification checks the original promised outcome.
- The interface returns structured success separately from diagnostics and one documented process exit.

The second diagram explains the most common pipeline mistake:

```text
GOOD
Get-Thing -> Where-Object -> Sort-Object -> Select-Object -> ConvertTo-Json
  object       object          object          object         JSON text

HUMAN DISPLAY
Get-Thing -> Where-Object -> Format-Table -> host renderer
  object       object       format records       screen

BROKEN MACHINE PATH
Get-Thing -> Out-String -> Where-Object Status -eq 'Ready'
  object       string       property Status is no longer the object property
```

Think of `Format-Table` as preparing ink for a page. Once data becomes ink, asking for the original object's `Status` is like asking a printed table cell to call a method.

The third diagram separates failure channels:

```text
PowerShell cmdlet                         native executable
       |                                         |
       +-- success objects (stream 1)             +-- stdout
       +-- ErrorRecord (stream 2)                 +-- stderr
              |                                   +-- integer exit code
       Continue or Stop?                                  |
              |                                           |
       catch only terminating flow                capture immediately
              \___________________   _____________________/
                                  \ /
                         [result classifier]
                                  |
                 rejected | failed | unknown | succeeded
                                  |
                          [verify state owner]
```

Finally, see remoting as a trust and representation boundary:

```text
local object + local identity
            |
     serialize request / authenticate
            v
remote endpoint policy -> remote process identity -> remote command
            |                                      |
            |                               third resource?
            |                                separate hop
            v
serialized properties -> Deserialized.TypeName object locally
```

The returned object may look familiar in a table while lacking live methods and current state. Display similarity is not semantic identity.

## Request or state path

Take a function that promises, "Ensure service `catalog-api` has four replicas and return one verified result." A reliable path has explicit stages.

**Stage 1: establish runtime.** Record engine executable, `$PSVersionTable.PSVersion`, `PSEdition`, language mode, process identity, elevation, working directory, culture when parsing culture-sensitive data, module path, and exact command resolution. Profiles should normally be disabled for noninteractive automation unless the profile is an explicit versioned dependency.

**Stage 2: bind and validate.** The caller's `"4"` may be converted to `[int]4` by the binder. That proves syntactic convertibility, not business validity. Use `[ValidateRange(1,20)]`, `[ValidateSet()]`, or a deliberate validation function and still enforce cross-field rules, authorization, tenant scope, and maximum batch size.

```powershell
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z][a-z0-9-]{2,39}$')]
    [string]$Service,

    [Parameter(Mandatory)]
    [ValidateRange(1, 20)]
    [int]$DesiredReplicas,

    [Parameter(Mandatory)]
    [ValidatePattern('^ops-[0-9a-f]{16}$')]
    [string]$OperationId
)
```

Validation attributes run before the body. They should be fast, deterministic, and side-effect free. Do not make `ValidateScript` call a production API; binding could then cause surprising network effects, repeat work, or depend on ambient credentials.

**Stage 3: create a typed internal request.** Normalize once. Do not pass untrusted hashtables through every layer. A `PSCustomObject` is useful, but a class or a carefully documented record shape gives stronger expectations. Treat `PSBoundParameters` as evidence of what the caller supplied; it distinguishes an omitted parameter from a defaulted value.

**Stage 4: read authoritative current state.** The console cache, prior variable, or last log is not the state owner. Query the target with a bounded deadline and capture its resource version or equivalent concurrency token. Sanitize evidence before logging.

**Stage 5: build a pure plan.** A pure function receives desired and observed state and returns a decision such as `NoChange`, `SetReplicas`, or `Conflict`. It makes no API call and is easy to test across zero, one, many, invalid, stale, and conflicting cases.

**Stage 6: ask whether to perform the exact change.** Call `ShouldProcess` around the mutation, with a useful target and operation. Under `-WhatIf`, validation and planning should still happen, while the mutation branch does not. Authorization remains separate; `ShouldProcess` does not grant permission.

**Stage 7: persist intent when ambiguity matters.** Before a remote mutation, durably associate the canonical desired-state digest with one logical operation ID. A controller retry must reuse that ID. If each attempt invents a new ID, the target cannot deduplicate one business intent.

**Stage 8: perform one bounded attempt.** The adapter receives an already validated request, target version, operation ID, and remaining deadline. It returns a closed classification: accepted with receipt, rejected, known no-effect transient, unknown outcome, or internal defect. It does not retry secretly.

**Stage 9: reconcile unknown outcomes.** A timeout after send means only that the client did not receive a timely response. Query the authoritative owner using the same operation ID or resource version. Retry only when the owner proves no effect and policy permits another attempt within count and elapsed-time budgets.

**Stage 10: verify the original postcondition.** Read back the service, confirm desired replicas equals four, verify the operation receipt, check duplicate effects, and state the observation window. A successful HTTP status or native code is an intermediate signal.

**Stage 11: publish one stable result.** Success stream output should have a documented shape. Diagnostics go to verbose, information, warning, or error according to caller needs. Exit code zero means the complete postcondition holds; invalid input, known dependency failure, partial completion, unknown outcome, and internal defect receive stable nonzero categories.

```text
REQUESTED
   |
   +-- invalid / unauthorized ----------------------> REJECTED
   |
   v
PLANNED -- already desired -------------------------> VERIFIED_NO_CHANGE
   |
   v
INTENT_RECORDED -> ATTEMPTING -> receipt ----------> VERIFYING
                         |
                         +-- proven no effect ------> RETRY_ELIGIBLE
                         |
                         +-- response missing ------> UNKNOWN -> RECONCILE
                                                              |
                                         committed -----------+--> VERIFYING
                                         absent --------------+--> RETRY_ELIGIBLE
                                         unresolved ----------+--> STOP_AND_OWN
```

Only `VERIFYING` can become `SUCCEEDED`, and only after the postcondition passes.

## Failure zoom

### Failure 1: presentation text enters a machine pipeline

```powershell
$ready = Get-Service |
    Format-Table Name, Status |
    Where-Object Status -eq 'Running'
```

This is not filtering service objects after formatting. `Format-Table` emits formatting data for the view system. A similar mistake with `Out-String` produces strings. The fix is not a clever text regular expression:

```powershell
$ready = Get-Service |
    Where-Object Status -eq 'Running' |
    Select-Object Name, Status

$ready | Format-Table
```

Filter and project objects first; format only for a human. If the consumer is a program, serialize a declared schema rather than a view.

### Failure 2: `try/catch` exists, but the script continues

```powershell
try {
    Get-Item -LiteralPath $Path
    $completed = $true
}
catch {
    $completed = $false
}
```

Many cmdlets report item-level failures as nonterminating errors. With the default `Continue` policy, `catch` does not run and the next statement can set `$completed = $true`. For a command whose failure must stop that unit of work, use `-ErrorAction Stop`, catch a meaningful type or inspect the error record, and translate it. Do not set global `SilentlyContinue` to make logs quiet; that removes an operator signal without restoring correctness.

### Failure 3: broad catch changes defects into success

```powershell
foreach ($target in $Targets) {
    try {
        Invoke-Change -Target $target -ErrorAction Stop
    }
    catch {
        Write-Warning $_
    }
}
exit 0
```

This design may be appropriate only if partial results are the documented success contract and every target gets a durable terminal record. Otherwise it loses the exception category, may leak target or credential material, and always reports success. A better result object has target, operation ID, outcome class, safe error code, receipt, and verification. The final process exit derives from the collection invariant.

### Failure 4: native exit status is overwritten

```powershell
& $helper @arguments
Write-Host 'helper finished'
& $env:ComSpec /d /c 'ver > nul'
if ($LASTEXITCODE -ne 0) { throw 'helper failed' }
```

The second native command replaced `$LASTEXITCODE`. Capture immediately:

```powershell
& $helper @arguments
$helperExit = $LASTEXITCODE
if ($helperExit -ne 0) {
    throw [InvalidOperationException]::new("helper returned code $helperExit")
}
```

Even this only translates the helper's documented status. It does not prove the helper's semantic output or remote effect. Validate structured output and read back the promised state.

### Failure 5: quoting turns data into source

PowerShell has expression mode and argument mode. Single-quoted strings are literal; double-quoted strings expand variables and subexpressions. Native programs add another parser boundary. Windows PowerShell 5.1 reconstructs a native command line according to legacy rules, and each native program may parse it differently.

For PowerShell commands, prefer named parameters and splatting:

```powershell
$parameters = @{
    LiteralPath = $approvedPath
    Destination = $approvedDestination
    ErrorAction = 'Stop'
}
Copy-Item @parameters
```

For native commands, use an approved absolute executable, construct an argument array, reject unsupported values such as embedded control characters according to the executable's contract, and test an argument-echo fixture containing spaces, quotes, Unicode, leading dashes, empty values, and metacharacters on every supported engine and operating system. Never use `Invoke-Expression` to solve quoting.

### Failure 6: a timeout is called a failure

The client sends a mutation, waits five seconds, and stops waiting. The server may have rejected, committed, or still be processing it. Blind retry can duplicate an effect. Preserve one operation ID, query the owner, and classify. A local exception cannot reverse a remote commit.

### Failure 7: `WhatIf` covers the wrapper, not the callee

```powershell
if ($PSCmdlet.ShouldProcess($Target, 'Apply configuration')) {
    Invoke-AnotherModule -Target $Target
}
```

This suppresses the direct call when the wrapper receives `-WhatIf`. But if planning invokes another function earlier, or the nested module makes changes during import, validation, discovery, or a supposedly read-only call, the claim fails. Test no-effect behavior at actual state owners. Pass `-WhatIf:$WhatIfPreference` explicitly where appropriate and design effect-free planning.

### Failure 8: remoting returns a familiar-looking copy

Remoting serializes most results. Locally, the type name may be prefixed with `Deserialized.` and methods may be absent. A timestamp may be stale by the time it is evaluated. Do filtering and sensitive reduction close to the remote owner when safe, return a narrow schema, and never assume the local copy can perform a live remote method.

### Failure 9: concurrency has no owner

`Start-Job`, runspaces, scheduled tasks, CI retries, and multiple operators can overlap. A process-local mutex does not coordinate another machine. A lock file is unsafe without owner, path, symlink or reparse, stale-owner, and crash rules. Prefer state-owner conditional writes or transactions. If using a lease, carry a monotonically increasing fencing token to every critical write owner so an expired worker cannot resume and overwrite newer work.

### Failure 10: diagnostic richness leaks secrets

PowerShell makes interpolation easy. That means a verbose message can accidentally include a token, a `PSCredential`, a full request header, or a signed URL. Native process arguments may be visible to process inspection. Transcripts and CI logs persist. Use allowlisted fields, safe identifiers and hashes, late-bound credentials, separate secret handles from business objects, and tests with canary secret strings that must never appear in any stream or artifact.

## Internals and state ownership

### Parsing happens before runtime

The parser builds an Abstract Syntax Tree (AST). A syntax error can stop the whole file before parameter validation or `try/catch`. Use the parser API to validate source without executing it. An AST also supports static analysis, but static inspection cannot know every dynamically resolved command or runtime effect.

PowerShell enters expression mode where values and operators are expected, then argument mode when invoking commands. Quoting rules change how tokens expand. The call operator `&` invokes a command value but does not evaluate an arbitrary command string as fresh source. That is useful: keep executable identity and argument data separate.

### Binding is a contract negotiation

The binder chooses a parameter set, handles named and positional arguments, performs conversion, and applies validation. In a pipeline it considers input rules declared by the receiving parameter. By-value binding asks whether the incoming object can satisfy the parameter type. By-property-name binding looks for a property matching the parameter name or alias.

Binding can surprise when objects contain similarly named properties, when a string converts to a number, or when multiple parameter sets remain possible. Production functions should minimize positional parameters, avoid ambiguous sets, document pipeline input, and test type plus property-name collisions.

### Output is enumerated

When a function writes an array, PowerShell normally emits each item. `return` does not wrap output; it stops the current scope after writing its expression. Any unassigned expression, command success output, or accidental helper output joins the function's success stream.

This function promises one result but accidentally emits three things:

```powershell
function Invoke-UnsafeExample {
    'starting'
    New-Item -ItemType File -Path $Path
    [pscustomobject]@{ Outcome = 'Created' }
}
```

The string and `FileInfo` join the result object. Assign or redirect expected incidental output deliberately, send diagnostics to an appropriate stream, and test the count and type of public output for zero, one, and many inputs.

### Streams are interface channels

Use success output for machine-consumable result objects. Use `Write-Verbose` for opt-in diagnostic detail, `Write-Debug` for development, `Write-Warning` for recoverable risk requiring attention, `Write-Information` for informational events, and `Write-Error` or terminating errors for failures. `Write-Host` participates in the information stream in Windows PowerShell 5.1, but host behavior still makes it a poor machine contract.

Merging `2>&1` puts error records into the success path. That may be useful when capturing a complete ordered diagnostic transcript, but it changes output type and can corrupt a JSON or object interface. Redirection is a caller-visible design decision.

### Error policy belongs at a boundary

`$ErrorActionPreference = 'Stop'` near an automation entrypoint can make unexpected nonterminating errors fail closed, but known item-level outcomes may need command-specific handling. The safe pattern is:

1. declare a default policy in the smallest useful scope;
2. override per command when the provider's documented nonterminating result is expected;
3. catch expected types or inspect `FullyQualifiedErrorId` and category;
4. preserve causal information for unexpected failures;
5. translate once into a stable domain result;
6. derive final exit from verified operation results.

`finally` is for releasing process-local resources and preserving resumability. It cannot roll back a remote mutation merely because the client failed. Forced termination and power loss may prevent `finally` from running, so durable state transitions must be recoverable without it.

### Native process ownership

A native child owns its process exit. PowerShell owns how it launches and observes the child. A remote system contacted by the child owns remote effects. Those are three owners.

A production adapter should declare:

- exact executable path and trusted artifact identity;
- argument contract and cross-platform quoting tests;
- minimal environment and fixed working directory;
- standard input policy;
- stdout and stderr encoding and maximum retained bytes;
- deadline based on monotonic elapsed time where available;
- child and descendant termination behavior;
- immediate exit-code capture;
- mapping of each documented status;
- structured-output schema;
- operation ID and reconciliation after ambiguous effects.

Windows PowerShell 5.1 does not have every native-argument feature of current PowerShell 7. Do not copy a modern `$PSNativeCommandArgumentPassing` recommendation into 5.1 and pretend it ran there.

### Remoting ownership

The local caller owns the request it sends. The transport owns authentication mechanics. The endpoint configuration owns allowed capabilities. The remote process identity owns operating-system access on that host. A third resource owns second-hop authorization. The remoting serializer owns which properties return.

`$Using:` captures a local value for use remotely; it does not make a shared live variable. In out-of-process remoting, that value is serialized. Avoid sending large graphs or secrets. Prefer explicit parameters to remote script blocks and validate them again at the remote boundary.

The "second hop" appears when the remote session on Server B needs resource C. The original credential is not automatically safe or available for delegation. CredSSP can expose reusable credentials to the intermediate machine and must not be enabled casually. Use an approved identity architecture, constrained delegation or Just Enough Administration where appropriate, and security review. This lesson performs no remoting configuration.

### Secret ownership

A vault owns stored secret material. The automation should receive a short-lived reference or value only at the latest required boundary. A `SecureString` reduces casual clear-text exposure in some operations but does not guarantee that downstream APIs, memory, serialization, or logs remain secret. Converting it to plain text creates a sensitive value whose lifetime must be minimized.

Do not put secrets in:

- command-line arguments;
- source, module manifests, or repository fixtures;
- environment variables unless the platform threat model explicitly accepts their visibility;
- success output or exception messages;
- transcripts, verbose streams, or CI annotations;
- serialized job/remoting payloads without a reviewed protocol;
- filenames, resource names, metric labels, trace attributes, or idempotency keys.

Prefer managed or workload identity, constrained scopes, short lifetimes, rotation, and audit. If exposure occurs, stop propagation, restrict log access, preserve safe evidence, rotate or revoke the credential, and investigate use.

### Mutation ownership and `ShouldProcess`

An advanced function declares `SupportsShouldProcess`. Call `ShouldProcess` close to every effect, ideally once per target so `-Confirm` and `-WhatIf` describe real scope. Validation and planning should remain outside so dry run still detects errors.

`ShouldProcess` answers, "Given the current WhatIf and confirmation policy, should this code enter the effect branch?" It does not answer:

- Is the caller authorized by the target?
- Is the plan still current?
- Will the nested tool mutate anyway?
- Is the action idempotent?
- Did a previous attempt commit?
- Can the action be rolled back?
- Did the postcondition hold?

Those controls remain explicit.

### Concurrency ownership

PowerShell jobs are normally separate processes and serialize results. Thread jobs and runspaces share a process but have separate session state and can still race on shared .NET objects or external resources. `ForEach-Object -Parallel` belongs to PowerShell 7, not Windows PowerShell 5.1. Version-gate it.

Use concurrency only after measuring work type. CPU-bound work competes for cores; native children multiply process and memory use; remote calls hit quotas; buffered outputs multiply memory; retries add failure load. Bound queue size and concurrency near the constrained dependency, propagate cancellation and deadlines, and define fairness across services or tenants.

### Module ownership

A module manifest declares identity, version compatibility, root module, and exports. Export exact public functions rather than wildcards. Keep import side effects minimal. A module-scoped cache is process-local and may be stale or unsafe across runspaces. Resolve dependencies through an approved locked build and test the packaged artifact in clean Windows PowerShell 5.1 and PowerShell 7 environments when both are supported.

## Evidence table

| Question | Evidence command | Risk | Important branches | Proves | Does not prove |
|---|---|---:|---|---|---|
| Which runtime is this? | LES-0019-CMD-001 | read-only | supported engine and normal user, or runtime drift | current process identity | module or script correctness |
| Which command wins? | LES-0019-CMD-002 | read-only | expected cmdlet, or shadowing | current resolution candidates | artifact integrity |
| Are values objects? | LES-0019-CMD-003 | read-only | typed properties, or text/formatting | sampled runtime type | uniformity or freshness |
| How can pipeline input bind? | LES-0019-CMD-004 | read-only | declared route, or unsupported assumption | metadata | actual safe mutation |
| Does conversion and validation occur? | LES-0019-CMD-005 | read-only | typed accepted value, or binding refusal | synthetic binder behavior | business authorization |
| Will catch run? | LES-0019-CMD-006 | read-only | promoted error caught, or false precondition | one error-policy path | all error behavior |
| What policies apply? | LES-0019-CMD-007 | read-only | expected preferences, or host policy drift | current scope values | nested-module inheritance |
| What did native code return? | LES-0019-CMD-008 | read-only | code 7, or runtime difference | immediate synthetic exit | remote outcome |
| Does source parse? | LES-0019-CMD-009 | read-only | zero parser errors, or location diagnostics | syntax | runtime safety |
| Does WhatIf suppress the branch? | LES-0019-CMD-010 | read-only | plan only, or guard defect | synthetic direct guard | nested effect safety |
| What survives JSON? | LES-0019-CMD-011 | read-only | expected round-trip types, or edition drift | synthetic serialization behavior | schema or secret safety |
| Does the local lab pass? | LES-0019-CMD-012 | mutating-bounded | pass and absence, or guarded refusal | tested deterministic controls | mastery or production behavior |

Evidence should be collected at the same boundary as the failure. A local `Get-Command` says nothing about a remote endpoint's module. A CI exit code says nothing about a target API's commit. A deserialized object says what was transported, not necessarily what is true now.

## Command decoders

### CMD-001: runtime identity

Representative output:

```text
PSVersion  PSEdition BuildVersion
---------  --------- ------------
5.1.26100  Desktop   10.0.26100.8875

   Id ProcessName Path
   -- ----------- ----
18420 powershell  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

Name             User
----             ----
DOMAIN\operator  S-1-5-21-...-11081
False
```

`PSVersion` is the engine language/runtime version, not the Windows version. `PSEdition` is `Desktop` for full Windows PowerShell and `Core` for modern PowerShell. `BuildVersion` here identifies the Windows PowerShell build family. `Id` is this process identifier. `Path` proves which executable image path the process reports. `Name` is the Windows account and `User` is its Security Identifier (SID). Final `False` means this token is not in the built-in Administrator role in the current process. It does not mean the user can never elevate or that target permissions are least privilege.

### CMD-002: command resolution

Representative output:

```text
CommandType Name          Version Source                         ModuleName
----------- ----          ------- ------                         ----------
Cmdlet      Get-ChildItem 3.1.0.0 Microsoft.PowerShell.Management Microsoft.PowerShell.Management
```

`CommandType` distinguishes alias, function, filter, cmdlet, external script, and application. `Name` alone is not identity. `Version`, `Source`, and `ModuleName` show provenance available to the session. `Definition` can show an alias target, function body, script path, or executable. `-All` matters because the first result is normally selected, while later candidates reveal shadowing. Module-qualified names such as `Microsoft.PowerShell.Management\Get-ChildItem` reduce ambiguity for cmdlets. External tools need an approved absolute path.

### CMD-003: objects and members

Representative output:

```text
System.IO.DirectoryInfo

Name       MemberType Definition
----       ---------- ----------
Attributes Property   System.IO.FileAttributes Attributes {get;set;}
Exists     Property   bool Exists {get;}
FullName   Property   string FullName {get;}

FullName                         Attributes
--------                         ----------
C:\work\devops-sre-training      Directory
```

The type is `DirectoryInfo`, not a row of text. `MemberType` says these entries are properties. `Definition` includes the .NET value type and whether a setter exists. `Select-Object` creates projected objects with selected properties; it does not mutate the directory. `-First 6` samples member metadata, not filesystem items. The sample cannot prove all pipeline items have the same type.

### CMD-004: parameter metadata

`PipelineInput` can display phrases such as `True (ByValue, ByPropertyName)` or `False`. `Type` is the expected parameter type, `Required` is whether the selected help syntax requires it, `Position` indicates positional binding, and `Aliases` affect by-property-name binding. Local help can be missing or stale. For authoritative runtime metadata, inspect `(Get-Command Rename-Item).Parameters`, then test a disposable target with `-WhatIf`.

### CMD-005: binding and validation

Representative output:

```text
Count Type
----- ----
    3 System.Int32
```

The input object's `Count` property contained a string. The parameter allowed pipeline input by property name, the binder found `Count`, converted `"3"` to `Int32`, and `ValidateRange(1,5)` accepted it. This convenience is also a trust boundary: `3` may still be unauthorized or too large for the actual service. Test `0`, `6`, empty text, whitespace, `3.5`, repeated values, and culture-sensitive inputs.

### CMD-006: error promotion

Representative output contains:

```text
Caught Exception                                             ErrorId
------ ---------                                             -------
  True System.Management.Automation.ItemNotFoundException    PathNotFound,...
```

`-ErrorAction Stop` changes how this command's nonterminating item-not-found error affects control flow, so `catch` receives it. `Exception` is the underlying .NET/PowerShell type. `FullyQualifiedErrorId` usually combines an error identifier and command identity; treat it as a classification aid, not a secret-free message. `Category` is a broad taxonomy such as `ObjectNotFound`. The exact synthetic pathname must be confirmed absent; if it unexpectedly exists, preserve it.

### CMD-007: strict mode and preferences

Representative values:

```text
Name                       Value
----                       -----
ErrorActionPreference      Continue
WarningPreference          Continue
VerbosePreference          SilentlyContinue
InformationPreference      SilentlyContinue
ConfirmPreference          High
WhatIfPreference           False
FullLanguage
```

`Continue` for errors means nonterminating errors display and processing normally continues. `SilentlyContinue` suppresses display for that stream but can have other recording semantics depending on the stream. `ConfirmPreference High` means commands whose impact reaches the threshold may prompt. `WhatIfPreference False` means normal effect execution unless a command receives `-WhatIf`. `FullLanguage` describes available language capabilities; constrained hosts can differ. The command enables strict mode only inside the child script-block scope, so the caller's scope is unchanged after the block returns. `Set-StrictMode` does not appear as a normal preference variable, so prove it with behavior or scope design rather than assuming a printable global flag.

### CMD-008: native status

Representative output:

```text
NativeExitCode PowerShellSuccess
-------------- -----------------
             7             False
```

The integer 7 belongs to this synthetic `cmd.exe` process. Only the executable's documented contract can tell what 7 means. `PowerShellSuccess` is our explicit comparison, not a magic exception. Capture before logging through another native utility, calling `git`, or starting a second helper. Preserve stdout and stderr separately and bound their size; a child can deadlock if the parent handles streams incorrectly.

### CMD-009: parser API

The command emits no rows when the parser reports no syntax errors. That silence is an expected empty result, so the automation should assert `$errors.Count -eq 0` rather than merely look for no red text. Each parser error has an `Extent` with start line and column. Parsing does not import modules, bind runtime parameters, or execute top-level statements. It is the safe first gate, not the final gate.

### CMD-010: ShouldProcess

Representative output:

```text
What if: Performing the operation "Set synthetic state" on target "lesson-only".
```

No `mutation-would-run` output means `ShouldProcess` returned false. `SupportsShouldProcess` adds common `-WhatIf` and `-Confirm` parameters; do not declare duplicate custom ones. `ConfirmImpact` participates in prompting relative to `$ConfirmPreference`. In CI, interactive confirmation can hang or fail, so approval normally belongs to the pipeline and the function should still expose `WhatIf` for planning. Never add a `-Force` switch that bypasses authorization or invariant validation.

### CMD-011: JSON round trip

Representative Windows PowerShell 5.1 output:

```text
Json       : {"Service":"api","Count":3,"When":"2026-08-02T00:00:00Z"}
BeforeType : System.Management.Automation.PSCustomObject
CountType  : System.Int32
WhenType   : System.String
```

JSON stores object members, number, and string representations; it does not promise reconstruction of arbitrary .NET types. The `DateTime` becomes JSON text and returns as `String` here. A consumer must validate schema and parse timestamps with exact offset rules. `ConvertTo-Json` has a depth limit; truncation into nested representations can silently change meaning, so set and test a bounded depth appropriate to the schema. Never serialize a credential object as an application protocol.

### CMD-012: lab verifier

The verifier runs in a child `powershell.exe` with `-NoProfile` and process-only `-ExecutionPolicy Bypass`. Setup first acquires an ACL-protected, current-SID, create-new exclusive file handle with delete-on-close semantics. Only its owner can proceed to create a random directory under the current Windows user's temporary directory and publish the non-overwriting private descriptor. The verifier proves that two bounded setup processes produce one owner, one refused contender, and one root; it also proves that a stale or unexpected lock is preserved. The lab refuses elevation, reparse roots, unknown names, ownership or ACL changes, model changes, and descriptor redirection.

Final output:

```text
verification_passed=true
engine=Windows-PowerShell-5.1
cases=guided,independent
interruption=cleanup-resume-tested
network_mutation=none
cleanup_proven=true
```

`cases` counts deterministic workflows, not learner competence. `interruption` means the verifier simulated a known partial-cleanup phase and the controller resumed. `network_mutation=none` is a design assertion backed by source review; it is not a packet capture. `cleanup_proven` means exact registered state was absent at the final check, not that every temporary file on the workstation was examined.

## Decision path

Use this path when PowerShell automation appears inconsistent.

```text
1. Is impact active or likely?
   yes -> pause retries and overlapping controllers; preserve state
   no  -> keep the reproduction offline and bounded

2. Does runtime identity match?
   no  -> engine/module/host/cwd/profile drift branch
   yes -> inspect values at the failed boundary

3. Are values typed objects?
   string/format data -> move presentation last; restore schema
   deserialized copy  -> treat as snapshot; query remote owner if freshness matters
   expected type      -> inspect binding and cardinality

4. Which failure channel exists?
   ErrorRecord + continued pipeline -> classify nonterminating policy
   terminating exception            -> inspect type, cause, invocation
   native nonzero                    -> capture code and bounded stderr
   timeout after possible effect     -> UNKNOWN; reconcile by operation ID
   no technical failure              -> verify business postcondition

5. Is another attempt safe?
   committed                         -> do not replay; verify
   proven absent + eligible          -> retry within one budget
   rejected/permanent                -> correct input, auth, or policy
   unknown                           -> stop blind retry; owner must reconcile

6. Can change be bounded?
   no  -> keep mitigation, escalate owner, improve observability
   yes -> one target/cohort, ShouldProcess, authorization, deadline, abort

7. Did the original postcondition hold?
   no  -> operation is not successful
   yes -> check duplicates, partials, cleanup, telemetry, and caller exit
```

The fastest safe incident response is often to **stop automatic replay**. PowerShell makes loops and retries easy; distributed truth makes them dangerous. Capture one complete attempt before changing error preferences or quoting.

For object problems, use a type checkpoint:

```powershell
$items = Get-WorkItem
if ($items.Count -gt 0) {
    $items[0].GetType().FullName
    $items[0] | Get-Member
}
```

Handle the empty collection before indexing. Record cardinality separately: zero can be a valid business result, a filtered result, or a failed upstream call. Type evidence cannot decide that alone.

For errors, build an outcome table per target:

| Target | Attempt | PowerShell error | Native status | Owner state | Classification | Retry |
|---|---:|---|---:|---|---|---|
| service-a | 1 | none | 0 | desired version | committed and verified | no |
| service-b | 1 | timeout exception | unknown | receipt found | committed, response lost | no |
| service-c | 1 | access denied ErrorRecord | not started | unchanged | rejected | no until authorization changes |
| service-d | 1 | none | 5 | unchanged proved | transient no-effect | bounded eligible |

This table prevents one global exit or red line from erasing per-target truth.

## Guided Ubuntu lab

The workstation has Ubuntu 24.04 in WSL and Windows PowerShell 5.1, but not native PowerShell 7. We will not install a runtime merely to make the lab look Ubuntu-native. That would add network, package, trust, and host changes unrelated to the lesson.

From WSL Ubuntu, establish the bridge:

```bash
LESSON_REPO_ROOT="$(git rev-parse --show-toplevel)" || exit 1
cd -- "$LESSON_REPO_ROOT/book/labs/LES-0019-powershell-automation"
pwd -P
id
test -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
LAB_PS1="$(wslpath -w ./lab.ps1)"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe \
  -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass \
  -File "$LAB_PS1" check
```

`git rev-parse --show-toplevel` asks the current Git worktree for its root, so run this from anywhere inside the clone. `|| exit 1` stops if that evidence is unavailable. Quoting preserves spaces in the path, and `cd --` prevents a path beginning with a dash from being parsed as an option. If this is not the intended dedicated learning repository, stop instead of changing the variable manually.

Decode the boundary:

- `pwd -P`, `id`, `test`, command substitution, and `wslpath` execute in Ubuntu.
- `powershell.exe` starts a Windows process through WSL interoperability.
- `LAB_PS1` becomes a Windows path because the Windows process cannot use a WSL path as its normal script argument.
- `$env:TEMP`, SIDs, ACLs, reparse points, and the process exit status inside `lab.ps1` are Windows concepts.
- `-ExecutionPolicy Bypass` applies to this child invocation. It is neither an execution-policy configuration change nor a security sandbox.

For the clearest output, use a normal Windows PowerShell window in the same directory for the lifecycle:

```powershell
.\lab.ps1 check
.\lab.ps1 setup -WhatIf
.\lab.ps1 check
.\lab.ps1 setup
.\lab.ps1 run baseline
.\lab.ps1 inject guided
```

The WhatIf setup should describe an action and leave `state=absent`. Real setup prints one registered root. Do not edit or navigate into that root; the controller owns it.

Observe each contract separately:

```powershell
.\lab.ps1 observe operation
.\lab.ps1 observe input
.\lab.ps1 observe pipeline
.\lab.ps1 observe errors
.\lab.ps1 observe native
.\lab.ps1 observe state
.\lab.ps1 observe outcome
```

Write an evidence table. The guided model shows:

- the input was `System.String`, while the required internal type was `System.Int32`;
- formatting text replaced `PSCustomObject` data before property filtering;
- a nonterminating provider error added an error record and did not run `catch`;
- the synthetic native helper returned 7 and no exception was thrown;
- `$LASTEXITCODE` was not read before another possible native command;
- zero of three promised records were published;
- observed replicas remained two while desired replicas was three;
- the wrapper still reported exit zero.

Notice that no single control fixes everything. `[int]` does not preserve objects. Moving `Out-String` does not translate native codes. `-ErrorAction Stop` does not verify remote state. A nonzero exit does not reconcile a timeout. Reliability comes from the whole contract path.

Recover only after explaining the mechanisms:

```powershell
.\lab.ps1 recover -WhatIf
.\lab.ps1 recover
.\lab.ps1 verify-operation
.\lab.ps1 status
.\lab.ps1 cleanup
.\lab.ps1 check
```

The modeled recovery validates the integer boundary, retains objects until serialization, promotes the expected provider error, captures and translates native status, builds a complete candidate, and verifies readback. It is a model, not a real change.

Run the full verifier from a clean state:

```powershell
powershell.exe -NoLogo -NoProfile -NonInteractive `
  -ExecutionPolicy Bypass -File .\verify.ps1
```

If it refuses, preserve the first error. Do not run as Administrator, loosen ACLs, or use `Remove-Item -Recurse`. If interruption leaves registered state, use only:

```powershell
.\lab.ps1 cleanup
.\lab.ps1 check
```

The lab's README contains the exact lifecycle and proof limits.

## Production transfer

### CI pipelines

Pin the runner image and PowerShell edition. Launch with `-NoProfile -NonInteractive`. Resolve modules from a reviewed artifact source and verify the installed package, not a developer's mutable module directory. Treat working directory and `$env:PSModulePath` as inputs. Make success output machine-readable and keep diagnostic streams separate. Capture and publish a sanitized result artifact even on nonzero completion.

Controller retries compose with script retries. If CI can retry a job twice and the script retries an API three times, one logical operation can make six attempts before other layers retry. Assign one retry owner and a fleet-wide budget. Use one durable operation ID across job attempts.

### Windows scheduled tasks and services

Interactive drive mappings, user profiles, credential prompts, and current directories may be absent. Use explicit paths, service identities, noninteractive error behavior, and a durable state location with reviewed access-control lists. A scheduled-task result reflects process exit, not target postcondition, so emit an operation receipt and verify state.

Do not store a password in a task argument or script file. Prefer managed service accounts or platform-supported identity. If a task can overlap, configure concurrency policy and still make the operation idempotent because manual starts and scheduler failover can bypass assumptions.

### PowerShell 7 and Linux

PowerShell 7 uses `pwsh`, Core edition, modern .NET, and cross-platform providers. Filesystem case sensitivity, environment-variable names, path syntax, executable discovery, encodings, native argument passing, process signals, ACLs/mode bits, and available modules differ. Windows-only cmdlets may not exist. Build a matrix with at least the exact editions and operating systems you support.

Do not branch throughout business logic on `$IsWindows`. Put platform differences behind narrow adapters and test the same operation contract against each implementation.

### Containers and Kubernetes

The image owns PowerShell version and modules. The pod's service account owns Kubernetes API permissions. The container filesystem is often ephemeral. A restart can happen after a remote effect but before local checkpoint, so durable intent belongs outside the container. A Kubernetes Job controller can repeat pods; an Operator reconciles repeatedly by design.

Use desired state, conditional resource versions, stable operation identity, and server-side or owner-side idempotency. Bound client and controller retries together. Emit metrics for logical operations separately from attempts. Verify the original resource and user-facing outcome.

### Remoting and private cloud

PowerShell remoting over WS-Management or SSH has distinct authentication and endpoint rules. Inventory endpoint configuration, allowed language, remote identity, and transport. Reduce returned data remotely but never send untrusted code text. Treat returned objects as serialized snapshots.

A request from workstation A to server B, followed by B accessing server C, is a second hop. Do not enable broad delegation as a troubleshooting shortcut. Design constrained identity, endpoint capability, and audit with the security owner. Prefer Just Enough Administration for bounded operational tasks where appropriate.

### Cloud APIs

Cloud modules are API clients. Module objects and convenience cmdlets do not remove eventual consistency, pagination, throttling, conditional updates, long-running operations, or rate limits. Capture request or correlation IDs without logging tokens. After a timeout, query operation or resource state. Use resource version or ETag-style conditions when offered.

Cloud cost is another postcondition. A script that "succeeds" while creating duplicate disks, public addresses, snapshots, or high-cardinality logs has failed operationally. Include cost and quota signals in canary abort rules.

### Data and platform operations

PowerShell often orchestrates SQL, files, directory services, certificates, or deployment tools. Avoid building SQL or command source through interpolation. Use parameterized APIs. For bulk operations, separate discovery, immutable plan, approval, effect, receipt, and verification. Store plan and receipt schemas with version and digest so a reviewer can prove what was authorized.

## Reliability, security, observability, capacity, and cost

### Reliability

A reliable public function has a stable contract:

- mandatory and optional parameters with exact types and ranges;
- deterministic behavior for empty, one, and many inputs;
- one documented success-output type;
- explicit partial and unknown outcomes;
- no accidental output from helpers;
- stable error categories and process exits;
- idempotent operation identity;
- bounded deadlines and retries;
- authoritative postcondition verification;
- resumable cleanup or reconciliation after interruption.

Set desired state rather than applying relative deltas. Use compare-and-set with a resource version. Keep an old known-good artifact until the new one passes consumer readback. Rollback code does not undo already accepted external effects; those may require reconciliation or compensation.

### Security

Execution policy helps control script loading behavior in supported Windows contexts; it is not an authorization boundary or sandbox. Script signing helps establish publisher and integrity policy when correctly operated; it does not make logic safe. Language modes constrain capabilities in managed environments; do not bypass them to make automation work.

Use least privilege at the real target. Separate read, plan, and apply identities when practical. Validate resource scope and tenant before `ShouldProcess`. Reject wildcard targets for mutation unless the exact expanded target set is reviewed and bounded. Prefer `-LiteralPath` for filesystem data so wildcard characters stay literal.

Never log the contents of `PSCredential`, `SecureString`, access tokens, certificate private keys, signed URLs, or secret-bearing exception payloads. Redaction should be allowlist-first. Test every stream, transcript, JSON artifact, and CI attachment with synthetic canary secrets.

### Observability

Count **logical operations** and **attempts** separately. Useful low-cardinality fields include tool version, operation class, outcome class, dependency, duration bucket, retry reason, and verification result. Keep high-cardinality operation ID in logs or traces, not metric labels.

Measure:

- invocation count and duration in seconds;
- validation rejection count;
- planned versus applied target count;
- outcomes: succeeded, no-change, rejected, failed, partial, unknown;
- native exits by documented class, not unbounded raw message;
- retry attempts and exhausted budgets;
- oldest unknown outcome age;
- queue age and active concurrency;
- output rows and bytes;
- duplicate and missing receipts;
- postcondition verification failures;
- cleanup refusals and stale registered state;
- module/engine drift.

A transcript is evidence for a human session but cannot replace structured events. Correlate local invocation, controller job, remote request, resource version, and final verification with one safe operation ID.

### Capacity

Suppose 2,400 targets each require a median 200 milliseconds of remote service time. Serial ideal service time is:

```text
2,400 targets x 0.2 seconds/target = 480 seconds = 8 minutes
```

With 12 workers, the impossible lower bound ignoring overhead is 40 seconds. Real duration includes tail latency, admission, authentication, serialization, retries, throttling, and verification. If each worker buffers 5 MiB of stdout and 2 MiB of objects, 12 workers can retain about 84 MiB before engine and module overhead. One unusually large output can dominate.

Do not choose concurrency by dividing target count by desired duration alone. Measure dependency rate limits, CPU, memory, process count, runspace startup, output size distribution, timeout rate, and failure amplification. Bound both work queue and retained output. Increase canary scope only while latency, error, unknown-outcome, memory, and quota guardrails remain healthy.

### Cost

Automation cost includes runner minutes, remote API calls, module downloads, log ingestion, trace storage, snapshots, and accidentally duplicated resources. Verbose per-object logs can cost more than the work. Retry storms consume rate quota and extend incidents. Keep sampled diagnostics and durable per-operation receipts, then aggregate metrics.

The cheapest safe automation is often `NoChange`: read desired versus actual, prove equality, and avoid an effect. But the read itself has cost and consistency limits. Cache only with an explicit freshness policy and conditional version.

## Traps and prevention

| Trap | Why it fails | Prevention |
|---|---|---|
| Treating formatted tables as data | presentation replaces object contract | format only at the final human edge; assert types before export |
| Assuming `catch` sees red errors | nonterminating errors continue by default | use command-specific `-ErrorAction Stop` where failure must terminate |
| Setting `SilentlyContinue` globally | hides evidence and preserves continuation | classify expected errors narrowly; retain safe error records |
| Checking `$?` much later | it describes a recent operation and has edition nuances | capture specific status immediately and translate once |
| Reading `$LASTEXITCODE` after another executable | the later program overwrites it | capture on the next statement |
| Building a native command string | parser layers reinterpret data | absolute executable, argument array, fixture tests, no `Invoke-Expression` |
| Trusting type annotations alone | binder conversion may accept text; business invariants remain | validation attributes plus semantic and authorization checks |
| Returning strings from every function | callers must parse presentation and lose types | return one documented object; format at caller edge |
| Letting helper output escape | public output cardinality and types change | assign, redirect deliberately, and contract-test output |
| Believing `-WhatIf` is a transaction | only participating branches are suppressed | effect-free planning, per-effect ShouldProcess, state-owner no-change test |
| Using `SecureString` as a security proof | downstream conversion and logging can expose material | late vault retrieval, least privilege, no arguments/logs, rotation plan |
| Passing credentials through remoting casually | intermediate hosts and serialization are trust boundaries | approved identity/delegation architecture and constrained endpoints |
| Treating deserialized objects as live | methods and freshness are not preserved | narrow schemas and authoritative remote readback |
| Retrying timeout automatically | effect may already be committed | stable operation ID and reconciliation before retry |
| Running many jobs for speed | process, memory, dependency, and retry load multiply | measure, bound, backpressure, and assign one state owner |
| Sharing a file as coordination | writes race and locks may be local or stale | transactional owner, conditional version, or proved lock protocol |
| Logging every target in metric labels | cardinality and cost explode | low-cardinality metrics; IDs in sampled logs/traces |
| Depending on profiles | interactive and CI behavior drift | `-NoProfile`; import explicit versioned dependencies |
| Wildcard module exports | auto-discovery and accidental API surface grow | explicit manifest exports and compatibility matrix |
| Mock-only tests | mocks prove assumptions, not real provider contracts | unit plus adapter, process, cross-edition, and canary tests |
| Recursive cleanup after a failure | wrong path or reparse point can expand blast radius | registered ownership, exact allowlist, nonrecursive empty-root removal |

Prevent defects at review time with a checklist:

```text
[ ] exact supported powershell/pwsh editions and operating systems
[ ] no profile or ambient-module dependency
[ ] advanced parameters validate syntax, range, semantics, and scope
[ ] public output has one stable type and cardinality rule
[ ] formatting only at presentation edge
[ ] ErrorRecord policy and native exit policy tested separately
[ ] absolute native executable and hostile-argument fixture
[ ] ShouldProcess immediately guards every effect
[ ] stable operation ID and unknown-outcome reconciliation
[ ] concurrency, queue, output, timeout, and retry budgets
[ ] allowlisted secret-safe telemetry across every stream
[ ] module manifest and explicit exports
[ ] parser, analyzer, unit, adapter, process, edition, interruption tests
[ ] authoritative postcondition and duplicate verification
[ ] exact cleanup and remaining-risk owner
```

## Memory card and retrieval

Remember **OBJECTS**:

```text
O  Observe engine, identity, command resolution, and types.
B  Bind and validate external values before planning.
J  Judge each failure channel separately.
E  Effects sit behind ShouldProcess, authorization, and a deadline.
C  Capture native status immediately; classify, do not guess.
T  Track one logical operation and reconcile unknown outcomes.
S  State-owner readback decides success; streams report it safely.
```

Remember the boundary phrase:

> Objects for decisions, formatting for humans, schemas for transport, receipts for effects.

Retrieval questions:

1. Why can red text appear without entering `catch`?
2. What exactly is lost when `Out-String` appears before `Where-Object`?
3. Why must `$LASTEXITCODE` be captured immediately?
4. What does `-WhatIf` prove, and what does it not prove?
5. Why is a timeout after a mutation not a normal retry signal?
6. What changes when an object crosses PowerShell remoting?
7. Why are `[int]` and `ValidateRange` necessary but insufficient?
8. How do logical operation metrics differ from attempt metrics?
9. What makes concurrency safe when several runners touch one resource?
10. Why does a passing mock-based test not prove production behavior?

Do not peek at the next section until you can explain the questions aloud. Retrieval strengthens memory; rereading alone can create familiarity without recall.

## Complete answers

### 1. Why can red text appear without entering catch?

Direct answer: many cmdlets emit a nonterminating `ErrorRecord`. The host renders it as red text, but the command continues and `catch` handles only terminating flow. Use `-ErrorAction Stop` for a command whose failure must enter the surrounding `try`, then classify the resulting error narrowly.

Foundation: PowerShell separates an error **record** from control flow. A provider can fail one item in a 100-item pipeline, write stream 2, and continue the remaining 99. That is useful for interactive bulk work. Automation must decide whether partial work is allowed. Color comes from the host and is not the mechanism.

Senior answer: define the per-item and whole-operation contract. Promote only expected command boundaries where continuation would violate the invariant, retain error category and fully qualified ID, produce one durable terminal record per target, and return nonzero for partial or unknown completion unless partial is explicitly successful. Verify state instead of treating absence or presence of red rendering as truth.

### 2. What exactly is lost when Out-String appears before Where-Object?

Direct answer: structured elements become presentation strings. Original properties and methods are no longer available to downstream commands.

Foundation: `Where-Object Status -eq 'Ready'` expects objects with a `Status` property. A string may display the word Ready, but that text is not the original property. Parsing column spacing is fragile across widths, locales, and versions.

Senior answer: preserve types through filtering, sorting, grouping, and projection; serialize a versioned minimal schema for machine consumers; format only for the host. Add contract tests that assert element type and property set immediately before serialization, plus empty/one/many cardinality and cross-edition output tests.

### 3. Why capture LASTEXITCODE immediately?

Direct answer: it belongs to the most recently completed native program. Another native invocation can overwrite it.

Foundation: PowerShell exceptions and native process exits are different systems. A native nonzero status does not automatically become a catchable exception in Windows PowerShell 5.1. Store the integer on the next statement, then map documented values.

Senior answer: the adapter captures code, bounded stdout, bounded stderr, elapsed time, timeout/process-tree status, executable identity, and operation ID as one immutable attempt result. It maps documented codes into closed domain outcomes. A timeout after possible effect becomes unknown and reconciles at the target; code zero still requires output-schema and postcondition verification.

### 4. What does WhatIf prove?

Direct answer: for a tested command path, participating calls to `ShouldProcess` returned false and their guarded blocks did not run. It does not prove authorization, transactionality, plan freshness, nested-tool compliance, or production success.

Foundation: declaring `SupportsShouldProcess` adds `-WhatIf` and `-Confirm`, but the author must call `$PSCmdlet.ShouldProcess` around changes. An external executable knows nothing about the protocol unless the wrapper suppresses its invocation or passes an independently supported dry-run option.

Senior answer: separate pure planning from effects, validate and discover before the guard, place per-target guards immediately around effect adapters, propagate WhatIf deliberately across module boundaries, and test no state-owner changes. Use a reviewed plan artifact and approval for production. Re-read state under a conditional version before apply because the WhatIf plan can become stale.

### 5. Why is timeout after mutation not a normal retry signal?

Direct answer: the client stopped waiting; the server may have committed. Retrying can duplicate the effect.

Foundation: network response and remote state are different. A request can reach the server, commit, and lose its response. The local timeout proves neither failure nor success.

Senior answer: persist canonical intent and a stable idempotency key before send, pass one deadline, record attempt start and ambiguity, and query the authoritative owner by the same identity. Record committed if a receipt exists, retry only when no effect is proved and policy permits, otherwise stop with an owned unknown outcome. Verify the original user operation and duplicate count.

### 6. What changes during remoting?

Direct answer: code runs under a remote endpoint and identity, while most results return as serialized property copies. Methods, live handles, exact types, depth, and freshness may not survive.

Foundation: the local table can look like the remote object even when its type name says `Deserialized.*`. Authentication to the remote host does not automatically authorize a second resource hop.

Senior answer: model local caller, transport/authentication, endpoint configuration, remote process identity, target resource, serialization schema, and second-hop identity separately. Validate remote parameters, reduce data near the owner, avoid secrets in payloads, use constrained endpoints and reviewed delegation, and query authoritative state for decisions requiring freshness.

### 7. Why are int and ValidateRange insufficient?

Direct answer: they establish convertibility and a numeric range, not business meaning, authorization, current capacity, cross-field invariants, or retry safety.

Foundation: the string `"4"` may become integer 4 and pass a range of 1 to 20. That does not prove this caller may scale `payments-api`, that the quota supports four, or that another controller is not changing it.

Senior answer: make boundary parsing explicit, validate resource-name grammar and allowed scope, authorize actor and tenant, enforce cross-field and capacity policy, read authoritative version, build a pure plan, condition the update, carry one operation ID, and verify. Treat validation attributes as the first layer of a larger request contract.

### 8. Logical operations versus attempts

Direct answer: a logical operation is the user's one intended outcome; attempts are individual executions caused by retries or redelivery.

Foundation: one deployment may be tried three times. Counting three "deployments" inflates throughput and hides retry cost. Count one logical deployment plus three attempts.

Senior answer: use stable operation identity across scheduler, script, helper, and target. Measure terminal outcome, end-to-end latency, oldest unknown, and verification per logical operation; measure dependency status, attempt latency, backoff, and retry reason per attempt. Bound label cardinality and use logs/traces for operation IDs.

### 9. What makes concurrency safe?

Direct answer: an authoritative state owner enforces ordering or exclusivity through a transaction, conditional version, atomic claim, or lease plus fencing. Process-local variables alone are insufficient.

Foundation: two scripts can both read replicas 2 and both decide to change. A shared file can also race. A mutex on one machine does not protect another runner.

Senior answer: assign one write owner, store durable intent, condition every critical transition on expected version, limit concurrency near the dependency, and use monotonic fencing so a stale worker cannot write after lease expiry. Test duplicate delivery, paused stale worker, cancellation, controller restart, and timeout after commit. Verify actual target state and duplicates.

### 10. Why are mocks not production proof?

Direct answer: a mock returns the behavior the test author assumed. It proves decision logic against that model, not the real command, provider, serializer, permissions, network, or state owner.

Foundation: mocks make unit tests fast and deterministic. They can also hide a wrong parameter name or output type if the fake accepts it.

Senior answer: layer tests. Unit-test pure planning with mocks or fakes; contract-test adapter inputs and outputs; run process-level tests against the packaged module; test exact PowerShell editions and operating systems; inject timeouts, partial streams, hostile arguments, interruption, and concurrency; then canary real authorized targets with abort thresholds and postcondition verification. Keep mocks strict enough that unexpected calls fail.

## Product-company interview

**Scenario.** A global payments platform uses a PowerShell module from Windows-based CI runners to rotate application certificates across 4,000 servers. A new release completes 30 percent faster and reports 99.8 percent success, but some services present the old certificate. Logs contain intermittent nonterminating remoting errors. The function formats remote certificate objects before exporting JSON, starts 200 background jobs, catches every exception, passes a credential into each job, retries failed server names twice, and exits zero if at least 95 percent returned a row. Explain your response and redesign.

**Direct answer.** Stop automatic retries and further rollout because the result artifact and green threshold do not prove certificate state. Preserve module and engine identity, target set, operation IDs, job results, every stream, remote endpoint identity, certificate thumbprints and validity, and load-balancer observations without logging credentials. Classify every server as verified new, verified old, rejected, unknown, duplicate, or not attempted. Formatting before JSON destroys the certificate object contract; nonterminating remoting errors may bypass catch; jobs serialize objects and credentials across process boundaries; 200 jobs create unproven resource and endpoint pressure; broad catches hide defects; name-based retries can repeat committed work; and 95 percent success violates a 100 percent security operation unless an explicit exception policy exists.

**Foundation reasoning.** A certificate rotation has at least three state owners: the local store on each server, the service process that may cache or load a certificate, and the user-facing TLS endpoint. Installing a certificate is not the same as the service using it. A remoting result is a serialized snapshot. `Format-Table` prepares display data, not JSON records. A background job has another process/session and returns serialized output. A credential object crossing into many jobs expands exposure. `catch` does not see default nonterminating errors. Exit zero based on rows confuses reporting with state.

**Senior answer.** I would establish one operation record containing the authorized 4,000-target inventory digest, desired certificate identifier, safe validity metadata, code/module version, and per-target stable operation ID. First run read-only discovery with bounded concurrency and endpoint quotas. A typed schema records store state, service-binding state, externally observed TLS state, resource version, and evidence time. A pure planner emits `NoChange`, `Install`, `Bind`, `RestartRequired`, `Rejected`, or `Unknown` per server. The effect adapter uses constrained remoting endpoints and least-privilege service identity; it never transports an exportable private key through logs or generic job state. It applies a conditional, idempotent desired state and returns a durable receipt. Expected remoting errors are promoted and classified; unexpected exceptions fail the target and retain sanitized causal evidence. Unknown outcomes reconcile remotely before retry.

Concurrency begins at a measured canary, perhaps one service and failure domain, not 200 because the number is available. Budgets cover CI parallelism, runspaces/jobs, WinRM quotas, certificate-store contention, service restart capacity, load balancer health, and retries. Backpressure limits queued work and retained output. Abort on unknown outcomes, authentication spikes, endpoint latency, service health regression, secret-canary detection, or old-certificate count above threshold.

Verification is layered: remote store contains expected certificate and private-key association where required; the service binding references it; the service reloaded successfully; external TLS handshakes across load-balanced endpoints present the intended chain; old certificate use falls to zero after the declared convergence window; and no unintended duplicate or extra certificate state remains. Exit zero requires every in-scope server terminal under the approved exception policy and the user-facing postcondition satisfied. A versioned JSON result is built from typed objects before any formatting. Human tables are rendered separately.

Rollback retains the prior certificate and binding until verification. Reverting configuration does not erase already distributed secrets or audit records; compromised or exposed material requires revocation and incident response. Rollout and rollback both reconcile each server rather than replaying an unbounded script.

**Weak answer.** Add `-ErrorAction SilentlyContinue`, increase jobs to 400, export the formatted table to a larger JSON file, and rerun the failed server list with a longer timeout.

**Why it is weak.** It suppresses evidence, doubles unmeasured pressure, preserves the object/text defect, repeats ambiguous effects, ignores credential exposure, and still does not verify which certificate users receive. It treats speed and row count as reliability while leaving state owners and operation identity undefined.

**Answered follow-ups.**

*Why not simply set `$ErrorActionPreference = 'Stop'`?* It is a useful fail-closed entrypoint default, but the design still needs typed output, target-level results, native/remoting outcome classification, concurrency control, secret handling, idempotency, reconciliation, and postcondition verification. Some expected provider outcomes may need narrow command-level handling.

*Are background jobs safe for credentials?* Jobs create process or session boundaries and serialize inputs/results. Safety depends on how credentials are obtained, protected, transported, retained, and used. Prefer a constrained remote or workload identity and late retrieval rather than distributing one broad credential to hundreds of jobs. Never infer safety because the variable type is `PSCredential`.

*How would you choose concurrency?* Measure one operation's CPU, memory, retained bytes, remote session setup, endpoint latency, WinRM quotas, service restart capacity, and failure load. Set per-service, per-failure-domain, and global budgets. Canary, observe tail latency and unknown outcomes, and increase only within abort thresholds.

*What is the result schema?* At minimum: schema version, logical operation ID, target stable ID, desired certificate safe identifier, observed prior and final safe identifiers, store/binding/endpoint outcome classes, attempt count, receipt or correlation ID, timestamps and durations, verification status, and a sanitized error code. It excludes private key, password, token, and raw credential.

*How do you test timeout after commit?* In a deterministic adapter fixture, accept and record the operation at the modeled owner, drop the response, terminate the worker, and start a replacement. The replacement must query by the same operation ID, find the receipt, avoid another install, and verify the endpoint. Then canary against a disposable authorized environment with the same protocol.

## Independent transfer and rubric

Use `ASM-0042` and the blank response template. The exercise is deliberately separate from this lesson's complete guided answers.

Run only the raw scenario first:

```powershell
.\lab.ps1 setup
.\lab.ps1 run baseline
.\lab.ps1 inject independent
.\lab.ps1 scenario
```

Before any `observe`, write:

- runtime and WSL/Windows boundary;
- exact promised postcondition;
- each state owner;
- facts present in the raw scenario;
- at least three possible outcomes or mechanisms;
- predicted evidence and one disconfirming check for each;
- whether another effect is safe now and why;
- blast radius, abort conditions, and secret exclusions.

Then gather only the evidence needed. Store your response outside the guarded lab directory. Do not inspect the fixture, another answer, or the assessment's reviewer material.

The 50-point rubric has five equal areas:

1. independent scope, prediction, and answer isolation;
2. PowerShell object, binding, stream, error, native, and exit accuracy;
3. state ownership, idempotency, reconciliation, and bounded recovery;
4. evidence, verification, interruption, refusal, and cleanup quality;
5. production transfer, security, observability, capacity, and incident communication.

A verifier pass is necessary evidence about the lab controller. It is not evidence that your reasoning earned any score. A human reviewer must assess your original prediction, proof limits, recovery design, and production transfer. Publishing this chapter does not award mastery.

## References and review

The lesson is paraphrase-first and uses primary project documentation. Pages are versioned where Microsoft Learn exposes a view selector; Windows PowerShell 5.1 differences remain called out explicitly.

- `REF-0105` — Microsoft Learn, `about_Objects`: objects, types, properties, methods, and pipeline identity.
- `REF-0106` — Microsoft Learn, `about_Pipelines`: object flow, enumeration, and pipeline mechanics.
- `REF-0107` — Microsoft Learn, `about_Error_Handling`: nonterminating, statement-terminating, script-terminating, and native-command failure channels.
- `REF-0108` — Microsoft Learn, `about_Parsing`: expression mode, argument mode, quoting, and native argument boundaries.
- `REF-0109` — Microsoft Learn, `about_Automatic_Variables`: `$LASTEXITCODE`, `$?`, `$Error`, `$PSBoundParameters`, and invocation state.
- `REF-0110` — Microsoft Learn, `ShouldProcess` deep dive: `SupportsShouldProcess`, `WhatIf`, `Confirm`, scope, and nested-module cautions.
- `REF-0111` — Microsoft Learn, PowerShell remoting second hop: remote identity, delegation choices, and credential risk.
- `REF-0112` — Microsoft Learn, SecretManagement overview: vault abstraction, current-user registration, runtime retrieval, and stated module lifecycle.

Review again by 2027-02-02, or earlier when any of these changes:

- a tested PowerShell engine or operating-system version;
- native argument-passing semantics;
- error-handling or stream behavior;
- remoting authentication or delegation guidance;
- SecretManagement support or preferred identity guidance;
- lab ACL behavior, fixture digest rules, or WSL interop;
- schema, assessment, or answer-isolation policy.

Known boundaries remain explicit: the lab is Windows PowerShell 5.1 and offline; native PowerShell 7, Linux ACL/mode behavior, real remoting, real credentials, module installation, real APIs, and distributed concurrency were not exercised. Independent evidence and review are still required.
