//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var singerLabel: UILabel!
    @IBOutlet var lyricsLabel: UILabel!
    @IBOutlet var seekBar: UISlider!
    @IBOutlet var albumImage: UIImageView!
    
    @IBOutlet var playPauseBtn: UIButton!
    
    @IBAction func touchUpPlayBtn(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false : true
        if sender.isSelected {
            print("play")
        } else {
            print("pause")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

