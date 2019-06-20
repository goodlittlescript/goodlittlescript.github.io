# curl

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

## Overview

**SYNOPSIS**/**DESCRIPTION**

* point is to transfer data
* MANY protocols, not just http/https.  *URL*
* format of the arguments is `[options] [URL...]`

**URL**

* Examples of multiple urls, expansions, globs
* "you probably  have to put the full URL within double quotes to avoid the shell from interfering with it"
* "very liberal with what it accepts"

Unix philosophy through and through.  We tend to use curl in a simple, straightforward, HTTP-centric way, but it is much more general under the hood.

**The rest**

Nearly 1M options.  Browsing them you can see hints of all the things and learn a lot about how things work, particularly HTTP.

* Headers (-H/--header)
* Auth (--basic, -n/--netrc)
* Uploads (-d/--data)
* Distributed system concerns (--retry, --retry-delay, --max-time)
* "Stuff" (-k/--insecure, -I/--head, -X/--request, --cookie, --cookie-jar)

## Examples

Extending the [jq tutorial](https://stedolan.github.io/jq/tutorial/)...

```bash
curl 'https://api.github.com/repos/stedolan/jq/commits?per_page=5'
```

Shape the output:

```bash
url="https://api.github.com/repos/stedolan/jq/commits"

format_output () {
  jq '.[] | {message: .commit.message, name: .commit.committer.name}'
}

curl "$url?per_page=5" | format_output
```

Use `-s` to remove progress and facilitate globs (there is a `--globoff` to turn off globs).

```bash
curl -s "$url?per_page=5" | format_output
curl -s "$url?per_page=5&page=[1-3]" | format_output
```

Use `-v` or `-vv` (even with `-s`) to see the request.

```bash
curl -sv "$url?per_page=5" | format_output
curl -sv "$url?per_page=5&page=[1-3]" | format_output
```

Redirect the output to see the request more clearly.

```bash
curl -sv "$url?per_page=5" > response.json
curl -sv -o response.json "$url?per_page=5"
```

Note things you can notice and use a a launching point to learn things.  First the TLS negotiation, prior to the request.  Then HTTP.

```
# HTTP request type, path, protocol... just as in the example.
> GET /repos/stedolan/jq/commits?per_page=5&page=1 HTTP/1.1

# Note curl adds a few default headers.
> Host: api.github.com
> User-Agent: curl/7.54.0
> Accept: */*

# Standard HTTP response and headers identifying the response data
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
< Content-Length: 20282
```

Note what you see in the `>` and `<` is (probably) an exact representation of what is literally being sent back-and-forth.  See [an example session](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session) for reference.

What you see is a negotiation.  Let's try a different negotiation.

```bash
curl -sv -H 'Accept: application/xml' "$url?per_page=5"
# < HTTP/1.1 415 Unsupported Media Type
# {
#   "message": "Unsupported 'Accept' header: [#<Sinatra::Request::AcceptEntry:0x00007f6bd1bcbdc8 @entry=\"application/xml\", @type=\"application/xml\", @params={}, @q=1.0>]. Must accept 'application/json'.",
#   "documentation_url": "https://developer.github.com/v3/media"
# }
```

Not supported, which is fine... it was just a guess.  Note they are leaking some implementation details; we now know this is ruby/sinatra.  You can request compressed data like this (saves maybe 50ms):

```bash
curl -sv -H 'Accept-Encoding: gzip, deflate' "$url?per_page=5"
# < Content-Encoding: gzip
# ...gzip data...

curl -sv -H 'Accept-Encoding: gzip, deflate' "$url?per_page=5" | gunzip
```

Remember, it's not just HTTP(S).

```bash
curl "file://$PWD/response.json"
```

## Day 2

POST data:

```bash
curl -d somefile ...
curl -d @- ... <somefile
```

PUT/DELETE:

```bash
curl -X PUT ...
curl -X DELETE ...
```

Common [auth](https://ec.haxx.se/http-auth.html) patterns:

```bash
# basic auth...
curl https://user:pass@domain/...
curl --user user:pass https://domain/...

# basic auth via netrc
# https://ec.haxx.se/usingcurl-netrc.html
curl -n netrc_file ...

# often auth is via a header
curl -H 'Authorization: Basic <base64 user:pass>' ...
curl -H 'Authorization: Bearer <token>' ...
```

Follow redirects:

```bash
curl -L ...
```

Turn off ssl cert verification (allow man-in-the-middle attacks):

```bash
curl -k ...
```
