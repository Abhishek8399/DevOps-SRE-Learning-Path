# LES-0038 provider-free Terraform/OpenTofu language lab

This lab uses only the built-in `terraform_data` resource. It creates plans and test runs but never applies them. It requires no cloud account, provider download, credential, backend, port or remote API.

The checked-in configuration teaches typed variables, validation, maps and objects, `for` expressions, `for_each` identity, locals, built-in functions, implicit graph edges, lifecycle preconditions, outputs and native tests.

Use a checksum-verified, version-pinned Terraform or OpenTofu CLI. Run only inside a disposable copy of `fixtures/`, because initialization and planning create local metadata and plan artifacts. Never run `apply` for this lesson.

The guarded Bash workflow binds the exact CLI path, version and SHA-256, copies only reviewed fixtures into `/tmp/reliability-atlas-les0038-<uid>`, refuses root and ambiguous state, permits only format/init/validate/test/plan/inspect/graph/negative cases, and proves exact cleanup.

~~~bash
bash lab.sh doctor terraform
bash lab.sh setup terraform
bash lab.sh run fmt
bash lab.sh run init
bash lab.sh run validate
bash lab.sh run test
bash lab.sh run plan
bash lab.sh run inspect
bash lab.sh run graph
bash lab.sh run negative
bash verify.sh terraform
~~~

Repeat with `tofu` only after the Terraform state is absent. Do not place one product's opaque plan in the other product's state directory. The verifier never runs `apply` and refuses any external provider declaration in the checked fixture.

Until this complete wrapper passes in Ubuntu 24.04, the package remains a quarantined teaching candidate rather than a learner-ready lab.
