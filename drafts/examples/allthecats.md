# All the cats

Many useful operations packaged for the command line, in the spirit of `cat`, extended to `cp`.

## Rationale

First this is a bit of an art project.  Second, this really is a useful pattern.  [Design programs to be connected to other programs](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2877684).

Building `cat` illustrates several fundamentals of a language like iteration, IO, and os interaction.  Parsing flags brings up the standard library.  Extending `cat` to `cp` brings up reuse and encapsulation. It's a useful exercise.  One helpful to repeat in many languages.

Also it's an excuse to read the POSIX spec.

Reading the POSIX spec opens the world.  To read a manpage is to know history and possibility.  It is one of the few things that has and will endure, one of the few things you can expect to work "everywhere".  When you find yourself on a desert island of a server, fighting for survival, you will have nothing, but you will have POSIX.

Specifically you'll have these sections:

* [Shell Command Language](https://pubs.opengroup.org/onlinepubs/000095399/idx/shell.html) -- wherein you learn the common denominator under bash, dash, zsh, sh.
* [Utilities](https://pubs.opengroup.org/onlinepubs/000095399/idx/utilities.html) -- wherein you learn what commands and flags are actually portable, and which are the quirky preference of some developer somewhere.

Learn these pattern and humble `cat` becomes a foundation of productivity.  No need to build.  Just use.  And ponder.  And appreciate, then marvel at how much is simple text and transform.


## Example

Say you want to do a simple transform, such as interpolating key-value pairs into a template.

The config might look like:

```json
{
  "Docs": "https://goodlittlescript.github.io",
  "Website": "https://goodlittlescript.com"
}
```

And the output like:

```html
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
  <DT><H3>Bookmarks Bar</H3>
    <DL><p>
    <DT><A HREF="https://goodlittlescript.github.io">Docs</A>
    <DT><A HREF="https://goodlittlescript.com">Website</A>
    </DL><p>
</DL><p>
```

The code for this is easy:

=== "Python"

    ```python
    def generate_bookmarks_html(config, output):
      output.write """
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
        <DT><H3>Bookmarks Bar</H3>
          <DL><p>
      """
      for key, value in config.items():
        output.write f"""
            <DT><A HREF="{value}">{key}</A>
        """
      output.write """
          </DL><p>
      </DL><p>
      """
    ```

=== "Ruby"

    ```ruby
    def generate_bookmarks_html(config, output):
      output.write "\
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks</H1>
      <DL><p>
        <DT><H3>Bookmarks Bar</H3>
          <DL><p>
      "
      config.each do |key, value|
        output.write "\
            <DT><A HREF=\"#{value}\">#{key}</A>
        "
      end
      output.write "\
          </DL><p>
      </DL><p>
      "
    ```
