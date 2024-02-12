# BattleTech API

A public access API for access to various bits of BattleTech data
sourced from MegaMek data.

## Dev Database

For local development, a docker version of Postgres should
be used to allow for the most portability. One can be created
with the following command:

```sh
docker run --name api-battletech \
  -e POSTGRES_DB=api-battletech \
  -e POSTGRES_USER=vapor \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 -d postgres:latest
```

To run:

```sh
swift build
swift run App migrate -y
swift run App serve
```

## Testing Database

For testing, use the following to load a docker instance:

```sh
docker run --name api-battletech-test \
  -e POSTGRES_DB=api-battletech \
  -e POSTGRES_USER=vapor \
  -e POSTGRES_PASSWORD=password \
  -p 5433:5432 -d postgres:latest
```

We use a different port to allow both to run at the same time.

```sh
swift test --enable-code-coverage
```
