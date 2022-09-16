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

Please note that YARA signature generation is slow and not accurate at present. Furthermore, not all YARA conditions are currently supported and they will probably never be (e.g. wild-cards, jumps of variable content and lengths, fragment alternatives and many more).



## Installation

The first step is cloning the NinjaSignature repository, or downloading its source code.

```shell
$ git clone https://github.com/rovellipaolo/NinjaSignature
$ cd NinjaSignature
```


NinjaSignature has two ways to be executed: natively in your local environment or in [Docker](https://www.docker.com/).

### Native
To execute NinjaSignature in your local machine, you need `Perl 5.30` or higher installed.
Just launch the following commands, which will install all the needed Perl dependencies and add a `ninjasignature` symlink to `/usr/local/bin/`.

```
$ make build-dev
$ make install
$ ninjasignature --help
```

### Docker
To execute NinjaSignature in Docker, you need `Docker` installed.
To build the Docker image, launch the following commands:

```
$ make build-docker
$ docker run --name ninjasignature -it --rm ninjasignature:latest ninjasignature --help
```

Note that you need to bind the directory containing the sample files to the Docker image:
```shell
$ mkdir samples
$ cp /path/to/your/first/file samples/sample1
$ cp /path/to/your/second/file samples/sample2
$ docker run --name ninjasignature -it --rm -v ${PWD}/samples:/samples ninjasignature:latest ninjasignature /samples/sample1 /samples/sample2
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

### Generate signature for "Zitmo" infamous Android trojan
Samples:
 * 1CF41BDC0FDD409774EB755031A6F49D: https://www.virustotal.com/gui/file/00ce460c8b337110912066f746731a916e85bf1d7f4b44f09ca3cc39f9b52a98
 * 2DFCCCA5A9CDF207FB43A54B2194E368: https://www.virustotal.com/gui/file/ceb54cba2561f62259204c39a31dc204105d358a1a10cee37de889332fe6aa27
 * 6DDAAE38A49CEFCB1445871E0955BEF3: https://www.virustotal.com/gui/file/638840b9c2567c3434d10c9ee474318e1e328df7813cc6a24bed15560354ee44
 * A1593777AC80B828D2D520D24809829D: https://www.virustotal.com/gui/file/8473f9c732d3e026d79c866b47342b39b502ad0ee8859a345c5b61e199372ddc
 * B1AE0D9A2792193BFF8C129C80180AB0: https://www.virustotal.com/gui/file/5e43837a72ff33168df7c877b07a3c89ad64b82a2719be1cd2601be552b07114
 * D1CF8AB0987A16C80CEA4FC29AA64B56: https://www.virustotal.com/gui/file/302c060432907e506643d39b7981df16a61c61b84981bcec379fa8c5b2ec6a99
 * E9068F116991B2EE7DCD6F2A4ECDD141: https://www.virustotal.com/gui/file/99621de457d2ff5d192cd7b27f64f3c7ad64aab2e60ad22610076850aaa2828c
 * E98791DFFCC0A8579AE875149E3C8E5E: https://www.virustotal.com/gui/file/be90c12ea4a9dc40557a492015164eae57002de55387c7d631324ae396f7343c
 * ECBBCE17053D6EAF9BF9CB7C71D0AF8D: https://www.virustotal.com/gui/file/f6239ba0487ffcf4d09255dba781440d2600d3c509e66018e6a5724912df34a9

Using (custom) simple string signature generator against all the above samples:
```
$ ninjasignature --type simple --name Trojan://Android/Zitmo.A --files 1CF41BDC0FDD409774EB755031A6F49D.classes.dex 2DFCCCA5A9CDF207FB43A54B2194E368.classes.dex 6DDAAE38A49CEFCB1445871E0955BEF3.classes.dex A1593777AC80B828D2D520D24809829D.classes.dex B1AE0D9A2792193BFF8C129C80180AB0.classes.dex D1CF8AB0987A16C80CEA4FC29AA64B56.classes.dex E9068F116991B2EE7DCD6F2A4ECDD141.classes.dex E98791DFFCC0A8579AE875149E3C8E5E.classes.dex ECBBCE17053D6EAF9BF9CB7C71D0AF8D.classes.dex
```
```
{
    name: "Trojan://Android/Zitmo.A"
    sha256:
        - 27bb3ef131d939a80fdd72d0b843440fb3eaf75acbc2bd4369f6d86b71f185c2
        - 0b404a99d6b70ed7a08a1b5cf4f7de1a79086279e7897548c94264cb32a5db0e
        - 6f458aed2c4f6b672ac7c0844d89bcf1e9215ad4369671c6472a9a5d353baaa2
        - cc734b5da5928492afc30f5cdffbda56e9c925a75cee230fbcd928974437b486
        - 39b149ffa3226e0b18d3d6eab71141f72a12488e1c1832d3d13b88ba11287d98
        - 29bb8493b4e24db832f937d654b8dc033694dcfc8c4a0a829bfb90c48b68cabb
        - a5a616ad6d783efcae7709e5d98546939f92ae37297ff00f0c740190f698cc99
        - 3ae77290f3d5b7f491b56089f8d40488e7afe609f7f124af8b5111cf697821e4
        - 2d05016097f87b195186204ca617b05051eb7c645b81b8521cb7406583ba7114
    bytes:
        0: 64 65 78 0A 30 33 35 00
        35: 00 70 00 00 00 78 56 34 12 00 00 00 00 00 00 00 00
        58: 00 00 70 00 00 00
}
```
**NOTE:** Removing some of the above samples will generate better signatures.

Using YARA signature generator against some of the above samples:
```
$ ninjasignature --type yara --name Trojan://Android/Zitmo.A --files 1CF41BDC0FDD409774EB755031A6F49D.classes.dex 2DFCCCA5A9CDF207FB43A54B2194E368.classes.dex 6DDAAE38A49CEFCB1445871E0955BEF3.classes.dex
```
```
rule Trojan://Android/Zitmo.A
{
    strings:
        $s0 = {64 65 78 0A 30 33 35 00}
        $s1 = {56 34 12 00 00 00 00 00 00 00 00}
        $s2 = {01 00 00 70}
        $s3 = {ED 01 00 00}
        $s4 = {2B 00 00 00}
        $s5 = {4F 00 00 00}
        $s6 = {5A 00 00 00}
        $s7 = {A2 00 00 00}

    condition:
        $s0 and $s1 and $s2 and $s3 and $s4 and $s5 and $s6 and $s7
}
```
