//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import Foundation
import AVKit


class PlayerViewModel : NSObject {
    
    // MARK: -AVPlayer
    var player : AVPlayer!
    
    func initPlayer(url : URL) {
        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)
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
            self.player.play()
        }
        else {
            self.player.pause()
        }
    }

    
   
    
    
    // MARK: -fetch data
    func fetchData(completion: @escaping (Result<Music, Error>)-> Void) {
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
