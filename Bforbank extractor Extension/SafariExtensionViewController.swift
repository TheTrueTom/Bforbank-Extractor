//
//  SafariExtensionViewController.swift
//  Bforbank extractor Extension
//
//  Created by Thomas Brichart on 18/01/2019.
//  Copyright © 2019 Thomas Brichart. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
