# cyclonedx-gomod

[![Build Status](https://github.com/CycloneDX/cyclonedx-gomod/actions/workflows/ci.yml/badge.svg)](https://github.com/CycloneDX/cyclonedx-gomod/actions/workflows/ci.yml)
[![Go Report Card](https://goreportcard.com/badge/github.com/CycloneDX/cyclonedx-gomod)](https://goreportcard.com/report/github.com/CycloneDX/cyclonedx-gomod)
[![License](https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg)](LICENSE)
[![Website](https://img.shields.io/badge/https://-cyclonedx.org-blue.svg)](https://cyclonedx.org/)
[![Slack Invite](https://img.shields.io/badge/Slack-Join-blue?logo=slack&labelColor=393939)](https://cyclonedx.org/slack/invite)
[![Group Discussion](https://img.shields.io/badge/discussion-groups.io-blue.svg)](https://groups.io/g/CycloneDX)
[![Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Follow)](https://twitter.com/CycloneDX_Spec)

*cyclonedx-gomod* creates CycloneDX Software Bill of Materials (SBOM) from Go modules

## Installation

Prebuilt binaries are available on the [releases](https://github.com/CycloneDX/cyclonedx-gomod/releases) page.

### From Source

```
go install github.com/CycloneDX/cyclonedx-gomod@latest
```

Building from source requires Go 1.16 or newer.

## Compatibility

*cyclonedx-gomod* will produce BOMs for the latest version of the CycloneDX specification 
[supported by cyclonedx-go](https://github.com/CycloneDX/cyclonedx-go#compatibility).  
You can use the [CycloneDX CLI](https://github.com/CycloneDX/cyclonedx-cli#convert-command) to convert between multiple 
BOM formats or specification versions. 

## Usage

```
Usage of cyclonedx-gomod:
  -json
        Output in JSON format
  -module string
        Path to Go module (default ".")
  -noserial
        Omit serial number
  -novprefix
        Omit "v" version prefix
  -output string
        Output path (default "-")
  -serial string
        Serial number (default [random UUID])
  -std
        Include Go standard library as component and dependency of the module
  -type string
        Type of the main component (default "application")
  -version
        Show version
```

In order to be able to calculate hashes, all modules have to be present in Go's module cache.  
Make sure to run `go mod download` before generating BOMs with *cyclonedx-gomod*.

### Example

```
$ go mod tidy
$ go mod download
$ cyclonedx-gomod -output bom.xml -std
```

Checkout the [`examples`](./examples) directory for examples of BOMs generated by *cyclonedx-gomod*.

### Hashes

*cyclonedx-gomod* uses the same hashing algorithm Go uses for its [module authentication](https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md#module-authentication-with).  
[`vikyd/go-checksum`](https://github.com/vikyd/go-checksum#calc-checksum-of-module-directory) does a great job of
explaining what exactly that entails. In essence, the hash you see in a BOM should be the same as in your `go.sum` file,
just in a different format. This is because the CycloneDX specification enforces hashes to be provided in hex encoding,
while Go uses base64 encoded values.

To verify a hash found in a BOM, do the following:

1. Hex decode the value
2. Base64 encode the value
3. Prefix the value with `h1:`
4. Compare with the expected module checksum

#### Example

Given the following `component` element in a BOM:

```xml
<component bom-ref="pkg:golang/github.com/google/uuid@v1.2.0" type="library">
  <name>github.com/google/uuid</name>
  <version>v1.2.0</version>
  <scope>required</scope>
  <hashes>
    <hash alg="SHA-256">
      a8962d5e72515a6a5eee6ff75e5ca1aec2eb11446a1d1336931ce8c57ab2503b
    </hash>
  </hashes>
  <purl>pkg:golang/github.com/google/uuid@v1.2.0</purl>
  <externalReferences>
    <reference type="vcs">
      <url>https://github.com/google/uuid</url>
    </reference>
  </externalReferences>
</component>
```

We take the hash, hex decode it, base64 encode the resulting bytes and prefix that with `h1:` (demonstrated [here](https://gchq.github.io/CyberChef/#recipe=From_Hex('Auto')To_Base64('A-Za-z0-9%2B/%3D')Pad_lines('Start',3,'h1:')&input=YTg5NjJkNWU3MjUxNWE2YTVlZWU2ZmY3NWU1Y2ExYWVjMmViMTE0NDZhMWQxMzM2OTMxY2U4YzU3YWIyNTAzYg) in a CyberChef recipe).

In this case, we end up with `h1:qJYtXnJRWmpe7m/3XlyhrsLrEURqHRM2kxzoxXqyUDs=`.  
In order to verify that this matches what we expect, we can query Go's [checksum database](https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md#checksum-database) for the component we're inspecting:

```
$ curl https://sum.golang.org/lookup/github.com/google/uuid@v1.2.0
2580307
github.com/google/uuid v1.2.0 h1:qJYtXnJRWmpe7m/3XlyhrsLrEURqHRM2kxzoxXqyUDs=
github.com/google/uuid v1.2.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqOeaOT+nhxU+yHo=

go.sum database tree
3935567
SapHtgdNCeF00Cx8kqztePV24kgzNg++Xovae42HAMw=

— sum.golang.org Az3grsm7Wm4CVNR1RHq9BFnu9jzcRlU2uw7lr0gfUWgO6+rqPNjT+fUTl9gH0NRTgdwW9nItuQSMbhSaLCsk8YeYSAs=
```

Line 2 of the response tells us that the checksum in our BOM matches that known to the checksum database.

## License

Permission to modify and redistribute is granted under the terms of the Apache 2.0 license.  
See the [LICENSE](./LICENSE) file for the full license.

## Contributing

Pull requests are welcome. But please read the
[CycloneDX contributing guidelines](https://github.com/CycloneDX/.github/blob/master/CONTRIBUTING.md) first.

It is generally expected that pull requests will include relevant tests. Tests are automatically run against all
supported Go versions for every pull request.
