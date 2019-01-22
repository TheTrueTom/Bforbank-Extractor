//
//  ViewController.swift
//  Bforbank extractor
//
//  Created by Thomas Brichart on 18/01/2019.
//  Copyright © 2019 Thomas Brichart. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBOutlet var appNameLabel: NSTextField!
    @IBOutlet var disclaimerLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appNameLabel.stringValue = "Bforbank extractor";
        self.disclaimerLabel.stringValue = "This app is not affiliated with BforBank or any of their services."
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.thetruetom.Bforbank-extractor-Extension") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.

            }
        }
    }

}
