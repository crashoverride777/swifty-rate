
//  Created by Dominik on 22/08/2015.

//    The MIT License (MIT)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

//    v1.0

import UIKit
import Foundation

private struct AlertString {
    static let title = "Review App"
    static let message = "If you enjoy playing ... would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"
    static let leaveReview = "Leave Review"
    static let remindMeLater = "Remind Me Later"
    static let noThanks = "No, Thanks"
}

private struct RateGame {
    
    /// URL
    static let url = "itms-apps://itunes.apple.com/app/id" + "YourAppID"
    
    /// App launches till showing
    static let appLaunchesTillShowing = 0 //30
    
    /// Current app launches
    static let showKey = "RateGameCounterUntilAlertKey"
    static var currentAppLaunches: Int {
        get { return NSUserDefaults.standardUserDefaults().integerForKey(showKey) }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: showKey) }
    }
    
    /// Hidding
    static let hideKey = "RateGameHideAlertKey"
    static var doNotShow: Bool {
        get { return NSUserDefaults.standardUserDefaults().boolForKey(hideKey) }
        set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: hideKey) }
    }
}

protocol RateGameAlert { }
extension RateGameAlert where Self: UIViewController {
    
    func checkRateGameAlert() {
        
        /// If already reviewed or pressed no thanks button exit method
        guard !RateGame.doNotShow else { return }
        
        /// Increase launch counter
        RateGame.currentAppLaunches += 1
        
        /// Check if timesTillShowingAlert counter is reached
        guard RateGame.currentAppLaunches >= RateGame.appLaunchesTillShowing else { return }
        
        /// Show alert
        showAlert()
    }
    
    private func showAlert() {
        
        /// Alert controller
        let alertController = UIAlertController(title: AlertString.title, message: AlertString.message, preferredStyle: .Alert)
        
        /// Leave review
        let leaveReviewAction = UIAlertAction(title: AlertString.leaveReview, style: .Default) { _ in
            RateGame.doNotShow = true
            guard let url = NSURL(string: RateGame.url) else { return }
            UIApplication.sharedApplication().openURL(url)
        }
        alertController.addAction(leaveReviewAction)
        
        /// Remind me later
        let remindMeLaterAction = UIAlertAction(title: AlertString.remindMeLater, style: .Default) { _ in
            RateGame.currentAppLaunches = RateGame.currentAppLaunches / 2
        }
        alertController.addAction(remindMeLaterAction)
        
        /// No thanks
        let noThanksAction = UIAlertAction(title: AlertString.noThanks, style: .Cancel) { _ in
            RateGame.doNotShow = true
        }
        alertController.addAction(noThanksAction)
        
        /// Present alert
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
}