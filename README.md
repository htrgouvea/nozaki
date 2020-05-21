<p align="center">
  <h3 align="center"><b>Nozaki</b></h3>
  <p align="center">A HTTP engine fuzzer security oriented</p>
  <p align="center">
    <a href="/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/GouveaHeitor/nozaki/releases">
      <img src="https://img.shields.io/badge/version-0.1.4-blue.svg">
    </a>
  </p>
</p>

---

⚠️ __Warning:__ Nozaki is currently in __beta__, you've been warned :) and please consider [contributing](./github/CONTRIBUTING.md)

### Download & Install

```bash 
    $ git clone https://github.com/GouveaHeitor/nozaki && cd nozaki
    $ cpan install Getopt::Long LWP::UserAgent HTTP::Request
```

---

### How to use

```bash
$ perl nozaki.pl --help

Nozaki v0.0.2
Core Commands
==============
	Command       Description
	-------       -----------
	--url         Define a target
	--wordlist    Define wordlist of paths
	--method      Define methods HTTP to use during fuzzing, separeted by ","
    --timeout     Define the timeout
	--delay       Define a seconds of delay between requests
	--help        See this screen

Copyright Nozaki (c) 2020 | Heitor Gouvêa

# Example
$ perl nozaki.pl -X GET -u http://lab.nozaki.io:8002/\?read\= -w wordlists/payloads/ssrf.txt | grep "574"

[-] -> [200] | http://lab.nozaki.io:8002/?read=http://2852039166/           [GET] - OK | Length: 574
[-] -> [200] | http://lab.nozaki.io:8002/?read=http://0xA9FEA9FE/           [GET] - OK | Length: 574
[-] -> [200] | http://lab.nozaki.io:8002/?read=http://0251.0376.0251.0376/  [GET] - OK | Length: 574
...
```

---

### Labs

Are you interested and want to test the tool in a controlled environment? On the following servers your tests are more than authorized!

- 1. [http://lab.nozaki.io:8001](http://lab.nozaki.io:8002)
- 2. [http://lab.nozaki.io:8002](http://lab.nozaki.io:8002)

---

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page.](https://github.com/GouveaHeitor/Nozaki/issues) See here the [security policy.](/SECURITY.md) (✿ ◕‿◕) This project follows the best practices defined by this [style guide](https://heitorgouvea.me/projects/perl-style-guide).

---

### License

- This work is licensed under [MIT License.](/LICENSE.md)
