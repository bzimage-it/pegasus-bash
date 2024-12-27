#!/bin/bash

[[ "$(basename "$PWD")" != examples ]] && echo "you have to 'cd examples' before" && exit 1

# PEGASO_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:
PEGASO_BASH_ROOT="$(readlink -f ..)"

declare -A PEGASO_VALID_ENV_PARAMS=(   [A]=upstring [SOMEBOOL]=bool   [ANOTHERBOOL]=bool  [Directory]=dir [File]=file)
declare -A PEGASO_VALID_ENV_DEFAULT=(  [A]=avalue   [SOMEBOOL]=TRUE   [ANOTHERBOOL]=FALSE [Directory]=.   [File]=)
declare -A PEGASO_VALID_ENV_HELP=(
    [A]="a string"
    [SOMEBOOL]="an example of bool param: YES|Y|1|T|TRUE or 0|N|NO|F|FALSE"
    [ANOTHERBOOL]="another bool param"
    [Directory]="an existing directory"
    [File]="an existing file"
)

PEGASO_BASH_IMPORT_VERBOSE=1 # default is 0, do not write info during parse
source $PEGASO_BASH_ROOT/pegaso-bash.sh all

if [ $# == 0 ]; then
    param2env_help_table
    log info
    log info "write again on standar error with a wider format,"
    log info "Note that only first 3 params needs format; DESCRIPTION is appended after"
    log info	 
    param2env_help_table 2 "%-16s  %-13s  %-18s"
    abort 0 "missing parameters"
else
    param2env_process "$@"
    # we do not want to allow any extra parameters
    if [ ${#PEGASO_ENV_PARAMS_NOT_PROCESSED[@]} -eq  0 ]; then
	log info "No extra params, ok"
    else
	abort 10 "some parameter is unknown ${PEGASO_ENV_PARAMS_NOT_PROCESSED[@]}"
    fi
fi












