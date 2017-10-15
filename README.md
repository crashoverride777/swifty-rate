# SwiftyRate

# SwiftyRate

iOS 11 note: Apple has updated the app store guidlines and it seems that with iOS 11 it is no longer allowed to show custom review prompts. I assume this also will apply to tvOS which sucks a bit because SKStoreReviewController is not supported on tvOS. This means I will mostly delete this repostitory once iOS 11 is released because using SKStoreReviewController is 1 line of code. Please bear this in mind when downloading.


A simple helper to show a SKStoreReviewController (iOS only) or custom rate game/app UIAlertController. This helper can be used on both iOS and tvOS.

This helper will use the SKStoreReviewController (iOS 10.3) if its supported otherwise it will show a custom alert with similar rules and behaviours. Apple restricts the use of SKStoreReviewController to 3 times per year, the actual logic behind the scheduling is unknown. If the user has rated the app the alert will never show again until the app is uninstalled.

I decided to keep this helper very simple by simply showing the custom rate app alert after a set amount of app launches. I decided to not go down the route of looking for things such as  

If SKStoreReviewController is not supported than this helper will show a custom rate app alert after a set amount of app launches. It will than show further alerts in 4 month intervals until the limit of 3 alerts per year has been reached. Once a new year has started everything will reset and start again.

# Cocoa Pods

CocoaPods is a dependency manager for Cocoa projects. You can install it with the following command:

```swift
$ gem install cocoapods
```

CocoaPods 1.1+ is required to build.

To integrate SwiftyRate into your Xcode project using CocoaPods, specify it in your Podfile:

```swift
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.3.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'SwiftyRate'
end
```

Then, run the following command:

```swift
$ pod install
```

You can also download the CocoaPods app for macOS and manage your pods this way.

https://cocoapods.org/app

# Set-Up

- Step 1: Add the SwiftyMusic.swift file to your project or if you used CocoaPods add the the 

```swift
import SwiftyRate 
```

to your .swift file(s).

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

# Release Notes

- v3.2.4

Swift 4 update

- v3.2.3

Updated request method (please see instructions)

Print statements will now only print in DEBUG mode

Cleanup

- v3.2.2

Cleanup

- v3.2.1

Fixed request method when using custom app launches

- v3.2

The app ID is now fetched automatically 

Updated alert text

- v3.1

Updated to Swift 3.1

Added SKStoreReviewController

Renamed "Cancel" button to "Not Now"

- v3.0.1

Cleanup

- v3.0

Renamed to SwiftyRate

Redesigned to behave more like the upcoming SKStoreReviewController
