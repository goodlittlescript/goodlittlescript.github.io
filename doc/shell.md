## Making Text

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
