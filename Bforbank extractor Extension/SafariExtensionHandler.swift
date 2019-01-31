//
//  SafariExtensionHandler.swift
//  Bforbank extractor Extension
//
//  Created by Thomas Brichart on 18/01/2019.
//  Copyright © 2019 Thomas Brichart. All rights reserved.
//

import SafariServices

struct Operation {
    let date: Date
    let amount: Float
    let details: String
}

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url)))")
            
            guard let accountNumber = userInfo?["accNumber"] as? String else {
                print("Could not retrieve account number")
                return
            }
            
            guard let operations = userInfo?["operations"] as? [Any] else {
                print("Could not process incoming html")
                return
            }
            
            var allOperations = [Operation]()
            
            for operation in operations {
                guard let operationElements = operation as? [String] else {
                    print("Could not process operations")
                    return
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                guard let date = formatter.date(from: operationElements[0]) else {
                    print("Could not get date from operation")
                    return
                }
                
                let amount = (operationElements[1].replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "&nbsp;", with: "") as NSString).floatValue
                
                let details = operationElements[2]
                
                let operation = Operation(date: date, amount: amount, details: details)
                
                allOperations.append(operation)
            }
            
            guard let ofxString = self.buildOFX(operationList: allOperations, accountNumber: accountNumber) else {
                print("Could not build OFX string")
                return
            }
            
            print("Saving OFX")
            self.saveInFile(dataString: ofxString)
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
        
        window.getActiveTab(completionHandler: { tab in
            tab?.getActivePage(completionHandler: { page in
                
                page?.dispatchMessageToScript(withName: "getPageSource", userInfo: nil)
            })
        })
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    func saveInFile(dataString: String) {
        
        let filePath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first!).appendingPathComponent("bforbank-export.ofx")
        
        do {
            try dataString.write(to: filePath, atomically: false, encoding: .utf8)
        } catch let error {
            print(error)
        }
    }
    
    func buildOFX(operationList: [Operation], accountNumber: String) -> String? {
        guard operationList.count > 0 else {
            print("Empty operation list")
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        var header = "<OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO</STATUS>" + "<DTSERVER>" + dateFormatter.string(from: Date()) + "<LANGUAGE>FRA</SONRS></SIGNONMSGSRSV1>"
        header += "<BANKMSGSRSV1><STMTTRNRS><TRNUID>" + accountNumber
        header += "<STATUS><CODE>0<SEVERITY>INFO</STATUS>"
        header += "<STMTRS><CURDEF>EUR"
        header += "<BANKACCTFROM><BANKID>16218<BRANCHID>00001<ACCTID>" + accountNumber + "<ACCTTYPE>CHECKING</BANKACCTFROM>"
        header += "<BANKTRANLIST>"
        header += "<DTSTART>" + dateFormatter.string(from: operationList.last!.date)
        header += "<DTEND>" + dateFormatter.string(from: operationList.first!.date)
        
        let footer = "</BANKTRANLIST></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>"
        
        var operations = ""
        
        operationList.forEach { operation in
            let fitid: String = dateFormatter.string(from: operation.date) + "\(operation.amount) \(operation.details)" + accountNumber
            
            operations += "<STMTTRN><TRNTYPE>OTHER"
            operations += "<DTPOSTED>" + dateFormatter.string(from: operation.date)
            operations += "<TRNAMT>\(operation.amount)"
            operations += "<FITID>" + fitid.md5() + ""
            operations += "<NAME>" + operation.details.split(separator: "\n")[0]
            operations += "<MEMO>" + operation.details + "</STMTTRN>"
        }
        
        return header + operations + footer
    }
}
