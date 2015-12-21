//
//  VoiceCell.swift
//  FinalWatch
//
//  Created by Tony on 15/12/2.
//  Copyright © 2015年 Tony. All rights reserved.
//

import UIKit

class VoiceCell: UITableViewCell {

    @IBOutlet weak var titleLab1: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var timeLab: UILabel!
    
    @IBOutlet weak var progressV: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
