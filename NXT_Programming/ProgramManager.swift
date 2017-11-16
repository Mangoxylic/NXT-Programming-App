//
//  Program.swift
//  NXT_Programming
//
//  Created by Erick Chong on 10/18/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class ProgramManager: NSObject {
    static let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    private var name: String;
    private var program: String;
    
    init(name: String, program: String) {
        self.name = name
        self.program = program
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getProgram() -> String {
        return self.program
    }
    
    class func getID(programName: String) -> String {
        /*
        self.isNewProgram = false
        self.programName = field.text!
        self.realmID = ProgramManager.getID(programName: self.programName)
        */
        
        let realm = try! Realm()
        
        // Programs with name of programName
        let programs = realm.objects(Program.self).filter("name = %@", programName)
        let program = programs.first
        
        if program != nil {
            return (program?.id)!
        }
        
        return ""
    }
    
    class func convertDictionaryToArrayWith(dictionary: NSMutableDictionary) -> Array<ProgramManager> {
        var resultArray: Array<ProgramManager> = []
        for (key, value) in dictionary {
            let program = ProgramManager(name: key as! String, program: value as! String)
            resultArray.append(program)
        }
        return resultArray
    }
    
    // If programNumber is < 0, the program doesn't already exist in the plist
    class func saveProgramWith(originalPrograms: NSMutableDictionary, programJSON: String, programNumber:String) {
        if let documents = directories.first {
            if let urlDocuments = URL(string: documents) {
                let urlPrograms = urlDocuments.appendingPathComponent("nxtprograms.plist")
                //print("Path: \(urlPrograms.path)")
                
                // Write
                //let programs = ["e", "r", "k"] as NSArray
                //let programs = originalPrograms as NSDictionary
                
                if programNumber == "-1" {
                    
                }
                originalPrograms[programNumber] = programJSON
                originalPrograms.write(toFile: urlPrograms.path, atomically: true)
            }
        }
    }
    
    class func saveNewProgramWith(programName: String, programJSON: String) -> Bool {
        let realm = try! Realm()
        
        if realm.objects(Program.self).filter("name = %@", programName).first != nil {
            return false
        } else {
            let program = Program()
            program.name = programName
            program.json = programJSON
            program.date = Int64(Date().ticks)
            
            try! realm.write {
                realm.add(program, update: true)
            }
            return true
        }
    }
    
    class func loadAllPrograms() -> Array<Program> {
        let realm = try! Realm()
        var resultArray: Array<Program> = []
        
        for program in realm.objects(Program.self) {
            resultArray.append(program)
        }
        
        // Sort descending (most recent first)
        return resultArray.sorted {
            $0.date > $1.date
        }
    }
    
    class func updateProgramWith(programName: String, programJSON: String, id: String) -> Bool {
        let realm = try! Realm()
        
        // Programs with name of programName
        let programs = realm.objects(Program.self).filter("name = %@", programName)
        
        if programs.first != nil {
            // If there exists a program with name equal to programName and it doesn't have the same date
            // as the program we are updating, then the name already exists so return false
            if programs.first?.id != id {
                return false
            } else {
                self.updateRealmWith(name: programName, json: programJSON, id: id)
                return true
            }
        } else {
            self.updateRealmWith(name: programName, json: programJSON, id: id)
            return true
        }
    }
    
    class func deleteProgramWith(name: String, json: String, id: String) {
        let realm = try! Realm()
        let program = realm.objects(Program.self).filter("id = %@", id)
        
        try! realm.write {
            realm.delete(program)
        }
    }
    
    class func clearAllPrograms() {
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    private class func updateRealmWith(name: String, json: String, id: String) {
        let realm = try! Realm()
        
        let program = Program()
        program.name = name
        program.json = json
        program.id = id
        program.date = Int64(Date().ticks)
        
        try! realm.write {
            realm.add(program, update: true)
        }
    }
    
}
