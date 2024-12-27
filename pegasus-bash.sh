# this file shall be sourced by your shell script

PEGASO_BASH_VERSION="0.1.0"

test -z "$PEGASO_BASH_ROOT" &&
    echo "PEGASO_BASH_ROOT environment undefined, abort" >&2 &&
    exit 1
test ! -d "$PEGASO_BASH_ROOT" &&
    echo "PEGASO_BASH_ROOT is not a accessible directory" >&2 &&
    exit 1
test -z "$PEGASO_BASH_IMPORT_VERBOSE" &&
    PEGASO_BASH_IMPORT_VERBOSE=0

# the order of incusion shall be this, regardless 
# that one given in the $PEGASO_BASH_IMPORT:   
declare _PEGASO_BASH_lib_all_order=(location param2env temp log debug)
declare -A _PEGASO_BASH_lib_in
declare -a _PEGASO_BASH_lib_to_source=()
declare -A PEGASO_BASH_IMPORTED=( [location]=0 [param2env]=0 [temp]=0 [log]=0 [debug]=0 )
PEGASO_BASH_IMPORT="$*"
test "$1" == "all" && PEGASO_BASH_IMPORT="${_PEGASO_BASH_lib_all_order[*]}"
# flag those one present:
for _PEGASO_BASH_lib_elem in $PEGASO_BASH_IMPORT; do
    _PEGASO_BASH_lib_in["$_PEGASO_BASH_lib_elem"]=1

    # also force dependecies:
    case "$_PEGASO_BASH_lib_elem" in
	debug)
	    # requires log:
	    _PEGASO_BASH_lib_in[log]=1
	    ;;
    esac
done
# push into final array to process only those ones
# with flag, but in the right order:
for _PEGASO_BASH_lib_elem in "${_PEGASO_BASH_lib_all_order[@]}"; do
    [[ -v _PEGASO_BASH_lib_in["$_PEGASO_BASH_lib_elem"] ]] && _PEGASO_BASH_lib_to_source+=($_PEGASO_BASH_lib_elem)
done
# echo "${_PEGASO_BASH_lib_to_source[@]}"
# process in the righ order:
for _PEGASO_BASH_lib_elem in "${_PEGASO_BASH_lib_to_source[@]}"; do
    _PEGASO_BASH_lib_file="${PEGASO_BASH_ROOT}/lib/${_PEGASO_BASH_lib_elem}.lib.sh"
    test ! -f "$_PEGASO_BASH_lib_file" &&
	echo "pegaso-bash import $_PEGASO_BASH_lib_file failed: file not found" >&2 && exit 1
    [[ $PEGASO_BASH_IMPORT_VERBOSE != 0 ]] && echo -n "PEGASO-BASH load: $_PEGASO_BASH_lib_file "
    _PEGASO_BASH_ret=0
    source "$_PEGASO_BASH_lib_file" || _PEGASO_BASH_ret=$?
    if [[ $_PEGASO_BASH_ret != 0 ]]; then
	echo "failed to source (code: $_PEGASO_BASH_ret): $_PEGASO_BASH_lib_file" >&"$PEGASO_BASH_IMPORT_VERBOSE"
	exit 1
    else
	[[ $PEGASO_BASH_IMPORT_VERBOSE != 0 ]] && echo " [OK]" >&"$PEGASO_BASH_IMPORT_VERBOSE"
	PEGASO_BASH_IMPORTED["$_PEGASO_BASH_lib_elem"]=1
    fi
done

test 0
