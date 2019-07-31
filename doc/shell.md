# bash

Links:

* The [POSIX Specification](http://pubs.opengroup.org/onlinepubs/000095399/toc.htm)
  * [Shell Command Language](http://pubs.opengroup.org/onlinepubs/000095399/utilities/xcu_chap02.html) - Shell & Utilities (top left) > Shell Command Language (bottom left).
  * [Utilities](http://pubs.opengroup.org/onlinepubs/000095399/idx/utilities.html)  - Shell & Utilities (top left) > Utilities (bottom left).
* [I/O Redirection](http://www.tldp.org/LDP/abs/html/io-redirection.html)

Suggestions:

* Go to the POSIX Specification, navigate to the Shell Command Language and Utilities sections (so you know where they are, and because you get navigation links).  This is a true manpage.  Very dense, very informative.  Go to the Shell Command Language and read as much of the following as possible.
  * 2.2 Quoting.  At minimum the intro, and scan the sections.
  * 2.6 Word Expansions as possible.  At minimum the paragraph starting with "The order of word expansion shall be as follows:", and skim 2.6.2 Parameter Expansion.
  * 2.9 Shell Commands as possible.  At minimum the intro, and scan the sections.
  * Go to the very bottom and view the 2.14 [Special Built-In Utilities](http://pubs.opengroup.org/onlinepubs/000095399/idx/sbi.html)
* View the (not special?) Utilities required by the POSIX spec.
* Read/Skim the I/O Redirection doc in full (easier than the spec).

## Streams Overview

Why does `jq` exist?  It exists to deal with JSON in a streaming manner.  For example we can put multiple JSON blobs through it.  It tackles them 1-1.

```bash
jq . <<DOC
"a string"
42
{"type": "an object"}
["an array"]
true
false
DOC
```

Notably `jq` doesn't care about whitespace "structure" between/within blobs.

```bash
jq . <<DOC
"a string"42{"type":                "an object"}

[         "an array"]     true
false
DOC
```

It can do this because JSON itself is the structure.  The parser in `jq` can interpret each character as it comes in to know "this is the start/end of a string", "this is meaningless whitespace", "this is a number".

* Great for complex data
* Verbose
* Hard to compose - requires specific tools

```bash
jq . <<DOC
{"source_ip": "0.0.0.1", "time": "10/Oct/2000:00:00:01", "zone": "-0700", "method": "GET", "path": "/one", "status": 200}
{"source_ip": "0.0.0.2", "time": "10/Oct/2000:00:00:02", "zone": "-0700", "method": "GET", "path": "/two", "status": 200}
DOC
```

Compare with whitespace delimited text.

* Great for flat data
* Compact
* Easy to compose

```bash
cat <<DOC
0.0.0.1 [10/Oct/2000:00:00:01 -0700] GET /one 200
0.0.0.2 [10/Oct/2000:00:00:02 -0700] GET /two 200
DOC
```

The name of the game on the command line is streams.  All the patterns are round making a stream of text and using it to drive work.  The streams are the  input to programs and output of them.  The entire language is geared around making them.

## Day 1 Streams

Make a stream:

```bash
# HEREDOC
cat <<DOC
0.0.0.1 [10/Oct/2000:00:00:01 -0700] GET /one 200
0.0.0.2 [10/Oct/2000:00:00:02 -0700] GET /two 200
DOC

# printf - use () to make one stream from multiple commands
(
  printf "%s [%s %s] %s %s %s\n" 0.0.0.1 10/Oct/2000:00:00:01 -0700 GET /one 200
  printf "%s [%s %s] %s %s %s\n" 0.0.0.2 10/Oct/2000:00:00:02 -0700 GET /two 200
)

# vs multiple streams
printf "%s [%s %s] %s %s %s\n" 0.0.0.1 10/Oct/2000:00:00:01 -0700 GET /one 200
printf "%s [%s %s] %s %s %s\n" 0.0.0.2 10/Oct/2000:00:00:02 -0700 GET /two 200
```

Save a stream (redirect **stdout**):

```bash
# redirect stdout
cat > 2000_10_10.log <<DOC
0.0.0.1 [10/Oct/2000:00:00:01 -0700] GET /one 200
0.0.0.2 [10/Oct/2000:00:00:02 -0700] GET /two 200
DOC

(
  printf "%s [%s %s] %s %s %s\n" 0.0.0.3 11/Oct/2000:00:00:03 -0700 GET /one 200
  printf "%s [%s %s] %s %s %s\n" 0.0.0.4 11/Oct/2000:00:00:04 -0700 GET /one 200
) > 2000_10_11.log
```

Use files.  "Glob" patterns exist to match multiple files.  The notion of concatenating multiple files is the pattern expressed by `command FILE...` and works *because* of streams; multiple files express an aggregate stream.

```bash
grep -h one 2000_10_10.log
grep -h one 2000_10_10.log 2000_10_11.log
grep -h one 2000_10_1{0,1}.log
grep -h one *.log
```

Use **stdin** as a stream.  Use of `-` is a common convention to place stdin within a list of files.

```bash
grep -h one < 2000_10_10.log
grep -h one - < 2000_10_10.log
grep -h one - 2000_10_11.log < 2000_10_10.log
grep -h one 2000_10_11.log - < 2000_10_10.log

# "-" is needed because stdin is ignored if a file is specified
grep -h one 2000_10_11.log < 2000_10_10.log

# most well-behaved commands follow this pattern
cat 2000_10_11.log - < 2000_10_10.log

# "/dev/stdin" is a fallback
grep -h one 2000_10_11.log /dev/stdin < 2000_10_10.log

# "useless use of cat" is another fallback
cat 2000_10_1{0,1}.log | grep -h one
cat - 2000_10_11.log < 2000_10_10.log | grep -h one

```

Pipe a stream:

```bash
# fancy use of HEREDOC
cat <<DOC | grep -h one
0.0.0.1 [10/Oct/2000:00:00:01 -0700] GET /one 200
0.0.0.2 [10/Oct/2000:00:00:02 -0700] GET /two 200
DOC

cat - 2000_10_11.log <<DOC | grep -h one
0.0.0.1 [10/Oct/2000:00:00:01 -0700] GET /one 200
0.0.0.2 [10/Oct/2000:00:00:02 -0700] GET /two 200
DOC

# key concept - any way of producing the stream works...
(
  cat 2000_10_10.log
  cat 2000_10_11.log
) | grep -h one

(
  printf "%s [%s %s] %s %s %s\n" 0.0.0.1 10/Oct/2000:00:00:01 -0700 GET /one 200
  printf "%s [%s %s] %s %s %s\n" 0.0.0.2 10/Oct/2000:00:00:02 -0700 GET /two 200
  curl -s file://$PWD/2000_10_11.log
) | grep -h one
```

## Day 2 Variables and Loops

**tldr; I double quote habitually to avoid problems.**

Use variables.

```bash
word=bird
printf "the word: %s\n" $word
```

Double quote if there is whitespace.  Double quotes expand variables.

```bash
word="bird bird bird"
printf "the word: %s\n" "$word"
printf "the word: $word\n"
```

Single quotes for double quotes.  Single quotes do not expand variables.

```bash
word='"quote"'
printf "the word: %s\n" "$word"
printf 'the word: $word\n'
```

Variables have various expansions.

```bash
word="understand"
printf "the word: %s\n" "mis$wording"
printf "the word: %s\n" "mis${word}ing"

# strip head
# mnemonic - H Head Hash
printf "the word: %s\n" "${word#under}"

# strip tail (useful for file extnames)
# mnemonic - er... not an H Head Hash so it must be a percent...
printf "the word: %s\n" "${word%stand}"

# default values
word=
printf "the word: %s\n" "${word:-default}"
word="notempty"
printf "the word: %s\n" "${word:-default}"
```

Variables are expanded, then the command is interpreted as if you typed it.  Allows metaprogramming.

```bash
command="printf"
pattern="the word: %s\n"
word="bird"
"$command" "$pattern" "$word"
```

Pitfall of not quoting is that you may not type what you intend.

```bash
command="printf"
pattern="the word: %s\n"
word="bird"
$command $pattern $word
```

Loop with printf.

```bash
printf "%s\n" "0.0.0.1" "0.0.0.2" "0.0.0.3" "0.0.0.4"
printf "%s\n" "1" "2" "3" "4"
printf "%s %s\n" "1" "2" "3" "4"
printf "%s %s\n" 1 one 2 two 3 one 4 one
printf "%s %s\n" \
  1 one \
  2 two \
  3 one \
  4 one
```

Loop with while.

```bash
printf "%s %s\n" 1 one 2 two 3 one 4 one |
while read n path
do
  printf "%s [%s %s] %s %s %s\n" "0.0.0.$n" "10/Oct/2000:00:00:0$n" -0700 GET "/$path" 200
done
```

Keep on piping (note last argument of `read` gets the rest):

```bash
printf "%s %s\n" 1 one 2 two 3 one 4 one |
while read n path
do
  printf "%s [%s %s] %s %s %s\n" "0.0.0.$n" "10/Oct/2000:00:00:0$n" -0700 GET "/$path" 200
done |
while read ip_addr timestamp zone message
do
   jq -n \
     --arg ip_addr "$ip_addr" \
     --arg timestamp "${timestamp#[}" \
     --arg zone "${zone%]}" \
     --arg message "$message" \
     '{
       source_ip: $ip_addr,
       time: $timestamp,
       zone: $zone,
       message: $message
     }'
done
```

## Day 4 fork/exec
###########################################################
# Bash Day 2
* fork/exec -- argv, env, streams, exit status
* executables
  * shell variation (case/esac, $@, set, unset, export, functions)
  * ruby variation for comparison
* gotchas

###########################################################
# Kubernetes
* Streams as input.  Add a rendering step.
* Disconnect render from apply.
* Now you have a deployment system.





## Appendix

### printf

```
printf "%s %s [%s %s] %s %s %s\n" 0.0.0.1 frank 10/Oct/2000:00:00:01 -0700 GET /data 200
printf "%s %s [%s %s] %s %s %s\n" 0.0.0.2 janet 10/Oct/2000:00:00:02 -0700 GET /data 200
```

Stream to printf with xargs.

```bash
cat > numbers.txt <<DOC
1
2
3
4
DOC
xargs printf "0.0.0.%s\n" < numbers.txt
```

### HEREDOC

A way to make a multiline stdin stream.  A common use is to make a file in combination with `cat` and a redirect.

```bash
# '<<DOC' puts the text on stdin
# '> filename' puts stdout to the file
# 'cat' copies stdin to stdout
cat > filename <<DOC
Goodnight moon
Goodnight room
Goodnight light and the red balloon.
DOC

cat filename
# Goodnight moon
# Goodnight room
# Goodnight light and the red balloon.
```

Variables are expanded in a HEREDOC.  To prevent expansion add quotes like `"DOC"`.  For one offs escape the expansion as normal.

```bash
thing=moon

cat <<DOC
Goodnight ${thing}
DOC
# Goodnight moon

cat <<"DOC"
Goodnight ${thing}
DOC
# Goodnight ${thing}

cat <<DOC
Goodnight ${thing}
Goodnight \${thing}
DOC
# Goodnight moon
# Goodnight ${thing}
```

The `DOC` is arbitrary; any mixed-case word will do but it must be fully outdented at the end.  The goal is to have it not match any of the interior text (in some editors/languages with a similar metaphor you get code highlighting if you identify the language with the word like 'RUBY' or 'JSON').


## Overview Shell

Having the right concept of shell is very helpful, both in terms of understanding how to compose commands, and how the language itself is meant to work.  It is not a general-purpose language like Java, Python, Ruby, etc.  The goal of the shell is simply to launch processes.

Processes consist of a very finite list of things, basically just:

* The program itself
* The args used to launch it
* ENV variables
* Plus system resources like file handles (stdin/stdout/stderr), memory, and cpu

You can actually see this in the system commands used to literally launch files:

* [exec](https://pubs.opengroup.org/onlinepubs/009695399/functions/exec.html
* [Kernel#exec](https://ruby-doc.org/core-2.6.3/Kernel.html#method-i-exec) (ruby)
* [os.exec](https://docs.python.org/2/library/os.html#process-management) (python)
