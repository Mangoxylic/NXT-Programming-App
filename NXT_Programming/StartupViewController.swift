//
//  StartupViewController.swift
//  NXT_Programming
//
//  Created by Erick Chong on 10/26/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

protocol StartupDelegate {
    func openProgram()
}

import UIKit

class StartupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NavigationDelegate  {
    @IBOutlet weak var newBarButton: UIBarButtonItem!
    @IBOutlet weak var openBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var renameBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var programsArray: Array<Program> = ProgramManager.loadAllPrograms()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.allowsMultipleSelection = true
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NavigationController {
            destination.navigationDelegate = self
            
            let barButton = sender as! UIBarButtonItem
            let barButtonTitle: String = barButton.title!
            if barButtonTitle == "New" {
                destination.isNewProgram = true
                destination.programName = ""
                destination.programJSON = ""
            } else {
                let program: Program = self.programsArray[self.collectionView.indexPathsForSelectedItems![0].row]
                destination.isNewProgram = false
                destination.programName = program.name
                destination.programJSON = program.json
                destination.realmID = program.id
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.programsArray.count == 0 {
            self.newBarButton.isEnabled = true
            self.openBarButton.isEnabled = false
            self.deleteBarButton.isEnabled = false
        }
        return self.programsArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgramCell", for: indexPath) as! ProgramCell
        cell.programLabel.text = programsArray[indexPath.row].name;
        
        if cell.isSelected {
            cell.backgroundColor = UIColor(red:30/255.0, green:144/255.0, blue:255/255.0, alpha:0.5)
        } else {
            cell.backgroundColor = UIColor.clear
            self.newBarButton.isEnabled = true
            self.openBarButton.isEnabled = false
            self.deleteBarButton.isEnabled = false
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(red:30/255.0, green:144/255.0, blue:255/255.0, alpha:0.5)
        let indexPaths = collectionView.indexPathsForSelectedItems!.count
        
        if indexPaths == 1 {
            self.newBarButton.isEnabled = false
            self.openBarButton.isEnabled = true
            self.deleteBarButton.isEnabled = true
            self.renameBarButton.isEnabled = true
        } else if indexPaths > 1 {
            self.openBarButton.isEnabled = false
            self.renameBarButton.isEnabled = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.clear
        let indexPaths = collectionView.indexPathsForSelectedItems!.count
        
        if indexPaths == 1 {
            self.newBarButton.isEnabled = false
            self.openBarButton.isEnabled = true
            self.deleteBarButton.isEnabled = true
            self.renameBarButton.isEnabled = true
        } else if indexPaths > 1 {
            self.openBarButton.isEnabled = false
            self.renameBarButton.isEnabled = false
        } else {
            self.newBarButton.isEnabled = true
            self.openBarButton.isEnabled = false
            self.deleteBarButton.isEnabled = false
            self.renameBarButton.isEnabled = false
        }
    }
    
    @IBAction func deleteBarButtonDidPress(_ sender: UIBarButtonItem) {
        /*
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete the selected program(s)?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
        */
        
        let indexPaths = collectionView.indexPathsForSelectedItems!
        
        for indexPath in indexPaths {
            let program = self.programsArray[indexPath.row]
            ProgramManager.deleteProgramWith(name: program.name, json: program.json, id: program.id)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        // Update collectionView
        self.programsArray = ProgramManager.loadAllPrograms()
        self.collectionView.reloadData()
    }
    
    @IBAction func renameBarButtonDidPress(_ sender: UIBarButtonItem) {
        let selectedProgram: Program = self.programsArray[(collectionView.indexPathsForSelectedItems?.first?.row)!]
        
        let alertController = UIAlertController(title: title, message: "Enter the name of this program", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                let valid = ProgramManager.updateProgramWith(programName: field.text!, programJSON: selectedProgram.json, id: selectedProgram.id)
                print("Saving program with name: \(field.text!)")
                if !valid {
                    self.addAlert(title: "Error", message: "A program with the same name already exists")
                } else {
                    self.addAlert(title: "Success", message: "\(field.text!) has been saved")
                    self.renameBarButton.isEnabled = false
                    self.collectionView.reloadData()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    
    @IBAction func testRealmButtonDidPress(_ sender: UIButton) {
        //let programDate = self.programsArray[self.programsArray.count - 1].date
        // Return true if successfully saved, false otherwise (false when program with name already exists
        var result = ProgramManager.saveNewProgramWith(programName: "testName1", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName2", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName3", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName4", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName5", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName6", programJSON: "testJSON")
        result = ProgramManager.saveNewProgramWith(programName: "testName7", programJSON: "testJSON")
        //let result = ProgramManager.updateProgramWith(programName: "testName1", programJSON: "testJSON3", date: programDate)
        if result {
            print("Successfully saved to Realm")
        } else {
            print("Object with the name already exists")
        }
        
        // Update collectionView
        self.programsArray = ProgramManager.loadAllPrograms()
        self.collectionView.reloadData()
    }
    
    @IBAction func clearRealmObjectsButtonDidPress(_ sender: UIButton) {
        ProgramManager.clearAllPrograms()
        self.programsArray = ProgramManager.loadAllPrograms()
        self.collectionView.reloadData()
    }

    // Private functions
    
    private func addAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    // NavigationDelegate functions
    
    func reloadCollectionView() {
        //print("event in startup viewcontroller fired")
        self.programsArray = ProgramManager.loadAllPrograms()
        self.collectionView.reloadData()
        self.newBarButton.isEnabled = true
        self.openBarButton.isEnabled = false
        self.deleteBarButton.isEnabled = false
        self.renameBarButton.isEnabled = false
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
