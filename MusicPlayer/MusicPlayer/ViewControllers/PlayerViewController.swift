//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import UIKit

class PlayerViewController: UIViewController {
    
    @IBOutlet var viewModel : PlayerViewModel!
    
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var singerLabel: UILabel!
    @IBOutlet var lyricsLabel: UILabel!
    @IBOutlet var seekBar: UISlider!
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var playPauseBtn: UIButton!
    
    @IBOutlet var totalPlaytimeLabel: UILabel!
    @IBOutlet var currentPlaytimeLabel: UILabel!
    
    
    
    
    @IBAction func touchUpPlayBtn(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false : true
        viewModel.playPauseMusic(sender.isSelected)
    }
    
    @IBAction func moveSeekBar(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMusicData()
    }
    
    
    func getMusicData() {
        viewModel.fetchData { result in
            if let music = try? result.get() {
                // ui 값 업데이트
                self.singerLabel.text = music.singer
                self.albumLabel.text = music.album
                self.titleLabel.text = music.title
                
                // 앨범커버 업데이트
                self.viewModel.getAlbumImage(music: music) { result in
                    if let imageData = try? result.get() {
                        let image = UIImage(data: imageData)
                        let resizedImage = image?.resizedImage(newWidth:  self.albumImage.frame.width)
                        self.albumImage.contentMode = .scaleAspectFit
                        self.albumImage?.image = resizedImage
                    }
                }
                // player 업데이트
                self.viewModel.initPlayer(url: music.file)
                self.totalPlaytimeLabel.text = self.viewModel.convertCMTimeToRealTime( self.viewModel.musicDuration(url: music.file))
                self.currentPlaytimeLabel.text = "0:00"
                
                // progressBar 업데이트
                self.seekBar.minimumValue = 0
                self.seekBar.maximumValue = Float(self.viewModel.musicDuration(url: music.file))
                
                self.seekBar.value = 0

            }
        }
        
        
    

        
    }


}

extension UIImage {
   func resizedImage(newWidth: CGFloat) -> UIImage {
       guard size.width > newWidth else { return self }
       let scale = newWidth / self.size.width
       let newHeight = self.size.height * scale
       let newSize = CGSize(width: newWidth, height: newHeight)
       let renderer = UIGraphicsImageRenderer(size: newSize)
       let image = renderer.image { (context) in
           self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
       }
       return image
   }
}


