#!/bin/bash

# this file can be both "sourced" via bash source command or
# included at the beginning of your script.
# 
# you may also be funny if you include "header.sh" too at the
# very beginning of your script.


################# LOGGING FACILITY #####################
# inspired from
# https://www.ludovicocaldara.net/dba/bash-tips-4-use-logging-levels/
#
declare -A log_term_colors=()
### from 0 (silent) to 6 (debug)
declare -A log_level2n=( ["any"]=0 ["force"]=0 ["silent"]=0 ["sil"]=0 ["s"]=0 ["o"]=0 ["out"]=0 ["output"]=0 ["crit"]=1 ["critical"]=1 ["c"]=1 ["error"]=2 ["err"]=2 ["e"]=2 ["warning"]=3 ["warn"]=3 ["w"]=3 ["notif"]=4 ["notification"]=4 ["n"]=4 ["info"]=5 ["information"]=5 ["i"]=5 ["informational"]=5 ["debug"]=6 ["d"]=6 )
declare log_n2str=("OUT"      "CRIT"  "ERROR" "WARN"  "NOTIF" "INFO"  "DEBUG")
declare log_n2strpad=("OUT  " "CRIT " "ERROR" "WARN " "NOTIF" "INFO " "DEBUG")
declare log_n2color=("reset" "purple" "red" "yellow" "green" "reset" "reset")
declare log_n2fd=(1 1 1 1 1 1 1) # write all to stdout
unset log_source_short_info # internal, for optimize execution time 
declare -A log_source_short_info
declare -i log_level=5 # set a starting level
declare -u log_on_bad_level=ABORT # define the behavoir on log level param error; value: ABORT | FAIL | LOGDEBUG | LOGERROR      | STDOUT | STDERR | IGNORE
declare -u log_on_msg=LOGDEBUG # define the behavoir on some application log error or param or message; value: LOGDEBUG | LOGERROR  | STDOUT | STDERR | IGNORE
declare -u log_on_error=LOGDEBUG
declare -u log_color_mode=AUTOLEVEL # set color mode for level printing; YESLEVEL | YESFULL | NO | AUTOLEVEL | AUTOFULL (Auto write color on terminal, no color on file, uses -t <fd>)
declare log_timestamp_format="" # a strftime(3) format for logging
# log_source_info; set to empty string to disable
declare -u log_source_format="%L %F" # contains format in % style to print source code; %s (source filename) %l (line number) %f (function name); if empty, disable source info print.
# provide API to configuration variabiles and customizations:
declare -u log_stack_delta=1 # hold stack delta information to print source code. with a value of i log will print source code information about BASH_SOURCE[i] and reset it always to 1; default is 1; change this for a one-time-only-log-call to print special information
declare -A _log_enum_values=(
    [log_on_bad_level]=ABORT,FAIL,LOGDEBUG,LOGERROR,STDOUT,STDERR,IGNORE
    [log_on_msg]=LOGDEBUG,LOGOUT,STDOUT,STDERR,IGNORE
    [log_on_error]=ABORT,LOGDEBUG,LOGERROR,STDOUT,STDERR,IGNORE
    [log_color_mode]=YESFULL,YESLEVEL,NO,AUTOFULL,AUTOLEVEL
)

_log_print() {
    local msg="$1"
    local saved_log_stack_delta=$log_stack_delta
    log_stack_delta=2
    case "$log_on_msg" in
	    LOGDEBUG)
		log debug "$msg"
		;;
	    LOGOUT)
		log out "$msg"
		;;
	    STDOUT)
		echo "$msg"
		;;
	    STDERR)
		echo "$msg" 2>&1
		;;	    
	    *)
		;;	
    esac
    # reset if log() have not been called
    log_stack_delta=$saved_log_stack_delta
    return 0
}

