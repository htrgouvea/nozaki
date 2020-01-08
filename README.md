<p align="center">
  <h3 align="center"><b>Berck</b></h3>
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
    $ git clone https://github.com/GouveaHeitor/berck
    $ cd berck
```
### How to use

```bash
    # print output in screen
    $ perl berck.pl <target> <wordlist>

    # save output in a file
    $ perl berck.pl <target> <wordlist> >> <output.txt>
```

### Docker image

```bash
    # building image
    $ docker build --rm --squash -t berck .

    # stop container
    $ docker stop berck

    # remove container
    $ docker rm berck
```

### Contribution

- Your contributions and suggestions are heartily ♥ welcome. [**See here the contribution guidelines.**](/.github/CONTRIBUTING.md) Please, report bugs via [**issues page.**](https://github.com/GouveaHeitor/berck/issues) See here the [**security policy.**](./github/SECURITY.md) (✿ ◕‿◕) 

### License

- This work is licensed under [**MIT License.**](https://github.com/GouveaHeitor/berck/blob/master/LICENSE.md)