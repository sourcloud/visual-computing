.PHONY: help run build

help:
	@cat Makefile

build:
	@docker build -t hdrplus .

run: bursts
	@docker run --rm -v "$(shell pwd)/bursts":/bursts --name hdrplus hdrplus:latest

bursts:
	@mkdir "$(shell pwd)/bursts"