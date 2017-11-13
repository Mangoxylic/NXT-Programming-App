//
//  NavigationController.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/9/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

protocol NavigationDelegate {
    func reloadCollectionView()
}

import UIKit

class NavigationController: UINavigationController, CollectionDelegate {
    var navigationDelegate: NavigationDelegate?
    var isNewProgram: Bool = true
    var programName: String = ""
    var programJSON: String = ""
    var realmID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let destination = self.viewControllers.first {
            let vc = destination as! ViewController /* REPLACE ViewController WITH THE CORRECT CLASS */
            vc.collectionDelegate = self
            //print("Adjusting variables")
            if !isNewProgram {
                //print("Program already exists")
                vc.isNewProgram = self.isNewProgram
                vc.programName = self.programName
                vc.programJSON = self.programJSON
                vc.realmID = self.realmID
            } else {
                //print("Program is new")
                vc.isNewProgram = self.isNewProgram
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // CollectionDelegate functions
    
    func sendEventToCollectionView() {
        //print("Event in navigationcontroller fired")
        self.navigationDelegate?.reloadCollectionView()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
