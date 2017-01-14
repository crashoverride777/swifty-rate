# SwiftyRateAppAlert

A simple helper to show a rate game/app UIAlertController after a set amount of app launches.

If you are looking for a more feature rich and advanced helper have a look at these 2 popular repositories.

https://github.com/nicklockwood/iRate

https://github.com/arashpayan/appirater

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

No more source breaking changes after this update. All future changes will be handled with deprecated messages unless the whole API changes.
