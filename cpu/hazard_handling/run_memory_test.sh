#!/bin/bash

echo "========================================"
echo "RV32IM Pipeline Hazard Test with Memory"
echo "========================================"
echo

echo "Compiling hazard test with memory file..."
iverilog -o hazard_test_memory hazard_test_with_memory.v ../cpu.v

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed!"
    exit 1
fi

echo
echo "Running hazard test with memory file..."
echo "========================================"
vvp hazard_test_memory

echo
echo "========================================"
echo "Test completed!"
echo "Check the output above for hazard handling with memory file."
echo "========================================" 