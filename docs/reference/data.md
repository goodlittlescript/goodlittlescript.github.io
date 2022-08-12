Data as a process sees it consists of:

- ARGV
- ENV variables
- Streams a process can read/write

Streams are typically local files, but they are also what you receive when you make an HTTP request, or what you read when you access things that look like files (a volume mounted in any fashion). Various things handle the details. To a process it all looks like a stream of 1s and 0s.

To give structure to a stream we make formats and encode types into those formats.
