include .env

NAMESPACE := Sample

.PHONY: help
help:
	@grep -A1 -E "^#:" Makefile \
	| grep -v -- -- \
	| sed 'N;s/\n/###/' \
	| sed -n 's/^#: \(.*\)###\(.*\):.*/\2###\1/p' \
	| column -t  -s '###'

.PHONY: gen/csharp
gen/csharp:
	docker run --rm -v $(PWD):/local openapitools/openapi-generator-cli:v6.4.0 generate \
		-i /local/build/openapi.yml \
		-g csharp \
		-o /local/build/csharp \
		-c /local/generator/csharp/configs.yml \
		-t /local/generator/csharp/templates

.PHONY: gen/csharp-debug
gen/csharp-debug:
	docker run --rm -v $(PWD):/local openapitools/openapi-generator-cli:v6.4.0 generate \
		-i /local/build/openapi.yml \
		-g csharp \
		-o /local/build/csharp \
		-c /local/generator/csharp/configs.yml \
		-t /local/generator/csharp/templates \
		--global-property debugModels=true

.PHONY: cp/csharp
cp/csharp:
	cp -r ./build/csharp/src/$(NAMESPACE)/Model/* $(CSHARP_MODEL_DIR)

.PHONY: gen-cp/csharp
#: build and copy cs files
gen-cp/csharp: gen/csharp cp/csharp

.PHONY: cp/openapi
#: copy openapi.yml
cp/openapi:
	cp ./build/openapi.yml $(SPEC_OPEN_API_PATH)

.PHONY: apply-all
#: build and copy all
apply-all: gen-cp/csharp cp/openapi
