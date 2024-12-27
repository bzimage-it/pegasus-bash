#!/bin/bash

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:

# set only if not defined already (suitable for double call, see above)
PEGASUS_BASH_ROOT="$(readlink -f ..)"

PEGASUS_BASH_IMPORT_VERBOSE=0 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh debug

func() {
    local level=$1
    echo "this is func at level$level"
    bash_stack_trace
    [[ $level == 0 ]] && return $level
    let level-=1
    func $level
    return 0
}

echo "CALL 0"
func 0
echo "CALL 1"
func 1
echo "CALL 6"
func 6

unix_stack_trace

assert  '[[ $(func 0) ]]'  "successful" || echo "internal error"
assert  '[[ 0 == 0 ]]'  "successful" || echo "internal error"
assert  '[[ -d /tmp ]]'  "successful" || echo "internal error"
assert  '[[ 1 == 0 ]]'  "expected error 1" || echo "error OK"
assert  '[[ ! -d /tmp ]]'  "expected error 2" || echo "error OK "




















