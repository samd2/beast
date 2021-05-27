
@ECHO ON
setlocal enabledelayedexpansion

if "%DRONE_JOB_BUILDTYPE%" == "boost" (

echo "============> INSTALL"
echo "============> SCRIPT"

echo "Running tests"
True
if !errorlevel! neq 0 exit !errorlevel!

echo "Running libs/beast/example"
True
False
if !errorlevel! neq 0 exit !errorlevel!

echo "Running run-fat-tests"
True
False
if !errorlevel! neq 0 exit !errorlevel!

REM echo "============> COMPLETED"

)

