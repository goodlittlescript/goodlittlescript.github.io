# Projectfile

Projects benefit greatly from having a standard workflow. We write our workflows in a shell script called the `Projectfile`.

## Example

Make a Projectfile:

```shell
#!/bin/bash
# usage: ./Projectfile [command]

#
# commands
#

shell () {
  docker run -it --rm debian:stable-slim /bin/bash
}

#
# boilerplate
#

list () {
  compgen -A function
}

if list | grep -qFx -- "${1:-}"
then "$@"; exit "$?"
else
  printf "unknown command: %s\n" "${1:-}" >&2
  exit 1
fi
```

Make it executable (`chmod +x Projectfile`), and then:

```shell
./Projectfile list
# list
# shell

./Projectfile shell
# ... now you're in bash, in debian ...

./Projectfile notathing
# unknown command: notathing
```

Whenever you want to add a workflow command, you define a function in this file, and you're done. Notably this is simply a bash script... there are no additional dependencies.

## Completions

To get completions, add this to your profile (typically `~/.bash_profile`):

```shell
_projectfile_completions() {
  COMPREPLY=($(compgen -o default -W "$(./Projectfile list 2>/dev/null)" "${COMP_WORDS[$COMP_CWORD]}"))
}
complete -F _projectfile_completions -o filenames ./Projectfile
```

With that commands will tab-complete, as will file names.

## Implementation

### Portability

The Projectfile is written to be highly portable, relying only on bash and [standard utilities](https://pubs.opengroup.org/onlinepubs/000095399/idx/utilities.html) outlined in the [POSIX Specification](https://pubs.opengroup.org/onlinepubs/000095399/toc.htm). Thus you should be able to take it anywhere bash is available.

### Exit After Command

Bash reads scripts line-by-line rather than all at once. As a result commands can "sneak in" if lines are added while a script is running. Projectfiles protect against this using an exit-after-command because the main use (running a shell) is long-running, giving the Projectfile plenty of time to change.

To illustrate:

```shell
# remove the exit-after-command '; exit "$?"'
sed -i '' -e 's/; exit "$?"//' ./Projectfile

# get a shell
./Projectfile shell

# change the Projectfile
cat >> Projectfile <<DOC
echo hello
DOC

# now exit the shell to see the echo "sneak in"
exit
# logout
# hello
```

So what to do? Add an exit on the same line as the command. That way you know the command, the exit, and any functions previously defined have already been read by bash and cannot change. You get fixed behavior for the duration of your command.

## Alternatives

* `README`: Super helpful, no additional dependencies. Not executable and prone to drift.
* `make`: Common all over. Requires `make` is available, which typically means build tools. Full of gotchas like confusion between a target and a command, leading to use of [.PHONY targets](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html).
* `rake`: Common in the ruby community, years ago. Rails originally used a Rakefile as the entrypoint for a project. As a solution it is language-specific and requires ruby+rake to be available.
