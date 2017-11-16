//
//  ProgramCell.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/1/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit

class ProgramCell: UICollectionViewCell {
    @IBOutlet weak var programLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
    }
}
