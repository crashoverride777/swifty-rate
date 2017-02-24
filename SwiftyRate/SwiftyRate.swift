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

import UIKit
//import StoreKit

/// Get app store URL
private func getStoreURL(forAppID appID: String) -> String {
    #if os(iOS)
        return "itms-apps://itunes.apple.com/app/id" + appID
    #endif
    #if os(tvOS)
        return "com.apple.TVAppStore://itunes.apple.com/app/id" + appID
    #endif
}

/// Alert strings
private enum LocalizedText { // TODO
    static let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "this app"
    
    static let title = "Enjoying \(appName)?"
    static let message = "Would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!"
    static let rate = "Rate"
    static let cancel = "Cancel"
}

/// Keys
private enum Key: String {
    case isRemoved           = "SwiftyRateIsRemovedKey"
    case currentAppLaunches  = "SwiftyRateAppLaunchesKey"
    case alertsShownThisYear = "SwiftyRateShownThisYearKey"
    case savedMonth          = "SwiftyRateSavedMonthKey"
    case savedYear           = "SwiftyRateSavedYearKey"
}

/**
 SwiftyRateAppAlert
 
 A helper for showing a SKStoreReviewController or rate game UIAlertController.
 */
public enum SwiftyRate {
    
    // MARK: - Properties
    
    /// Is removed
    fileprivate static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: Key.isRemoved.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.isRemoved.rawValue) }
    }
    
    /// Current app launches
    fileprivate static var currentAppLaunches: Int {
        get { return UserDefaults.standard.integer(forKey: Key.currentAppLaunches.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.currentAppLaunches.rawValue) }
    }
    
    /// Alerts shown this year
    fileprivate static var alertsShownThisYear: Int {
        get { return UserDefaults.standard.integer(forKey: Key.alertsShownThisYear.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.alertsShownThisYear.rawValue) }
    }
    
    /// Saved month
    fileprivate static var savedMonth: Int {
        get { return UserDefaults.standard.integer(forKey: Key.savedMonth.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.savedMonth.rawValue) }
    }
    
    /// Saved year
    fileprivate static var savedYear: Int {
        get { return UserDefaults.standard.integer(forKey: Key.savedYear.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.savedYear.rawValue) }
    }
    
    // MARK: - Methods
    
    /// Request review controller
    ///
    /// - parameter forAppID: The app ID string for the app to rate.
    /// - parameter appLaunchesUntilFirstAlert: The app launches required until the first alert is shown. Set to 0 or negative number to test alert. Defaults to 18.
    /// - parameter viewController: The view controller that will present the alert.
    public static func request(forAppID appID: String, appLaunchesUntilFirstAlert: Int = 18, from viewController: UIViewController?) {
        
        /*
        // SKStoreReviewController
        #if os(iOS)
            if #available(iOS 10.3, *) {
                SKStoreReviewController.request()
                return
            }
        #endif
        */
        
        // Custom alert
        guard let viewController = viewController else { return }
        
        if appLaunchesUntilFirstAlert > 0 {
            guard !isRemoved, isTimeToShowAlert(appLaunches: appLaunchesUntilFirstAlert) else { return }
        }
       
        let alertController = UIAlertController(title: LocalizedText.title, message: LocalizedText.message, preferredStyle: .alert)
        
        let rateAction = UIAlertAction(title: LocalizedText.rate, style: .default) { _ in
            isRemoved = true
            guard let url = URL(string: getStoreURL(forAppID: appID)) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(rateAction)
        
        let cancelAction = UIAlertAction(title: LocalizedText.cancel, style: .default)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: - Internal

private extension SwiftyRate {
    
    /// Check if alerts needs to be showed
    static func isTimeToShowAlert(appLaunches appLaunchesUntilFirstAlert: Int) -> Bool {
        
        // Get date
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // Set local to US so it always returns an english formatted number
        formatter.dateFormat = "MM.yyyy"
        let dateResult = formatter.string(from: date)
        
        guard let monthString = dateResult.components(separatedBy: ".").first, let month = Int(monthString) else { return false }
        guard let yearString = dateResult.components(separatedBy: ".").last, let year = Int(yearString) else { return false }
        
        // Update saved month/year if never set before
        if savedMonth == 0 {
            savedMonth = month
        }
        
        if savedYear == 0 {
            savedYear = year
        }
        
        // If year has changed reset everthing
        if year > savedYear {
            savedYear = year
            alertsShownThisYear = 0
            currentAppLaunches = 0
        }
        
        // Check that max (3) alerts shown per year is not reached
        guard alertsShownThisYear < 3 else { return false }
        
        // Show alert if needed
        currentAppLaunches += 1
        
        if currentAppLaunches == appLaunchesUntilFirstAlert {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        } else if currentAppLaunches > appLaunchesUntilFirstAlert, month >= (savedMonth + 4) {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        }
        
        // No alert is needed to show
        return false
    }
}
