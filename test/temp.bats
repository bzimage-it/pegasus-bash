#!/usr/bin/env bats

PEGASO_BASH_IMPORT_VERBOSE=1
export PEGASO_BASH_ROOT="$(readlink -f .)"

test ! -d test && echo "bats test suite shall be executed from main directory; a 'test' directory was expected here" && exit 1

@test "basic temp file" {
    source "$PEGASO_BASH_ROOT"/pegaso-bash.sh temp || exit 3
    wrap_mktemp
    t1=$WRAP_MKTEMP
    [ -f "$WRAP_MKTEMP" ]
    wrap_mktemp -d
    t2=$WRAP_MKTEMP
    [ -d "$WRAP_MKTEMP" ]
    # do not create file really:
    wrap_mktemp -u 
    [ ! -f "$WRAP_MKTEMP" ]
    run -0 cleanup_temp
    [ ! -f "$t1" ]
    [ ! -d "$t2" ]
}








