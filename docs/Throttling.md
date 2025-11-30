### Throttling 

Throttling is a technique used to control the rate of execution for tasks or requests. It ensures that resources are used efficiently and prevents overloading servers or systems. This is particularly useful when interacting with APIs or performing operations that require controlled concurrency.

The following options are available for configuring throttling:

- **`-T, --tasks`**: specifies the number of threads to run concurrently. The default value is 30. Adjust this value based on the capacity of the system or server to handle concurrent operations.
- **`-d, --delay`**: sets the delay in seconds between consecutive requests. This helps to space out requests and avoid triggering rate limits or overwhelming the server.
- **`-t, --timeout`**: defines the timeout duration for each request. The default is 10 seconds. This ensures that requests do not hang indefinitely and fail gracefully if the server does not respond within the specified time.

### Example Usage

```bash
$ ./nozaki.pl -u https://target.com -w /path/to/wordlist.txt --tasks 10 --delay 2 --timeout 5
```

```bash
$ ./nozaki.pl -u https://target.com -w /path/to/wordlist.txt -T 10 -d 2 -t 5
```