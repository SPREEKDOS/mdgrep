#!/usr/bin/env bash
########################
# NAME
#       mdgrep
# SYNOPSIS
#       mdgrep ELEMENT_REGEXP REGEXP FILE
# DESCRIPTION
#       mdgrep grep certain element or their content from .md file using regexp   
# EXIT STATUS
#       0 if patterns matched
#       1 if no pattern matched
#       2 if an error occured
#######################
#TODO line 34: warning: command substitution: ignored null byte in input

# shell options
set -o xtrace

# variable
USAGE=
ELEMENT_REGEXP="${1:?}"
FILE="$( envsubst <<< "${2:?}" )"
VALID_MD_ELEMENTS=('#' '##' '###')

# function 
usage() { 
    printf '%s\n' "usage: ${SCRIPT_NAME} ELEMENT_REGEXP FILE \
    options: 
-r REGEXP" 
    exit 0 
}

while getopts "r:h" OPTS
do
    case ${OPTS} in
        r)
            REGEXP="${OPTARG:?}"
            ;;
        *|h)
            usage
            ;;
    esac
done
#shift $(($OPTIND - 1))

# logic
if [[ "$#" -eq 0  ]] ; then usage ; fi
if [[ ! -f "$FILE" ]] ; then printf '%s\n' "${SCRIPT_NAME} | file doesn't exist" ; exit 1 ; fi
for element in "${VALID_MD_ELEMENTS[@]}" ; do
    if [[ "$ELEMENT_REGEXP" =~ ^"$element"[[:alnum:]]* ]] ; then 
        break
    else 
        printf '%s\n' "${SCRIPT_NAME} | ELEMENT_REGEXP is not a valid element"
        exit 1 
    fi
done

case "$ELEMENT_REGEXP" in 
    *[[:alnum:]]*) 
        result="$(grep --perl-regexp \
        --only-matching \
        --null-data \
        "(?ms)^${ELEMENT_REGEXP}\s?.*?(?=^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+|\Z)" "$FILE" )"
        result="${result//$'\0'/$'\n'}"
        result="${result#*$'\n'}"

        result="${result:?"the specified ${ELEMENT_REGEXP} header is not found in ${FILE}"}"
    ;;
    *)
        result="$(grep --perl-regexp \
        --only-matching \
        "^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+$" "$FILE")"
        result="${result:?"${ELEMENT_REGEXP} headers are not found in ${FILE}"}"
    ;;
esac

if [[ -n "$REGEXP" ]] ; then result="$( grep "$REGEXP" <<< "$result")" ; fi

printf '%s\n' "$result"

exit 0 
