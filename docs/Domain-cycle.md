# Domain Cycling Feature

## Overview

The domain-cycle feature implements a round-robin load balancer bypass technique to evade rate limiting. By distributing requests across multiple domains (that point to the same target), you can bypass per-domain rate limits.

This technique is based on the research from: https://blog.lva.sh/article/2023/10/23/Abusing-Load-Balancers-To-Bypass-Rate-Limit.html

## How It Works

When using the `--domain-cycle` flag with multiple targets, Nozaki distributes fuzzing requests in a round-robin fashion:

1. Provide multiple targets using multiple `-u` flags
2. Enable round-robin with the `--domain-cycle` flag
3. For each path in your fuzzing wordlist, cycle through the targets sequentially
4. This ensures even distribution and can bypass rate limits

## Usage

### Basic Example

```bash
perl nozaki.pl \
  -u http://domain1.example.com \
  -u http://domain2.example.com \
  -u http://domain3.example.com \
  --domain-cycle \
  -w paths.txt \
  -m GET
```

### With Additional Options

```bash
perl nozaki.pl \
  -u http://cdn1.target.com \
  -u http://cdn2.target.com \
  -u http://cdn3.target.com \
  --domain-cycle \
  -w paths.txt \
  -m GET,POST \
  -r 200,301,302 \
  -T 10 \
  -d 0
```

### Multiple Targets via Script

For many domains, you can generate the command with a script:

```bash
#!/bin/bash
domains=("http://domain1.com" "http://domain2.com" "http://domain3.com")
cmd="perl nozaki.pl"
for domain in "${domains[@]}"; do
  cmd="$cmd -u $domain"
done
cmd="$cmd --domain-cycle -w paths.txt -m GET"
eval $cmd
```

### Example Scenario

Given:
- Domains: `domain1.com`, `domain2.com`, `domain3.com`
- Paths: `admin`, `login`, `api`, `dashboard`, `config`, `test`

Nozaki will generate requests in this order:
1. `domain1.com/admin`
2. `domain2.com/login`
3. `domain3.com/api`
4. `domain1.com/dashboard` (cycles back)
5. `domain2.com/config`
6. `domain3.com/test`

## Thread Safety

The feature uses a shared counter across all threads to ensure proper round-robin distribution, even when running with multiple concurrent tasks (`--tasks`).

## Notes

- The `-u/--url` option is not required when using `--domain-cycle`
- All domains should point to the same target application
- This technique is intended for authorized security testing only
- Respect rate limits and terms of service
- Consider using `--delay` to control request rate

## Legal & Ethical Use

This feature is designed for:
- Authorized penetration testing
- Security research on your own systems
- Bug bounty programs that explicitly allow this technique

Always obtain proper authorization before testing any systems you don't own.
