@echo off
tskill neko
cd server\bin
%NEKOPATH%\neko server.n
if %ERRORLEVEL% NEQ 0 pause
