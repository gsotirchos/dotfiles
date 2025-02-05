# original: https://saeedesmaili.com/delete-unwanted-and-duplicated-items-on-1password

main() {
    vault="${1:-"Private"}"
    account="${2:-"HQRXQK6P2FAE7NAAUUQF4ILVG4"}"
    declare -A itemMap
    local id item fields username title urls href website key

    for id in $(op item list --categories Login --vault "$vault" --account "$account" --format=json | jq -r '.[] | select(.id != null) | .id'); do
        item=$(op item get "$id" --vault "$vault" --account "$account" --format=json)  # TIME consuming

        if [[ $item != null ]]; then
            fields=$(echo "$item" | jq -r '.fields')
            if [[ $fields != null ]]; then
                username=$(echo "$fields" | jq -r '.[] | select(.label=="username").value')
            fi
            if [[ $username == http* ]]; then
              op item delete "$id" --archive --vault "$vault" --account "$account"
              echo "$id deleted (url in username)"
            fi

            title=$(echo "$item" | jq -r '.title')
            if [[ "$title" =~ \(.*\)$ ]]; then
                fixed_title="${title% (*)}"
                op item edit "$id" --vault "$vault" --account "$account" .title="$fixed_title" > /dev/null
                echo "$id fixed title from '$title' to '$fixed_title'"
            fi

            urls=$(echo "$item" | jq -r '.urls')
            href=$(echo "$urls" | jq -r '.[0].href')
            website=$(echo "$href" | awk -F[/:] '{print $4}')
            if [[ -n $website && -n $username ]]; then
                key="$website-$username"

                if [[ ${itemMap[$key]} ]]; then
                    echo "Duplicate found:"
                    echo "  Item 1: id: ${itemMap[$key]}, username: $username, website: $website"
                    echo "  Item 2: id: $id, username: $username, website: $website"
                    op item delete "$id" --archive --vault "$vault" --account "$account"
                    echo "$id deleted"
                else
                    itemMap[$key]=$id
                    echo "$id added to itemMap"
                fi
            fi
        fi
    done
}

main "$@"
unset main
