# PDC Server Stack DevOps Scripts

## Deploy via https://hub.docker.com/r/pdcbc

This will also install Docker and disable transparent_hugepage for MongoDB.

```bash
git clone https://github.com/pdcbc/stack.git
cd stack
make
```

## Dependencies

To install without dependencies type:

```bash
make deploy
```

Or install just the dependencies:
```bash
make configure
```


## Development

To build using select local repositories:

 * Copy ./dev/dev.yml-sample to ./dev/dev.yml
 * This file has been excluded in .gitignore
 * Uncomment the appropriate line in ./dev/dev.yml
  * e.g. build: './dev/<repository>' in ./dev/dev.yml
 * Clone repositories to dev
  * cd dev; git clone https://github.com/pdcbc/<repository>

Make them using dev mode:

```bash
MODE=dev make
```


## Settings

The default tag is latest, which pulls from the master branches on GitHub.  Prod
tags tied to releases will be used when this project leaves alpha.

Use dev tags:

```bash
TAG=dev make
```

Mix tag changes and local repos with:
```bash
MODE=dev TAG=dev make
```

## Paths

Default paths are broken into private and configuration (not private) folders.
For consistency, use a similar path for this repo.

* Private: /pdc/data/private
* Configuration: /pdc/data/config
* DevOps: /pdc/data/stack
