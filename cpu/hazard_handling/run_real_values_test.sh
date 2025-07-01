#!/bin/bash

echo "========================================"
echo "RV32IM Pipeline Hazard Test with Real Values"
echo "========================================"
echo

echo "Compiling hazard test with real values..."
iverilog -o hazard_test_real hazard_test_with_real_values.v ../cpu.v

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed!"
    exit 1
fi

echo
echo "Running hazard test with real values..."
echo "========================================"
vvp hazard_test_real

echo
echo "========================================"
echo "Test completed!"
echo "Check the output above for hazard handling with real data."
echo "========================================" 