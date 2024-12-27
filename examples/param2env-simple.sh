#!/bin/bash

# you can try this example by invoking it passing some param :

# cd examples
# bash param2env-simple.sh MODE=Hello  PATCH=1 PREPARE=F
# bash param2env-simple.sh --x 1 MODE=Hello2 PATCH=FALSE PREPARE=0 VER=1.1 MYPARAM=MUVALUE
# bash param2env-simple.sh -p UNKNOW=FALSE PATCH=1

# try also setting PEGASUS_BASH_IMPORT_VERBOSE=0 ; see below.

[[ "$(basename "$PWD")" != examples ]] && echo "you have to 'cd examples' before" && exit 1

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because we are in example dir already:
PEGASUS_BASH_ROOT="$(readlink -f ..)"

declare -A PEGASUS_VALID_ENV_PARAMS=(   [MODE]=upstring [PATCH]=bool   [PREPARE]=bool  [VER]=upstring )
declare -A PEGASUS_VALID_ENV_DEFAULT=(  [MODE]=BB       [PATCH]=TRUE   [PREPARE]=FALSE [VER]=undef )
declare -A PEGASUS_VALID_ENV_HELP=(
    [MODE]="a string"
    [PATCH]="apply path to source code"
    [PREPARE]="set prepare flag"
    [VER]="report Version as target"
)

PEGASUS_BASH_IMPORT_VERBOSE=1 # default is 0, disabled; othewise is the file descriptior to write to (1:stdout)
source $PEGASUS_BASH_ROOT/pegasus-bash.sh param2env log || exit 3

if [ $# == 0 ]; then
	param2env_help_table 2
	log critical "missing parameters"
	exit 0
else
    param2env_process "$@"
    param2env_set_defaults
    # process residual non processed paramams:
    for unprocessed in "${PEGASUS_ENV_PARAMS_NOT_PROCESSED[@]}"; do
	log info unprocessed: $unprocessed
    done

    echo "And yes, i can use them directrly as valid env too:"
    log info "the MODE was $MODE ; the PATCH was $PATCH and PREPARE $PREPARE; finally VER was $VER"
    
fi

