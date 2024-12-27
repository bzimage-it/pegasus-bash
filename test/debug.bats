#!/usr/bin/env bats

PEGASUS_BASH_IMPORT_VERBOSE=1
export PEGASUS_BASH_ROOT="$(readlink -f .)"

test ! -d test && echo "bats test suite shall be executed from main directory; a 'test' directory was expected here" && exit 1


funcXYZ() {
    local level=$1
    n=$(bash_stack_trace | grep funcXYZ | wc -l)
    echo "this is func at level$level with n=$n"
    [[ $level == 0 ]] && return $n
    let level-=1
    funcXYZ $level
    return $n
}

@test "basic bash_stack" {
    source "$PEGASUS_BASH_ROOT"/pegasus-bash.sh debug || exit 3
    bats_require_minimum_version 1.5.0
    
    PEGASUS_DEBUG_OUTPUT=1
    run -1 funcXYZ 0
    [[ "$output" =~ level0 ]]
    [[ ! "$output" =~ level1 ]]

    run -2 funcXYZ 1
    [[ "$output" =~ level0 ]]
    [[ "$output" =~ level1 ]]
    [[ ! "$output" =~ level2 ]]    

    run -5 funcXYZ 4
}

@test "unix_stack" {
    source "$PEGASUS_BASH_ROOT"/pegasus-bash.sh debug || exit 3
    bats_require_minimum_version 1.5.0
    PEGASUS_DEBUG_OUTPUT=1

    run -0 unix_stack_trace
    [[ $output =~ $$ ]]
    [[ $output =~ debug.bats ]]
    [[ $output =~ 'bats-core/bats' ]]
    [[ $output =~ 'bats-core/bats-exec-suite' ]]
    [[ $output =~ 'bats-core/bats-exec-file' ]]
    [[ $output =~ 'bats-core/bats-exec-test' ]]
}

@test "assertions" {
    source "$PEGASUS_BASH_ROOT"/pegasus-bash.sh log debug || exit 3
    bats_require_minimum_version 1.5.0
    PEGASUS_DEBUG_OUTPUT=1
    run -0 assert  '[[ $(funcXYZ 0) ]]'  "successful" 
    run -0 assert  '[[ 0 == 0 ]]'  "successful" 
    run -0 assert  '[[ -d /tmp ]]'  "successful" 
    run -1 assert  '[[ 1 == 0 ]]'  "expected error 1" 
    run -1 assert  '[[ ! -d /tmp ]]'  "expected error 2"
}
@test "assertions with abort" {
    source "$PEGASUS_BASH_ROOT"/pegasus-bash.sh log debug || exit 3
    bats_require_minimum_version 1.5.0
    PEGASUS_BASH_ASSERT_ABORT=5
    run -0 assert  '[[ 0 == 0 ]]'  "successful" 
    run -5 assert  '[[ ! -d /tmp ]]'  "expected error 2"
    run -33 assert  '[[ ! -d /tmp ]]'  "expected error 2" 33    
}










