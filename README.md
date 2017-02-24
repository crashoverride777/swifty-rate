# SwiftyRateAppAlert

A simple helper to show a rate game/app UIAlertController

This helper is desinged to behave like the upcoming SKStoreReviewController (I will include this once released). 

What does that mean exactly?

You will request the 1st review alert after a set amount of app launches e.g 20. Than the helper will show another rate app alert after 4 months and another one after 4 months. In total there will be a max of 3 alerts shown. If the year has passed everything will reset and start again.


# SKStoreReviewController

It seems Apple will introduce their own rating sytem (view controller) with iOS 10.3. I will update this helper accordingly when the update is released.

# Cocoa Pods

I know that the current way with copying the .swift file(s) into your project sucks and is bad practice, so I am working hard to finally support CocoaPods very soon. Stay tuned.

In the meantime I would create a folder on your Mac, called something like SharedFiles, and drag the swift file(s) into this folder. Than drag the files from this folder into your project, making sure that "copy if needed" is not selected. This way its easier to update the files and to share them between projects.

# SetUp

- Step 1:

Copy the SwiftyRateAppAlert.swift file into your project

- Step 2:

I prefer to show the rateGameAlert at app launch, so I use viewDidAppear in my first view controller (viewDidLoad is too early to show an alert)

```swift
class ViewController: UIViewController {

override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // To test the alert you can set appLaunchesUntilAlert to something negative e.g -1

        // This way it will use the default app launches setting of 20
        SwiftyRateAppAlert.request(forAppID: "Enter your app ID", from: self)
        
        // This way it will use your own custom app launches setting
        SwiftyRateAppAlert.request(forAppID: "Enter your app ID", appLaunchesUntilAlert: 5, from: self) 
    }
```

To get your app ID, login to iTunes connect and go to MyApps-AppInformation and you should see it under General Information.

# Release Notes

- v3.0

Redesigned to behave more like the upcoming SKStoreReviewController
