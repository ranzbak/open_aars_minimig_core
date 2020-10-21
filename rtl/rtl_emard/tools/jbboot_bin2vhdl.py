#!/usr/bin/env python3

import sys
import os.path

fin = open(sys.argv[1], 'rb')
fout = open(sys.argv[2], 'w')

# module name
modulename = "jbboot"
# output data size (bytes)
datasize = 2

data = fin.read()

array_len = int(len(data)/datasize)

# calculate addr size
adrsize = 0
fitsize = 1

while fitsize < array_len:
  adrsize += 1
  fitsize += fitsize

fout.write("-- converted by jbboot_bin2vhdl.py\n");
fout.write("library ieee;\n");
fout.write("use ieee.std_logic_1164.all;\n");
fout.write("use ieee.numeric_std.all;\n");
fout.write("\n");
fout.write("entity " + modulename + " is\n");
fout.write("   port\n");
fout.write("   (\n");
fout.write("        clk: in std_logic;\n");
fout.write("        addr: in std_logic_vector(" + str(adrsize - 1) + " downto 0);\n");
fout.write("        data: out std_logic_vector(" + str(8*datasize - 1) + " downto 0)\n");
fout.write("   );\n");
fout.write("end " + modulename + ";\n");
fout.write("\n") 
fout.write("architecture arch of " + modulename + " is\n");
fout.write("   type rom_type is array (0 to " + str(fitsize-1) + ") of std_logic_vector(" + str(8*datasize - 1) + " downto 0);\n");
fout.write("   constant rom_data: rom_type := (");

last = array_len-1

if datasize == 1:
 for i in range(0, array_len):
  if (i % 8) == 0:
    fout.write("\n")
  fout.write("x\"%02x\"" % (data[i],) )
  if i != fitsize-1:
    fout.write(",")

if datasize == 2:
 for i in range(0, array_len):
  if (i % 8) == 0:
    fout.write("\n")
  fout.write("x\"%02x%02x\"" % (data[2*i+0],data[2*i+1],) )
  if i != fitsize-1:
    fout.write(",")

if array_len < fitsize:
  fout.write("\nothers => (others => '0')");
fout.write(");\n");
fout.write("   signal R_data: std_logic_vector(" + str(8*datasize - 1) + " downto 0);\n");
fout.write("   signal R_addr: std_logic_vector(" + str(adrsize - 1) + " downto 0);\n");
fout.write("begin\n");
fout.write("   process(clk)\n");
fout.write("   begin\n");
fout.write("      if rising_edge(clk) then\n");
fout.write("         R_data <= rom_data(to_integer(unsigned(addr)));\n");
fout.write("      end if;\n");
fout.write("   end process;\n");
fout.write("   data <= R_data;\n");
fout.write("end arch;\n");

fin.close()
fout.close()

