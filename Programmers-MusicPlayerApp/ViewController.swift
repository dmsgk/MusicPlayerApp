//
//  ViewController.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/04.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var player: AVPlayer!
    var timer: Timer!
    
    @IBOutlet var singer : UILabel!
    @IBOutlet var album : UILabel!
    @IBOutlet var musicTitle : UILabel!
    @IBOutlet var albumCoverImageView : UIImageView!
    @IBOutlet var progressSlider : UISlider!
    @IBOutlet var playPauseButton : UIButton!
    @IBOutlet var currentTime : UILabel!
    @IBOutlet var totalTime : UILabel!
    
    
    // MARK: -IBActions
    @IBAction func touchUpPlayPauseMusic(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false : true
        if sender.isSelected {
            self.player.play()
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main)
            { time in
                let rawTime = CMTimeGetSeconds(time)
                let totalRawTime = CMTimeGetSeconds(self.player.currentItem!.duration)
                let fraction = rawTime / totalRawTime
                self.progressSlider.value = Float(fraction)
                let currTime = self.convertCMTimeToRealTime(seconds: time)
                self.currentTime?.text = currTime[0] as? String
            }
        }
        else {
            self.player.pause()
        }
    }
    
    //MARK: -AudioPlayer
    func initPlayer(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
        
        DispatchQueue.main.async { [self] in
            self.progressSlider.minimumValue = 0
            self.progressSlider.value = 0
            
            if player.currentItem?.status == .readyToPlay {    //  반영안된다. 나중에 수정하기.
                let totalSeconds = player.currentItem!.duration
                print("totalSeconds: \(totalSeconds)")
                self.totalTime?.text = self.convertCMTimeToRealTime(seconds: totalSeconds)[0] as? String
            }
        }
        
    
    }
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
          
            if self.progressSlider.isTracking { return }
//            self.convertCMTimeToRealTime(seconds: self.player.currentTime())
            self.progressSlider.value = Float(CMTimeGetSeconds(self.player.currentTime()))
        })
        self.timer.fire()
    }
    
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    func convertCMTimeToRealTime (seconds : CMTime) -> Array<Any> {
        let totalSeconds = CMTimeGetSeconds(seconds)
        let seconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let minutes: Int = Int(totalSeconds / 60)
        let miliseconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 1) * 100)
        let timeFormatString = String(format: "%01d:%02d", minutes, seconds)
      return [timeFormatString, miliseconds]
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.invalidateTimer()
    }
    
    
    
    // MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") {
           URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
                    let imageUrl = parsedJSON.image
                    guard let imageData = try? Data(contentsOf: imageUrl) else {
                        return
                    }
                    let image = UIImage(data: imageData)
                    let fileUrl = parsedJSON.file
                    self.initPlayer(url: fileUrl)
                    
                    DispatchQueue.main.async { [self] in
                        let resizedImage = image?.resizedImage(newWidth:  self.albumCoverImageView.frame.width)

                        self.singer?.text = parsedJSON.singer
                        self.musicTitle?.text = parsedJSON.title
                        self.album?.text = parsedJSON.album
                        self.albumCoverImageView.contentMode = .scaleAspectFit
                        self.albumCoverImageView?.image = resizedImage
                    }
                   
                } catch {
                    print(error)
                }
            }
           }.resume()
            
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
