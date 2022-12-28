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
$ xcmonkey test --udid "413EA256-CFFB-4312-94A6-12592BEE4CBA" --bundle-id "com.apple.mobilesafari"
12:44:19.343: Device info: iPhone 14 Pro | 413EA256-CFFB-4312-94A6-12592BEE4CBA | Booted | simulator | iOS 16.2 | x86_64 | /tmp/idb/413EA256-CFFB-4312-94A6-12592BEE4CBA_companion.sock

12:44:22.550: App info: com.apple.mobilesafari | MobileSafari | system | x86_64, arm64 | Running | Not Debuggable | pid=43398

12:44:23.203: Tap: {
  "x": 53,
  "y": 749
}

12:44:23.511: Swipe: {
  "x": 196,
  "y": 426
} => {
  "x": 143,
  "y": 447
}

12:44:24.355: Tap: {
  "x": 143,
  "y": 323
}
```

### Describe point

```bash
$ xcmonkey describe -x 125 -y 760 --udid "413EA256-CFFB-4312-94A6-12592BEE4CBA"
12:41:03.840: Device info: iPhone 14 Pro | 413EA256-CFFB-4312-94A6-12592BEE4CBA | Booted | simulator | iOS 16.2 | x86_64 | /tmp/idb/413EA256-CFFB-4312-94A6-12592BEE4CBA_companion.sock

12:41:05.342: x:125 y:760 point info: {
  "AXFrame": "{{120, 759}, {64, 64}}",
  "AXUniqueId": "Safari",
  "frame": {
    "y": 759,
    "x": 120,
    "width": 64,
    "height": 64
  },
  "role_description": "button",
  "AXLabel": "Safari",
  "content_required": false,
  "type": "Button",
  "title": null,
  "help": "Double tap to open",
  "custom_actions": [
    "Edit mode",
    "Today",
    "App Library"
  ],
  "AXValue": "",
  "enabled": true,
  "role": "AXButton",
  "subrole": null
}
```

## Code of Conduct

Help us keep *xcmonkey* open and inclusive. Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file.
