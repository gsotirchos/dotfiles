#!/usr/bin/env bash

#
# ~/dotfiles/bin/ttt
#
# Simple script to convert whitespace separated text to latex table cells.

USAGE="Usage:\n `basename $0` [-hl] source_file"

hline=0

#receive flags
while getopts hl OPTION; do
    case "$OPTION" in
        h)
            echo -e "$USAGE" && exit 0
            ;;
        l)
            hline=1
            ;;
    esac
done
shift "$((OPTIND-1))"

# read input file
if [ $# -ge 1 -a -f "$1" ]; then
    input="$1"
else
    echo -e "$USAGE" && exit 1
fi

## The following sed lines do
## in the following order:
# replace tabs with spaces
# replace multiple spaces with a single one
# replace spaces with <TAB>&<TAB>
# append <TAB> at end of each line
# append \\ at end of each line

output=$( \
    cat $input \
    | sed 's/'$'\t/\ /g' \
    | sed 's/\  */ /g' \
    | sed 's/\ /'$'\t\&\t/g' \
    | sed 's/$/'$'\t/' \
    | sed 's/$/\ \\\\/' \
)

## If the -l option is selected
## then the following sed will:
# insert \hline after each line

if [ $hline = 1 ]; then 
    output=$( \
        echo "$output" \
        | sed 's/$/\'$'\n\\\hline/g' \
    )
fi

echo "$output"
