.PHONY: verify lint typecheck test

verify:
	./scripts/harness/verify-env.sh
	./scripts/harness/knowledge-contract.sh
	./scripts/harness/check-all.sh

lint:
	./scripts/lint.sh

typecheck:
	./scripts/typecheck.sh

test:
	./scripts/unit-test.sh
