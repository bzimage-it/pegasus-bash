#!/bin/bash

[[ "$(basename "$PWD")" != examples ]] && echo "you have to 'cd examples' before" && exit 1

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:
PEGASUS_BASH_ROOT="$(readlink -f ..)"

# define a model for the command line, declare names, types, default values and help:
declare -A PEGASUS_VALID_ENV_PARAMS=(   [A]=upstring [SOMEBOOL]=bool   [ANOTHERBOOL]=bool  [Directory]=dir [File]=file)
declare -A PEGASUS_VALID_ENV_DEFAULT=(  [A]=avalue   [SOMEBOOL]=TRUE   [ANOTHERBOOL]=FALSE [Directory]=.   [File]=)
declare -A PEGASUS_VALID_ENV_HELP=(
    [A]="a string"
    [SOMEBOOL]="an example of bool param: YES|Y|1|T|TRUE or 0|N|NO|F|FALSE"
    [ANOTHERBOOL]="another bool param"
    [Directory]="an existing directory"
    [File]="an existing file"
)

PEGASUS_BASH_IMPORT_VERBOSE=1 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh all

PEGASUS_BASH_ASSERT_ABORT=5
set -u
# configure your 'traps' to exit cleanly:
trap on_exit EXIT QUIT

# configure your own 'on_exit' function. dont forget to call cleanup_temp()
function on_exit() {
    cleanup_temp
    
    # some other code here:
    # ...

    bash_stack_trace debug
    unix_stack_trace debug
}

log_conf mode default
log notif "full name    : $PEGASUS_SCRIPT_FULL"
log notif "canonical dir: $PEGASUS_SCRIPT_DIR"
log notif "my name is   : $PEGASUS_SCRIPT_FILE"
log_conf mode debug-full
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
    if [ ${#PEGASUS_ENV_PARAMS_NOT_PROCESSED[@]} -eq  0 ]; then
	log info "No extra params, ok"

	wrap_mktemp 
	tmp=$WRAP_MKTEMP
	assert '[[ -f $tmp ]]' "file do not exists any more!" 3	
	assert '[[ $Directory == "/tmp" ]]' "Directory is not /tmp, abort" 6
	
    else
	log error "some parameter is unknown ${PEGASUS_ENV_PARAMS_NOT_PROCESSED[@]}"
	abort 10 "exit the script"
    fi
fi












