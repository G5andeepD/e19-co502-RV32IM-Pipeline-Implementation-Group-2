#!/bin/bash
echo "Assembling $1 to generate .mem file..."
python3 assembler.py -i $1
echo "Assembly complete!"
echo "Generated files:"
echo "  - ../cpu/build/$1.bin"
echo "  - ../cpu/hazard_handling/$1.mem" 