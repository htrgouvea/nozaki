<p align="center">
  <h3 align="center"><b>Fukon</b></h3>
  <p align="center">A simple and complete HTTP fuzzer</p>
  <p align="center">
    <a href="https://github.com/GouveaHeitor/security-spellbook/blob/master/LICENSE.md">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg">
    </a>
    <a href="https://github.com/GouveaHeitor/security-spellbook/releases">
      <img src="https://img.shields.io/badge/version-0.1-blue.svg">
    </a>
  </p>
</p>

---

### Download & Install

```bash 
    $ git clone https://github.com/GouveaHeitor/fukon
    $ cd fukon
```
### How to use

```bash
    $ perl fukon.pl --help

    Fukon v0.0.1
    Core Commands
    ==============
        Command       Description
        -------       -----------
        --url         Define the target
        --wordlist    Define the wordlist
        --help        See this screen

      Copyright Fukon (c) 2019 - 2020 | Heitor Gouvêa

    # Examples
    $ perl fukon.pl -u https://heitorgouvea.me -w personal-wordlist.txt -t 5
```

### Docker image

```bash
    # building image
    $ docker build --rm --squash -t fukon .

    # stop container
    $ docker stop fukon

    # remove container
    $ docker rm fukon
```

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [**See here the contribution guidelines.**](/.github/CONTRIBUTING.md) Please, report bugs via [**issues page.**](https://github.com/GouveaHeitor/fukon/issues) See here the [**security policy.**](./github/SECURITY.md) (✿ ◕‿◕) 

### License

- This work is licensed under [**MIT License.**](https://github.com/GouveaHeitor/fukon/blob/master/LICENSE.md)