Half
========

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d30d31c29f17449481b97a04610ff5b9)](https://app.codacy.com/app/SomeRandomiOSDev/Half?utm_source=github.com&utm_medium=referral&utm_content=SomeRandomiOSDev/Half&utm_campaign=Badge_Grade_Dashboard)
[![License MIT](https://img.shields.io/cocoapods/l/Half.svg)](https://cocoapods.org/pods/Half)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Half.svg)](https://cocoapods.org/pods/Half) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Platform](https://img.shields.io/cocoapods/p/Half.svg)](https://cocoapods.org/pods/Half)
[![Code Coverage](https://codecov.io/gh/SomeRandomiOSDev/Half/branch/master/graph/badge.svg)](https://codecov.io/gh/SomeRandomiOSDev/Half)

![Swift Package](https://github.com/SomeRandomiOSDev/Half/workflows/Swift%20Package/badge.svg)
![Xcode Project](https://github.com/SomeRandomiOSDev/Half/workflows/Xcode%20Project/badge.svg)
![Cocoapods](https://github.com/SomeRandomiOSDev/Half/workflows/Cocoapods/badge.svg)
![Carthage](https://github.com/SomeRandomiOSDev/Half/workflows/Carthage/badge.svg)

**Half** is a lightweight framework containing a Swift implementation for a half-precision floating point type for iOS, macOS, tvOS, and watchOS.

Installation
--------

**Half** is available through [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and the [Swift Package Manager](https://swift.org/package-manager/). 

To install via CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'Half'
```

To install via Carthage, simply add the following line to your Cartfile:

```ruby
github "SomeRandomiOSDev/Half"
```

To install via the Swift Package Manager add the following line to your `Package.swift` file's `dependencies`:

```swift
.package(url: "https://github.com/SomeRandomiOSDev/Half.git", from: "1.0.0")
```

Usage
--------

First import **Half** at the top of your Swift file:

```swift
import Half
```

After importing, use the imported `Half` type excatly like you'd use Swift's builtin `Float`, `Double`, or `Float80` types. 

```swift
let value: Half = 7.891
let squareRoot = sqrt(value)

...
```

NOTE
--------

* [[SE-0277]](https://github.com/apple/swift-evolution/blob/master/proposals/0277-float16.md) added support for a native `Float16` type starting with Swift 5.3, therefore, this library is no longer recommended for projects using Swift 5.3 or later.  

Author
--------

Joe Newton, somerandomiosdev@gmail.com

Credits
--------

**Half** is based heavily on the implementations of the `Float`, `Double`, and `Float80` structures provided by Swift. See `ATTRIBUTIONS` for more details. 

License
--------

**Half** is available under the MIT license. See the `LICENSE` file for more info.
