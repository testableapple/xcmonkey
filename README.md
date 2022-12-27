<p align="center">
  <img src="/assets/images/xcmonkey.png"/>
</p>

<p align="center">
  <a href="https://github.com/alteral/xcmonkey/actions"><img src="https://github.com/alteral/xcmonkey/actions/workflows/test.yml/badge.svg" /></a>
  <a href="https://sonarcloud.io/summary/new_code?id=alteral_xcmonkey"><img src="https://sonarcloud.io/api/project_badges/measure?project=alteral_xcmonkey&metric=coverage" /></a>
  <a href="https://rubygems.org/gems/xcmonkey"><img src="https://img.shields.io/gem/v/xcmonkey.svg?style=flat" /></a>
  <a href="/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg?style=flat" /></a>
</p>

*xcmonkey* is a tool for doing randomised UI testing of iOS apps.

## Requirements

```bash
brew install facebook/fb/idb-companion
pip3.6 install fb-idb
```

## Installation

```bash
gem install xcmonkey
```

## Usage

### Test

```bash
xcmonkey test --udid "20694801-2018-460F-BBA6-97D7911A1AC0" --bundle-id "com.example.app"
```

### Describe point

```bash
xcmonkey describe -x 10 -y 10 --udid "20694801-2018-460F-BBA6-97D7911A1AC0"
```

## Code of Conduct

Help us keep *xcmonkey* open and inclusive. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.
