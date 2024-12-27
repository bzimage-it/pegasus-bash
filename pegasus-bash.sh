# this file shall be sourced by your shell script

PEGASUS_BASH_VERSION="0.1.0"

test -z "$PEGASUS_BASH_ROOT" &&
    echo "PEGASUS_BASH_ROOT environment undefined, abort" >&2 &&
    exit 1
test ! -d "$PEGASUS_BASH_ROOT" &&
    echo "PEGASUS_BASH_ROOT is not a accessible directory" >&2 &&
    exit 1
test -z "$PEGASUS_BASH_IMPORT_VERBOSE" &&
    PEGASUS_BASH_IMPORT_VERBOSE=0

# the order of incusion shall be this, regardless 
# that one given in the $PEGASUS_BASH_IMPORT:   
declare _PEGASUS_BASH_lib_all_order=(location param2env temp log debug)
declare -A _PEGASUS_BASH_lib_in
declare -a _PEGASUS_BASH_lib_to_source=()
declare -A PEGASUS_BASH_IMPORTED=( [location]=0 [param2env]=0 [temp]=0 [log]=0 [debug]=0 )
PEGASUS_BASH_IMPORT="$*"
test "$1" == "all" && PEGASUS_BASH_IMPORT="${_PEGASUS_BASH_lib_all_order[*]}"
# flag those one present:
for _PEGASUS_BASH_lib_elem in $PEGASUS_BASH_IMPORT; do
    _PEGASUS_BASH_lib_in["$_PEGASUS_BASH_lib_elem"]=1

    # also force dependecies:
    case "$_PEGASUS_BASH_lib_elem" in
	debug)
	    # requires log:
	    # _PEGASUS_BASH_lib_in[log]=1
	    ;;
    esac
done
# push into final array to process only those ones
# with flag, but in the right order:
for _PEGASUS_BASH_lib_elem in "${_PEGASUS_BASH_lib_all_order[@]}"; do
    [[ -v _PEGASUS_BASH_lib_in["$_PEGASUS_BASH_lib_elem"] ]] && _PEGASUS_BASH_lib_to_source+=($_PEGASUS_BASH_lib_elem)
done
# echo "${_PEGASUS_BASH_lib_to_source[@]}"
# process in the righ order:

for _PEGASUS_BASH_lib_elem in "${_PEGASUS_BASH_lib_to_source[@]}"; do
    _PEGASUS_BASH_lib_file="${PEGASUS_BASH_ROOT}/lib/${_PEGASUS_BASH_lib_elem}.lib.sh"

    test ! -f "$_PEGASUS_BASH_lib_file" &&
	echo "pegasus-bash import $_PEGASUS_BASH_lib_file failed: file not found" >&2 && exit 1
    [[ $PEGASUS_BASH_IMPORT_VERBOSE != 0 ]] && echo -n "PEGASUS-BASH load: $_PEGASUS_BASH_lib_file ">&"$PEGASUS_BASH_IMPORT_VERBOSE"
    _PEGASUS_BASH_ret=0
    source "$_PEGASUS_BASH_lib_file" || _PEGASUS_BASH_ret=$?
    if [[ $_PEGASUS_BASH_ret != 0 ]]; then
	echo "failed to source (code: $_PEGASUS_BASH_ret): $_PEGASUS_BASH_lib_file" >&2
	exit 1
    else
	[[ $PEGASUS_BASH_IMPORT_VERBOSE != 0 ]] && echo " [OK]" >&"$PEGASUS_BASH_IMPORT_VERBOSE"
	PEGASUS_BASH_IMPORTED["$_PEGASUS_BASH_lib_elem"]=1
    fi
done

test 0
