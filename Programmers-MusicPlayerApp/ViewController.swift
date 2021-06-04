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
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main) //0.1초마다
            { time in
                let rawTime = CMTimeGetSeconds(time)
                self.progressSlider.value = Float(rawTime)
                let currTime = self.convertCMTimeToRealTime(cMTime: time)
                self.currentTime?.text = currTime[0] as? String
            }
        }
        else {
            self.player.pause()
        }
    }
    
    @IBAction func moveProgressSlider(_ sender: UISlider) {
        // 슬라이더 움직이면 슬라이더 값 변화하고, 변화한 값 토대로 음원도 시간변경시키는 함수
        // sender.value 에 맞는 CMTime을 찾기
        if sender.value == sender.maximumValue {
            self.audioPlayerDidFinishPlaying(self.player, successfully: true)
        }
        let currTime : String = (self.convertCMTimeToRealTime(cMTime:CMTime(seconds: Double(sender.value), preferredTimescale: 1))[0]) as! String
        
        if sender.isTracking { return }
        self.player.seek(to: CMTime(seconds: Double(sender.value), preferredTimescale: 1))
        self.currentTime?.text = currTime
    }
    
    //MARK: -AudioPlayer
    func initPlayer(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let avAsset = AVAsset(url: url)
        self.player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
        
        DispatchQueue.main.async { [self] in
            self.progressSlider.minimumValue = 0
            self.progressSlider.maximumValue = Float(CMTimeGetSeconds(avAsset.duration))
            self.progressSlider.value = 0
            
            let totalSeconds = avAsset.duration
            self.totalTime?.text = self.convertCMTimeToRealTime(cMTime: totalSeconds)[0] as? String
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
    
    func convertCMTimeToRealTime (cMTime : CMTime) -> Array<Any> {
        let totalSeconds = CMTimeGetSeconds(cMTime)
        let seconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let minutes: Int = Int(totalSeconds / 60)
        let miliseconds: Int = Int(totalSeconds.truncatingRemainder(dividingBy: 1) * 100)
        let timeFormatString = String(format: "%01d:%02d", minutes, seconds)
      return [timeFormatString, miliseconds]
    }

    func audioPlayerDidFinishPlaying(_ player: AVPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
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
