.PHONY: build lint test

IVERILOG ?= iverilog
VVP ?= vvp
BUILD_DIR := build
SIM := $(BUILD_DIR)/game
SOURCES := game.v game_tb.v

build:
	@mkdir -p $(BUILD_DIR)
	$(IVERILOG) -g2012 -Wall -s game_tb -o $(SIM) $(SOURCES)

lint: build
	@echo "Icarus warning check completed during build."

test: build
	$(VVP) $(SIM)
