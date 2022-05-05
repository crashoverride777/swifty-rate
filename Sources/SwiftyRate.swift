//    The MIT License (MIT)
//
//    Copyright (c) 2016-2022 Dominik Ringler
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

/**
 SwiftyRate
 
 A helper for showing a SKStoreReviewController or a custom rate game UIAlertController.
 */
public enum SwiftyRate {
    
    // MARK: - Types
    
    public struct Request {
        let afterAppLaunches: Int
        let customAlertTitle: String
        let customAlertMessage: String
        let customAlertActionCancel: String
        
        public init(afterAppLaunches: Int,
                    customAlertTitle: String,
                    customAlertMessage: String,
                    customAlertActionCancel: String) {
            self.afterAppLaunches = afterAppLaunches
            self.customAlertTitle = customAlertTitle
            self.customAlertMessage = customAlertMessage
            self.customAlertActionCancel = customAlertActionCancel
        }
    }
    
    // MARK: - Properties
    
    private static let iTunesBaseURL = UIDevice.current.userInterfaceIdiom == .tv ?
        "com.apple.TVAppStore://itunes.apple.com/app/id" : "itms-apps://itunes.apple.com/app/id"
    
    private static let dataURL = "http://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "-")"
    private static var appID: Int?
    
    private static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: "SwiftyRateIsRemovedKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateIsRemovedKey") }
    }
    
    private static var requestCounter: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateRequestCounterKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateRequestCounterKey") }
    }
    
    private static var alertsShownThisYear: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateShownThisYearKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateShownThisYearKey") }
    }
    
    private static var savedMonth: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateSavedMonthKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateSavedMonthKey") }
    }
    
    private static var savedYear: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateSavedYearKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateSavedYearKey") }
    }
    
    // MARK: - Request
    
    /// Request rate app alert
    ///
    /// - parameter request: The request configuration model.
    /// - parameter viewController: The view controller that will present the UIAlertController.
    public static func requestReview(_ request: Request, from viewController: UIViewController) {
       
        // Make sure app launches is not set to 0 or lower
        var appLaunchesUntilFirstAlert = request.afterAppLaunches
        
        if appLaunchesUntilFirstAlert <= 0 {
            appLaunchesUntilFirstAlert = 15
        }
        
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
                requestReview(request, from: viewController)
            }
            return
        }
    
        // Show alert
        guard !isRemoved, isTimeToShowAlert(forAppLaunches: appLaunchesUntilFirstAlert) else {
            return
        }
        
        let alertController = UIAlertController(
            title: request.customAlertTitle,
            message: request.customAlertMessage,
            preferredStyle: .alert
        )
        
        let rateAction = UIAlertAction(title: "☆☆☆☆☆", style: .default) { _ in
            isRemoved = true
            guard let url = URL(string: iTunesBaseURL + "\(appID)") else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        alertController.addAction(rateAction)
        
        let cancelAction = UIAlertAction(title: request.customAlertActionCancel, style: .default)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: - Private Methods

private extension SwiftyRate {
    static func fetchAppID(handler: @escaping () -> Void) {
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
                results.forEach { appID = $0["trackId"] as? Int }
                
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
