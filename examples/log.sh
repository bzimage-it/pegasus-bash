#!/bin/bash

# PEGASUS_BASH_ROOT shall be better set systemwide,
# e.g: in ~/.bashrc
# but we set manually here, just because is a demo:

# set only if not defined already (suitable for double call, see above)
PEGASUS_BASH_ROOT="$(readlink -f ..)"

PEGASUS_BASH_IMPORT_VERBOSE=0 # default is 0, do not write info during parse
source $PEGASUS_BASH_ROOT/pegasus-bash.sh log

# use default settings, info mode

log out   "this is a output message, always given regardless of level"
log crit  "this is a critical error"
log error "this is an error message"
log warn  "this is a warning message"
log notif "this is a notification message"
log info  "this is an info message"
log debug "this is a debug message, undisplayed !"

log_conf set level debug

log debug "this is a debug message, now displayed"

log_conf mode debug-simple

log debug "you can see different formatting, line and function"
log err   "you can use also aliases, like 'err' as 'error'"
log e     "also 'e' is another alias"

log_conf mode debug-full

log debug "a more detailed message is given"
# redirect some type of error to an external file
tmp3=$(mktemp)
exec 3>$tmp3
log_set_fd 3 err warn crit

log err "this shall be written to a file, no color is written casue color mode is AUTOLEVEL"

echo cat $tmp3:
cat $tmp3

log_conf set log_color_mode YESFULL

log err "this is also written to a file, but full color is written any case"
log warning "and also a warning too, also full colored"
echo cat $tmp3:
cat $tmp3
exec 3>&-
rm -fv $tmp3

# now write all to stderr, but only debug to a file too:
tmp3=$(mktemp)
exec 3> >(tee -a $tmp3)
log_set_fd 2
log_set_fd 3 debug

# i also want debug messages to be in cyan bold color:
log_conf color define cyanbold '\033[1;36m' 
log_conf color level debug cyanbold

log info "this is an info message, only to stderr"
log debug "this is a debug message, shall be seen in both stderr and $tmp3"

echo cat $tmp3:
cat $tmp3
exec 3>&-
rm -fv $tmp3

log_set_fd 1
log_conf info

# reprint info to stdout:
log_conf set log_on_msg STDOUT
log_conf info
































