
function param2env_check() {
    [[ ${#PEGASO_VALID_ENV_PARAMS[@]} -eq 0 ]] && echo "PEGASO_VALID_ENV_PARAMS not set" >&2 && return 1
    [[ ${#PEGASO_VALID_ENV_DEFAULT[@]} -eq 0 ]] && echo "PEGASO_VALID_ENV_DEFAULT not set" >&2 && return 2
    [[ ${#PEGASO_VALID_ENV_HELP[@]} -eq 0 ]] && echo "PEGASO_VALID_ENV_HELP not set" >&2 && return 3
    return 0
}
 
function param2env_help_table() {
    param2env_check || return $?
    local fd="$1"
    local format="$2"    
    local pp=
    local V=
    test -z "$format" && format="%-12s  %-8s  %-12s"
    test -z "$fd" && fd=1
    printf "$format DESCRIPTION\n" "NAME" "TYPE" "DEFAULT" >&"$fd"
    for V in "${!PEGASO_VALID_ENV_HELP[@]}"; do
	if [[ -v PEGASO_VALID_ENV_HELP[$V] ]]; then
	    printf -v pp "$format" "$V" "${PEGASO_VALID_ENV_PARAMS[$V]}" "${PEGASO_VALID_ENV_DEFAULT[$V]}" 
	    echo -e "$pp ${PEGASO_VALID_ENV_HELP[$V]}" >&"$fd"
	fi
    done
    return 0
}
 

function param2env_set_defaults() {
    param2env_check || return $?    
    local V=
    for V in "${!PEGASO_VALID_ENV_DEFAULT[@]}"; do 
	if [[ ! -v "$V" ]]; then
	    eval "$V=\"${PEGASO_VALID_ENV_DEFAULT[$V]}\""
     	    [[ $PEGASO_BASH_IMPORT_VERBOSE -eq 1 ]] && eval echo "PARAM SET DEFAULT: $V=\$$V"
	fi
    done
    return 0
}

# declare -a PEGASO_ENV_PARAMS_NOT_PROCESSED=()
PEGASO_ENV_PARAMS_NOT_PROCESSED=()
PEGASO_env_param_errors=0

function param2env_process() {
    param2env_check || return $?
    PEGASO_env_param_errors=0
    PEGASO_ENV_PARAMS_NOT_PROCESSED=()
    local i=0
    while [[ $# > 0 ]]; do
	_PP="$1"
	var="${_PP%=*}"
	value="${_PP#*=}"
	if [[ -z $value ]]; then
	    # value is the next param
	    shift
	    let i+=1
	    value="$1"
	    _PP2="$1"
	    _PP2_i=$i
	else
	    _PP2=
	fi
	let i+=1
	_PP_i=$i
	shift
	
	# echo "VAR=$var VALUE=$value"
	if [[ -v "PEGASO_VALID_ENV_PARAMS[${var}]" ]]; then
	    case "${PEGASO_VALID_ENV_PARAMS[${var}]}" in
		string)
		# no checks, any value is valid
		;;
		upstring)
		    # no checks, any value is valid,
		    # but change value in uppercase
		    value="${value^^}"
		    # eval echo "$myevalstr"
		    # log info "$value"
		    ;;
		int)
		    if [[ ! "$value" == ?(-)+([0-9]) ]] ; then
			echo "$var has invalid value $value shall be integer" >&2 
			let PEGASO_env_param_errors+=1		    
		    fi		
		    ;;
		uint)
		    if [[ ! "$value" == +([0-9]) ]] ; then
			echo "$var has invalid value $value shall be unsigned integer" >&2 
			let PEGASO_env_param_errors+=1		    
		    fi	
		    ;;
		file)
		    if [ ! -f "$value" ]; then
			echo "$var hold unexisting filename: $value" >&2 
			let PEGASO_env_param_errors+=1	    
		    fi
		    ;;
		dir)
		    if [ ! -d "$value" ]; then
			echo "$var hold unexisting dirname: $value" >&2 
			let PEGASO_env_param_errors+=1	    
		    fi
		    ;;
		bool)
		    case "${value^^}" in
			0|N|F|FALSE|NO)
			    value="FALSE"
			    ;;
			1|Y|T|TRUE|YES)
			    value="TRUE"
			    ;;
			*)
			    echo "$var shall be bool expected values: 0||N|F|FALSE|NO|1|Y|T|TRUE|YES , but found: $value" >&2 
			    let PEGASO_env_param_errors+=1	    
			    ;;
		    esac
		    ;;
		*)
		    echo "invalid type for ${PEGASO_VALID_ENV_PARAMS[${var}]} (script internal error)" >&2 
		    let PEGASO_env_param_errors+=1
		    ;;
	    esac
	    eval "$var=\"$value\""
	    [[ $PEGASO_BASH_IMPORT_VERBOSE -eq 1 ]] && eval echo "PARAM2ENV: $var=\$$var"
	else
	    # other parameters not recognized as valid X=V are pushed here:
	    PEGASO_ENV_PARAMS_NOT_PROCESSED+=("$_PP")
	    # echo ${PEGASO_ENV_PARAMS_NOT_PROCESSED} >> /tmp/pppp
	    [[ -n $_PP2 ]] && PEGASO_ENV_PARAMS_NOT_PROCESSED+="$_PP2"
	fi
    done
    return $PEGASO_env_param_errors
}
