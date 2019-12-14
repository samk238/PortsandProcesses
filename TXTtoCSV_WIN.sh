#!/bin/bash
#set -x
clear
if [[ $(ls [DW]*_results.txt 2>/dev/null | wc -l) -ge 2 ]]; then
  for SERVER in $(ls [DW]*_pid_path_results.txt [DW]*_netstat_results.txt 2>/dev/null | cut -d "_" -f1 | sort -u); do
  #SERVER=$(echo $WSERVER | cut -d "_" -f1)
  NETSTAT_RES=${SERVER}_netstat_results.txt
  PID_PATH_RES=${SERVER}_pid_path_results.txt
  if [[ -f $NETSTAT_RES ]] && [[ -f $PID_PATH_RES ]]; then
    RandD="/opt/sw/prd_middleware/MWDev_Test/MWDev_TEAM_CHECKOUT/unused_ports_services/WINDOWS/results"
    mkdir -p processed_files
    mkdir -p $RandD
    mkdir -p $RandD/old
    mv $RandD/*.csv $RandD/old  &>/dev/null
    CSV_RES="./${SERVER}.csv"
    echo -e "\nWorking on \e[1m$SERVER:\e[0m\n"
    dos2unix $NETSTAT_RES
    dos2unix $PID_PATH_RES
    echo "USER,PID,PORTS,PROCESS" > $CSV_RES
    ALL_PIDS=$(cat $NETSTAT_RES |awk '{print $NF}' |sort -u |grep -v ^$ |awk '{$1=$1;print}')
    for PID in $ALL_PIDS; do
      ALL_PORTS=$(cat $NETSTAT_RES |grep -w $PID | awk '{print $2}' |awk -F ":" '{print $NF}' |xargs -n1 |sort -u |xargs |awk '{$1=$1;print}')
      PROCESS_NAME=$(cat $PID_PATH_RES |grep -v ^$ |grep -w -A3 "${PID} " |head -3 |tail -1 |awk '{print $1}' |awk '{$1=$1;print}') 
      PROCESS_PATH=$(cat $PID_PATH_RES |grep -v ^$ |grep -w -A3 "${PID} " |head -2 |tail -1 |awk '{$1=$1;print}')
      USID=$(cat $PID_PATH_RES |grep -v ^$ |grep -w -A3 "${PID} " |head -3 |tail -1 |awk '{$1=$1;print}' |cut -d '\' -f2 |xargs -n1 |grep "[a-z]\|[A-Z]" |xargs |awk '{print $1}' |grep "[A-Z][A-Z]")
      DOM=$(cat $PID_PATH_RES |grep -v ^$ |grep -w -A3 "${PID} " |head -3 |tail -1 |awk '{$1=$1;print}' |cut -d '\' -f1 |awk '{print $(NF-1)" "$NF}' |xargs -n1 |grep "[a-z]\|[A-Z]" |xargs)
      if [[ -z $PROCESS_NAME ]]; then PROCESS_NAME=NO_NAME; fi
      if [[ -z $PROCESS_PATH ]]; then PROCESS_PATH=NO_PATH; fi
      if [[ -z $USID ]]; then USER=${DOM}; else USER=$(echo "${DOM}\\${USID}"); fi
      echo "$USER,$PID,$ALL_PORTS,$PROCESS_NAME - $PROCESS_PATH" >> $CSV_RES
    done
    echo -e "\n\t\e[1mDone... please check \"$CSV_RES\" file.\n\tfiles moved under processed dir...\e[0m"
    mv $NETSTAT_RES $PID_PATH_RES processed_files 2>/dev/null
  else
    echo -e "\nPlease verfiy...\n\t\"${SERVER}_netstat_results.txt\" \"${SERVER}_pid_path_results.txt\" files...\n"
  fi
  echo -e "\n##################################################################"
  sleep 2
  done
  #mv *.csv $RandD 2>/dev/null
  #echo -e "\n\nMoved *.csv's under - \"\e[1m$RandD\e[0m\""
  echo ""
  #TMPOUT=`ls $RandD`
  TMPOUT=`ls *.csv`
  echo $TMPOUT | tr ' ' '\n'
  echo ""
  sleep 2
else
  echo -e "\n\e[1mPlease verfiy the existance of...\n\t\"SERVERname_netstat_results.txt\" \"SERVERname_pid_path_results.txt\" file(s) under.... \n\t    `pwd`\n\e[0m"
fi  
