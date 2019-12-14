############################
# Sampath Kunapareddy      #
# sampath.a926@gmail.com   #
############################
#!/bin/bash
#set -x
clear
HOST=`hostname`
OUT="./${HOST}_ports_output.txt"
ALLPORTOUT="./${HOST}_allports.txt"
WHITELIST_RES="./${HOST}_whitelist"
>|${OUT}
>|${ALLPORTOUT}
>|${WHITELIST_RES}
CLEANUP() {
   rm ./${OUT} 2>/dev/null
   rm ./${ALLPORTOUT} 2>/dev/null
   rm ./${WHITELIST_RES} 2>/dev/null
}
CLEANUP
echo "USER,PID,PORTs,PROCESS,," | tee -a ${OUT}
PIDS=`netstat -atulpn 2>/dev/null |grep -i LISTEN |grep -v "-" |awk -F "/" '{print $(NF-1)}' |awk '{print $NF}' |sort -u |grep -v ^$`
PIDs=$(for pid in $PIDS; do echo $pid | grep '^[0-9]'; done)
for PIDD in $PIDs; do
   EACHPID=$PIDD
   PROCESS=$(echo `netstat -atulpn 2>/dev/null |grep -i LISTEN |grep -v "-" |grep -w ${PIDD} |cut -d / -f2 |sort -u |grep -v ^$`)  
   ALLPORTS=`netstat -tulpn 2>/dev/null |grep -i LISTEN |grep -v "-" |grep $EACHPID |awk '{print $4}' |awk -F ':' '{print $NF}' |grep -v ^$ |awk '{$1=$1;print}' |xargs -n1 |sort -u |xargs`
   EACHPROC=$(ps -ef | awk -v EAP="$EACHPID" '$2 == EAP {print $0}' | grep -v ^$ | awk '{$1=$1;print}')
   PROC_USER=$(echo $EACHPROC | awk '{print $1}' | grep -v ^$ | awk '{$1=$1;print}' )
   echo $ALLPORTS >> ${ALLPORTOUT}
   echo "${PROC_USER},${EACHPID},$(echo $ALLPORTS | tr '\n' ' ' |grep -v ^$ |awk '{$1=$1;print}' |xargs -n1 |sort -u |xargs),${EACHPROC},," | tee -a ${OUT}
done
PORTnoPIDs=`netstat -tulpn 2>/dev/null |grep -i LISTEN |grep -w "-" |awk '{print $4}' |awk -F ':' '{print $NF}' |grep -v ^$ |awk '{$1=$1;print}'  |grep -v ^$ |sort -u |tr '\n' ' '`
PORTnoPID=$(for nopid in $PORTnoPIDs; do echo $nopid | grep '^[0-9]' |grep -v ^$ |sort -u |tr '\n' ' '; done)
if [[ ! -z ${PORTnoPID} ]]; then
   echo "NO_USER,NO_PID,${PORTnoPID},NONE,," | tee -a ${OUT}
   echo $PORTnoPID >> ${ALLPORTOUT}
else
   echo "NO_USER,NO_PID,NONE,NONE,," | tee -a ${OUT}
fi
echo "" | tee -a ${OUT}
echo "########,," | tee -a ${OUT}
echo "Summary:,," | tee -a ${OUT}
echo "########,," | tee -a ${OUT}
cat ${ALLPORTOUT} |xargs -n1 |sort -u | tee -a ${OUT}
echo "" | tee -a ${OUT}
echo -e "TOTAL:, \"$(cat ${ALLPORTOUT} |xargs -n1 |sort -u |xargs |wc -w)\", PORTs LISTENING on $HOST,," | tee -a ${OUT}

#################################MODIFYING THE OUTPUT#################################################
OLDIFS=$IFS; IFS=$';'
WHITELISTED_PORTS="sshd,22;sendmail,587 25;strexecd,5026"
  #to whitelist mention as "uniq-string_1,port_1;uniq-string_2,port_2" - semicolon seperated
  #ex: "sshd,22;strexecd,5026;sshd,22 10711"   for multiple ports with space
for PROCESScPORT in $WHITELISTED_PORTS; do    
  cPROCESS=$(echo $PROCESScPORT |cut -d , -f1)
  cPORT=$(echo $PROCESScPORT |cut -d , -f2 |xargs -n1 |sort -u |xargs); cPORTS=$(echo "$cPORT $cPORTS" | awk '{$1=$1;print}')
  cNUM=$(echo $PROCESScPORT |cut -d , -f2 |wc -w)
  cALLPORTS=$(cat ${OUT} |grep -w $cPROCESS |awk -F , '{print $3}'|xargs -n1 |sort -u |xargs)
  cALLPORTSCOUNT=$(echo $cALLPORTS |wc -w)
  if [[ $(cat ${OUT} | grep -w "$cPROCESS" | wc -l) == 1 ]]; then
    if [[ $cALLPORTSCOUNT == $cNUM ]] && [[ $cALLPORTS == $cPORT ]]; then
	  cPRO=$(cat ${OUT} |grep -w "$cPROCESS" |awk -F "," '{print $(NF-2)}')
	  num=$(cat -n ${OUT} | grep -w "$cPROCESS" | awk '{print $1}')
	  sed -i ${num}d ${OUT}
      echo "PORTs,-,${cPORT},for ${cPROCESS} are WHITELISTED - ${cPRO},," >> ${WHITELIST_RES}
    fi
  fi
done
IFS=$OLDIFS
########################################CAPTURING SYSTEMD#################################################
if [[ $(cat ${OUT} | grep -w "systemd" | wc -l) == 1 ]]; then
  cSUMMARY=$(cat ${OUT} | grep -v systemd | awk -F , '{print $3}' | grep [0-9] | grep -v [a-z] | xargs -n1 |sort -u |xargs)
  cSUMMARY=$(echo "$cPORTS $cSUMMARY" | xargs -n1 |sort -u |xargs)
  cSYSTEMD=$(cat ${OUT} | grep -w systemd | awk -F , '{print $3}')
  cPRO=$(cat ${OUT} |grep -w systemd |awk -F "," '{print $(NF-2)}')
  for u in $cSYSTEMD ; do 
    OPD=$(echo $cSUMMARY | grep -w $u) #if grep result empty new port found
    if [[ -z $OPD ]]; then pSYSTEMD=$(echo "$u $pSYSTEMD" | awk '{$1=$1;print}'); else zSYSTEMD=$(echo "$u $zSYSTEMD" | awk '{$1=$1;print}'); fi
  done
  if [[ $(echo $pSYSTEMD | wc -w) -eq 0 ]]; then
    num=$(cat -n ${OUT} | grep -w systemd | awk '{print $1}')
    sed -i ${num}d ${OUT}
    echo "PORTs,-,${cSYSTEMD},for ${cPROCESS} are WHITELISTED - ${cPRO},," >> ${WHITELIST_RES}
  else 
    sed -i "s/$cSYSTEMD/$pSYSTEMD/g" ${OUT}
    echo "PORTs,-,${zSYSTEMD},for ${cPROCESS} are WHITELISTED - ${cPRO},," >> ${WHITELIST_RES}
  fi
fi
############################################################################################################
if [[ -f ${WHITELIST_RES} ]]; then
  echo " " >> ${OUT}
  cat ${WHITELIST_RES} >> ${OUT}
fi

cat ${OUT} >| "./${HOST}_ports_and_process_output.txt"
CLEANUP

