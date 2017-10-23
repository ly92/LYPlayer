//
//  VideoCollectionCell.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import SwiftyJSON

class VideoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var jsonModel : JSON = []{
        didSet{
            self.titleLbl.text = jsonModel["title"].stringValue
        }
    }
    
}
