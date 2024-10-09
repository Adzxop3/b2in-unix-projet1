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
