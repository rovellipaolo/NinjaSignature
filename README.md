NinjaSignature
==============

NinjaSignature is a simple signature generator tool for malware.



## Overview

NinjaSignature automatically generates simple signatures that matches multiple files.

**NOTE:** This is more a playground to play with Perl than anything serious.

There are currently two supported types of signature: a (custom) simple string one and a YARA one.
Please note that not all YARA conditions are currently supported, and they will probably never be (e.g. wild-cards, jumps of variable content and lengths, fragment alternatives and many more).



## Installation

The first step is cloning the NinjaSignature repository, or downloading its source code.

```shell
$ git clone https://github.com/rovellipaolo/NinjaSignature
$ cd NinjaSignature
```

To execute NinjaSignature in your local machine, you need `Perl 5.30` or higher installed.
Just launch the following commands, which will install all the needed Perl dependencies and add a `ninjasignature` symlink to `/usr/local/bin/`.

```
$ make build-dev
$ make install
```



## Checkstyle

Once you've configured it (see the _"Installation"_ section), you can also run NinjaSignature checkstyle as follows.

```
$ make checkstyle
```
**NOTE:** This is using [`perltidy`](https://metacpan.org/dist/Perl-Tidy/view/bin/perltidy) under-the-hood.



## Tests

Once you've configured it (see the _"Installation"_ section), you can also run NinjaSignature tests as follows.

```
$ make test
```

You can also run the tests with coverage by launching the following command:
```
$ make test-coverage
```



## Usage

The following are examples of running NinjaSignature against sample files.

### Generate a (custom) simple string signature
```
$ ninjasignature --type simple --name TestSignature --files ./t/data/sample1 ./t/data/sample2
```
```
{
    name: "TestSignature"
    sha256:
        - 266cdd168de3e6363ac76059905c1608ce126e6c7f8e4a1fcc7389f9d7f9f897
        - 91638dbf219262900aea9b13dbe9b0528b7d8056f16ba1d52d2a38b60cb7c90a
    bytes:
        0: 41 41 42 42
        22: 41 41 42 42 43 43 44 44 45 45 46 46
        42: 30 30 46 46 0A
}
```

### Generate a YARA signature
```
$ ninjasignature --type yara --name TestSignature --files ./t/data/sample1 ./t/data/sample2
```
```
rule TestSignature
{
    strings:
        $s0 = {41 41 42 42}
        $s1 = {43 43 44 44 45 45 46 46}
        $s2 = {30 30 46 46}

    condition:
        $s0 and $s1 and $s2
}
```
