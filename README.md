# LeaveAppReview

A simple helper class to show a rate game/app alert after a set amount of app launches.

If you are looking for a more feature rich and advanced helper check these 2 great helper.

https://github.com/nicklockwood/iRate

https://github.com/arashpayan/appirater

# SetUp

- Step 1:

Copy the LeaveAppReview.swift file into your project

By default the app launches until the alert are set to 25. To change this value go to the helper and adjust to your preferred value.
To not annoy your users I would set this lower 20.

- Step 2:

I prefer to show the rateGameAlert at app launch. To do this go to your intial ViewController (GameViewController) and comform to the protocol and than check for the alert in viewDidAppear (viewDidLoad is too early to show an alert)

```swift
class ViewController: UIViewController, RateGameAlertController {....

override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkRateGameAlert(forAppID: "Enter your app ID")
    }
```

To get your app ID login to iTunes connect and go to MyApps-AppInformation and you should see it under General Information.

Note: 
If you want to show the alert at a later step simply add this code at the desired viewController

If you would like to show this alert in a SKScene than go to the helper and change the protocol extension from
```swift
extension RateGameAlert where Self: UIViewController {
```

to 
```swift
extension RateGameAlert where Self: SKScene {
```

# Release Notes

- v1.1

Tweaks and improvements

- v1.0
