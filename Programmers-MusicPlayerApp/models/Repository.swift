//
//  Repository.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/27.
//

import Foundation

class Repository {
    private let httpClient = HttpClient()
    
    func list() {
        httpClient.getJSON(path: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") { result in
            if let json = try? result.get() {
                print(json.album)
                print(json.singer)
                print(json.lyrics)
            }
        }
        
    }
}
