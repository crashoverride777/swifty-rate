//
//  GameViewController.swift
//  LeaveAppReview
//
//  Created by Dominik on 19/05/2016.
//  Copyright (c) 2016 Dominik Ringler. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, RateGameAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //checkRateGameAlert(forAppID: "Enter your app ID, iTunesConnect -> GeneralApp Information") // This way default app launches is 25
        
        checkRateGameAlert(forAppID: "Enter your app ID, iTunesConnect -> GeneralApp Information", appLaunchesUntilAlert: 0) // This way you set your custom app launches
        
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
