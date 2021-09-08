//
//  SwitchTableViewCell.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/28.
//

import UIKit

class SwitchTableViewCell : UITableViewCell {
    
    var viewModel = PlayerViewModel.shared
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        viewModel.getSwitchStatus(sender.isOn)
    }
    
}


