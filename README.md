# SwiftyRateAppAlert

A enum to show a rate game/app UIAlertController after a set amount of app launches.

If you are looking for a more feature rich and advanced helper have a look at these 2 popular projects.

https://github.com/nicklockwood/iRate

https://github.com/arashpayan/appirater

Cocoa Pods

I know that the current way with copying the .swift file(s) into your project sucks and is bad practice, so I am working hard to finally support CocoaPods very soon. Stay tuned.

# SetUp

- Step 1:

Copy the SwiftyRateAppAlert.swift file into your project

- Step 2:

I prefer to show the rateGameAlert at app launch, so I use viewDidAppear in my first view controller (viewDidLoad is too early to show an alert)

```swift
class ViewController: UIViewController {

override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // This way it will use the default app launches setting of 25
        SwiftyRateAppAlert.check(forAppID: "Enter your app ID", view: view)
        
        // This way it will use your own custom app launches setting
        SwiftyRateAppAlert.check(forAppID: "Enter your app ID", appLaunchesUntilAlert: 5, view: view) 

    }
```

To get your app ID, login to iTunes connect and go to MyApps-AppInformation and you should see it under General Information.

# Release Notes

- v2.0

Project has been renamed to SwiftyRateAppAlert.

No more source breaking changes after this update. All future changes will be handled with deprecated messages.
