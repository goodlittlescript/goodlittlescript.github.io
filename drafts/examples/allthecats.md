
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
