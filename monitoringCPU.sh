#!/bin/bash
# Run "chmod 775 script.sh" or "chmod +x script.sh" to change permissions!

# Limites de alerta
WARNING_LIMIT=70
CRITICAL_LIMIT=80
LOG_FILE="/var/log/cpu_monitor.log" # Caminho do arquivo de log

NAME_INSTANCE="PROD"
# NAME_INSTANCE="STAGE"
# NAME_INSTANCE="PROD WHITELABEL"
# NAME_INSTANCE="STAGE WHITELABEL"
# NAME_INSTANCE="DATABASE"

# Notificacao Discord
# DISCORD_WEBHOOK="DiSCORD_WEBHOOK_URL"


# Função para verificar o uso da CPU
check_cpu_usage() {
    DATE=$(date)
    # Obtém o uso da CPU (média de todas as CPUs)
    CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print 100 - $NF}')

    # Converte para número inteiro (para facilitar as comparações)
    CPU_USAGE_INT=$(printf "%.0f" "$CPU_USAGE")

    # Avalia os limites
        echo "CRÍTICO: Uso de CPU em $CPU_USAGE_INT%!"
        MESSAGE="CRÍTICO: $NAME_INSTANCE - Uso de CPU em $CPU_USAGE_INT%!"
        echo "$DATE: $MESSAGE" >> $LOG_FILE
        send_notification "$MESSAGE"
    elif [ "$CPU_USAGE_INT" -ge "$WARNING_LIMIT" ]; then
        echo "WARNING: Uso de CPU em $CPU_USAGE_INT%."
        MESSAGE="WARNING: $NAME_INSTANCE - Uso de CPU em $CPU_USAGE_INT%!"
        echo "$DATE: $MESSAGE" >> $LOG_FILE
        send_notification "$MESSAGE"
    else
        echo "OK: Uso de CPU em $CPU_USAGE_INT%."
    fi
}

# Função para enviar notificação ao Discord
send_notification(){
  local MESSAGE="$1"
  echo "$DATE: Enviando notificação para o Discord..."
  curl -d "{\"content\": \"** $MESSAGE **\"}" -H "Content-Type: application/json" "$DISCORD_WEBHOOK"
}

# Executar monitoramento
check_cpu_usage