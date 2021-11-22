//
//  MusicRepository.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/11/23.
//

import Foundation

class MusicRepositoty  {
    let urlStr = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json"
    
    func decodeData(completion: @escaping (Result<Music, Error>)-> Void) {
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, response, error in
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
}
