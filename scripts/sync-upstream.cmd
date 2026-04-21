@echo off
REM Sync upstream reference repo (shrimbly/node-banana) -> origin/develop (Windows)
REM Usage:
REM   scripts\sync-upstream.cmd            -- check + push
REM   scripts\sync-upstream.cmd --check    -- only show diff

bash "%~dp0sync-upstream.sh" %*
