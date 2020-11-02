# YAML

A commonly used markup language intended for human use. It is a superset of JSON, meaning any JSON document can be loaded as YAML. Typically YAML is used for data (ex config files) managed by people and JSON is used for data managed by computers.

YAML can serialize/deserialize arbitrary objects, meaning it is often an attack vector. As a best practice find a "safe" variant of your library's loader (ex ["safe_load"](https://pyyaml.org/wiki/PyYAMLDocumentation#loading-yaml) in python or ["safe_load"](https://ruby-doc.org/stdlib-2.6.1/libdoc/psych/rdoc/Psych.html#method-c-safe_load) in ruby) and use that habitually so you only can deserialize the basic objects: null, bool, number, string, list, dict.

See also:

- https://yaml.org/
- [The YAML 1.2 Spec](https://yaml.org/spec/1.2/spec.html)

The spec has examples and things. It's a good read to really learn everything. Like any spec it isn't too friendly though so just google and you'll find many other tutorials.

Formats like HCL and TOML have been invented due to angst against JSON and YAML. YAML was considered a great leap forward in the rails-era, relative to XML-based configs.

## YAML in Practice

YAML is not that hard unless you make it hard. Unless you have a specific reason otherwise:

- Think of it as JSON, with less markup on average. Meaning only use it for basic types: null, bool, number, string, list, dict.
- Recognize the few cases where strings and the other types collide, and quote for string if you mean string.
- Quote if you're uncertain.
- Safe load habitually.
- `---` is a document separator to allow multiple objects (aka "documents") to live in one file.

With that you'll be fine. When you get fancy, block strings and anchors are helpful. Not much else is worth remembering - just have a YAML load/dump handy to guess/check as needed.

## You mostly know YAML already

Make a list (aka array).

```yaml
- one
- two
- three
```

Pretty much what you'd write even on paper! Make a dict (aka object, hash, map):

```yaml
todo:
- a
- b
- c

done:
- x
- y
- z
```

Again this is just what you would probably think to write. And they become exactly what you'd imagine as objects in a language.

```
# first one
["one", "two", "three"]

# second one
{"todo": ["a", "b", "c"], "done": ["x", "y", "z"]}
```

If you wanted to be more compact in that second document you'd probably want to just write out the arrays like they are loaded.

```yaml
todo: ["a", "b", "c"]
done: ["x", "y", "z"]
```

If you wanted to nest further, you'd probably just indent.

```yaml
john:
  todo: ["a", "b", "c"]
  done: ["x", "y", "z"]
jane:
  todo: []
  done: ["a", "b", "c", "x", "y", "z"]
```

And this is just how it works, and it looks remarkably like JSON, just with out the extra punctuation. But like you can write a list literally, you can also dicts literally.

```yaml
{
  "john": {
    "todo": ["a", "b", "c"],
    "done": ["x", "y", "z"]
  },
  "jane": {
    "todo": [],
    "done": ["a", "b", "c", "x", "y", "z"]
  }
}
```

Thus you have achieved JSON. And thus you may be able to see that YAML behaves the way you might think, if you think of YAML as how you'd write a list or dict without JSON punctuation, but then let yourself add punctuation as needed/desired.

```yaml
john:
  todo:
  - a
  - b
  - c
  done: [x, y, z]
"jane": {"todo": [], "done": ["a", "b", "c", "x", "y", "z"]}
```

If you wanted to put both these things into one file, you'd need something to delimit them. In YAML that is `---`. If you wanted comments you'd add comments.

```yaml
---
# first document
- one
- two
- three

---
# second document
todo: ["a", "b", "c"]

done: ["x", "y", "z"]
```

If you wanted to be more compact, you'd probably want to just write out the arrays like they are loaded.

```yaml
---
# first document
- one
- two
- three

---
# second document
todo:
- a
- b
- c

done:
- x
- y
- z
```

### Special Strings (aka things you need to quote)

Many of these feel arbitrary, and might be the source of programmer angst against YAML. For example the boolean true can be specified by pretty much any variant of "true", "yes", or "on".

```
irb(main):001:0> require 'yaml'
=> true
irb(main):002:0> YAML.load("true")
=> true
irb(main):003:0> YAML.load("True")
=> true
irb(main):004:0> YAML.load("TrUe")
=> true
irb(main):005:0> YAML.load("YES")
=> true
irb(main):006:0> YAML.load("ON")
=> true
irb(main):007:0> YAML.load("off")
=> false
```

Here's some things I'm on the lookout for:

```
String-ish       Value
true, yes, on => true
false, no, off => true
~ => null
123, 0.1, 1e10 => some number
<string with space, non-alphanumeric chars> => might collide somewhere
```

If I'm not certain what the string will be, I either just use a load/dump to check, or I quote. Sometimes you get pleasant surprises.
