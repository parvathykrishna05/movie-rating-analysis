@echo off
echo ===========================================
echo   Starting Movie Rating Shiny Dashboard...
echo ===========================================

:: Attempt standard PATH execution
Rscript -e "shiny::runApp('app.R', launch.browser=TRUE, port=8080)"

:: If it fails because R is not inPATH, fallback to the direct executable path installed by winget
if %errorlevel% neq 0 (
    echo.
    echo Rscript not found in standard system PATH. Utilizing direct local executable...
    "C:\Program Files\R\R-4.5.3\bin\x64\Rscript.exe" -e "shiny::runApp('app.R', launch.browser=TRUE, port=8080)"
)

pause
