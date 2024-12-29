% pegasus-bash(3) | Pegasus Bash User Manual

NAME
====

pegasus-bash - library of different utilities and iprovements in bash shell.

SYNOPSIS
========

!/bin/bash

PEGASUS_BASH_ROOT=$HOME/my/pegasus/bash/installation/dir

source $PEGASUS_BASH_ROOT/pegasus-bash.sh [*PACKAGE1* [*PACKAGE2* ..]]

DESCRIPTION
===========

You should include via 'source' or '.' bash command single packages.

It provides following *PACKAGES*:

* ```log```: a powerfull logging API with log levels, colors, custom formatting, writes to different output descriptors

* ```param2env``` : maps command line parameters to ordinary environment variables, likes ```env(1)``` command. A valid alternarnavite to classic '''getopt''' or '''--option''' style cli.

* ```location``` : knows where its own script is located, regardless of symlinks.

* ```temp``` : provides temporary files via ```mktemp(1)```, hold names in order to be remoted at exit; the programmer can forget names and call a cleanup method when exit

* ```debug``` : provides ```assert()``` function, bash strack and unix stack trace dump 

IMPORT
=======

In order to import one or more *PACKAGES* you should:

1. define PEGASUS_BASH_ROOT to point to the root directory where program is installed. A file named ```pegaso-bash.sh``` shall be present there. You can do that at the very beginnig of your script or export it in your bash initialization file, for example ```.bashrc```.
2. execute a *source* command to import:
```$PEGASUS_BASH_ROOT/pegasus-bash.sh```
followed by one or more *PACKAGES* indicating the list packages to be used by the script.

LOG PACKAGE API
===============

log package provides advanced logging configurations with support for different output devices and files (via file descriptors), colors, log levels.

LEVELS
--------

log levels shall be specified by the programmer with lowercase strings; also some aliases is allowed as an alternative string. Each level has a numeric integer value and one or more string representation. The output representation in a short version written in uppercase, this is the format how the level is presetented in log messages give in output.

|Integer |Level name|allowed aliases|output|default color name|Notes|
|--------|----------|---------------|------|-----             |-------|
|0       |out       |any force silent sil s o|OUT|reset|output is alwasy taken|
|1       |crit      |critical c|CRIT|purple|you may want to abort most of the cases|
|2       |error     |err e     |ERROR|red||
|3       |warn      |warning w |WARN|yellow||
|4       |notif     |notification n|NOTIF|green||
|5       |info      |information i informational|INFO|reset||
|6       |debug     |d |DEBUG|reset||

Note that 'reset' indicate to go back the original color of the terminal.

abort()
--------
```abort [<exit-code>] [message...]```

Function that exit by the process with a specific ```<exit-code>```, if given. If first parameter is an interger number it is assumed to be the exit code; if it is not an integer, is treated as a parameter to be passed as message. Messages are passed to ```log()``` function that is invoked in "critical" level. Default exit code is 1.

log()
--------
```log <level-name> [ <message> ... ]```

Log a message with a given log level name. If the current application log level is less or equal to the given ```<level-name>``` the message is logged; othewice logging is skipped, with no effetc. Logging is performet accordingly with the given configuration: file descriptor (see *log_set_fd()* below), colors, formatting styles and more. See also *log_conf()* below.

log_conf()
--------

Function provides log configuration variables access in a controlled manner. Different subcommand are availables: most of of them update and change configuration, a few other only read:

```log_conf level``` : print current log level string name to stdout
	    
```log_conf set <variable-name> <value>``` : change value to a configuration variable; only allow valid values, in case of error or invalid value, the variable is not changed. See section *log CONFIGURATION VARIABLES* below.

```log_conf mode <conf-modes>``` : set predefined values for tipical usage of configurations. Used to avoid many "log_conf set" commands. *<conf-modes>* are listed in following table columns and can be: ```default```, ```debug-simple```, ```debug-full```. Note that *mode* do not affect other configuration variables.

|Conf. Var.     | default   | debug-simple|debug-full   |
|:---           | :---:     | :----:      | :----:      |
|log_level      |    5 (info) | 6 (debug) | 6 (debug)   |
|log_timestamp_format| ""   |  ""         | "%Y-%m-%d %H:%M:%S" |
|log_source_format| ""      | "%L %F"     | "%S:%L %F"  |
|log_on_bad_level| ABORT    | LOGDEBUG    | ABORT       |
|log_on_error    | ABORT    | LOGDEBUG    | ABORT       |
|log_on_msg      | LOGOUT   | LOGDEBUG    | LOGDEBUG    |
|log_color_mode | AUTOLEVEL | AUTOLEVEL   | AUTOLEVEL   | 
|log_stack_delta|    1      |     1       |     1       |


