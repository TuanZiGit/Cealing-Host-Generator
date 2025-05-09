#!/bin/bash

SOURCES="Cealing-Source.txt"
OUTPUT="Cealing-Host.json"

declare -a RESULTS
WARNINGS=0

is_local() {
    local ip="$1"
    if ipcalc-ng --all-info "$ip" | grep -qiE 'Address Class: (Loopback|Link-scoped|Unique Local|Private)'; then
        return 0
    fi
    return 1
}

resolve_ip() {
    local domain="$1"
    local sni="$2"
    local ip=""

    v4_records=$(dig +noall +answer A "$domain" | awk '$4=="A"{print $5}')
    while read -r record; do
        if [ -n "$record" ] && ! is_local "$record"; then
            ip="$record"
            break
        fi
    done <<< "$v4_records"

    if [ -z "$ip" ]; then
        v6_records=$(dig +noall +answer AAAA "$domain" | awk '$4=="AAAA"{print $5}')
        while read -r record; do
            if [ -n "$record" ] && ! is_local "$record"; then
                ip="$record"
                break
            fi
        done <<< "$v6_records"
    fi

    if [ -n "$ip" ]; then
        RESULTS+=$(jq -n --indent 0 --arg d "$domain" --arg i "$ip" --arg s "$sni" '[["\($d)"], if $s=="" then "" else "\($s)" end, "\($i)"]')
    else
        echo "⚠️ Resolve $domain failed : No valid records found." >&2
        ((WARNINGS++))
    fi
}

main() {
    local sources="$1"
    local output="${2:-Cealing-Host.json}"
    echo "🖋️ Sheas Cealer Host File Generator by @TuanZiGit" >&2
    echo "📝 Result File: $output"
    [ ! -f "$sources" ] && echo "❌ Cannot read source $sources : No such file" >&2 && return 1
    [ ! -r "$sources" ] && echo "❌ Cannot read source $sources : Permission denied" >&2 && return 1
    [ ! -f "$output" ] && (touch "$output" || echo "❌ Cannot write output $output : Permission denied" >&2 && return 1)
    [ ! -w "$output" ] && echo "❌ Cannot write output $output : Permission denied" >&2 && return 1
    while IFS= read -r line; do
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        [ -z "$line" ] && continue

        if [[ "$line" == *":"* ]]; then
            domain="${line%%:*}"
            sni="${line#*:}"
        else
            domain="$line"
            sni=""
        fi
        echo "🔍 Resolving $domain..." >&2
        resolve_ip "$domain" "$sni"
    done < "$sources"

    echo "${RESULTS[@]}" | jq -s '.' --indent 0 > "$output"
    echo "✅ Done" >&2
    [[ $WARNINGS -gt 0 ]] && echo "⚠️ During the process, $WARNINGS warning(s) were found."
    return $WARNINGS
}

main "$SOURCES" "$OUTPUT"
exit $?