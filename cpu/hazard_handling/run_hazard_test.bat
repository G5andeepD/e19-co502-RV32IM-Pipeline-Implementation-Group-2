@echo off
echo ========================================
echo RV32IM Pipeline Hazard Handling Test
echo ========================================
echo.

echo Compiling hazard test...
iverilog -o hazard_test_with_print.exe hazard_test_with_print.v ../cpu.v

if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo.
echo Running hazard test...
echo ========================================
vvp hazard_test_with_print.exe

echo.
echo ========================================
echo Test completed!
echo Check the output above for hazard handling verification.
echo ========================================
pause 