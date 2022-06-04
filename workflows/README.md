<p align="center">
  <h3 align="center"><b>Workflows</b></h3>
  <p align="center">A catalog of public workflows to use with Nozaki Fuzzer</p>
</p>

---

### Summary 

This repository is a catalog of workflows that our team has been using during the development and use of Nozaki in research, bug bounty and pentests.

---

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

```
$ perl nozaki.pl -u http://lab.nozaki.io:31337/ -W /path/to/workflows/cms.yml

Code: 200 | URL: http://lab.nozaki.io:31337/wp-content/plugins/easy-wp-smtp/ | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-json/wp/v2/users/ | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-config.php | Method: GET | Response: OK | Length: null
Code: 200 | URL: http://lab.nozaki.io:31337/wp-content/backup-db/ | Method: GET | Response: OK | Length: null
```