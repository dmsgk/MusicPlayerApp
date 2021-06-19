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
    @IBOutlet var lyricsButton : UIButton!
    @IBOutlet var progressBar : UISlider!
    
    
    // MARK: -IBActions
    @IBAction func touchUpPlayPauseMusic(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false : true
        if sender.isSelected {
            self.player.play()
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: .main) //0.1초마다
            { time in
                let rawTime = CMTimeGetSeconds(time)
                self.progressSlider.value = Float(rawTime)
                let currTime = ViewController.convertCMTimeToRealTime(cMTime: time)
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
        let currTime : String = (ViewController.convertCMTimeToRealTime(cMTime:CMTime(seconds: Double(sender.value), preferredTimescale: 1))[0]) as! String
        
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
        let totalSeconds = avAsset.duration
        
        DispatchQueue.main.async { [self] in
            self.progressSlider.minimumValue = 0
            self.progressSlider.maximumValue = Float(CMTimeGetSeconds(totalSeconds))
            self.progressSlider.value = 0
            
            self.totalTime?.text = ViewController.convertCMTimeToRealTime(cMTime: totalSeconds)[0] as? String
        }
        
    
    }
    
    // 수정할 것
    
    func audioPlayerDidFinishPlaying(_ player: AVPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            if self.progressBar.value == self.progressBar.maximumValue {
                self.playPauseButton.isSelected = false
                self.progressSlider.value = 0
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
    
    class func convertCMTimeToRealTime (cMTime : CMTime) -> Array<Any> {
        let totalSeconds = CMTimeGetSeconds(cMTime)
        let seconds: Int = Int(round(totalSeconds.truncatingRemainder(dividingBy: 60)))
        let minutes: Int = Int(totalSeconds / 60)
        let milliseconds: String = String(format: "%d00", Int(totalSeconds.truncatingRemainder(dividingBy: 1) * 10))
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
      return [timeFormatString, milliseconds]
    }

    
    
    func showLyricsWhilePlaying(lyrics: String){
        let lyricsArray = lyrics.components(separatedBy: "\n")
        var lyricsDic : [String : String] = [:]
        for lyr in lyricsArray {
            let lyr = lyr.trimmingCharacters(in: ["["])
            let tempArr = lyr.components(separatedBy: ["]"])
            lyricsDic[tempArr[0]] = tempArr[1]
        }
        
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1000), queue: .main) //밀리초마다
        { time in
            let currTime = ViewController.convertCMTimeToRealTime(cMTime: time)   // 현재시간
            let TimeContainMiliSeconds = "\(currTime[0]):\(currTime[1])"
            if (lyricsDic[TimeContainMiliSeconds] != nil) {
                self.lyricsButton.setTitle(lyricsDic[TimeContainMiliSeconds] , for: .normal)
                
            }
            
        }

    }
    
    
    
    // MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
                        guard let imageData = try? Data(contentsOf: parsedJSON.image) else {
                            return
                        }
                        let image = UIImage(data: imageData)
                        self.initPlayer(url: parsedJSON.file)
                        self.audioPlayerDidFinishPlaying(self.player, successfully: true)
                        self.showLyricsWhilePlaying(lyrics: parsedJSON.lyrics)
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
        }}
    
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
