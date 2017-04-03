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

/// Data url
private let dataURL = "http://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "-")"

/// JSON Keys
private enum JSONKey: String {
    case app_id = "trackId"
}

/// Get app store URL
private func getStoreURL(forID appID: Int) -> String {
    #if os(iOS)
        return "itms-apps://itunes.apple.com/app/id\(appID)"
    #endif
    #if os(tvOS)
        return "com.apple.TVAppStore://itunes.apple.com/app/id\(appID)"
    #endif
}

/// Alert strings
private enum LocalizedText { // TODO
    static let title = "Enjoying \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "this app")?"
    static let message = "Tap the stars to rate it on the App Store."
    static let rate = "☆☆☆☆☆"
    static let notNow = "Not Now"
}

/// Keys
private enum Key: String {
    case isRemoved           = "SwiftyRateIsRemovedKey"
    case requestCounter      = "SwiftyRateRequestCounterKey"
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
    
    /// Request type
    public enum RequestType {
        case debug
        case appLaunch
        case gameOver
        case buttonPressed
    }
    
    /// App ID
    fileprivate static var appID: Int?
    
    /// Is removed
    fileprivate static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: Key.isRemoved.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.isRemoved.rawValue) }
    }
    
    /// Request counter
    fileprivate static var requestCounter: Int {
        get { return UserDefaults.standard.integer(forKey: Key.requestCounter.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: Key.requestCounter.rawValue) }
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
    
    /// Request rate app alert
    ///
    /// - parameter viewController: The view controller that will present the alert.
    public static func request(from viewController: UIViewController?) {
        
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
                request(from: viewController)
            }
            return
        }
        
        // Update requests
        let requestsUntilFirstAlert: Int = 18
        
        // Show alert
        guard let viewController = viewController else { return }
        
        if requestsUntilFirstAlert >= 0 {
            guard !isRemoved, isTimeToShowAlert(requestsUntilFirstAlert: requestsUntilFirstAlert) else { return }
        }
        
        let alertController = UIAlertController(title: LocalizedText.title, message: LocalizedText.message, preferredStyle: .alert)
        
        let rateAction = UIAlertAction(title: LocalizedText.rate, style: .default) { _ in
            isRemoved = true
            guard let url = URL(string: getStoreURL(forID: appID)) else { return }
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
            print("SwiftyRate url error")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Error
            if let error = error {
                print("SwiftyRate data with task error: \(error.localizedDescription)")
                return
            }
            
            // Check response
            guard let _ = response else {
                print("SwiftyRate response error")
                return
            }
            
            // Check data
            guard let data = data else {
                print("SwiftyRate data error")
                return
            }
            
            // JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                // Get data
                guard let jsonData = json as? [String: Any] else {
                    print("SwiftyRate json data object error")
                    return
                }
                
                // Get results
                guard let results = jsonData["results"] as? [[String: Any]] else {
                    print("SwiftyRate json results error")
                    return
                }
                
                // Update app id
                results.forEach {
                    appID = $0[JSONKey.app_id.rawValue] as? Int
                }
            
                // Return handler
                DispatchQueue.main.async {
                    guard appID != nil else { return }
                    handler()
                }
            }
                
            catch let error {
                print("SwiftyRate JSON parse error" + error.localizedDescription)
            }
        }.resume()
    }
}

// MARK: - Check Time To Show Alert

private extension SwiftyRate {
    
    /// Check if alerts needs to be showed
    static func isTimeToShowAlert(requestsUntilFirstAlert: Int) -> Bool {
        
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
            requestCounter = 0
        }
        
        // Check that max (3) alerts shown per year is not reached
        guard alertsShownThisYear < 3 else { return false }
        
        // Show alert if needed
        requestCounter += 1
        
        if requestCounter == requestsUntilFirstAlert {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        } else if requestCounter > requestsUntilFirstAlert, month >= (savedMonth + 4) {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        }
        
        // No alert is needed to show
        return false
    }
}
