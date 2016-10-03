# SwiftyRateAppAlert

Note: I will lock down this project withing the next 1-2 updates. This means there will be no more source breaking changes which I am sure is frustrating some. All future changes will be handled via deprecated warnings. I am also looking to create a cocoa pod for this project very soon.

A simple protocol extension to show a rate game/app UIAlertController after a set amount of app launches.

If you are looking for a more feature rich and advanced helper have a look at these 2 popular projects.

https://github.com/nicklockwood/iRate

https://github.com/arashpayan/appirater

# SetUp

- Step 1:

Copy the SwiftyRateAppAlert.swift file into your project

- Step 2:

I prefer to show the rateGameAlert at app launch. To do this go to your intial ViewController (GameViewController) and comform to the protocol and than check for the alert in viewDidAppear (viewDidLoad is too early to show an alert)

```swift
class ViewController: UIViewController, RateGameAlert {....

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
