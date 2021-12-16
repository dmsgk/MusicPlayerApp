//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/23.
//

import Foundation
import AVKit
var player : AVPlayer!



class PlayerViewModel {
    static let shared = PlayerViewModel()
    private init() {}
    
    var repository = MusicRepositoty()
    
    let singer = Observable(" ")
    let title = Observable(" ")
    let albumTitle = Observable(" ")
    let albumImg : Observable<UIImage?> = Observable(nil)
    
    let totalTime = Observable("")
    let currTime = Observable("")
    
    let currLocation = Observable(Float(0))
    let maxLocation = Observable(Float(0))
    
    let currLyrics = Observable("")
   
    var lyricsDict = Dictionary<String, String>()
    var lyricsArr = [[String]]()
    let switchStatus = Observable(true)
    let isNowPlaying = Observable(false)

    
    
    //MARK: - PlayerViewController
    
    
    func updatePlayerStatus(_ time : CMTime){
        let cmTime = CMTimeGetSeconds(time)
        
        // slider 위치 업데이트
        self.currLocation.value = Float(cmTime)
        
        // 현재 재생시간 업데이트
        let minSecMilliSec = self.convertCMTimeToRealTime(cmTime)
        let endIdx = minSecMilliSec.index(minSecMilliSec.startIndex, offsetBy: 5)
        self.currTime.value = String(minSecMilliSec[..<endIdx])
        
        // 가사 업데이트
        for key in lyricsDict.keys {
            let arr = key.split{ $0 == ","}.map{ String($0) }
            if arr[0] > minSecMilliSec {
                if arr[1] <= minSecMilliSec{
                    if let lyrics = self.lyricsDict[key] {
                        self.currLyrics.value = lyrics
                    }
                }
            }
        }
        
        
    }
    
    
    func playPauseMusic() {
        // isSelected == true일 때 재생, 아닐 때 멈춤
        if isNowPlaying.value {
            player.play()
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10),
                                           queue: .main) //0.1초마다
            { time in
                self.updatePlayerStatus(time)
            }
        } else {
            player.pause()
        }
    }

    func moveSeekBar(_ value : Float)  {
        player.seek(to: CMTime(seconds: Double(value), preferredTimescale: 100))
        
        let minSecMilliSec : String = convertCMTimeToRealTime(Double(value))
        let endIdx = minSecMilliSec.index(minSecMilliSec.startIndex, offsetBy: 5)
        self.currTime.value = String(minSecMilliSec[..<endIdx])
        
        if let lyrics = self.lyricsDict[minSecMilliSec] {
            self.currLyrics.value = lyrics
        }
    }

    // 디코딩한 데이터 observable클래스타입으로
    func fetchData() {
        repository.decodeData { result in
            switch result {
            case .failure(let error):
                print("error: \(error)")
                
            case .success(let music):
                // ui 값 업데이트
                self.singer.value = music.singer
                self.title.value = music.title
                self.albumTitle.value = music.album
                
                // 앨범커버 업데이트
                self.getAlbumImage(music: music) { result in
                    switch result {
                    case .success(let imageData):
                        let image = UIImage(data: imageData)
                        self.albumImg.value = image
                    case .failure(let error):
                        print("error: \(error)")
                    }
                }
                
                // player 업데이트
                self.initPlayer(url: music.file)
                
                let minSecMilliSec = self.convertCMTimeToRealTime(self.musicDuration(url: music.file))
                let endIdx = minSecMilliSec.index(minSecMilliSec.startIndex, offsetBy: 5)
                self.totalTime.value = String(minSecMilliSec[..<endIdx])
                self.currTime.value = "0:00"
                
                // progressBar 업데이트
                self.currLocation.value = 0
                self.maxLocation.value = Float(self.musicDuration(url: music.file))
                
                //lyrics
                self.lyricsArr = self.getLyricsArr(music: music)
                self.lyricsDict = self.getLyricsDict(music: music)
            }
        }
    }
      
    // MARK: - LyricsViewController
    
    func fetchLyrics() {
        repository.decodeData { result in
            switch result {
            case .success(let data):
                self.lyricsArr = self.getLyricsArr(music: data)
            case .failure(let error):
                print("error : \(error)")
            }
        }
    }
    
    
    func movePlayerToLyricsPart(_ targetTime : String){
        let cmTime = CMTime(seconds: convertRealtimeToDouble(targetTime), preferredTimescale: 100)
        player.seek(to: CMTime(seconds: cmTime.seconds, preferredTimescale: 100))
        updatePlayerStatus(cmTime)
        playPauseMusic()

    }
    
    
    func getSwitchStatus(_ status: Bool) {
        self.switchStatus.value = status
    }
    
    func convertRealtimeToDouble(_ timeStr : String) -> Double{
        let minEndIdx = timeStr.index(timeStr.startIndex, offsetBy: 2), secEndIdx = timeStr.index(minEndIdx, offsetBy: 3)
        
        let min =  Double(timeStr[..<minEndIdx])!
        let sec =  Double(timeStr[timeStr.index(after: minEndIdx)..<secEndIdx])!
        let milli = Double(timeStr[timeStr.index(after:secEndIdx)...])!
        return 60 * min + sec +  0.001 * milli
    }
    
    
}


// MARK: - AVPlayer
extension PlayerViewModel {
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
}

// MARK: - Private
private extension PlayerViewModel {
    func convertCMTimeToRealTime (_ totalSeconds: Double) -> String {
        let seconds = Int(floor(totalSeconds.truncatingRemainder(dividingBy: 60)))
        let minutes = Int(totalSeconds / 60)
        let milliseconds = Int(totalSeconds.truncatingRemainder(dividingBy: 1) * 10)
        let timeFormatString = String(format: "%02d:%02d:%01d00", minutes, seconds, milliseconds)
        
        return timeFormatString
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
        var lyricsDict = [String: String]()
        
        for i in 0..<lyricsArr.count {
            let nextTime : String
            if i == lyricsArr.count - 1{
                nextTime = "00:00:000"
            }
            else {
                nextTime = lyricsArr[i+1][0]
            }
            lyricsDict[nextTime + "," + lyricsArr[i][0]] = lyricsArr[i][1]
        }
        return lyricsDict
    }

    // lyrics의 [초, 가사]를 담은 배열 생성
    private func getLyricsArr(music: Music) -> [[String]] {
        
        let lyricsStr = music.lyrics
        var lyricsArr = [[String]]()
        
        let arr = lyricsStr.split{ $0 == "\n"}.map{ String($0) }
        for i in 0..<arr.count {
            var lyrics = arr[i]
            lyrics.removeFirst()
            
            let timeLyricsArr = lyrics.split{ $0 == "]"}.map{ String($0) }
            lyricsArr.append(timeLyricsArr)
        }
        return lyricsArr
    }
}



