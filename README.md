# iam-lint
Github action for linting AWS IAM policy documents

## Inputs

### `path`
Path to folder with IAM policy document files that is passed to 'find' command.  This should be a shell glob expression.

**Required:** False

**Default:** '.'

### `file_suffix`
IAM policy document file suffix

**Required"** False

**Default:** 'json'

### `minimum_severity`
Minimum severity of findings to display (passed to [parliament](https://github.com/duo-labs/parliament)).

**Required:** False

**Default:** ''

### `config`
Custom config file (passed to [parliament](https://github.com/duo-labs/parliament)).

**Required:** False

**Default:** ''

### `private_auditors`
Private auditors path (passed to [parliament](https://github.com/duo-labs/parliament)).

**Required:** False

**Default:** ''

## Example usage
### Without specifying a path
```
- uses: actions/checkout@v2
- uses: xen0l/iam-lint@v1
```

### With specifying a path
```
- uses: actions/checkout@v2
- uses: xen0l/iam-lint@v1
  with:
    path: 'policies'
```

## Credits
This action would not be possible without [parliament](https://github.com/duo-labs/parliament). Special thanks goes to [Scott piper](https://github.com/0xdabbad00) and other contributors.
