#!/usr/bin/env bash
set -x
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
ELEMENT_REGEXP="$(echo -e "${1}")"
REGEXP="${2}"
FILE="${3}"
VALID_MD_ELEMENTS=('#' '##' '###')
# headings
[[ -n "$ELEMENT_REGEXP" ]] || { echo "${SCRIPT_NAME} | ELEMENT_REGEXP paramater is empty" ; exit 2; }
[[ -n "$FILE" ]] || { echo "${SCRIPT_NAME} | FILE paramater is empty" ; exit 2; }
[[ -f "$FILE" ]] || { echo "${SCRIPT_NAME} | file doesn't exist" ; exit 2; }

for element in ${VALID_MD_ELEMENTS[@]} ; do
    if [[ "$ELEMENT_REGEXP" =~ "^$element\w*" ]] ; then
        { echo "${SCRIPT_NAME} | ELEMENT_REGEXP is not a valid element" ; exit 2; }
    fi
done

if [[ "$ELEMENT_REGEXP" =~ [[:alnum:]]+ ]] ; then
    result="$(grep -Poz "(?ms)^${ELEMENT_REGEXP}\s?.*?(?=^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+|\Z)" "$FILE" | tr '\0' '\n' | sed "1d" )"
     [[ -n "$result" ]] || { echo "${SCRIPT_NAME} | the specified ${ELEMENT_REGEXP} header is not found in $file" ; exit 1; }

else
    result="$(grep -Po "^${ELEMENT_REGEXP%%[[:alnum:]]*}\s?[^${ELEMENT_REGEXP%%[[:alnum:]]*}]+$" "$FILE")"
     [[ -n "$result" ]] || { echo "${SCRIPT_NAME} | ${ELEMENT_REGEXP} headers are not found in $file" ; exit 1; }
fi
[[ -n "$REGEXP" ]] && result="$( grep "$REGEXP" <<< "$result")"
echo "$result"
exit 0 
