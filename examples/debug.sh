#!/bin/bash

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:

# set only if not defined already (suitable for double call, see above)
PEGASUS_BASH_ROOT="$(readlink -f ..)"

PEGASUS_BASH_IMPORT_VERBOSE=0 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh debug

func1() {
    local level=$1
    echo "this is func at level$level"
    bash_stack_trace
    [[ $level == 0 ]] && return $level
    let level-=1
    func2 $level
    return 0
}
func2() {
    func1 $1
}

echo "CALL 0"
func2 0
echo "CALL 1"
func2 1
echo "CALL 6"
func2 6

unix_stack_trace

assert  '[[ $(func 0) ]]'  "successful" || echo "internal error"
assert  '[[ 0 == 0 ]]'  "successful" || echo "internal error"
assert  '[[ -d /tmp ]]'  "successful" || echo "internal error"
assert  '[[ 1 == 0 ]]'  "expected error 1" || echo "error OK"
assert  '[[ ! -d /tmp ]]'  "expected error 2" || echo "error OK "




















