@echo off
setlocal

if "%~1"=="" goto :usage

if /I "%~1"=="pub" (
  shift
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Release-Auto.ps1" %*
  exit /b %errorlevel%
)

echo Action inconnue: %~1
goto :usage

:usage
echo Usage: lance pub -CommitMessage "message" [-ReleaseAs patch^|minor^|major]
exit /b 1
