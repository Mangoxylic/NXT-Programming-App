//
//  ViewController.swift
//  LA's BEST Robotics App
//
//  Created by Erick Chong on 09/20/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit
import SocketIO

/*
// NEED TO INCLUDE THE PROTOCOL UNDER THIS COMMENT
protocol TableDelegate {
    func initializeTable(selectedIndex: Int, macAddressArray: Array<String>)
}

protocol CollectionDelegate {
    func sendEventToCollectionView()
}
 */

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddressDelegate {
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var disconnectButton: UIBarButtonItem!
    @IBOutlet weak var sendJSONButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var getMacAddressesButton: UIButton!
    @IBOutlet weak var macAddressTableView: UITableView!
    
    // NEED THIS VARIABLE
    let client = Client.sharedInstance
    
    
    //let socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!)
    var clientArray: Array<String> = []
    var programNum: Int = -1
    var programsDictionary: NSMutableDictionary = [:]
    
    
    // Delegate variables - NEED THE REST OF THE VARIABLES BELOW THIS COMMENT
    var tableDelegate: TableDelegate?
    var macAddressArray: Array<String> = [] // Used to reload tableView
    var chosenMacAddress: String = "" // The MAC address that the app will "build" to
    var chosenMacAddressIndex: Int = -1 // Also used to reload the tableView
    
    // Variables to modify from the StartupViewController
    var isNewProgram: Bool?
    var programName: String = ""
    var programJSON: String = ""
    var realmID: String = ""
    
    var commandsArray: Array<Dictionary<String, Any>> = []
    
    var collectionDelegate: CollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.disconnectButton.isEnabled = false
        self.sendJSONButton.isEnabled = true
        self.getMacAddressesButton.isEnabled = false
        
        // NEED THE REST OF THE CODE IN THIS FUNCTION BELOW THIS COMMENT
        self.addListeners()
        commandsArray = JSONHelper.parseJSONWith(json: self.programJSON)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    
    // NEED THIS FUNCTION. CALL IN viewDidLoad() METHOD
    func addListeners() {
        /*
        socket.on(clientEvent: .connect) { data, ack in
            print("Mac address that is selected: \(self.chosenMacAddress)")
            
            let json: JSON =  ["commands":[["type":"playsound", "soundfile": "Woops"], ["type":"motor", "brake": true, "power": 100, "revolutions":5, "port":"A"]], "address":self.chosenMacAddress]
            
            
                                                // *********************************************
            let jsonString = json.description   // * CHANGE THIS TO WHAT THE ACTUAL PROGRAM IS *
                                                // *********************************************
            
            // The address for the json will be stored in the variable: self.chosenMacAddress
 
            
            self.socket.emit("run code", jsonString)
        }
        
        socket.on("busy") { data, ack in
            print("Server is busy. Please rebuild in a few seconds")
        }
 */
        
        /*
        socket.on(clientEvent: .connect) { data, ack in
            self.connectButton.isEnabled = false
            self.disconnectButton.isEnabled = true
            self.getMacAddressesButton.isEnabled = true

            self.addAlert(title: "Connected", message: "Your session ID: " + self.socket.sid!)
        }
        
        socket.on(clientEvent: .reconnect) { data, ack in
            self.idLabel.text = nil
            self.connectButton.isEnabled = false
            self.disconnectButton.isEnabled = false
            self.getMacAddressesButton.isEnabled = true
            self.sendJSONButton.isEnabled = true
            
            
            self.addAlert(title: "Connection Failed", message: "Attempting to connect to the server")
        }
        
        socket.on("chat message") { data, ack in
            let stringData = data[0] as! String
            self.addAlert(title: "Server Message", message: stringData)
        }
        
        socket.on("available nxts") { data, ack in
            //print("Interpreting data from server")
            print(data[0])
            
            let addressData = data[0] as! NSDictionary
            let addressArray = addressData["addresses"] as! Array<String>
            self.clientArray = addressArray

            for i in 0..<self.clientArray.count {
                print(self.clientArray[i])
            }
            self.macAddressTableView.reloadData()
        }
        */
    }
    
    
    @IBAction func connectButtonDidPress(_ sender: UIBarButtonItem) {
        //self.socket.connect()
    }
    
    
    @IBAction func sendJSONButton(_ sender: UIButton) {
        let address: String = self.idLabel.text!
        
        let json: JSON =  ["commands":[["type":"playsound", "soundfile": "Woops"], ["type":"motor", "brake": true, "power": 100, "revolutions":5, "port":"A"]], "address":address]
        
        let jsonString = json.description //json.rawString([.castNilToNSNull: true])!
        //var array = JSONHelper.parseJSONWith(json: jsonString)
        //JSONHelper.iterateArrayOfDictionariesWith(array: array)
        //self.socket.emit("jsonCommand", jsonString, self.idLabel.text as String!)
        //self.socket.emit("run code", jsonString)
    }
    
    @IBAction func disconnectButtonDidPress(_ sender: UIBarButtonItem) {
        //self.socket.disconnect()
        self.idLabel.text = nil
        self.connectButton.isEnabled = true
        self.disconnectButton.isEnabled = false
        self.sendJSONButton.isEnabled = false
        self.getMacAddressesButton.isEnabled = false
        self.addAlert(title: "Disconnected", message: "You have disconnected from the server")
    }
    
    @IBAction func getMacAddressesButtonDidPress(_ sender: UIButton) {
        //self.socket.emit("getPiDevices")
        //macAddressTableView.reloadData()
        //self.socket.emit("get available nxts")
    }
    
    /*
    @IBAction func playSoundButtonDidPress(_ sender: UIButton) {
        var request = URLRequest(url: URL(string: "https://robocode-server.herokuapp.com/test")!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in guard let data = data, error == nil else {
            print("error: \(error as Optional)")
            return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response: \(response as Optional)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("response: \(responseString as Optional)")
        }
        task.resume()
    }
    */
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a cell
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = clientArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        self.idLabel.text = clientArray[indexPath.row]
        self.sendJSONButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
        self.idLabel.text = nil
    }

    
    @IBAction func testDataPersistenceDidPress(_ sender: UIButton) {
        let testDictionary =  ["5": "json", "3": "json", "4": "json"] as NSMutableDictionary
        ProgramManager.saveProgramWith(originalPrograms: testDictionary, programJSON: "newjson", programNumber: "3")
        //ProgramManager.loadProgramWith(programNumber: "3")
    }
    
    
    // NEED THIS IBAction FUNCTION TO SEND JSON TO THE SERVER/ROBOT
    @IBAction func buildBarButtonDidPress(_ sender: UIBarButtonItem) {
        if self.chosenMacAddressIndex > -1 && self.client.connected {
            //print("Mac address that is selected: \(self.chosenMacAddress)")
            
            let json: JSON =  ["commands":[["type":"playsound", "soundfile": "Woops"], ["type":"motor", "brake": true, "power": 100, "revolutions":5, "port":"A"]], "address":self.chosenMacAddress]
            
            
                                                // *********************************************
            let jsonString = json.description   // * CHANGE THIS TO WHAT THE ACTUAL PROGRAM IS *
                                                // *********************************************
            
            self.client.socket.emit("run code", jsonString)
            //print(jsonString)
            print("Build request was sent to server with the selected mac address")
        }
    }
    
    // NEED THIS IBAction FUNCTION TO SAVE A PROGRAM
    @IBAction func saveBarButtonDidPress(_ sender: UIBarButtonItem) {
        
                            // *********************************************
        let jsonString = "" // * CHANGE THIS TO WHAT THE ACTUAL PROGRAM IS *
                            // *********************************************
        
        if self.isNewProgram! {
            let alertController = UIAlertController(title: title, message: "Enter the name of this program", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = alertController.textFields?[0] {
                    let valid = ProgramManager.saveNewProgramWith(programName: field.text!, programJSON: jsonString)
                    print("Saving program with name: \(field.text!)")
                    print ("Saving program with json: \(jsonString)")
                    if !valid {
                        self.addAlert(title: "Error", message: "A program with the same name already exists")
                    } else {
                        self.addAlert(title: "Success", message: "\(field.text!) has been saved")
                        self.collectionDelegate?.sendEventToCollectionView()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addTextField(configurationHandler: nil)
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        } else {
            let valid = ProgramManager.updateProgramWith(programName: self.programName, programJSON: jsonString, id: self.realmID)
            print("Saving program with name: \(programName)")
            print ("Saving program with json: \(jsonString)")
            if !valid {
                self.addAlert(title: "Error", message: "A program with the same name already exists")
            } else {
                self.addAlert(title: "Success", message: "\(self.programName) has been saved")
                self.collectionDelegate?.sendEventToCollectionView()
            }
        }
    }
    
    // NEED THIS IBAction FUNCTION TO RETURN TO THE STARTUP SCREEN. COMMENT THIS OUT IF ERRORS SHOW UP
    @IBAction func backBarButtonDidPress(_ sender: UIBarButtonItem) {
        self.collectionDelegate?.sendEventToCollectionView()
        self.dismiss(animated: true)
    }
    
    // NEED THIS FUNCTION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddressTableViewController {
            destination.addressDelegate = self
            self.tableDelegate = destination
        }
    }
    
    // NEED THE REST OF THE FUNCTIONS BELOW THIS COMMENT (BESIDES THE COMMENTED OUT ONES)
    
    // AddressDelegate functions
    func updateMacAddressWith(index: Int) {
        self.chosenMacAddressIndex = index
        if index > -1 {
            self.chosenMacAddress = self.macAddressArray[self.chosenMacAddressIndex]
        } else {
            self.chosenMacAddress = ""
        }
    }
    
    func storeMacAddressesWith(macAddressArray: Array<String>) {
        self.macAddressArray = macAddressArray
    }
    
    func initializeTableView() {
        self.tableDelegate?.initializeTable(selectedIndex: self.chosenMacAddressIndex, macAddressArray: self.macAddressArray)
    }
    
    /*
    @IBAction func saveProgramButtonDidPress(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: title, message: "Enter Theoretical Program", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                ProgramManager.saveProgramWith(originalPrograms: self.programsDictionary, programJSON: field.text!, programNumber: String(self.programsDictionary.count))
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    */
    
    
    /*
    @IBAction func loadProgramButtonDidPress(_ sender: UIBarButtonItem) {
        self.programsDictionary = ProgramManager.loadAllPrograms()
        var programs: String = ""
        for (programNumber, programJSON) in self.programsDictionary {
            programs += "\(programNumber) : \(programJSON) \n"
        }
        self.programLabel.text = programs
    }
 */
    
    
}

