//
//  HttpClient.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/25.
//

import Foundation

class HttpClient {
    
    func getJSON(path: String, completed: @escaping (Result<MusicData, Error>) -> Void) {
        if let url = URL(string: path) {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
                        DispatchQueue.main.async {
                            completed(Result.success(parsedJSON))
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completed(Result.failure(error))
                        }
                    }
                }
            }.resume()
        }
        
    }
    
}
