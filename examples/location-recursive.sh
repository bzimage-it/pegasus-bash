#!/bin/bash

# this script shows a complex example of how "location" module
# works by calling recursivelly the script with different
# symlink copy of itself.
#
# best way to invoke this script is this:
#
# cd examples
# unset LEVEL
# unset PEGASUS_BASH_ROOT
# bash location-recursive.sh

# set only if not defined already (suitable for double call, see above)
test -z "$PEGASUS_BASH_ROOT" && export PEGASUS_BASH_ROOT="$(readlink -f ..)"
test -z "$LEVEL" && export LEVEL=0

PEGASUS_BASH_IMPORT_VERBOSE=0 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh location

echo
echo "execution at level $LEVEL"
echo "my own canonical full name is: $PEGASUS_SCRIPT_FULL"
echo "my own canonical location is : $PEGASUS_SCRIPT_DIR"
echo "my own name is               : $PEGASUS_SCRIPT_FILE"

echo "use same code in another place:":

# stop recurstion at level 2:
[[ $LEVEL == 2 ]] && exit 0

tmp="$(mktemp -d)"
mkdir -p $tmp/1/2/3
cp -v $PEGASUS_SCRIPT_FULL $tmp
cd $tmp/1/2/3
pwd
ln -sv ../../../$PEGASUS_SCRIPT_FILE .
ls -l
let LEVEL+=1
export LEVEL
bash $PEGASUS_SCRIPT_FILE
cd ..
pwd
ln -sv ../../$PEGASUS_SCRIPT_FILE .
ls -l
bash $PEGASUS_SCRIPT_FILE
rm -rfv $tmp














