<p align="center">
  <img src="https://heitorgouvea.me/images/projects/nozaki/logo.png" width="150px" heigth="150px">
  <h3 align="center"><b>Nozaki</b></h3>
  <p align="center">HTTP engine fuzzer security oriented</p>
  <p align="center">
    <a href="/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/htrgouvea/nozaki/releases">
      <img src="https://img.shields.io/badge/version-0.2.7-blue.svg">
    </a>
  </p>
</p>

---

### Summary

"Fuzzing is one of the most powerful and proven strategies for identifying security issues in real-world software" and for this reason, Nozaki tries to bridge the gap for a complete solution focused on web applications.

The idea is that this solution is complete enough to cover the entire fuzzing process in a web application (be it a monolith, a REST API, or even a GraphQL API) being fully parameterized, piped with other tools and with amazing filters.

Nozaki supports dynamic workflows written in YAML, from there we can write test cases only once and then reuse them as many times as necessary on different targets.

---

### Download & Install

``` bash
  $ git clone https://github.com/NozakiLabs/nozaki && cd nozaki
  $ cpan install Find::Lib JSON YAML::Tiny Mojo::UserAgent # or cpanm --installdeps .
```

---

### How to use

```
$ perl nozaki.pl

Nozaki v0.2.7
Core Commands
==============
    Command           Description
    -------           -----------
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
    -W, --workflow    Pass a YML file with a fuzzing workflow
    -S, --skip-ssl    Ignore SSL verification
    -l, --length      Filter by content response length
    -h, --help        See this screen
```

---

### Basic examples

```bash
# Content Discovery: finding pages with 200 response code for the GET method
$ perl nozaki.pl --method GET --url https://nozaki.io/ --return 200 --wordlist /path/to/wordlist.txt

Code: 200 | URL: https://nozaki.io/CNAME | Method: GET | Response: OK | Length: null
Code: 200 | URL: https://nozaki.io/index | Method: GET | Response: OK | Length: 6335
Code: 200 | URL: https://nozaki.io/index.html | Method: GET | Response: OK | Length: 6335
Code: 200 | URL: https://nozaki.io//README.md | Method: GET | Response: OK | Length: 3950
```

```bash
# Discovery HTTP methods supported by the application with a personalized wordlist and auth token
$ perl nozaki.pl -u http://lab.nozaki.io:8081 -e 404,400,405 -w ~/path/to/wordlist.txt -H "X-Auth-Token=da1b16b40fe719cb73c7a19e2b6fa9c7" -H "Content-type=application/json"

Code: 200 | URL: http://lab.nozaki.io:8081/ | Method: GET | Response: OK | Length: 85
Code: 200 | URL: http://lab.nozaki.io:8081/ | Method: HEAD | Response: OK | Length: 85
Code: 200 | URL: http://lab.nozaki.io:8081/tokens | Method: GET | Response: OK | Length: 246
Code: 500 | URL: http://lab.nozaki.io:8081/tokens | Method: POST | Response: Internal Server Error | Length: 1469
Code: 200 | URL: http://lab.nozaki.io:8081/user/6 | Method: GET | Response: OK | Length: 72
Code: 200 | URL: http://lab.nozaki.io:8081/tokens | Method: HEAD | Response: OK | Length: 246
Code: 200 | URL: http://lab.nozaki.io:8081/uptime | Method: GET | Response: OK | Length: 129
Code: 200 | URL: http://lab.nozaki.io:8081/user/6 | Method: HEAD | Response: OK | Length: 72
Code: 200 | URL: http://lab.nozaki.io:8081/uptime | Method: HEAD | Response: OK | Length: 129
```

```yml
# Using a YAML workflow for "complex" fuzzing tests cases
rules:
  - description: Find valid paths based on CMS directories
    method: GET
    wordlist: wordlists/technologies/cmsmap.txt
    return: 200
  - description: Find valid paths based on Wordpress
    method: GET
    wordlist: wordlists/technologies/wordpress.txt
    return: 200
  - description: Find valid paths based on Drupal
    method: GET
    wordlist: wordlists/technologies/drupal.txt
    return: 200
```

```bash
$ perl nozaki.pl -u http://lab.nozaki.io:31337/ -W /path/to/workflows/cms.yml

Code: 200 | URL: http://lab.nozaki.io:31337/wp-content/plugins/easy-wp-smtp/ | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-json/wp/v2/users/ | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-config.php | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-content/backup-db/ | Method: GET | Response: OK | Length: null
```

---

### Docker container

```
$ docker build -t nozaki . 
$ docker run -ti --rm nozaki --help
```

---

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [See here the contribution guidelines.](/.github/CONTRIBUTING.md) Please, report bugs via [issues page](https://github.com/htrgouvea/nozaki/issues) and for security issues, see here the [security policy.](/SECURITY.md) (✿ ◕‿◕) This project follows the best practices defined by this [style guide](https://heitorgouvea.me/projects/perl-style-guide).

---

### License

- This work is licensed under [MIT License.](/LICENSE.md)