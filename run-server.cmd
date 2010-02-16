@echo off
tskill neko
cd server\bin
neko server.n
if %ERRORLEVEL% NEQ 0 pause
