# pegasus-bash
a Bash API improvement and enhancements with logging, debugging, command parameters and more.
* includes different modules to be imported via ```source(1)```
* ```log```: a powerfull logging API with log levels, colors, custom formatting, writes to different output descriptors
* ```param2env``` : maps command line parameters to ordinary environment variables, likes ```env(1)``` command. A valid alternarnavite to classic '''getopt''' or '''--option''' style cli.
* ```location``` : knows where its own script is located, regardless of symlinks.
* ```temp``` : provides temporary files via ```mktemp(1)```, hold names in order to be remoted at exit; the programmer can forget names and call a cleanup method when exit
* ```debug``` : provides ```assert()``` function, bash strack and unix stack trace dump 

# Quick reference

a [quickstart.sh](examples/quickstart.sh) script using ```pegasus-bash```:

```
$ bash quickstart.sh foo=123 A=astring Directory= /tmp/
NOTIF|my own canonical full name is: /home/sebastiani/git/pegasus-bash/examples/quickstart.sh
NOTIF|my own canonical location is : /home/sebastiani/git/pegasus-bash/examples
NOTIF|my own name is               : quickstart.sh
PARAM2ENV: A=ASTRING
PARAM2ENV: Directory=/tmp/
ERROR|some parameter is unknown foo=123
CRIT |ABORT [exit code 10] exit the script
STACK TRACE of $$=16511 BASHPID=16511 
   on_exit quickstart.sh:36
   abort /home/sebastiani/git/pegasus-bash/lib/log.lib.sh:1
   main quickstart.sh:65

Unix process backtrace (PID+command line): 
     16511   bash quickstart.sh foo=123 A=astring Directory= /tmp/ 
      3814   /bin/bash 
      3813   SCREEN -D -R 
      3812   screen -D -R 
      3804   xfce4-terminal -e screen -D -R 
      3220   xfce4-panel 
      2940   xfce4-session 
      2867   /usr/lib/x86_64-linux-gnu/sddm/sddm-helper --socket /tmp/sddm-auth-ae4f48d6-9d79-4dbd-b7fe-5faf81a56166 --id 1 --start startxfce4 --user sebastiani 
      1639   /usr/bin/sddm 
         1   /sbin/init splash 

```
