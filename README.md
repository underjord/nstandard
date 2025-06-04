# Nstandard

A library for easily setting up a library that follows good standard practices.

Linting, CI (via GitHub Actions), preparing for publishing to Hex and a bunch
of other busy-work that most would prefer not to do.

## Installation

In your library project:

```
mix archive.install hex igniter_new
mix igniter.install nstandard
```

It should prompt you about the changes it wants to make.

## Usage

Most of it is config. The CI should run automatically.

You also get an alias for running the linters:

```sh
mix check
```
