# jq and curl

## jq

Links:

* [Homepage](https://stedolan.github.io/jq/)
* [Install](https://stedolan.github.io/jq/download/)
* [Manual](https://stedolan.github.io/jq/manual/)
* [Tutorial](https://stedolan.github.io/jq/tutorial/)

Suggestions:

* Read the Homepage
* Invoke `man jq` and read the SYNOPSIS/FILTERS sections.  Scan the options.
* Try the Tutorial

## curl

Links:

* [Homepage](https://curl.haxx.se/)
* [Everything curl](https://ec.haxx.se/)
* [HTTP scripting tutorial](https://curl.haxx.se/docs/httpscripting.html)

Suggestions:

* Read the Homepage
* Invoke `man curl` and read the SYNOPSIS/DESCRIPTION/URL sections.  Scan the options.
* Read the [How it started](https://ec.haxx.se/curl-started.html), [The name](https://ec.haxx.se/curl-name.html), and [What does curl do?](https://ec.haxx.se/curl-does.html) sections of the "Everything curl" book.

Also:

* Read the [Rule of Composition](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2877684)
* Read [Doug McIlroy](https://en.wikipedia.org/wiki/Douglas_McIlroy)'s summarization of [the unix philosophy](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html)
  > This is the Unix philosophy: Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.
* Read this quote from [an interview](https://interviews.slashdot.org/story/04/10/18/1153211/rob-pike-responds) with [Rob Pike](https://en.wikipedia.org/wiki/Rob_Pike)
  > Q: Given the nature of current operating systems and applications, do you think the idea of "one tool doing one job well" has been abandoned? A: Those days are dead and gone and the eulogy was delivered by Perl.

## jq Overview

**SYNOPSIS**

* point is to work with JSON
* stream processing mentioned and format of the arguments is `[options...] filter [files...]`

JSON has classically been hard to work with on the command line.  Lots of quotes and structure.  Even things like pretty print are a PIA.  Good hints this command is designed with common text processing patterns (a-la cat/sed/awk/grep/tr/ssh/sqlite/...).  

**FILTERS**

* `program is a "filter"`
* filter input/output
* filters can be combined/piped into one another

General idea is that composition will be a thing and the style is pipes, much like the command line.  This means the "way of thinking" in jq is much like shell.  By way of mental preparation this is bound to be easy and intuitive in some situations and difficult in others.

**INVOKING JQ** (and the rest....)

> Note: it is important to mind the shell's quoting rules. As a general rule it's best to always quote (with single-quote characters) the  jq  program, as  too  many  characters  with  special  meaning  to  jq  are  also shell meta-characters.

Echo/pretty print (using [HEREDOCS](doc/shell#HEREDOC) to pass in JSON).  Notice the input can be any JSON blob and whitespace is not an issue.

```bash
jq '.' <<DOC
  "Hello, world!"
DOC
# "Hello, world!"

jq '.' <<DOC
  42
DOC
# 42

jq '.' <<DOC
  {"foo": 42, "bar": "less interesting data"}
DOC
# {
#   "foo": 42,
#   "bar": "less interesting data"
# }
```

Selection in an object.  Note the JSON can come from a file.

```bash
cat > object.json <<DOC
  {"foo": 42, "bar": "less interesting data"}
DOC

jq '.foo' object.json
# 42

jq '."foo"' object.json
# 42

jq '.["foo"]' object.json
# 42
```

Selection in an array (similar to the generalized object selection, but with integers).

```bash
cat > array.json <<DOC
   [{"name":"JSON", "good":true}, {"name":"XML", "good":false}]
DOC

jq '.[0]' array.json
# {
#   "name": "JSON",
#   "good": true
# }

jq '.[]' array.json
# {
#   "name": "JSON",
#   "good": true
# }
# {
#   "name": "XML",
#   "good": false
# }
```

Chained and piped selection.

```bash
jq '.[0].name' array.json
# "JSON"

jq '.[].name' array.json
# "JSON"
# "XML"

jq '.[] | .name' array.json
# "JSON"
# "XML"

jq '.[] | select(.good == true) | .name' array.json
# "JSON"
```

The point of all this being that the initial utility of jq is to pull out elements from JSON.  Arbitrary JSON can be used (see the first examples).  This alone is SUPER helpful in combination with curl and most APIs, as illustrated in the [Tutorial](https://stedolan.github.io/jq/tutorial/).

## Day 2 Examples

Helpful format options (-r raw, -c compact):

```bash
cat > array.json <<DOC
   [{"name":"JSON", "good":true}, {"name":"XML", "good":false}]
DOC

jq -r '.[].name' array.json
# JSON
# XML

jq -c '.[]' array.json
# {"name":"JSON","good":true}
# {"name":"XML","good":false}
```

Transform JSON:

```bash
jq -c '.[] | {format: .name}' array.json
# {"format":"JSON"}
# {"format":"XML"}

jq -c '.[] | [.name, .good]' array.json
# ["JSON",true]
# ["XML",false]
```

Helpful format filters (use with -r):

```bash
jq '.[] | [.name, .good] | @tsv' array.json
# "JSON\ttrue"
# "XML\tfalse"

jq -r '.[] | [.name, .good] | @tsv' array.json
# JSON	true
# XML	false

jq -r '.[] | [.name, .good] | join(":")' array.json
# jq: error (at array.json:1): string (":") and boolean (true) cannot be added

jq -r '.[] | [.name, (.good | tostring)] | join(":")' array.json
# JSON:true
# XML:false
```

More advanced selection... all values in an object (looks like array selection):

```bash
cat > object.json <<DOC
  {"foo": 42, "bar": "less interesting data"}
DOC

jq '.[]' object.json
# 42
# "less interesting data"
```

Object keys using `keys` filter:

```bash
jq -c '. | keys' object.json
# ["bar","foo"]
```

All key-value pairs using `to_entries` filter.

```bash
jq '. | to_entries' object.json
# [
#   {
#     "key": "foo",
#     "value": 42
#   },
#   {
#     "key": "bar",
#     "value": "less interesting data"
#   }
# ]

jq -r '. | to_entries | .[] | [.key, .value] | @csv' object.json
# "foo",42
# "bar","less interesting data"
```

Point here is you can slice/dice JSON in pretty advanced ways, with minimal effort.  It's a bit to learn the patterns but like anything it's typically something you incrementally build.

# Day 3 Examples

Streams of JSON:

```bash
cat > file_a <<DOC
{"name":"a1"}
{"name":"a2"}
DOC
cat > file_b <<DOC
{"name":"b1"}
DOC

jq -r '.name' file_a file_b
# a1
# a2
# b1
```

Manufacture JSON (hard-code, ENV var, arg):

```bash
jq -c '{name: .name, num: 42}' file_a
# {"name":"a1","num":42}
# {"name":"a2","num":42}

export MY_NUMBER=42
jq -c '{name: .name, num: env.MY_NUMBER}' file_a
# {"name":"a1","num":42}
# {"name":"a2","num":42}

jq --arg number "$MY_NUMBER"  -c '{name: .name, num: $number}' file_a
# {"name":"a1","num":42}
# {"name":"a2","num":42}
```

Template JSON from a file.

```bash
cat > template.json <<"DOC"
{
  name: .name,
  arbitrary: [
    {
      "complex_json": true,
      num: $number
    }
  ]
}
DOC

jq -c --arg number "$MY_NUMBER" -f template.json file_a
# {"name":"a1","arbitrary":[{"complex_json":true,"num":"42"}]}
# {"name":"a2","arbitrary":[{"complex_json":true,"num":"42"}]}
```

"Slurp" a stream into an array, map, etc.

```bash
jq -c --slurp '.' file_a file_b
# [{"name":"a1"},{"name":"a2"},{"name":"b1"}]

jq -c --slurp '.[] | {name: .name, num: 42}' file_a file_b
# {"name":"a1","num":42}
# {"name":"a2","num":42}
# {"name":"b1","num":42}

jq -c --slurp '. | map({name: .name, num: 42})' file_a file_b
# [{"name":"a1","num":42},{"name":"a2","num":42},{"name":"b1","num":42}]
```
