<p align="center">
  <h3 align="center"><b>Nozaki</b></h3>
  <p align="center">HTTP engine fuzzer security oriented</p>
  <p align="center">
    <a href="/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/GouveaHeitor/nozaki/releases">
      <img src="https://img.shields.io/badge/version-0.0.6-blue.svg">
    </a>
  </p>
</p>

⚠️ __Warning:__ Nozaki is currently in __development__, you've been warned :) and please consider [contributing](./github/CONTRIBUTING.md)

---

### Download & Install

```bash 
    $ git clone https://github.com/GouveaHeitor/nozaki && cd nozaki
    $ cpan install Getopt::Long LWP::UserAgent HTTP::Request
```

---

### How to use

```bash
$ perl nozaki.pl

Nozaki v0.0.6
Core Commands
==============
	Command       Description
	-------       -----------
	--url         Define a target
	--wordlist    Define wordlist of paths
	--method      Define methods HTTP to use during fuzzing, separeted by ","
  --timeout     Define the timeout
	--delay       Define a seconds of delay between requests
  --maxtime     Define the timeout 
	--agent       Define a custom User Agent
	--return      Set a filter based on HTTP Code Response

# Example
$ perl nozaki.pl -m GET -u http://lab.nozaki.io:8002/\?read\= -w wordlists/payloads/ssrf.txt | grep "574"

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


### To do

- Implement multi threads
- Implement "--payload" option: a feature to send a custom payload
- Implement "--header" option: send a custom header
- Implement some filters: return/exclude based in HTTP Codes or Response Length/Size
- Implement "--version": fuzzing htttp version
- Feature to fuzzing params
- Feature to fuzzing mime type
- Try implement a feature to receive input files from swagger, openapi, graphql
- Implement "--json" option: genereate output in json file supported by postman/insomnia