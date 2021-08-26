//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import Foundation
import AVKit
var player : AVPlayer!



class PlayerViewModel : NSObject {
    
    
    let singer = Observable(" ")
    let title = Observable(" ")
    let albumTitle = Observable(" ")
    let albumImg : Observable<UIImage?> = Observable(nil)
    
    let totalTime = Observable("")
    let currTime = Observable("")
    
    let currLocation = Observable(Float(-1))
    let maxLocation = Observable(Float(-1))
    
    
    
    
    // MARK: -AVPlayer
    func initPlayer(url : URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
    }
    
    
    func musicDuration(url : URL) -> Double {
        let totalDuration = AVAsset(url: url).duration
        return CMTimeGetSeconds(totalDuration)
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
    
    
    func playPauseMusic(_ senderIsSelected : Bool) {
        // isSelected == true일 때 재생, 아닐 때 멈춤
        
        if senderIsSelected {
            player.play()
        }
        else {
            player.pause()
        }
    }

    func moveSeekBar(_ value : Float)  {
        player.seek(to: CMTime(seconds: Double(value), preferredTimescale: 1))
    }
    
    func getCurrTime(_ value : Float) -> String {
        let currTime : String = convertCMTimeToRealTime(Double(value)) 
        return currTime
    }
   
    
    
    // MARK: -fetch data
    func decodeData(completion: @escaping (Result<Music, Error>)-> Void) {
        let urlStr = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
        
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let music = try jsonDecoder.decode(Music.self, from: data)
                        DispatchQueue.main.async {
                            completion(Result.success(music))
                        }
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            completion(Result.failure(error))
                        }
                    }
                }
            }.resume()
        }
    
    }
    
    
    func fetchData() {
        decodeData { result in
            if let music = try? result.get() {
                // ui 값 업데이트
                self.singer.value = music.singer
                self.title.value = music.title
                self.albumTitle.value = music.album
            
                
                // 앨범커버 업데이트
                self.getAlbumImage(music: music) { result in
                    if let imageData = try? result.get() {
                        let image = UIImage(data: imageData)
                        self.albumImg.value = image
                    }
                }
                // player 업데이트
                self.initPlayer(url: music.file)
                self.totalTime.value = self.convertCMTimeToRealTime(self.musicDuration(url: music.file))
                self.currTime.value = "0:00"
                

                // progressBar 업데이트
                self.currLocation.value = 0
                self.maxLocation.value = Float(self.musicDuration(url: music.file))
            }
        }
        
    }
    
    func getAlbumImage(music : Music, completion : @escaping (Result<Data, Error>) -> Void){
        
        do {
            let imageData = try Data(contentsOf: music.image)
            DispatchQueue.main.async {
                completion(Result.success(imageData))
            }
        } catch {
            DispatchQueue.main.async {
                completion(Result.failure(error))
            }
        }
    }
    
    // lyrics의 초를 key, 가사를 value로 하는 딕셔너리 생성
    func getLyricsDict(music: Music) -> [String:String] {
        let lyricsStr = music.lyrics
        var lyricsDict = [String: String]()
        
        let lyricsArr = lyricsStr.split{ $0 == "\n"}.map{ String($0) }
        for i in 0..<lyricsArr.count {
            var lyrics = lyricsArr[i]
            lyrics.removeFirst()
            
            let timeLyricsArr = lyrics.split{ $0 == "]"}.map{ String($0) }
            lyricsDict[timeLyricsArr[0]] = timeLyricsArr[1]
        }
        
        return lyricsDict
        
    }
    
    func convertCMTimeToRealTime (_ totalSeconds: Double) -> String {
        let seconds = Int(floor(totalSeconds.truncatingRemainder(dividingBy: 60)))
        let minutes = Int(totalSeconds / 60)
        let milliseconds = Int(totalSeconds.truncatingRemainder(dividingBy: 1) * 10)
        let timeFormatString = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        
        return timeFormatString
    }
    
    
}
