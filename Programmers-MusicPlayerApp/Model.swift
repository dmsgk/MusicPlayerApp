//
//  Model.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/04.
//

import Foundation

struct MusicData: Codable {
    let singer: String
    let album: String
    let title: String
    let image: URL
    let file: URL
    let lyrics: String
}
