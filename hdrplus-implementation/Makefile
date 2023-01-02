.PHONY: help run build clean

help:
	@cat Makefile

build:
	@docker build -t hdrplus .

run: bursts
	@docker run --rm -v "$(shell pwd)/bursts":/bursts --name hdrplus hdrplus:latest

clean: bursts
	@find "$(shell pwd)/bursts" -type f -name "*.jpg" -exec rm -f {} \;
	@find "$(shell pwd)/bursts" -type f -name "*.log" -exec rm -f {} \;

bursts:
	@mkdir "$(shell pwd)/bursts"