```log_conf color define <color-name> <color-specification>``` : update the color interal table hash. Associate a ```<color-specification>``` string to a given ```<color-name>```. if ```<color-name>``` is already in table, is updated; if is a new one, it will be added. Color name could be a free string, tipically 'red' or 'yellow' or your custom stile like 'boldcyan' or whatever you like. ```<color-specification>``` is a terminal style color spefication that have been written to give that color or style; probably you should use string quoting. See your terminal documention for more infomation. 

```log_conf color level <level-name> <color-name>``` : associate a given ```<level-name>``` to an existing ```<color-name>``` in order ty apply that color to the level. See *LEVELS* above.

```log_conf color default``` : completelly inizialize color table and hash association table to the default values. All custom color and associations to level have been clered and reset to the default values. See table *LEVELS* above. 

```log_conf info``` : provides full configuration dump output of internal configuration variables, includeing colors and file descriptors. Note that the output format is bash-compatible code, such that it can be sourced again via shell itself. This could be a pratical way to save and restore full configuration by using and external file. The output is written based on setting specified in ```log_on_msg``` variable, see above.


log_set_fd()
--------------

```log_set_fd <fd> [ <level1> [ <level2> ...]]```

Function provides customization of output file descriptor for the given log level list. By default all log levels are set to 1 (write on stdout). This function change the value of the current file descriptor ```<fd>``` to all specified level list. If no level list is given, the new descriptor is applied for all levels. ```<fd>``` shall be a numeric positive value and a valid file descriptor open for output. A tipical value is 2 (stderr) or another costom file. See ```examples/log.sh``` how to use this feature.


log CONFIGURATION VARIABLES
---------------------------

Configuration variables corresponds to internal bash environment names used to change behavoir of logging. You program shall *not* use such names in order to avoid side effects.


```log_color_mode```

String variable defining color mode. Allowed values are combination of possibility to color all the line (color line) or only the level name (color level); also choose to "Always" applly color versus automatic mode (Auto) that means to appy colors only if the output file descriptor is living in a terminal. In this way color terminal sequences can be avoieded if logging to files. Finally "Never" color do not apply colors at all.

|Value    |color line|color level|Always|Auto |Never color|
|:---     |  :---:   |   :---:   | :---:|:---:| :----:    |
|YESFULL  |    X     |           |   X  |    |           |
|YESLEVEL |          |     X     |   X  |    |           |     
|AUTOFULL |    X     |           |      | X  |           |
|AUTOLEVEL|          |     X     |      | X  |           |
|NO       |          |           |      |    |     X     |


```log_on_bad_level```

String variable defining behavoir of log() function in case of a bad level name is given. See table *log error management logic* below. Allowed values are: ABORT, FAIL, LOGDEBUG, LOGERROR, STDOUT, STDERR, IGNORE.

```log_on_error```

String variable defining behavoir of normal messages of the library that are errors but not in *log_bad_level* class. For example when invoking *log_conf()*. Allowed values are: ABORT, LOGDEBUG, LOGERROR, STDOUT, STDERR, IGNORE.

```log_on_msg```

String variable defining behavoir of normal messages of the library that are not errors. See table *log error management logic* below. Allowed values are: LOGDEBUG, LOGOUT, STDOUT, STDERR, IGNORE.

```log_stack_delta```

Integer positive number defining ho many stack level up the source code information shall be retrieved. the default is 1, meaning that the source log information shall be retrieved at the immediated caller level of he *log()* function. If you define your own 'logging' function that calls *log()* you may want to give value of 2.

```log_level```

String variable defining the log level name. See section *LEVELS* above. This is a real variable name; 

```level```

*level* is not a real internal variable name, only an alias to ```log_level```, managed internally by *log_conf()* . So you can also use e.g.: 'log_conf set level debug' is the same as 'log_conf set log_level debug'



log error management logic
---------------------------

The library *log* is designed to write log that are messages and errors. But what about errors of the library log itself? The library is designed to give to the user the decision to direct errors of the library in a configurable way. This is done with special values given to configuration variables named *log_on_bad_level*, *log_on_error*, *log_on_msg*.

|Value    |Description|
|:---     |  :---     |  
|ABORT    | causes the abort() function to be called |
|FAIL     | causes only a fail of the function *log()* |
|LOGDEBUG | causes to use "log debug" to manage the message |
|LOGERROR | causes to use "log error" to manage the message |
|LOGOUT   | causes to use "log out" to manage the message |
|STDOUT   | causes the message to be written to stdout (fd 1)|
|STDERR   | causes the message to be written to stderr (fd 2)|
|IGNORE   | do nothing|


default at startup
------------------

after the module ```log``` is loaded, following calls are taken in oder to initialize the log configuration:

```log_conf mode default```

```log_conf color default```





BUGS
====

Bugs can be reported at https://github.com/bzimage-it/pegasus-bash/issues 

