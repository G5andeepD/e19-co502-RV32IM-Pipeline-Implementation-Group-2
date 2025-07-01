@echo off
echo ========================================
echo RV32IM Pipeline Hazard Test with Real Values
echo ========================================
echo.

echo Compiling hazard test with real values...
iverilog -o hazard_test_real.exe hazard_test_with_real_values.v ../cpu.v

if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo.
echo Running hazard test with real values...
echo ========================================
vvp hazard_test_real.exe

echo.
echo ========================================
echo Test completed!
echo Check the output above for hazard handling with real data.
echo ========================================
pause 