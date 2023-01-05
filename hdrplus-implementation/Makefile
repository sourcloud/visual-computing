.PHONY: help run build clean clean-logs

help:
	@cat Makefile

build:
	@docker build -t hdrplus .

run: bursts
	@docker run --rm -v "$(shell pwd)/bursts":/bursts --name hdrplus hdrplus:latest

clean: bursts
	@find "$(shell pwd)/bursts" -type f -name "output.png" -exec rm -f {} \;

clean-logs: bursts
	@find "$(shell pwd)/bursts" -type f -name "*.log" -exec rm -f {} \;

bursts:
	@mkdir "$(shell pwd)/bursts"