//
//  PickerViewController.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/16/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var sensorOptions: [String] = [String]()
    var compOptions: [String] = [String]()
    var portOptions: [String] = [String]()
    
    var picker = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0){
            return self.sensorOptions.count
        } else if(component == 1) {
            return self.compOptions.count
        } else {
            return self.portOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0){
            return self.sensorOptions[row]
        } else if(component == 1) {
            return self.compOptions[row]
        } else {
            return self.portOptions[row]
        }
    }
    
    // MARK: PickerDelegate functions
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 400, height: 200)
        
        self.picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
        self.picker.backgroundColor = UIColor.white
        self.picker.showsSelectionIndicator = true
        self.picker.delegate = self
        self.picker.dataSource = self
        
        view.addSubview(picker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
