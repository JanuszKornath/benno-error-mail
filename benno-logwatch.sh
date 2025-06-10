#!/bin/bash

LOGFILE="/var/log/benno/archive.log"
STATEFILE="/var/log/benno/.archive_log.lastpos"
PATTERN="ERROR|Exception|failed"
MAILTO="host@tld"

# STATEFILE prüfen, wenn nicht vorhanden, mit 0 initialisieren
if [ ! -f "$STATEFILE" ]; then
    echo 0 > "$STATEFILE"
fi

# Letzte bekannte Zeile holen, Default 0 wenn leer/ungültig
if [[ -s "$STATEFILE" && "$(<"$STATEFILE")" =~ ^[0-9]+$ ]]; then
    LAST_LINE=$(cat "$STATEFILE")
else
    LAST_LINE=0
fi

TOTAL_LINES=$(wc -l < "$LOGFILE")

if [[ "$TOTAL_LINES" =~ ^[0-9]+$ ]] && [ "$TOTAL_LINES" -gt "$LAST_LINE" ]; then
    NEW_LINES=$(tail -n +"$((LAST_LINE + 1))" "$LOGFILE")
    ERRORS=$(echo "$NEW_LINES" | grep -E "$PATTERN")

        if [ -n "$ERRORS" ]; then
        echo "$ERRORS" | mail -s "⚠️ Benno MailArchiv Fehler erkannt auf $(hostname)" "$MAILTO"
    fi

    echo "$TOTAL_LINES" > "$STATEFILE"
fi
