#!/bin/bash

echo "========================================"
echo "RV32IM Pipeline Hazard Handling Test"
echo "========================================"
echo

echo "Compiling hazard test..."
iverilog -o hazard_test_with_print hazard_test_with_print.v ../cpu.v

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed!"
    exit 1
fi

echo
echo "Running hazard test..."
echo "========================================"
vvp hazard_test_with_print

echo
echo "========================================"
echo "Test completed!"
echo "Check the output above for hazard handling verification."
echo "========================================" 