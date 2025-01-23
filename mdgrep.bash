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
set -x
ELEMENT_REGEXP="${1:?}"
REGEXP="${2-''}"
FILE="$(printf '%s\n' "${3:?}" | envsubst)"
VALID_MD_ELEMENTS=('#' '##' '###')
# headings
if [[ ! -f "$FILE" ]] ; then printf '%s\n' "${SCRIPT_NAME} | file doesn't exist" ; exit 1 ; fi

for element in "${VALID_MD_ELEMENTS[@]}" ; do
    if [[ "$ELEMENT_REGEXP" =~ ^"$element"\w* ]] ; then printf '%s\n' "${SCRIPT_NAME} | ELEMENT_REGEXP is not a valid element" ; exit 1 ; fi
done

case "$ELEMENT_REGEXP" in 
    *[[:alnum:]]*) 
        result="$(grep -Poz "(?ms)^${ELEMENT_REGEXP}\s?.*?(?=^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+|\Z)" "$FILE" \
        | tr '\0' '\n' \
        | sed "1d" )"
#        result="${result//$'\0'/$'\n'}"
#        result="${result##*$'\n'}"

        result="${result:?"the specified ${ELEMENT_REGEXP} header is not found in ${FILE}"}"
    ;;
    *)
        result="$(grep -Po "^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+$" "$FILE")"
        result="${result:?"${ELEMENT_REGEXP} headers are not found in ${FILE}"}"
    ;;
esac

if [[ -n "$REGEXP" ]] ; then result="$( grep "$REGEXP" <<< "$result")" ; fi

printf '%s\n' "$result"

exit 0 