_log_error() {
    local msg="$1"
    local exit_code="$2"
    local saved_log_stack_delta=$log_stack_delta
    log_stack_delta=2
    case "$log_on_error" in
	    ABORT)
		abort ${exit_code:=1} "$msg"
		;;
	    LOGDEBUG)
		log debug "$msg"
		;;
	    LOGERROR)
		log error "$msg"
		;;
	    STDOUT)
		echo "$msg"
		;;
	    STDERR)
		echo "$msg" 2>&1
		;;	    
	    *)
		;;	
    esac
    # reset if log() have not been called
    log_stack_delta=$saved_log_stack_delta
    return 0
}
log_conf() {
    local what="$1"
    local n_level=
    local split=()
    local found=1
    local msg=
    shift
    case "$what" in
	level)
	    echo "${log_n2str[$log_level]?}"
	    ;;
	set)
	    [[ -z $1 ]] && _log_error "log_conf() set variabile name missed after '$what'" && return 21
	    [[ -z $2 ]] && _log_error "log_conf() set value  missed after '$1': $2" && return 22
	    case "$1" in
		log_color_mode|log_on_bad_level|log_on_msg)
		    IFS=',' read -r -a split <<< "${_log_enum_values[$1]}"
		    found=0
		    for i in "${split[@]}"; do
			if [[ $i == $2 ]] ; then
			    found=1
			    break;
			fi
		    done		    
		    [[ $found == 0 ]] && _log_error "log_conf() value for $1=$2 invalid" && return 23
		    eval "$1=\"$2\""
		    ;;
		log_stack_delta)
		    [[ ! $2 =~ ^[0-9]+$ ]] && _log_error "log_conf() value for $1=$2 invalid, shall be integer" && return 24
		    log_stack_delta="$2"
		    ;;
		log_level|level)
		    level="$2"
		    [[ ! -v log_level2n[$level] ]] && _log_error "log_conf() bad log level '$level'" && return 27
		    log_level="${log_level2n[$level]?}"
		    ;;
		*)
		    _log_error "log_conf() set bad variable name '$1'" && return 25
		    ;;
	    esac
	    ;;
	mode)
	    log_color_mode=AUTOLEVEL
	    log_stack_delta=1
	    # set all fd to stdout:
	    log_set_fd 1
	    case "$1" in
		default)
		    log_level=5		
		    log_timestamp_format=""
		    log_source_format=""
		    log_on_bad_level=ABORT
		    log_on_error=ABORT
		    log_on_msg=LOGOUT
		    ;;
		debug-simple)
		    log_level=6
		    log_timestamp_format=""
		    log_source_format="%L %F"
		    log_on_bad_level=LOGDEBUG
		    log_on_error=LOGDEBUG
		    log_on_msg=LOGDEBUG	    
		    ;;
		debug-full)
		    log_level=6
		    log_timestamp_format="%Y-%m-%d %H:%M:%S"
		    log_source_format="%S:%L %F"
		    log_on_bad_level=ABORT
		    log_on_error=ABORT
		    log_on_msg=LOGDEBUG
		    ;;
		internal)
		    # a tipical configuration to debug this module itself
		    # maybe not suitable for the user
		    log_level=6
		    log_timestamp_format="%Y-%m-%d %H:%M:%S"
		    log_source_format="%S:%L %F"
		    log_on_bad_level=STDERR
		    log_on_error=STDERR
		    log_on_msg=STDERR		    
		    ;;
		*)
		    _log_error "log_conf() bad mode: '$1'" && return 26
		    ;;
	    esac
	    ;;
	color)
	    case "$1" in
		define) # $1: color name | $3: color specification code
		    [[ -z $1 ]] && _log_error "log_conf() color name missed after '$1'" && return 11
		    [[ -z $2 ]] && _log_error "log_conf() color specification missed after '$2'" && return 12
		    log_term_colors["$2"]="$3"
		    ;;
		level) # $1: level , $2: color name
		    [[ -z $2 ]] && _log_error "log_conf() level specification missed after 'level'" && return 13
		    [[ -z $3 ]] && _log_error "log_conf() color specification missed after log level '$2'" && return 14
		    # echo "$2 $3 ${log_level2n[$2]}" >> /tmp/e4
		    [[ ! -v log_level2n[$level] ]] && _log_error "log_conf() bad log level '$2'" && return 15
		    n_level=${log_level2n[$level]}
		    [[ ! -v log_n2color[$n_level] ]] && _log_error "log_conf() undefined color for level $n_level" && return 16
		    log_n2color[$n_level]="$3"
		    ;;
		default)
		    log_term_colors=( ["black"]='\033[0;30m' ["red"]='\033[0;31m' ["green"]='\033[0;32m' ["yellow"]='\033[0;33m' ["purple"]='\033[0;35m' ["cyan"]='\033[0;36m' ["yellow"]='\033[0;33m'  ["white"]='\033[0;37m'  ["reset"]='\033[0m' ["magenta"]='\033[0;35m' )
		    log_n2color=("reset" "purple" "red" "yellow" "green" "reset" "reset")		    
		    ;;
		*)
		    _log_error "log_conf() bad color param: '$1'" && return 17
		    ;;		
	    esac
	    ;;
	info)	    
	    # print full configuration info for conf:
	    _log_print "# log_conf() $what BEGIN:"
	    _log_print "log_level=$log_level # ${log_n2str[$log_level]?}"
	    _log_print "log_timestamp_format=\"$log_timestamp_format\""
	    _log_print "log_source_format=\"$log_source_format\""
	    msg=${log_n2fd[@]}
	    _log_print "log_n2fd=($msg)"
	    _log_print "log_stack_delta=$log_stack_delta"	    
	    _log_print "log_on_bad_level=$log_on_bad_level"
	    _log_print "log_on_msg=$log_on_msg"
	    _log_print "log_on_error=$log_on_msg"
	    _log_print "log_color_mode=$log_color_mode"
	    for msg in "${!log_term_colors[@]}"; do _log_print "log_term_colors[$msg]=\"${log_term_colors[$msg]}\"" ; done
	    for msg in "${!log_n2color[@]}"; do _log_print "log_n2color[$msg]=\"${log_n2color[$msg]}\"" ; done
	    _log_print "# log_conf() $what END"
	    ;;
	*)
	    _log_error "log_conf() bad sub-command: $what"
	    return 30
	    ;;
    esac
    return 0
}
log_level_assert() { # say wheather a log shall be done or not; return numeric level of the given level on successful (do log) or >=250 on fail (do not log); 
    local level="$1"
    if [[ ! -v log_level2n[$level] ]] ; then
	case "$log_on_bad_level" in
	    ABORT)
		abort 1 "bad log level: $level"
		;;
	    FAIL)
		return 254
		;;
	    LOGDEBUG)
		log debug "error in given log level: $level"
		return 254
		;;
	    LOGERROR)
		log error "error in given log level: $level"
		return 254
		;;
	    STDOUT)
		echo "error in given log level: $level"
		return 254
		;;
	    STDERR)
		echo "error in given log level: $level" 2>&1
		return 254
		;;	    
	    *)
		return 250; # return error (to not to log) but do nothing
		;;
	esac
    fi
    local n_level=${log_level2n[$level]?}
    # if [ $log_level -ge $n_level -o $n_level == 0 ]; then
    if [ $log_level -ge $n_level ]; then
	return $n_level # successfull
    fi
    return 255 # unsuccessfull, false
}
log() {
    log_level_assert "$1"
    local n_level=$?
    local fast_color_mode=0  # 0: no ; 1: LEVEL ; 2: FULL
    test $n_level -ge 250 && return 0
    shift
    local fd1=${log_n2fd[$n_level]?}
    if [[ ( $log_color_mode == AUTOFULL && -t $fd1 ) || $log_color_mode == YESFULL ]]; then
	fast_color_mode=2
	echo -e -n ${log_term_colors[${log_n2color[$n_level]}]} >&$fd1
    fi
    if [[ ( $log_color_mode == AUTOLEVEL && -t $fd1 ) || $log_color_mode == YESLEVEL ]]; then
	fast_color_mode=1
    fi
    if [[ -n $log_timestamp_format ]]; then
	# echo -n $(date "+$log_timestamp_format")"|" >&$fd1
	printf "%($log_timestamp_format)T|" >&$fd1
    fi
    if [[ $fast_color_mode == 1 ]]; then
	echo -e -n ${log_term_colors[${log_n2color[$n_level]}]}"${log_n2strpad[$n_level]}"${log_term_colors[reset]}"|" >&$fd1
    else
	echo -n "${log_n2strpad[$n_level]}|" >&$fd1
    fi
    if [[ -n ${log_source_format} ]]; then
	local k="${BASH_SOURCE[$log_stack_delta]}"
	local short=
	if [ ! -v log_source_short_info[$k] ]; then
	    short="$(basename "$k")"
	    log_source_short_info[$k]="$short"
	else
	    short="${log_source_short_info[$k]}"
	fi
	local sinfo=${log_source_format/"%S"/"$short"}
	sinfo=${sinfo/"%L"/"${BASH_LINENO[(($log_stack_delta-1))]}"}
	sinfo=${sinfo/"%F"/"${FUNCNAME[$log_stack_delta]}"}
	echo -n "$sinfo|" >&$fd1  
    fi
    # after usage of log_stack_delta, reset to 1:    
    log_stack_delta=1    
    echo "$@" >&$fd1
    [[ $fast_color_mode == 2 ]] && echo -e -n "${log_term_colors[reset]}" >&$fd1
    return 0
}
log_set_fd () { #  <fd> [<level1> [<level2> ... ]] : set levels to log to the given new file descriptor id; if no level given, all levels are processed
    local fd="$1"
    if [[ ! $fd =~ ^[0-9]+$ ]]; then # if is a number
	log warn "log_set_fd: passed fd=$fd not a number, ignoring"
    fi
    shift
    local n=    
    if [ $# -gt 0 ]; then
	for level in "$@"; do
	    n=${log_level2n[$level]?}
	    log_n2fd[$n]="$fd"
	done
    else # if no level, process all:
	log_n2fd=($fd $fd $fd $fd $fd $fd $fd)
    fi
}

################# ABORT #####################
abort() {
    # if first param is a number, assume is the exit code to return
    # (default=1). all the remaing args are passed to log function
    local code=1 # set default
    if [[ $1 =~ ^[0-9]+$ ]]; then # if is a number
	code=$1
	shift
    fi
    log critical "ABORT [exit code $code]" "$@" 
    exit $code
}
# assure default mode settings:
log_conf mode default
log_conf color default
