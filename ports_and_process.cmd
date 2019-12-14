@echo off
rem ############################
rem # Sampath Kunapareddy      #
rem # sampath.a926@gmail.com   #
rem ############################
setlocal disabledelayedexpansion
rem cd %userprofile%\Desktop
cd \ && cd windows && D:
FOR /F "usebackq" %%h IN (`hostname`) DO SET HOST=%%h
type nul > %HOST%_netstat_results.txt
type nul > %HOST%_pid_results.txt
type nul > %HOST%_uniq_pid_results.txt
type nul > %HOST%_pid_path_results.txt
netstat -anob | FINDSTR LISTEN > %HOST%_netstat_results.txt
rem "Protocal  LocalAddress ForeignAddress    State   PID"
for /f "tokens=5" %%a in (%HOST%_netstat_results.txt) do echo %%a >> %HOST%_pid_results.txt
set "prev="
for /f "delims=" %%F in ('sort %HOST%_pid_results.txt') do (
  set "curr=%%F"
  setlocal enabledelayedexpansion
  if "!prev!" neq "!curr!" echo !curr!
  endlocal
  set "prev=%%F"
) >> %HOST%_uniq_pid_results.txt
for /F "usebackq tokens=*" %%A in (%HOST%_uniq_pid_results.txt) do (
  echo. >> %HOST%_pid_path_results.txt
  echo XXXX >> %HOST%_pid_path_results.txt
  echo %%A >> %HOST%_pid_path_results.txt
  wmic process where processId=%%A get ExecutablePath | FINDSTR /V ExecutablePath | FINDSTR /R "." >> %HOST%_pid_path_results.txt
  rem "Image Name"  "PID"  "Session Name"   "Session#"   "Mem Usage" "Status"  "User Name"    "CPU Time"  "Window Title"
  tasklist /V /FI "PID eq %%A" | FINDSTR %%A | FINDSTR /R "." >> %HOST%_pid_path_results.txt
  rem FOR /F "tokens=1" %%B IN ('tasklist /V /FI "PID eq %%A" ^| FINDSTR %%A') DO ECHO %%B >> %HOST%_pid_path_results.txt
  echo ZZZZ >> %HOST%_pid_path_results.txt
)
rem %HOST%_del netstat_results.txt
del %HOST%_pid_results.txt
del %HOST%_uniq_pid_results.txt
rem %HOST%_del pid_path_results.txt