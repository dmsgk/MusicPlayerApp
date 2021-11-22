//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var viewModel = PlayerViewModel.shared
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
        
        viewModel.isNowPlaying.value = !viewModel.isNowPlaying.value
        viewModel.playPauseMusic()
    }
    
    @IBAction func moveSeekBar(_ sender: UISlider) {
        viewModel.moveSeekBar(sender.value)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        bindData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchData()
    }
}

// MARK: - Private
private extension PlayerViewController {
    func bindData() {
        viewModel.singer.bind { [weak self] singer in
            self?.singerLabel.text = singer
        }
        
        viewModel.title.bind { [weak self] title in
            self?.titleLabel.text = title
        }
        
        viewModel.albumTitle.bind { [weak self] albumTitle in
            self?.albumLabel.text = albumTitle
        }
        
        viewModel.albumImg.bind { [weak self] albumImg in
            let resizedImage = albumImg?.resizedImage(newWidth:  (self?.albumImage.frame.width)!)
            self?.albumImage.contentMode = .scaleAspectFit
            self?.albumImage?.image = resizedImage
            
        }
        
        viewModel.currTime.bind { [weak self] time in
            self?.currentPlaytimeLabel.text = time
        }
        
        viewModel.totalTime.bind { [weak self] time in
            self?.totalPlaytimeLabel.text = time
        }
        
        self.seekBar.minimumValue = 0
        viewModel.currLocation.bind { [weak self] currLocation in
            self?.seekBar.value = currLocation
        }
        
        viewModel.maxLocation.bind { [weak self] maxLoaction in
            self?.seekBar.maximumValue = maxLoaction
        }
        
        viewModel.currLyrics.bind { [weak self] lyrics in
            self?.lyricsLabel.text = lyrics
        }
        
        viewModel.isNowPlaying.bind { [weak self] isNowPlaying in
            self?.playPauseBtn.isSelected = isNowPlaying
        }
    }
}

// MARK: - ImageResizing
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


