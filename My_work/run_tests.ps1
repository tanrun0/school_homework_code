# Build and test script for simplified COOL parser
cd (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Run make
make

# Run parser on sample files
if (Test-Path "..\good.cl") {
    Write-Host "Parsing good.cl..."
    .\parser ..\good.cl
}
if (Test-Path "..\bad.cl") {
    Write-Host "Parsing bad.cl..."
    .\parser ..\bad.cl
}
if (Test-Path "..\stack.cl") {
    Write-Host "Parsing stack.cl..."
    .\parser ..\stack.cl
}
