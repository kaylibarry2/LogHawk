!/bin/bash

#constant file paths
AUTH_LOG=project_auth_log.txt
#AUTH_LOG=/var/log/auth.log
#SYSLOG=/var/log/syslog
SYSLOG=project_app_log.txt
THRESHOLD=10
#CRON=/etc/crontab
CRON=project_system_log.txt
SAFE_SCRIPTS="^networkd-dispatcher$|^VBoxService$|^unattended-upgrade$|^LogHawk\.sh$|.*backup\.py$|.*cleanup\.py$|bash$"
TRAFFIC=project_access_log.txt
#TRAFFIC=/var/log/apache2/access.log
IP_THRESHOLD=3
TEMP_LOG=$(mktemp)
MONITOR=LogHawk.txt
ALERTS=LogHawkAlerts.txt





#checking too many failed logins
check_failed_logins() {
#grabbing all Failed password from log,grabbing the IP address from found lines, sorting, counting unique entries,
#chekcing which are above 3 failed attempts, sorting so the most frequent is top, printing to alerts
        sudo grep -E "Failed password" "$AUTH_LOG" \
        | awk '{for (i=1; i<=NF; i++) if ($i=="from") print $(i+1)}' \
        | sort \
        | uniq -c \
        | awk '$1 >= 3' \
        | sort -nr \
        | awk '{print $1 " Failed logon attempts from " $2}' >> "$ALERTS"
}

#chekcing for system errors
check_system_errors() {
#getting error messages from logs and counting them
        ERRORS=$(grep -E "ERROR" "$SYSLOG" \
        | wc -l )
#counting logs with critical messages
        CRITICALS=$(grep -E "CRITICAL" "$SYSLOG" \
        | wc -l )
#totalling them 
        TOTALS=$((ERRORS + CRITICALS))
#giving results to alerts file
        echo "$ERRORS Errors" >> "$ALERTS"
        echo "$CRITICALS Critical Alerts" >> "$ALERTS"
#if alerts are more than 5 sending an alert that there are too many
        if [ "${TOTALS:-0}" -gt 5 ]; then
                echo "High number of system issues : $TOTALS total." >> "$ALERTS"
        fi
}
check_scripts() {
#while  loop for file
        while read -r line; do
#only scan cron entries
                if echo "$line" | grep -q 'CRON.*CMD'; then
#get username
                        USER=$(echo "$line" | awk -F '[()]' '{print $2}')
#get script
                        SCRIPT=$(echo "$line" | grep -Eo '[^ ]+\.(sh|py)')
#skip trusted root scripts
                        if [[ "$USER" == "root" ]] && echo "$SCRIPT" | grep -qE "$SAFE_SCRIPTS"; then
                                continue
                        fi
                        echo "Suspicous cron job: $line" >> "$ALERTS"
                fi
        done < "$CRON"
}

# Checking traffic for IP threshold
check_traffic() {
#gets the first field from each log, sorts, counts duplicates, filters IPs that exceed a threshold
        awk '{print $1}' "$TRAFFIC" \
        | sort \
        | uniq -c \
        | awk -v threshold="$IP_THRESHOLD" '$1 >= threshold {print $1 " requests from IP " $2 ". This is over the threshold."}' \
        >> "$ALERTS"
}




#checking what needs to be monitored from LogHawk.txt
info=$(tail -n 1 "$MONITOR")
checks="${info#*here: }"
echo "$checks"

#if input is all 

if [ "$checks" = "All" ] ; then
        check_failed_logins
       check_system_errors
       check_scripts
       check_traffic
fi
#if input includes script scanning
if echo "$checks" |grep -q "SSA";then
        check_scripts
fi
#if input includes failed login checks

if echo "$checks" |grep -q "TFL";then
        check_failed_logins
fi
# if input includes system error check
if echo "$checks" |grep -q "UTS";then
        check_traffic
fi
# if input includes traffic scanning
if echo "$checks" |grep -q "CTS";then
        check_system_errors
fi



