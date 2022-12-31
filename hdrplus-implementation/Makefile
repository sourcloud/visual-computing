.PHONY: help run build

help:
	@cat Makefile

build:
	@docker build -t hdrplus .

run: input output
	@docker run --rm -v "$(shell pwd)/input":/input -v "$(shell pwd)/output":/output --name hdrplus hdrplus:latest

input:
	@mkdir "$(shell pwd)/input"

output:
	@mkdir "$(shell pwd)/output"
