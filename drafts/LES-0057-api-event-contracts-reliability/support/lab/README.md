# LES-0057 API and event architecture model

This bounded offline model evaluates contract evolution and delivery boundaries. It opens no socket, starts no broker, sends no webhook, uses no credential and creates no external resource.

On Ubuntu 24.04 as a normal user, inspect the files, run `bash lab.sh setup`, evaluate cases with `bash lab.sh evaluate CASE_ID`, run `bash verify.sh` from an absent state, and finish with `bash lab.sh cleanup`. The model proves only its explicit rules and synthetic cases; it is not HTTP, OpenAPI, AsyncAPI, CloudEvents, Kafka, a schema registry, a webhook provider or production evidence.
