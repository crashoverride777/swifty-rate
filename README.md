# LeaveAppReview

A simple helper class to show a rate game/app alert after a set amount of app launches.

If you are looking for a more feature rich and advanced helper check these 2 great helper.

https://github.com/nicklockwood/iRate

https://github.com/arashpayan/appirater

# SetUp

- Step 1:

Copy the LeaveAppReview.swift file into your project

- Step 2:

In LeaveAppReview.swift go to the struct "RateGame" and set your desired app launches until showing the alert.
To not annoy your users I would set this to at least 15-20.

- Step 3:

Still in the "RateGame" struct enter your app ID from iTunes Connect

To get the ID login to iTunes connect and go to MyApps-AppInformation and you should see it under General Information.

- Step 4:

I prefer to show the rateGameAlert at app launch. To do this go to your intial ViewController (GameViewController) and comform to the protocol

```swift
class ViewController: UIViewController, RateGameAlert {....
```

Than create an NSTimer (this ensures your app fully launched before the alert is shown)

```swift
NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(rateGameAlert), userInfo: nil, repeats: false)
```

and the corresponding function calling the checkRateGameAlert method from the helper

func rateGameAlert() {
    checkRateGameAlert(forAppURL: "Enter your app store url")
}


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

Small tweaks

- v1.0
