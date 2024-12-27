# this file is part of the pegasus-bash
# it is tipically includedd via source bash command

# PEGASUS_DEBUG_OUTPUT hold the file descriptor to write debug output to or the debug level if log module shall be used
PEGASUS_DEBUG_OUTPUT=1

dumpvar () { for var in "$@" ; do echo "$var=${!var}" ; done }
################# DEBUG AND STACK TRACE #####################
# snipped from : 
# http://stackoverflow.com/questions/685435/bash-stacktrace
_pegasus_debug_print() {
    if [[ ${PEGASUS_DEBUG_OUTPUT?} =~ ^[0-9]+$ ]]; then
	echo "$@" >&${PEGASUS_DEBUG_OUTPUT}
    else
	log "$PEGASUS_DEBUG_OUTPUT" "$@"
    fi
}

unix_stack_trace () { # param is the log level
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
    _pegasus_debug_print "Unix process backtrace (PID+command line): $TRACE"
    # echo -en "$TRACE" | tac | grep -n ":" # using tac to "print in reverse" [3]	
}
# snipped from : 
# http://stackoverflow.com/questions/685435/bash-stacktrace
bash_stack_trace() { # param is the log level
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
    _pegasus_debug_print "STACK TRACE of \$\$=$$ BASHPID=$BASHPID ${STACK}"
}

# PEGASUS_BASH_ON_ASSERT define log level on assertion,
# default : error
PEGASUS_BASH_ASSERT_LOG_LEVEL=error

# if undefiend or empty do not abort on assert;
# otherwice hold the default exit code on assert (unless given in assert() param itself)
# return code of 'command' is returned
PEGASUS_BASH_ASSERT_ABORT=

assert() {
    local command="$1"  # Command or expression to evaluate
    local message="${2:-Assertion failed}"  # Error message (optional)
    local exit_code=${3:-$PEGASUS_BASH_ASSERT_ABORT}  # exit code to abort in case of fail; default PEGASUS_BASH_ASSERT_ABORT
    local lineno=
    local funcname=
    local filename=
    
    # Execute the command and capture the result
    eval "$command"
    ret=$?
    if [[ $ret != 0 ]] ; then
        lineno="${BASH_LINENO[0]}"  # Line number where the error occurred
        funcname="${FUNCNAME[1]:-main}"  # Name of the calling function
        filename="${BASH_SOURCE[1]}"  # Source file of the calling script

        # Print error details
	_pegasus_debug_print "$filename:$lineno $funcname | Assertion failed: $command | $message"
        # Exit or continue based on configuration 
        if [[ -n $PEGASUS_BASH_ASSERT_ABORT ]]; then
            abort $exit_code "Assertion failed: $message"
        fi
    fi
    return $ret
}
