echo off

for %%x in (%*) do (
  PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%CD%\split_on_landscape_portrait.ps1' -FolderPath '%%x'"
)

PAUSE
