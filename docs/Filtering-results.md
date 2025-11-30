### Filtering Options Documentation

This section provides an overview of the available filtering options for processing HTTP response results, along with examples of how to use them with `nozaki.pl`:

#### Summary of Options
- `-r, --return`: Apply a filter based on the HTTP Response Code.
- `-e, --exclude`: Exclude specific results based on the HTTP Response Code.
- `-j, --json`: Output the results in JSON line format, where each line represents a single JSON object.
- `-l, --length`: Filter results by the length of the content response.
- `-c, --content`: Filter results by a specific string found in the content response.


1. **Return Filter** (`-r, --return`):
    - Filters results based on the specified HTTP Response Code(s).
    - **Usage Example**:
      ```bash
      perl nozaki.pl -r 200
      ```
      This command includes only the results with an HTTP Response Code of `200`.

2. **Exclude Filter** (`-e, --exclude`):
    - Exclude specific results based on the HTTP Response Code.
    - **Usage Example**:
      ```bash
      perl nozaki.pl -e 404
      ```
      This command omits results with an HTTP Response Code of `404`.

3. **JSON Output** (`-j, --json`):
    - Output the results in JSON line format, where each line represents a single JSON object.
    - **Usage Example**:
      ```bash
      perl nozaki.pl -j
      ```
      This command formats the output in JSON line format for easier parsing.

4. **Length Filter** (`-l, --length`):
    - Filter results by the length of the content response.
    - **Usage Example**:
      ```bash
      perl nozaki.pl -l 500
      ```
      This command includes only the results where the content length is `500`.

5. **Content Filter** (`-c, --content`):
    - Filter results by a specific string found in the content response.
    - **Usage Example**:
      ```bash
      perl nozaki.pl -c "example"
      ```
      This command includes only the results that contain the string `"example"` in the response content.

