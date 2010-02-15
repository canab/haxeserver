@echo off
set ANTPATH=d:\development\ant
%ANTPATH%\bin\ant -lib lib -propertyfile local.properties %1
pause