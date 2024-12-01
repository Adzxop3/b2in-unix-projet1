#!/bin/bash

log_file="./processus_ordi.log"
interval=5
# Fonction qui permet d'enregistrer une anomalie dans le fichier log
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
    echo "$message" | mail -s "Alerte de processus suspect" exemple@exemple.com
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

# " Boucle infinie " qui surveille en permanence les processus
while true; do
    ordi_processus

    # Surveillance des process pour chaque 'domain', celui ci, les processus qui utilisent plus de 80% du CPU
    high_cpu_processes=$(ps -eo pid,user,pcpu,comm --sort=-pcpu | awk '$3 > 80')
    if [ ! -z "$high_cpu_processes" ]; then
        log_anomaly "Utilisation CPU élevée" "$high_cpu_processes"
        send_notification "Anomalie détectée : Utilisation CPU élevée pour le processus : $high_cpu_processes"
    fi

    unauthorized_processes=$(ps -eo pid,user,comm | grep -E 'sshd|apache2|nginx' | awk '$2 != "root"')
    if [ ! -z "$unauthorized_processes" ]; then
        log_anomaly "Processus exécuté par un utilisateur non autorisé" "$unauthorized_processes"
        send_notification "Anomalie détectée : Processus non autorisé : $unauthorized_processes"
    fi

    zombie_processes=$(ps -eo stat,pid,comm | grep '^Z')
    if [ ! -z "$zombie_processes" ]; then
        log_anomaly "Processus zombie" "$zombie_processes"
        send_notification "Anomalie détectée : Processus zombie : $zombie_processes"
    fi

    # Demander l'action à entreprendre pour les processus suspects
    read -p "Entrez le PID du processus suspect pour l'action (ou tapez 'skip' pour ignorer) : " pid
    if [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "Quelle action souhaitez-vous entreprendre pour le processus PID $pid ?"
        echo "1. Tuer le processus"
        echo "2. Baisser la priorité (renice)"
        echo "3. Ignorer"
        read -p "Votre choix (1/2/3) : " choice
        case $choice in
            1) kill -9 "$pid" && log_anomaly "Processus tué" "$pid" "N/A" "N/A" "N/A" "Processus terminé" ;;
            2) renice +10 "$pid" && log_anomaly "Priorité réduite" "$pid" "N/A" "N/A" "N/A" "Priorité du processus réduite" ;;
            3) echo "Aucune action prise" ;;
            *) echo "Choix invalide." ;;
        esac
    elif [ "$pid" == "skip" ]; then
        echo "Aucune action entreprise."
    else
        echo "Erreur : Le PID doit être un nombre entier."
    fi

    sleep $interval
done

