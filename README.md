# SwiftyRate

iOS 11 note: Apple has updated the app store guidlines and it seems that with iOS 11 it is no longer allowed to show custom review prompts. I assume this also will apply to tvOS which sucks a bit because SKStoreReviewController is not supported on tvOS.

A simple helper to show a SKStoreReviewController (iOS 10.3 or above) or custom UIAlertController with similar rules and behaviours. 

## Requirements

- iOS 9.3+
- Swift 4.0+

## Installation

CocoaPods is a dependency manager for Cocoa projects. Simply install the pod by adding the following line to your pod file

```swift
pod 'SwiftyRate'
```

Altenatively you can drag the swift file(s) manually into your project.

## Usage

- Step 1: Add the import statment when you installed via cocoa pods. 

```swift
import SwiftyRate 
```

- Step 2: Request review

As Apple describes in the documentation for SKStoreReviewController 

"Although you should call this method when it makes sense in the user experience flow of your app, the actual display of a rating/review request view is governed by App Store policy. Because this method may or may not present an alert, it's not appropriate to call it in response to a button tap or other user action."

UIViewController
```swift
SwiftyRate.request(from: self) // 18 app launches needed
SwiftyRate.request(from: self, afterAppLaunches: 15) // custom app launches
```

SKScene (needs to be called outside/after DidMoveToView or it will not work)
```swift
if let viewController = view?.window?.rootViewController {
     SwiftyRate.request(from: viewController) // 18 app launches needed
     SwiftyRate.request(from: viewController, afterAppLaunches: 15) // custom app launches
}
```
