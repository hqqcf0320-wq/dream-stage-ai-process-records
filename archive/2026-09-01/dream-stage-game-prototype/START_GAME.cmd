@echo off
cd /d "%~dp0"
start "Dream Stage Server" /min cmd /c "npm run dev -- --port 4174"
timeout /t 2 /nobreak >nul
start "" "http://localhost:4174/?variant=A&seed=grandpa"
