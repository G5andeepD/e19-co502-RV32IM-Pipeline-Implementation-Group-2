@echo off
echo ========================================
echo RV32IM Pipeline Hazard Test with Memory
echo ========================================
echo.

echo Compiling hazard test with memory file...
iverilog -o hazard_test_memory.exe hazard_test_with_memory.v ../cpu.v

if %errorlevel% neq 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo.
echo Running hazard test with memory file...
echo ========================================
vvp hazard_test_memory.exe

echo.
echo ========================================
echo Test completed!
echo Check the output above for hazard handling with memory file.
echo ========================================
pause 