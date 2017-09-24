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
import StoreKit

/// Localized text - TODO
private enum LocalizedText {
    static let title = "Enjoying \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "this app")?"
    static let message = "Tap the stars to rate it on the App Store."
    static let rate = "☆☆☆☆☆"
    static let notNow = "Not Now"
}

// MARK: - Get iTunes Web URL

private enum ITunesURL: String {
    
    #if os(iOS)
        case base = "itms-apps://itunes.apple.com/app/id"
    #endif
    #if os(tvOS)
        case base = "com.apple.TVAppStore://itunes.apple.com/app/id"
    #endif
}

/// User default keys
private enum UserDefaultKey: String {
    case isRemoved           = "SwiftyRateIsRemovedKey"
    case requestCounter      = "SwiftyRateRequestCounterKey"
    case alertsShownThisYear = "SwiftyRateShownThisYearKey"
    case savedMonth          = "SwiftyRateSavedMonthKey"
    case savedYear           = "SwiftyRateSavedYearKey"
}

/**
 SwiftyRateAppAlert
 
 A helper for showing a SKStoreReviewController or a custom rate game UIAlertController.
 */
public enum SwiftyRate {
    
    // MARK: - Properties
    
    /// Data url
    private static let dataURL = "http://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "-")"
    
    /// App ID
    private static var appID: Int?
    
    /// Is removed
    private static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: UserDefaultKey.isRemoved.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.isRemoved.rawValue) }
    }
    
    /// Request counter
    private static var requestCounter: Int {
        get { return UserDefaults.standard.integer(forKey: UserDefaultKey.requestCounter.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.requestCounter.rawValue) }
    }
    
    /// Alerts shown this year
    private static var alertsShownThisYear: Int {
        get { return UserDefaults.standard.integer(forKey: UserDefaultKey.alertsShownThisYear.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.alertsShownThisYear.rawValue) }
    }
    
    /// Saved month
    private static var savedMonth: Int {
        get { return UserDefaults.standard.integer(forKey: UserDefaultKey.savedMonth.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.savedMonth.rawValue) }
    }
    
    /// Saved year
    private static var savedYear: Int {
        get { return UserDefaults.standard.integer(forKey: UserDefaultKey.savedYear.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.savedYear.rawValue) }
    }
    
    // MARK: - Methods
    
    /// Request rate app alert
    ///
    /// - parameter viewController: The view controller that will present the UIAlertController.
    /// - parameter appLaunchesUntilFirstAlert: The requests needed until first alert is shown. Set to negative value to test. Defaults to 18.
    public static func request(from viewController: UIViewController, afterAppLaunches appLaunchesUntilFirstAlert: Int = 18) {
        
        // SKStoreReviewController
        #if os(iOS)
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return
            }
        #endif
        
        // Custom alert
        
        // Check app id
        guard let appID = appID else {
            fetchAppID {
                request(from: viewController, afterAppLaunches: appLaunchesUntilFirstAlert)
            }
            return
        }
    
        // Show alert
        if appLaunchesUntilFirstAlert >= 0 {
            guard !isRemoved, isTimeToShowAlert(forAppLaunches: appLaunchesUntilFirstAlert) else { return }
        }
        
        let alertController = UIAlertController(title: LocalizedText.title, message: LocalizedText.message, preferredStyle: .alert)
        
        let rateAction = UIAlertAction(title: LocalizedText.rate, style: .default) { _ in
            isRemoved = true
            guard let url = URL(string: ITunesURL.base.rawValue + "\(appID)") else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(rateAction)
        
        let cancelAction = UIAlertAction(title: LocalizedText.notNow, style: .default)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: - Fetch App ID

private extension SwiftyRate {
    
    /// Fetch app id
    static func fetchAppID(handler: @escaping () -> ()) {
        guard let url = URL(string: dataURL) else {
            print("SwiftyRate url session url error")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Error
            if let error = error {
                print("SwiftyRate url session data with task error: \(error.localizedDescription)")
                return
            }
            
            // Check response
            guard let _ = response else {
                print("SwiftyRate url session response error")
                return
            }
            
            // Check data
            guard let data = data else {
                print("SwiftyRate url session data error")
                return
            }
            
            // JSON
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("SwiftyRate url session json data object error")
                    return
                }
                
                // Get results
                guard let results = json["results"] as? [[String: Any]] else {
                    print("SwiftyRate url session json results error")
                    return
                }
                
                // Update app id
                results.forEach {
                    appID = $0["trackId"] as? Int
                }
                
                guard appID != nil else { return }
            
                // Return handler
                DispatchQueue.main.async {
                    handler()
                }
            }
                
            catch let error {
                print("SwiftyRate url session JSON parse error" + error.localizedDescription)
            }
        }.resume()
    }
}

// MARK: - Check If Time To Show Alert

private extension SwiftyRate {
    
    /// Check if alerts needs to be showed
    static func isTimeToShowAlert(forAppLaunches appLaunchesUntilFirstAlert: Int) -> Bool {
        
        // Get date
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // Set local to US so it always returns an english formatted number
        formatter.dateFormat = "MM.yyyy"
        let dateResult = formatter.string(from: date)
        
        // Get month string
        guard let monthString = dateResult.components(separatedBy: ".").first else {
            print("SwiftyRate month string error")
            return false
        }
        
        // Get month int
        guard let month = Int(monthString) else {
            print("SwiftyRate month int error")
            return false
        }
        
        // Get year string
        guard let yearString = dateResult.components(separatedBy: ".").last else {
            print("SwiftyRate year string error")
            return false
        }
        
        // Get year int
        guard let year = Int(yearString) else {
            print("SwiftyRate year int error")
            return false
        }
        
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
            requestCounter = 0
        }
        
        // Check that max number of 3 alerts shown per year is not reached
        guard alertsShownThisYear < 3 else { return false }
        
        // Update request counter
        requestCounter += 1
        
        // Show alert if needed
        if requestCounter == appLaunchesUntilFirstAlert {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        } else if requestCounter > appLaunchesUntilFirstAlert, month >= (savedMonth + 4) {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        }
        
        // No alert is needed to show
        return false
    }
}

// MARK: - Print 

private extension SwiftyRate {
    
    /// Overrides the default print method so it print statements only show when in DEBUG mode
    static func print(_ items: Any...) {
        #if DEBUG
            Swift.print(items)
        #endif
    }
}
