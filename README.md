# YopakiBIP39 (Swift)

![Wordlist diff](https://github.com/yopaki/bip39-swift/actions/workflows/wordlists.yaml/badge.svg)
![Test Vectors diff](https://github.com/yopaki/bip39-swift/actions/workflows/test-vectors.yaml/badge.svg)
![Tests diff](https://github.com/yopaki/bip39-swift/actions/workflows/tests.yaml/badge.svg)

Swift implementation without dependencies of Trezor's [`python-mnemonic`](https://github.com/trezor/python-mnemonic/tree/master), i.e. [BIP-0039](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).

⚠️ Implementation of `to_hd_master_key` is missing as it would require to include a library for Base 58 or port an implementation such as [libbase58](https://github.com/bitcoin/libbase58).

## Installation

### Cocoapods

_Coming soon_ (really useful for [Expo native modules](https://docs.expo.dev/workflow/customizing/)). 

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "git@github.com:yopaki/bip39-swift.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for this package.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate BIP39 into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Tests

The tests cover the recommended vectors in [BIP-0039](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki), i.e. the vectors in

- https://github.com/trezor/python-mnemonic/blob/master/vectors.json
- https://github.com/bip32JP/bip32JP.github.io/blob/master/test_JP_BIP39.json

Additionally, via GitHub Actions we check that these vectors as well as the word lists for all languages are the same as [`python-mnemonic`'s](https://github.com/trezor/python-mnemonic/tree/master). 

## License

[MIT License](LICENSE).
