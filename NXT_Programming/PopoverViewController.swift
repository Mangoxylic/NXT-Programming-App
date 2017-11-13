//
//  PopoverViewController.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/4/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit
import SocketIO

protocol PopoverDelegate {
    func sendMacAddresses(macAddresses: Array<String>)
    func connectToServer()
    func disconnectFromServer()
    func initializePopover()
}

class PopoverViewController: UIViewController, ServerDelegate {
    @IBOutlet weak var serverStatusLabel: UILabel!
    @IBOutlet weak var getMacAddressesButton: UIButton!
    @IBOutlet weak var connectToServerButton: UIButton!
    @IBOutlet weak var disconnectFromServerButton: UIButton!
    
    var serverStatusString: String = "Not Connected"
    var getMacAddressButtonEnabled: Bool = false
    var connectToServerButtonEnabled: Bool = true
    var disconnectFromServerButtonEnabled: Bool = false
    
    var delegate: PopoverDelegate?
    let socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://robocode-server.herokuapp.com")!)
    var macAddressArray: Array<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 200, height: 200)
        
        delegate?.initializePopover()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let source = segue.source as? AddressTableViewController {
            source.serverDelegate = self
        }
    }
    
    
    @IBAction func getMACAddressesButtonDidPress(_ sender: UIButton) {
        /*
        self.macAddressArray.append("Test 1")
        self.macAddressArray.append("Test 2")
        self.macAddressArray.append("Test 3")
        */
        self.delegate?.sendMacAddresses(macAddresses: self.macAddressArray)
    }
    
    @IBAction func connectToServerButtonDidPress(_ sender: UIButton) {
        self.delegate?.connectToServer()
    }

    @IBAction func disconnectFromServerButtonDidPress(_ sender: UIButton) {
        self.delegate?.disconnectFromServer()
        self.serverStatusLabel.text = "Not Connected"
        self.serverStatusLabel.textColor = UIColor.red
        self.connectToServerButton.isEnabled = true
        self.disconnectFromServerButton.isEnabled = false
    }
    
    // Server Delegate functions
    func updateServerStatusWhere(connected: Bool) {
        //print("Updating server status")
        if connected {
            self.serverStatusLabel.text = "Connected"
            self.serverStatusLabel.textColor = UIColor.green
            self.getMacAddressesButton.isEnabled = true
            self.connectToServerButton.isEnabled = false
            self.disconnectFromServerButton.isEnabled = true
        } else {
            self.serverStatusLabel.text = "Not Connected"
            self.serverStatusLabel.textColor = UIColor.red
            self.getMacAddressesButton.isEnabled = false
            self.connectToServerButton.isEnabled = true
            self.disconnectFromServerButton.isEnabled = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
