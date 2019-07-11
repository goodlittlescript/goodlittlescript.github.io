
## Processes

![A Process](images/process-1.jpg)

A process.  Inside the box is the program and the program can work with stuff in the box, like the ENV and file descriptors.  Outside the box is the os (ex linux).  The program can only reach outside the box via system calls to the os.  This is encapsulation.  The process is literally a chunk of memory the program controls.

![ENV](images/process-2-env.jpg)

The ENV is a special bit of memory that belongs to the process rather than the program.

![exec](images/process-3-exec.jpg)

A process gets its program via a system call to `exec` with an argument vector, ARGV.  ARGV is the command you type in, split into tokens.  `exec` looks along the PATH ENV variable for an executable file matching the 0th arg ($0).  Then exec loads the program into the process memory and runs it.

![file descriptors](images/process-3-fds.jpg)

File descriptors let a program read/write files.  Files exist outside the process, and system calls drive the actual read/write on a file descriptor.  By default you get stdin (0) stdout (1) and stderr (2).  Calls to `open` make new file descriptors.

![pid](images/process-5-pid.jpg)

Processes are made and live in a tree of parent-child relationships.  Each process has an id (pid), which can be used to send a process a signal (ex INT or TERM).  When a process exits, it reports an exit status back to its parent.  0 is success.  Non-zero is failure.

In aggregate these are make up the interface of a process, each of which is reflected in the shell.

* ENV (`export PATH="$PWD/bin:$PATH"`)
* ARGV (`ruby -e "puts :hello"`)
* file descriptors (`< stdin > stdout 2> stderr`)
* signals (`kill <pid>`)
* exit status (`$?`)

The "thing to know" is that this is basically it.  If want to send information to a process or get information from a process, you have to do it in one of the above ways.  ENV, ARGV, and exit status have value at the beginning and end of a process, but only file descriptors and signals work in the middle.  Signals are of limited use, so again it becomes about streams... which is all a file really is.

Note that turning the world to files lets you see the utility of stdin/stdout/stderr... it's a way to push coordination up.  Individual programs need not make an specific agreement about "where do I get input or put output".  Those 3 file descriptors are the agreement.  Get input from stdin.  Put output to stdout.  Put other communication to stderr.

## In practice

Write a script.

```bash
printf "the iso8601 time is: %s\n" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
```

Make the script into an executable:

```bash
cat > what_time_is_it <<"DOC"
printf "the time is: %s\n" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
DOC
chmod +x what_time_is_it
./what_time_is_it
```

The `./` is necessary. It's a way to write a full path to the command, which is what `exec` needs.  To make this like any command, put it on PATH.

```bash
mkdir bin
mv what_time_is_it bin
export PATH="$PWD/bin:$PATH"
what_time_is_it
```

Now we can go anywhere and run the command.

```bash
cd ~
what_time_is_it
cd -  # note `cd -` is a way to go back to where you were last
```

To write a command in something other than bash, use a shebang.

```bash
cat > bin/what_time_is_it_rb <<"DOC"
#!/usr/bin/env ruby
require 'time'
puts "la la the time is: #{Time.now.utc.iso8601}"
DOC
chmod +x bin/what_time_is_it_rb
```

The shebang is like typing what is there, then using the command file as the next argument.  Examples:

* catfile
* jqfile
* sedfile

Usually you want to `/usr/bin/env xyz` with command-friendly programs like python and ruby, or `/bin/bash` for everything else.  Other cases almost never arise in practice (ex: you will probably never write a "sedfile" and if you need to then you'll probably just `/bin/bash`).

In a command, you have what all processes have:

```
cat > bin/process_stuff <<"DOC"
#!/bin/bash
printf "argv 0: %s\n" "$0"
printf "argv 1: %s\n" "$1"
printf "argv 2: %s\n" "$2"
printf "env: %s\n" "$VAR"
exit 8
DOC
chmod +x bin/process_stuff

export VAR=value
./bin/process_stuff a b
echo $?
```

Same stuff in ruby.

```bash
cat > bin/process_stuff_rb <<"DOC"
#!/usr/bin/env ruby
puts "argv 0: #{$0}"
puts "argv 1: #{ARGV[0]}"
puts "argv 2: #{ARGV[1]}"
puts "env: #{ENV['VAR']}"
exit 8
DOC
chmod +x bin/process_stuff_rb

export VAR=value
./bin/process_stuff_rb a b
echo $?
```

Making these little programs really behave more like commands means adding options, help, etc.  It's a pattern in all languages.  Here are patterns for bash and ruby; there definitely are details but you can read, study, and/or copy-paste your way to success, if you have a starting point.

# Gochas

What is happening with fds.  fork/exec.  What looks one way is actually just a politeness.  You need to see processes so you see when your memory stops and another process begins.
