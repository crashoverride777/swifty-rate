# SwiftyRate

A simple helper to show a SKStoreReviewController or custom rate game/app UIAlertController.

This helper is designed to behave similary to the upcoming SKStoreReviewController from Apple which I will include once iOS 10.3 is released.

This helper will use the SKStoreReviewController (iOS 10.3) if its supported otherwise it will show a custom alert with similar rules and behaviours. Apple restricts the use of SKStoreReviewController to 3 times per year, the actual logic behind the scheduling is unknown. If the user has rated the app the alert will never show again until the app is uninstalled.

If SKStoreReviewController is not supported than this helper will show a custom rate app alert after a set amount of app launches. It will than show further alerts in 4 month intervals until the limit of 3 alerts per year has been reached. Once a new year has started everything will reset and start again.

![alt tag](https://raw.githubusercontent.com/crashoverride777/SwiftyRate/Image.png)

# Cocoa Pods

I know that the current way with copying the .swift file(s) into your project sucks and is bad practice, so I am working hard to finally support CocoaPods very soon. Stay tuned.

In the meantime I would create a folder on your Mac, called something like SharedFiles, and drag the swift file(s) into this folder. Than drag the files from this folder into your project, making sure that "copy if needed" is not selected. This way its easier to update the files and to share them between projects.

# How to use

- Step 1: 

Copy the SwiftyRate.swift file into your project

- Step 2:

Request review e.g at app launch. 

As Apple describes in the documentation for SKStoreReviewController 

"Although you should call this method when it makes sense in the user experience flow of your app, the actual display of a rating/review request view is governed by App Store policy. Because this method may or may not present an alert, it's not appropriate to call it in response to a button tap or other user action."


```swift
class ViewController: UIViewController {

// NOTE: Use view did appear as viewDidLoad is to early to show a UIAlertController

override func viewDidAppear(animated: Bool) { 
        super.viewDidAppear(animated)
       
        // This way it will use the default app launches setting of 18.
        SwiftyRate.request(forAppID: "Enter your app ID", from: self)
        
        // This way it will use your own custom app launches setting e.g 15.
        // I would not go lower than 10-15 app launches.  
        SwiftyRate.request(forAppID: "Enter your app ID", appLaunchesUntilFirstAlert: 15, from: self) 
    }
    
// To test the alert you can set appLaunchesUntilFirstAlert to 0.
```

To get your app ID, login to iTunes connect and go to MyApps-AppInformation and you should see it under General Information.

# Release Notes

- v3.0.1

Cleanup

- v3.0

Renamed to SwiftyRate

Redesigned to behave more like the upcoming SKStoreReviewController
