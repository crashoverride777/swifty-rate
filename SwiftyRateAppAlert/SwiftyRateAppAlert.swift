
//  Created by Dominik on 22/08/2015.

//    The MIT License (MIT)
//
//    Copyright (c) 2016-2017 Dominik Ringler
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

//    v2.0

import UIKit
import StoreKit

/// Get app store URL
private func getAppStoreURL(forAppID appID: String) -> String {
    #if os(iOS)
        return "itms-apps://itunes.apple.com/app/id" + appID
    #endif
    #if os(tvOS)
        return "com.apple.TVAppStore://itunes.apple.com/app/id" + appID
    #endif
}

/// Alert strings
private enum AlertString {
    static let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    
    static let title = "Review App"
    static let message = "If you enjoy playing \(appName) would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"
    static let leaveReview = "Leave Review"
    static let remindMeLater = "Remind Me Later"
    static let noThanks = "No, Thanks"
}

/// Keys
private enum Key: String {
    case currentAppLaunches = "RateGameAlertCurrentAppLaunchesKey"
    case isRemoved = "RateGameAlertDoNotShowKey"
}


/**
 SwiftyRateGameAlert
 
 A helper for showing a SKStoreReviewController or rate game UIAlertController.
 */
public enum SwiftyRateGameAlert {
    
    // MARK: - Properties
    
    /// Current app launches
    private static var currentAppLaunches: Int {
        get { return UserDefaults.standard.integer(forKey: Key.currentAppLaunches.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.currentAppLaunches.rawValue) }
    }
    
    /// Dho not show
    private static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: Key.isRemoved.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.isRemoved.rawValue) }
    }
    
    // MARK: - Methods
    
    /// Check rate game alert
    ///
    /// - parameter forAppID: The app ID for the app to rate.
    /// - parameter appLaunchesUntilAlert: The app launches required until the alert is shown. Defaults to 20.
    /// - parameter view: The view that presents the alert.
    public static func request(forAppID appID: String, appLaunchesUntilAlert: Int = 20, view: UIView?) {
        
        // SKStoreReviewController if supported
        /*
         #if os(iOS)
            if #available(iOS 10.3, *) {
                SKStoreReviewController.request()
                return
            }
         #endif
         */
        
        /// Check if already reviewed/cancelled and internet connection
        guard !isRemoved else { return }
        
        /// Increase launch counter
        currentAppLaunches += 1
        
        /// Check if timesTillShowingAlert counter is reached
        guard currentAppLaunches >= appLaunchesUntilAlert else { return }
        
        /// Alert controller
        let alertController = UIAlertController(title: AlertString.title, message: AlertString.message, preferredStyle: .alert)
        
        /// Leave review
        let leaveReviewAction = UIAlertAction(title: AlertString.leaveReview, style: .default) { _ in
            isRemoved = true
            guard let url = URL(string: getAppStoreURL(forAppID: appID)) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(leaveReviewAction)
        
        /// Remind me later
        let remindMeLaterAction = UIAlertAction(title: AlertString.remindMeLater, style: .default) { _ in
            currentAppLaunches = currentAppLaunches / 2
        }
        alertController.addAction(remindMeLaterAction)
        
        /// No thanks
        let noThanksAction = UIAlertAction(title: AlertString.noThanks, style: .destructive) { _ in
            isRemoved = true
        }
        alertController.addAction(noThanksAction)
        
        /// Present alert
        view?.window?.rootViewController?.present(alertController, animated: true)
    }
}
