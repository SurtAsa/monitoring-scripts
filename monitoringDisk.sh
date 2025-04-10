#!/bin/bash
# Run "chmod 775 script.sh" or "chmod +x script.sh" to change permissions!

# Configuracoes
WARNING_THRESHOLD=60  # Percentual de uso do disco para warning
ALERT_THRESHOLD=80    # Percentual de uso do disco para alerta crítico
LOG_FILE="/var/log/disk_usage_monitor.log"  # Caminho do arquivo de log
NAME_INSTANCE="PROD"
# NAME_INSTANCE="STAGE"
# NAME_INSTANCE="PROD WHITELABEL"
# NAME_INSTANCE="STAGE WHITELABEL"
# NAME_INSTANCE="DATABASE"

# Notificacao Discord
# DISCORD_WEBHOOK="DiSCORD_WEBHOOK_URL"

# Função para verificar uso de disco
check_disk_usage() {
    df -h | grep -E '^/dev/' | while read -r line; do
        FILESYSTEM=$(echo $line | awk '{print $1}')
        USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo $line | awk '{print $6}')
        DATE=$(date)

        if [ "$USAGE" -ge "$ALERT_THRESHOLD" ]; then
            MESSAGE="ALERTA CRÍTICO: $NAME_INSTANCE - O sistema de arquivos $FILESYSTEM no ponto de montagem $MOUNT está com $USAGE% de uso."
            echo "$DATE: $MESSAGE" >> $LOG_FILE

            # Envia alerta para o Discord
            send_notification "$MESSAGE"

        elif [ "$USAGE" -ge "$WARNING_THRESHOLD" ]; then
            MESSAGE="WARNING: $NAME_INSTANCE - O sistema de arquivos $FILESYSTEM no ponto de montagem $MOUNT está com $USAGE% de uso."
            echo "$DATE: $MESSAGE" >> $LOG_FILE

            # Envia notificacao de warning para o Discord
            send_notification "$MESSAGE"
        else
            echo "$DATE: $NAME_INSTANCE - O sistema de arquivos $FILESYSTEM está com $USAGE% de uso, dentro dos limites aceitáveis."
        fi
    done
}

# Função para enviar notificação ao Discord
send_notification(){
  local MESSAGE="$1"
  echo "$DATE: Enviando notificação para o Discord..."
  curl -d "{\"content\": \"** $MESSAGE **\"}" -H "Content-Type: application/json" "$DISCORD_WEBHOOK"
}

# Executa a verificação
check_disk_usage
