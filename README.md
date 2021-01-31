<p align="center">
  <img src="https://heitorgouvea.me/images/projects/nozaki/logo.png" width="150px" heigth="150px">
  <h3 align="center"><b>Nozaki</b></h3>
  <p align="center">HTTP engine fuzzer security oriented</p>
  <p align="center">
    <a href="/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/NozakiLabs/nozaki/releases">
      <img src="https://img.shields.io/badge/version-0.2.3-blue.svg">
    </a>
  </p>
</p>

---

### Summary 

⚠️ __Warning:__ Nozaki is currently in __development__, you've been warned :) and please consider [contributing!](./github/CONTRIBUTING.md)

"Fuzzing is one of the most powerful and proven strategies for identifying security issues in real-world software" and for this reason, Nozaki tries to bridge the gap for a complete solution focused on web applications.

The idea is that this solution is complete enough to cover the entire fuzzing process in a web application (be it a monolith, a REST API, or even a GraphQL API) being fully parameterized, piped with other tools and with amazing filters.

---

### Download & Install

```
  $ git clone https://github.com/NozakiLabs/nozaki && cd nozaki
  $ cpan install Getopt::Long LWP::UserAgent HTTP::Request Parallel::ForkManager
```

---

### How to use

```
$ perl nozaki.pl

Nozaki v0.2.3
Core Commands
==============
	Command       Description
    -------       -----------
    -A, --accept      Define a custom 'Accept' header
    -T, --tasks       The number of threads to run in parallel
    -H, --header      Define a custom header (header=value)
    -m, --method      Define HTTP methods to use during fuzzing, separeted by ","
    -u, --url         Define a target
    -w, --wordlist    Define wordlist of paths
    -d, --delay       Define seconds of delay between requests
    -a, --agent       Define a custom User Agent
    -r, --return      Set a filter based on HTTP Response Code
    -e, --exclude     Exclude a specific result based on HTTP Response Code
    -t, --timeout     Define the timeout, default is 10s
    -p, --payload     Send a custom data
    -j, --json        Display the results in JSON format
    -h, --help        See this screen
```

---

### Examples

1. Content Discovery: finding pages with 200 response code for the GET method

```
$ perl nozaki.pl --method GET --url https://heitorgouvea.me/ --return 200

Code: 200 | URL: https://nozaki.io/CNAME | Method: GET | Response: OK | Length: null
Code: 200 | URL: https://nozaki.io/index | Method: GET | Response: OK | Length: 6335
Code: 200 | URL: https://nozaki.io/index.html | Method: GET | Response: OK | Length: 6335
Code: 200 | URL: https://nozaki.io/README.md | Method: GET | Response: OK | Length: 3950
...
```

2. Discovery of HTTP methods supported by the application with a personalized wordlist

```
$ perl nozaki.pl --url https://heitorgouvea.me/ -w wordlists/hackerone/paths_h1.txt

Code: 200 | URL: https://heitorgouvea.me/ | Method: [GET] | Response: OK | Length: null
Code: 403 | URL: https://heitorgouvea.me/ | Method: [POST] | Response: Forbidden | Length: null
Code: 403 | URL: https://heitorgouvea.me/ | Method: [PUT] | Response: Forbidden | Length: null
Code: 403 | URL: https://heitorgouvea.me/ | Method: [DELETE] | Response: Forbidden | Length: null
Code: 200 | URL: https://heitorgouvea.me/ | Method: [HEAD] | Response: OK | Length: null
Code: 405 | URL: https://heitorgouvea.me/ | Method: [OPTIONS] | Response: Not Allowed | Length: null
Code: 400 | URL: https://heitorgouvea.me/ | Method: [CONNECT] | Response: Bad Request | Length: 155
Code: 405 | URL: https://heitorgouvea.me/ | Method: [TRACE] | Response: Not Allowed | Length: 155
Code: 403 | URL: https://heitorgouvea.me/ | Method: [PATCH] | Response: Forbidden | Length: null
...
```

3. Fuzzing with personal payload and output in JSON format

```
$ perl nozaki.pl -m POST -u https://heitorgouvea.me/ --payload \{\"data\": \"\"\} --json

{"Length":"null","Method":"POST","Code":"403","Response":"Forbidden","URL":"https://heitorgouvea.me/.DS_Store"}
{"Code":"403","Method":"POST","Length":"null","URL":"https://heitorgouvea.me/.aws/","Response":"Forbidden"}
{"Response":"Forbidden","URL":"https://heitorgouvea.me/.git/","Length":"null","Code":"403","Method":"POST"}
{"Length":"null","Code":"403","Method":"POST","Response":"Forbidden","URL":"https://heitorgouvea.me/.svn/"}
{"Method":"POST","Code":"403","Length":"null","URL":"https://heitorgouvea.me/0","Response":"Forbidden"}
{"Method":"POST","Code":"403","Length":"null","URL":"https://heitorgouvea.me/00","Response":"Forbidden"}
{"Response":"Forbidden","URL":"https://heitorgouvea.me/01","Length":"null","Method":"POST","Code":"403"}
...
```

---

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page](https://github.com/NozakiLabs/Nozaki/issues) and for security issues, see here the [security policy.](/SECURITY.md) (✿ ◕‿◕) This project follows the best practices defined by this [style guide](https://heitorgouvea.me/projects/perl-style-guide).

---

### License

- This work is licensed under [MIT License.](/LICENSE.md)