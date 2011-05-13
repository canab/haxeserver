@echo off
tskill neko
cd server\bin
%NEKO_INSTPATH%\neko server.n
if %ERRORLEVEL% NEQ 0 pause
