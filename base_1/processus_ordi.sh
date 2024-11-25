#!/bin/bash


log_file="./processus_ordi.log"


interval=5


log_anomaly() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local anomaly_type=$1
    local pid=$2
    local process_name=$3
    local user=$4
    local details=$5
    local action=$6

    echo "[$timestamp] ANOMALIE DÉTECTÉE : $anomaly_type" >> $log_file
    echo "PID : $pid, Processus : $process_name, Utilisateur : $user" >> $log_file
    echo "Détails : $details" >> $log_file
    echo "Action entreprise : $action" >> $log_file
    echo "===============================" >> $log_file
}

high_cpu_processes=$(ps -eo pid,user,pcpu,comm --sort=-pcpu | awk '$3 > 80')
if [ ! -z "$high_cpu_processes" ]; then
  echo "$(date) - Anomalie détectée : Utilisation CPU élevée" >> ./processus_ordi.log
  echo "$high_cpu_processes" >> ./processus_ordi.log
fi

unauthorized_processes=$(ps -eo pid,user,comm | grep -E 'sshd|apache2|nginx' | awk '$2 != "root"')
if [ ! -z "$unauthorized_processes" ]; then
  echo "$(date) - Anomalie détectée : Processus exécuté par un utilisateur non autorisé" >> ./process_ordi.log
  echo "$unauthorized_processes" >> ./processus_ordi.log
fi
zombie_processes=$(ps -eo stat,pid,comm | grep '^Z')
if [ ! -z "$zombie_processes" ]; then
  echo "$(date) - Anomalie détectée : Processus zombie" >> ./processus_ordi.log
  echo "$zombie_processes" >> ./processus_ordi.log
fi

echo "Quelle action souhaitez-vous entreprendre pour le processus PID $pid (nom : $process_name) ?"
echo "1. Tuer le processus"
echo "2. Baisser la priorité (renice)"
echo "3. Ignorer"
read choice
case $choice in
  1) kill -9 $pid ;;
  2) renice +10 $pid ;;
  3) echo "Aucune action prise" ;;
esac


send_notification() {
    local message=$1
    echo "$message" | mail -s "Alerte de processus suspect" user@example.com
}  

ordi_processus() {
    echo "===============================" >> $log_file
    echo "Processus de l'ordinateur Log - $(date)" >> $log_file
    echo "===============================" >> $log_file
    echo "" >> $log_file
    
    
    ps aux --sort=-%cpu | awk '
    BEGIN { printf "%-8s %-6s %-10s %-6s %-6s %-6s %s\n", "USER", "PID", "CPU%", "MEM%", "VSZ", "RSS", "COMMAND" }
    { printf "%-8s %-6s %-10s %-6s %-6s %-6s %s\n", $1, $2, $3, $4, $5, $6, $11 }
    ' >> $log_file

    echo "" >> $log_file
    echo "===============================" >> $log_file
    echo "" >> $log_file
}


# " Boucle infinie "
while true; do
    ordi_processus
    sleep $interval
done
