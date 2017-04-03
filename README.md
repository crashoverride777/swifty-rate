# SwiftyRate

A simple helper to show a SKStoreReviewController or custom rate game/app UIAlertController.

This helper will use the SKStoreReviewController (iOS 10.3) if its supported otherwise it will show a custom alert with similar rules and behaviours. Apple restricts the use of SKStoreReviewController to 3 times per year, the actual logic behind the scheduling is unknown. If the user has rated the app the alert will never show again until the app is uninstalled.

If SKStoreReviewController is not supported than this helper will show a custom rate app alert after a set amount of requests. It will than show further alerts in 4 month intervals until the limit of 3 alerts per year has been reached. Once a new year has started everything will reset and start again.

# Cocoa Pods

I know that the current way with copying the .swift file(s) into your project sucks and is bad practice, so I am working hard to finally support CocoaPods very soon. Stay tuned.

In the meantime I would create a folder on your Mac, called something like SharedFiles, and drag the swift file(s) into this folder. Than drag the files from this folder into your project, making sure that "copy if needed" is not selected. This way its easier to update the files and to share them between projects.

# How to use

- Step 1: 

Copy the SwiftyRate.swift file into your project

- Step 2:

Request review

As Apple describes in the documentation for SKStoreReviewController 

"Although you should call this method when it makes sense in the user experience flow of your app, the actual display of a rating/review request view is governed by App Store policy. Because this method may or may not present an alert, it's not appropriate to call it in response to a button tap or other user action."



By default this helper will offer 3 types of alert types (appLaunch, gameOver, buttonPressed). The number of times the request methods needs to be called until the 1st alert is shown depends on the type.

.appLaunch     = 18 times
.gameOver      = 40 times
.buttonPressed = 60 times

UIViewController

```swift
SwiftyRate.request(type: .appLaunch, from: self)
SwiftyRate.request(type: .gameOver, from: self)
SwiftyRate.request(type: .buttonPressed, from: self)
```

// SpriteKit Scene (needs to be shown outside ViewDidLoad or it will not work)

```swift
SwiftyRate.request(type: .appLaunch, from: view?.window?.rootViewController)
SwiftyRate.request(type: .gameOver, from: view?.window?.rootViewController)
SwiftyRate.request(type: .buttonPressed, from: view?.window?.rootViewController)
``

To test you can set the type to debug

```swift
SwiftyRate.request(type: .debug, from: self) 
```

Note: Should you forget to set this back to regular type this helper will change the type to .buttonPressed when app is in release mode

# Release Notes

- v3.2

The app ID is now fetched automatically 

Simplified request method (please check documentation again)

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
