.PHONY: help run build

help:
	@cat Makefile

run:
	@docker run --rm -v $(shell pwd)/input:/input -v $(shell pwd)/output:/output hdrplus

build:
	@docker build -t hdrplus .

