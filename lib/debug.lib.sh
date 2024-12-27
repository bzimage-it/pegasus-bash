# this file is part of the pegaso-bash
# it is tipically includedd via source bash command

# PEGASO_DEBUG_OUTPUT hold the file descriptor to write debug output to.
# special value "LOG" (default value) uses the PEGASO's log module
PEGASO_DEBUG_OUTPUT=LOG

dumpvar () { for var in "$@" ; do echo "$var=${!var}" ; done }
################# DEBUG AND STACK TRACE #####################
# snipped from : 
# http://stackoverflow.com/questions/685435/bash-stacktrace
_pegaso_debug_print() {
    local level="$1"
    shift
    if [[ ${PEGASO_DEBUG_OUTPUT?} == "LOG" ]]; then
	log "$level" "$@"
    else
	echo "$@" >&${PEGASO_DEBUG_OUTPUT}
    fi
}

unix_stack_trace () { # param is the log level
    local level="$1"
    test -z "$level" && level=debug
    log_level_assert "$level"
    test $? -ge 250 && return 0
    local TRACE=""
    local CP=$$ # PID of the script itself [1]
    local CMDLINE=
    local tmp=
    local PP=
    local platform=$(uname -o)
    while true # safe because "all starts with init..."
    do
        if [ "$CP" == "1" -a "${platform^^}" == 'CYGWIN' ]; then 
	    break
        fi
        CMDLINE=$(cat /proc/"$CP"/cmdline | perl -ne 's/\x00/ /og;print;')
        PP=$(grep PPid /proc/"$CP"/status | awk '{ print $2; }') # [2]
        printf -v tmp "\n%10d   $CMDLINE" "$CP"
        TRACE+="$tmp"
        # $'\n'"   [$CP]:$CMDLINE"
        if [ "$CP" == "1" ]; then # we reach 'init' [PID 1] => backtrace end
	    break
        fi
        CP=$PP
    done
    _pegaso_debug_print "$level" "Unix process backtrace (PID+command line): $TRACE"
    # echo -en "$TRACE" | tac | grep -n ":" # using tac to "print in reverse" [3]	
}
# snipped from : 
# http://stackoverflow.com/questions/685435/bash-stacktrace
bash_stack_trace() { # param is the log level
    local level="$1"
    test -z "$level" && level=debug    
    log_level_assert "$level"
    test $? -ge 250 && return 0    
    local STACK=""
    # to avoid noise we start with 1 to skip get_stack caller
    local i
    local stack_size=${#FUNCNAME[@]}
    for (( i=1; i<$stack_size ; i++ )); do
        local func="${FUNCNAME[$i]}"
        [ "$func" = "" ] && func=MAIN
        local linen="${BASH_LINENO[(( i - 1 ))]}"
        local src="${BASH_SOURCE[$i]}"
        [ "$src" = "" ] && src=non_file_source
        STACK+=$'\n'"   "$func" "$src":"$linen
    done
    STACK+=$'\n';
    _pegaso_debug_print "$level" "STACK TRACE of \$\$=$$ BASHPID=$BASHPID ${STACK}"
}

# PEGASO_BASH_ON_ASSERT define log level on assertion,
# default : error
PEGASO_BASH_ASSERT_LOG_LEVEL=error

# if undefiend or empty do not abort on assert;
# otherwice hold the default exit code on assert (unless given in assert() param itself)
PEGASO_BASH_ASSERT_ABORT=

assert() {
    local command="$1"  # Command or expression to evaluate
    local message="${2:-Assertion failed}"  # Error message (optional)
    local exit_code=${3:-$PEGASO_BASH_ASSERT_ABORT}  # exit code to abort in case of fail; default PEGASO_BASH_ASSERT_ABORT
    
    # Execute the command and capture the result
    if ! eval "$command"; then
        local lineno="${BASH_LINENO[0]}"  # Line number where the error occurred
        local funcname="${FUNCNAME[1]:-main}"  # Name of the calling function
        local filename="${BASH_SOURCE[1]}"  # Source file of the calling script

        # Print error details
	
        log $PEGASO_BASH_ASSERT_LOG_LEVEL "Assertion failed: $message\n\tCommand: $command\n\tLocation: $filename:$lineno in $funcname"
        # Exit or continue based on configuration 
        if [[ -n $PEGASO_BASH_ASSERT_ABORT ]]; then
            abort $exit_code "Assertion failed: $message"
        fi
    fi
}
