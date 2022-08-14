## Development

Many of these projects use a dockerized pattern, where the expectation is that development, testing, and deployment can all be done from a container. Orchestration occurs via a simple shell script called the Projectfile.

The goal is to make setup as easy as:

```shell
# install docker then...
./Projectfile shell
```

And you should be ready to go regardless of what runtime dependencies are needed. Details can be found in [The Projectfile Pattern](patterns/projectfile).

## Examples

Examples are essential.

- [All the cats](examples/allthecats) - shell scripts
- [Boom Api](examples/boomapi) - basic api
- [Basics App](examples/basicsapp) - basic app using typical utilities

## Learning

- Khan Academy
- Make Code
- GitHub Student Developer https://education.github.com/pack
- Google Sheets
