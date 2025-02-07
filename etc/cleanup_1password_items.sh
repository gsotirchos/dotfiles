# original: https://saeedesmaili.com/delete-unwanted-and-duplicated-items-on-1password

main() {
    vault="${1:-"Private"}"
    account="${2:-"HQRXQK6P2FAE7NAAUUQF4ILVG4"}"
    declare -A itemMap
    local id item fields username title fixed_title urls href website key prefixes modified
    prefixes=(
        www
        www1
        m
        com
        org
        web
        api
        app
        nl
        se
        uk
        eu
        es
        dk
        gr
        na
        no
        sso
        my
        mijn
        jouw
        apps
        auth
        oauth
        oauth2
        secure
        connect
        access
        signin
        login
        inloggen
        mygovlogin
        user
        customerlogin
        customerconnect
        career
        careers
        account
        accounts
        identity
        id
        idp
        idmsa
        odc
        play
        start
        shop
        checkout
        store
        mobile
        manage
        applyweb
        cloud
        club
        hub
        community
        help
        press
        books
        data
    )

    for id in $(op item list --categories Login --vault "$vault" --account "$account" --format=json | jq -r '.[] | select(.id != null) | .id'); do
        item=$(op item get "$id" --vault "$vault" --account "$account" --format=json)  # TIME consuming
        if [[ $item == null ]]; then
            echo "$id has no items; skipped"
            continue
        fi

        fields=$(echo "$item" | jq -r '.fields')
        if [[ $fields == null ]]; then
            echo "$id has no fields; skipped"
            continue
        fi

        # delete items with URLs as usernames
        username=$(echo "$fields" | jq -r '.[] | select(.label=="username").value')
        if [[ $username == http* ]]; then
          op item delete "$id" --archive --vault "$vault" --account "$account"
          echo "$id deleted (url in username)"
          continue
        fi

        # delete duplicate items
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
                continue
            else
                itemMap[$key]=$id
                echo "$id added to itemMap"
            fi
        fi

        title=$(echo "$item" | jq -r '.title')
        fixed_title="$title"

        # remove "...(username)" from title
        if [[ "$fixed_title" =~ \(.*\)$ ]]; then
            fixed_title="${fixed_title% (*)}"
        fi

        # use the full website name
        if [[ "$fixed_title" != *.* ]]; then
            fixed_title="$website"
        fi

        # remove prefixes like "www."
        modified=true
        while $modified; do
            modified=false
            for prefix in "${prefixes[@]}"; do
                if [[ "$fixed_title" == "$prefix."* ]]; then
                    fixed_title="${fixed_title#"$prefix."}"
                    modified=true
                    break
                fi
            done
        done

        if [[ "$title" != "$fixed_title" ]]; then
            op item edit "$id" --vault "$vault" --account "$account" .title="$fixed_title" > /dev/null
            echo "$id fixed title from '$title' to '$fixed_title'"
        fi
    done
}

main "$@"
unset main
