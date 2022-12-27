*xcmonkey* is a tool for doing randomised UI testing of iOS apps 🐒

## Requirements

```bash
brew install facebook/fb/idb-companion
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
