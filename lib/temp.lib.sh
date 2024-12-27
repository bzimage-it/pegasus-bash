# this file can be both "sourced" via bash source command or
# included at the beginning of your script.
# 
# you may also be funny if you include "header.sh" too at the
# very beginning of your script.

################# TEMPORARY FILES + CLEANUP #####################
unset mktemp_stack
declare mktemp_stack=()
# this function execute mktemp(1) passing parameters
# and store filename in order to be clen up at the end of the program.
# first parameter is the variable to write the output of mktemp(1)
# return created file name into WRAP_MKTEMP.
# DO NOT USE THIS FUNCTION AS SUBSHELL LIKE $(wrap_mktemp) !!
WRAP_MKTEMP=
function wrap_mktemp() {
    WRAP_MKTEMP=$(mktemp "$@")
    mktemp_stack+=("$WRAP_MKTEMP")
    # echo "${mktemp_stack[@]}"
}
function cleanup_temp() { 
    local F=
    for F in "${mktemp_stack[@]}"; do 
	rm -rf "$F" 
    done
    mktemp_stack=()
}
