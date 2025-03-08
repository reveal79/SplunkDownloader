#!/bin/bash
# code used for the article https://olivontech.com/en/posts/splunk/download-splunk-without-login/
# inspired from https://gist.github.com/ThinGuy/ee76f181151047267cdb38b7e1c1f1e3
# compatible with bash 4.4+
# you need curl for the dowloads to happen
# if download is interrupted, it will resume where it left off

download-splunk() {

    # Array of Splunk URLS
    echo "⏳ fetching the list of splunk enterprise URLs..."
    local -a SPLUNK_ENTERPRISE_URLS
    mapfile -t SPLUNK_ENTERPRISE_URLS < <(curl -sSlL https://www.splunk.com/en_us/download/splunk-enterprise.html | grep -oP '(?<=data-link=")[^"]+')
    echo "⏳ fetching the list of splunk universal forwarder URLs..."
    local -a SPLUNK_UF_URLS
    mapfile -t SPLUNK_UF_URLS < <(curl -sSlL https://www.splunk.com/en_us/download/universal-forwarder.html | grep -oP '(?<=data-link=")[^"]+')

    local -a ALL_URLS
    ALL_URLS=("${SPLUNK_ENTERPRISE_URLS[@]}" "${SPLUNK_UF_URLS[@]}")

    # Display the array elements to the user
    echo "❓Please choose a value from the following list:"
    for i in "${!ALL_URLS[@]}"; do
        printf "%2d. %s\n" "$((i + 1))" "${ALL_URLS[i]}"
    done

    # Prompt for user selection
    while true; do
        read -rp "Enter the number of your choice (1-${#ALL_URLS[@]}): " choice

        # Validate input
        if ((choice > 0)) && ((choice <= ${#ALL_URLS[@]})); then
            # Adjust for zero-based indexing
            local SELECTED_URL="${ALL_URLS[$((choice - 1))]}"
            local FILENAME="${SELECTED_URL##*/}"
            # Download the file
            echo " ⤵️ Dowloading to current directory: $FILENAME"
            curl -L -O -C - "$SELECTED_URL"
            echo "Downloaded \"$FILENAME\""
            echo "🎉Done, have a great day!"

            break
        else
            echo "❌Invalid selection. Please enter a number between 1 and ${#ALL_URLS[@]}."
        fi
    done
}

download-splunk
