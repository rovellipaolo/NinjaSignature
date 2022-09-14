NinjaSignature
==============

NinjaSignature is a simple signature generator tool for malware.

[![Build Status: GitHub Actions](https://github.com/rovellipaolo/NinjaSignature/actions/workflows/ci.yml/badge.svg)](https://github.com/rovellipaolo/NinjaSignature/actions)
[![Test Coverage: Coveralls](https://coveralls.io/repos/github/rovellipaolo/NinjaSignature/badge.svg)](https://coveralls.io/github/rovellipaolo/NinjaSignature)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)



## Overview

NinjaSignature automatically generates simple signatures that matches multiple files.

**NOTE: This is more a playground to play with Perl than anything serious.**

There are currently two supported types of signature: a (custom) simple string one and a YARA one.

Please note that YARA signature generation is not accurate at present. Furthermore, not all YARA conditions are currently supported and they will probably never be (e.g. wild-cards, jumps of variable content and lengths, fragment alternatives and many more).



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
$ ninjasignature --help
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

### Generate a (custom) simple string signature from two files
```
$ ninjasignature --type simple --name TestSignature --files ./t/data/sample1 ./t/data/sample2
```
```
{
    name: "TestSignature"
    sha256:
        - 3a878ce59dce8bb4a73d5548ce923131816b33edb928099f049fc557c056eccc
        - 2087bd049dd4cdd71fe3fe78235cf5cd89908f0cb349633e90b7c4481e07e875
    bytes:
        0: 41 41 42 42
        22: 41 41 42 42 43 43 44 44 45 45 46 46
        42: 30 30 3F 3F 21 21
}
```

### Generate a (custom) simple string signature from multiple files
```
$ ninjasignature --type simple --name TestSignature --files ./t/data/sample1 ./t/data/sample2 ./t/data/sample3
```
```
{
    name: "TestSignature"
    sha256:
        - 3a878ce59dce8bb4a73d5548ce923131816b33edb928099f049fc557c056eccc
        - 2087bd049dd4cdd71fe3fe78235cf5cd89908f0cb349633e90b7c4481e07e875
        - 6b6b205afa5ab6c1e24852a6afb49a53b795c11d4e7081a31be5b6a069195bd5
    bytes:
        0: 41 41 42 42
        22: 41 41 42 42 43 43 44 44 45 45
        42: 30 30 3F 3F
}
```

### Generate a YARA signature from two files
```
$ ninjasignature --type yara --name TestSignature --files ./t/data/sample1 ./t/data/sample2
```
```
rule TestSignature
{
    strings:
        $s0 = {41 41 42 42}
        $s1 = {43 43 44 44 45 45 46 46}
        $s2 = {30 30 3F 3F 21 21}

    condition:
        $s0 and $s1 and $s2
}
```

### Generate a YARA signature from multiple files
```
$ ninjasignature --type yara --name TestSignature --files ./t/data/sample1 ./t/data/sample2 ./t/data/sample3
```
```
rule TestSignature
{
    strings:
        $s0 = {41 41 42 42}
        $s1 = {43 43 44 44 45 45}
        $s2 = {30 30 3F 3F}

    condition:
        $s0 and $s1 and $s2
}
```
