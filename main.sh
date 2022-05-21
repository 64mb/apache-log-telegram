#!/bin/bash

LOG_FILE=$1
TG_BOT_TOKEN=""
TG_CHAT_ID=""

TG_TIME="10"
TG_URL="https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage"

AWK_BY_TIME=$(awk -vDate2=$(date -d'now' +[%d/%b/%Y) -vDate=$(date -d'now-1 minutes' +[%d/%b/%Y:%H:%M:%S) '$5 >= Date && substr($5,1,12) == Date2 {printf $2; printf " "$10" ";for(i=13;i<=NF;i+=1)printf $i" ";printf "\n"}' $LOG_FILE)

AWK_RESULT=$(printf "$AWK_BY_TIME" | awk '{print $1}' | sort | uniq -c | sort -n | tail -n 10 | sort -n -r)

OUT_RESULT=""
# DEBUG_RESULT=""

IFS=$'\n'
for LINE in $AWK_RESULT; do
    COUNT=$(echo "$LINE" | awk '{print $1}')
    IP=$(echo "$LINE" | awk '{print $2}')

    SEED=$(printf "$AWK_BY_TIME" | grep $IP)
    AGENTS=$(printf "$SEED" | awk '{for(i=3;i<=NF;i+=1)printf $i" ";printf "\n"}' | sed 's/"//g' | sort | uniq)
    AGENTS=$(echo -e "$AGENTS" | sed ':a;N;$!ba;s/\n/%0A   /g')
    CODES=$(printf "$SEED" | awk '{print $2}' | sort | uniq)

    CODES=$(echo $CODES | sed 's/ /  /g')

    OUT_RESULT="$OUT_RESULT""$COUNT""   ""$IP""%0A   ""$AGENTS""%0A""$CODES""%0A%0A"
    #     DEBUG_RESULT="$DEBUG_RESULT""$COUNT""   ""$IP""\n   ""$AGENTS""\n   ""$CODES""\n\n"
done

TG_TEXT="$1""$OUT_RESULT"

#echo -e "$DEBUG_RESULT"

curl -s --max-time $TG_TIME -X POST "$TG_URL" \
    -d chat_id="$TG_CHAT_ID" \
    -d disable_web_page_preview="1" \
    -d text="$TG_TEXT" >/dev/null
