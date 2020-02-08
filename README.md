# SwiftyRate

[![Swift 5.0](https://img.shields.io/badge/swift-5.0-ED523F.svg?style=flat)](https://swift.org/download/)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyRate.svg?style=flat)]()
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SwiftyRate.svg)](https://img.shields.io/cocoapods/v/SwiftyRate.svg)

A simple helper to show a SKStoreReviewController (iOS 10.3 or above) or custom UIAlertController with similar rules and behaviours. 

## iOS 11 

Apple has updated the app store guidlines and it seems that with iOS 11 you are no longer allowed to show custom review prompts, at least automatic ones. I assume this also will apply to tvOS which sucks a bit because SKStoreReviewController is not supported on tvOS.

## Requirements

- iOS 10.3+
- Swift 5.0+

## Installation

### Cocoa Pods

[CocoaPods](https://developers.google.com/admob/ios/quick-start#streamlined_using_cocoapods) is a dependency manager for Cocoa projects. Simply install the pod by adding the following line to your pod file


```swift
pod 'SwiftyRate'
```

### Swift Package Manager

The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

To add a swift package to your project simple open your project in xCode and click File > Swift Packages > Add Package Dependency.
Than enter `https://github.com/crashoverride777/swifty-rate` as the repository URL and finish the setup wizard.

Alternatively if you have a Framwork that requires adding SwiftyReceiptValidator as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```swift
dependencies: [
.package(url: "https://github.com/crashoverride777/swifty-rate.git", from: "3.5.0")
]
```

### Manually

Altenatively you can drag the SwiftyRate.swift file manually into your project.

## Usage

- Add the import statement when using CocoaPods or SwiftPackageManager

```swift
import SwiftyRate 
```

- Request review

As Apple describes in the documentation for SKStoreReviewController 

"Although you should call this method when it makes sense in the user experience flow of your app, the actual display of a rating/review request view is governed by App Store policy. Because this method may or may not present an alert, it's not appropriate to call it in response to a button tap or other user action."

UIViewController
```swift
SwiftyRate.request(from: self, afterAppLaunches: 15)
```

SKScene (needs to be called outside/after DidMoveToView or it will not work)
```swift
if let viewController = view?.window?.rootViewController {
     SwiftyRate.request(from: viewController, afterAppLaunches: 15)
}
```
