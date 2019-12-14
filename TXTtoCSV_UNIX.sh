############################
# Sampath Kunapareddy      #
# sampath.a926@gmail.com   #
############################
#!/bin/bash
#set -x
#mkdir -p /tmp/port_results
#rm /tmp/port_results/* &>/dev/null
clear
RandD="/opt/sw/prd_middleware/MWDev_Test/MWDev_TEAM_CHECKOUT/unused_ports_services/UNIX/results"
if [[ ! -z $(ls *_ports_and_process_output.txt 2>/dev/null) ]]; then
  RandD="/opt/sw/prd_middleware/MWDev_Test/MWDev_TEAM_CHECKOUT/unused_ports_services/UNIX/results"
  mkdir -p processed_files
  mkdir -p $RandD
  mkdir -p $RandD/old 
  mv $RandD/*.csv $RandD/old &>/dev/null
  for i in $(ls *_ports_and_process_output.txt); do
    j=$(echo $i | cut -d '_' -f1)
    cp $i ${j}.csv
    mv $i processed_files 
    #cp $i /tmp/port_results/${j}.csv
    #chmod -R 777 /tmp/port_results
    echo -e "\nWorking on \e[1m${j}\e[0m:"
    echo -e "\n\e[1mDone... please check \"${j}.csv\" file.\n\t \'$i\' moved under ./processed_files dir...\e[0m"
    sleep 1
  done
  echo -e "\n##########################################################\n"
  #mv *.csv $RandD 2>/dev/null 
  #echo -e "\n\e[1mMoved *.csv under - \"$RandD\"\e[0m\n"
  #for i in $(ls $RandD/*.csv); do
  #  echo ""
  #  unix2dos $i
  #done 
  echo ""
  #TMPOUT=`ls $RandD`
  TMPOUT=`ls *.csv`
  echo $TMPOUT | tr ' ' '\n'
  echo ""
  sleep 3
else
  sleep 2
  echo -e "\n\nNO Output files present to Convert...\n\tPlease check and re-run...\n"
  #for file in $(ls $RandD/*.csv); do
  #  echo ""
  #  unix2dos $file
  #done
  #sleep 2
  #TMPOUT=`ls $RandD`
  #echo -e "\n\e[1m*.csv files under - \"$RandD\"\e[0m"
  #echo $TMPOUT | tr ' ' '\n'
  #echo ""
fi
