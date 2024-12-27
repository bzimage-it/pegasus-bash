#!/usr/bin/env bats

PEGASO_BASH_IMPORT_VERBOSE=0
export PEGASO_BASH_ROOT="$(readlink -f .)"
test ! -d test && echo "bats test suite shall be executed from main directory; a 'test' directory was expected here" && exit 1

ret=0
source "$PEGASO_BASH_ROOT"/pegaso-bash.sh param2env || ret=$?
test $ret != 0 && echo $ret && exit $ret
test "${PEGASO_BASH_IMPORTED[param2env]}" != 1 && exit 2

tmp=
cmd() {
    VARNAME="$1"
    shift
    local ret=0
    param2env_process "$@" || ret=$?
    eval echo \$$VARNAME
    return $ret
}

@test "basic test positive 1 no default" {
    run -1 param2env_check
    source test/param2env.set-1.sh || exit 1

    run -0 param2env_check
    param2env_process --A A=str
    [ $? == 0 ]
    [ "$A" == "STR" ]
    [ "${PEGASO_ENV_PARAMS_NOT_PROCESSED[0]}" == "--A" ]
}

@test "basic test positive2 with default" {
    run -1 param2env_check    
    source test/param2env.set-1.sh || exit 1
    run -0 param2env_check
    tmp=$(mktemp)
    param2env_process B=A File=$tmp OTHER=X1
    [ $? == 0 ]
    [ -f $tmp ]
    [ "$File" == "$tmp" ]
    [ "${PEGASO_ENV_PARAMS_NOT_PROCESSED[0]}" == "B=A" ]
    [ "${PEGASO_ENV_PARAMS_NOT_PROCESSED[1]}" == "OTHER=X1" ]
    [ -z "$S" ]    
    param2env_set_defaults
    [ "$S" == '__undef__' ]
    rm $tmp
    # fails because the file do not exists:
    run -1 param2env_process B=A File= $tmp OTHER=X1
    tmp=$(mktemp)
    param2env_process B=A File= $tmp OTHER=X2 
    [ "$File" == "$tmp" ]
    [ "$S" == "__undef__" ]
    [ "${PEGASO_ENV_PARAMS_NOT_PROCESSED[0]}" == "B=A" ]
    [ "${PEGASO_ENV_PARAMS_NOT_PROCESSED[1]}" == "OTHER=X2" ]
}

@test "basic test positive 2 no default 2: Dir+File" {
    run -1 param2env_check
    source test/param2env.set-1.sh || exit 1
    param2env_check
    tmp=$(mktemp)
    # fails because the dir do not exists:
    dtmp=$(mktemp -d)
    param2env_process Directory=$dtmp File=$tmp OTHER=X
    [ "$Directory" == "$dtmp" ]
    [ -d $dtmp ]
    [ -f $tmp ]
    [ "$File" == "$tmp" ]
}

# more tests needed: TODO









