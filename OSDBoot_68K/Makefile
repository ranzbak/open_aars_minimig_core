# *nix Makefile for Minimig bootfirmware assembly
# Written by Christian Vogelgsang <chris@vogelgsang.org>

# ----- the following tools need to be installed -----
# vasm homepage http://sun.hasenbraten.de/vasm
ASM=vasmm68k_mot
ASM_OPTS=-m68000 -chklabels -nocase
OUT_DIR=../rtl/
SCRIPT_DIR=../rtl/rtl_emard/tools

PROJECT=osdload

# ----- rules -----
.PHONY: all
all: osdload.vhd jbboot.vhd

.PHONY: clean
clean:
	rm -f *.vhd *.bin
	
%.bin: %.asm
	$(ASM) $(ASM_OPTS) -Fbin -o $@ $<

osdload.vhd: osdload.bin
	$(SCRIPT_DIR)/osdbootstrap_bin2vhdl.py $< $@

jbboot.vhd: amigaboot.bin
	$(SCRIPT_DIR)/jbboot_bin2vhdl.py $< $@

.PHONY: install
install: osdload.vhd jbboot.vhd
	cp $^ $(OUT_DIR)

