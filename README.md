Zonemaster LDNS
===============

## Introduction

This module provides a Perl interface to the [ldns library](https://www.nlnetlabs.nl/projects/ldns/) from [NLnet Labs](https://www.nlnetlabs.nl/). This module includes the necessary C code from ldns, so the library does not need to be globally installed. It does, however, rely on a sufficiently recent version of OpenSSL being present.

This module is written as part of the [Zonemaster project](http://github.com/dotse/zonemaster), and therefore primarily exposes the functionality needed for that. Since Zonemaster is a diagnostic tool, that means the functions most used are those for looking things up and inspecting them.

If you want a module that specifically aims to be a complete and transparent interface to ldns, [DNS::LDNS](http://search.cpan.org/~erikoest/DNS-LDNS/) is a better fit than this module.

Initially this module was named Net::LDNS.


## Features

When installing from source, you can choose to enable or disable a number
of optional features using command line options to the `perl Makefile.PL`
commands.

### IDN

This feature is enabled by default.
Disable with `--no-idn`.

If the IDN feature is enabled, the GNU `libidn` library will be used to
add a simple function that converts strings from Perl's internal encoding
to IDNA domain name format.
In order to convert strings from whatever encoding you have to Perl's
internal format, use L<Encode>.
If you need any kind of control or options, use L<Net::LibIDN>.
The included function here is only meant to assist in the most basic case,
although that should cover a lot of real-world use cases.

> **Note:** The Zonemaster Engine test suite assumes this feature
> is enabled.

### Randomized capitalization

This feature is disabled by default.
Enable with `--randomize`.

Randomizes the capitalization of returned domain names.


## Dependencies

This module depends on the `openssl` library and has an optional
dependency on the `libidn` (with the [IDN](#idn) feature, enabled by
default) library.


## Installation

The recommended way to install Zonemaster::LDNS is to install it from CPAN as a dependency to Zonemaster::Engine. If you follow the [installation instructions for Zonemaster::Engine](https://github.com/dotse/zonemaster-engine/blob/master/docs/Installation.md) you will get all the prerequisites for Zonemaster::LDNS before installing it from CPAN.

To install Zonemaster LDNS from from sources, follow the instruction
below.

> **Note:** This procedure has additional compile-time dependencies on
> `git`, `libtool`, `autoconf`, `automake`, `make` and `Devel::CheckLib`,
> as well as a test-time dependency on `Test::Fatal`.

Install this module with the following commands.
Override the default set of features by appending `--FEATURE` and/or
`--no-FEATURE` options to the `perl Makefile.PL` command.

    git clone https://github.com/dotse/zonemaster-ldns
    cd zonemaster-ldns
    perl Makefile.PL
    make
    make test
    make install

> **Note:** The source ZIP files downloaded from Github are broken with
> respect to this instruction.


## Testing

Some of the unit tests depend on data on Internet, which may change. To avoid false 
fails, those unit tests are only run if the environment variable `TEST_WITH_NETWORK` is `true`. By default that variable
is unset (those tests are not run). To run all tests, execute

```
TEST_WITH_NETWORK=1 make test
```


## Compatibility

There is a small part in the code that may not be compatible with non-Unix operating systems, in that it assumes that the file /dev/null exists.
