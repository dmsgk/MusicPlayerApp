//
//  LyricsViewController.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/06.
//

import UIKit

class LyricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lyricsList : [String] = ["we wish you a merry christmas", "we wish you a merry christmas", "we wish you a merry christmas", "and a happy new year", "we wish you a merry christmas", "we wish you a merry christmas", "we wish you a merry christmas", "and a happy new year", "good tidings we bring", "to you and your kin", "good tidings for christmas", "and a happy new year", "Oh, bring us some figgy pudding", "Oh, bring us some figgy pudding", "Oh, bring us some figgy pudding", "And bring it right here", "Good tidings we bring ", "to you and your kin", "Good tidings for Christmas ", "and a happy new year", "we wish you a merry christmas", "we wish you a merry christmas", "we wish you a merry christmas", "and a happy new year", "We won\'t go until we get some", "We won\'t go until we get some", "We won\'t go until we get some", "So bring some out here", "연주", "Good tidings we bring ", "to you and your kin", "good tidings for christmas", "and a happy new year", "we wish you a merry christmas", "we wish you a merry christmas", "we wish you a merry christmas", "and a happy new year", "Good tidings we bring ", "to you and your kin", "Good tidings for Christmas ", "and a happy new year", "Oh, bring us some figgy pudding", "Oh, bring us some figgy pudding", "Oh, bring us some figgy pudding", "And bring it right here", "we wish you a merry christmas", "we wish you a merry christmas", "we wish you a merry christmas", "and a happy new year"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lyricsList.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath)
            return toggleCell
        }
        else {
            let lyricsCell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath)
            let target = self.lyricsList[indexPath.row-1]
            lyricsCell.textLabel?.text = target
            return lyricsCell
        }
        
    }
    
    
    
    func showLyricsDict(lyrics: String) -> [String] {
        let lyricsArray = lyrics.components(separatedBy: "\n")
        var lyricsList : [String ] = []
        for lyr in lyricsArray {
            let lyr = lyr.trimmingCharacters(in: ["["])
            let tempArr = lyr.components(separatedBy: ["]"])
            lyricsList.append(tempArr[1])
        }
        return lyricsList
    }
    

    @IBAction func closeModal(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var artist : UILabel!
    @IBOutlet var muzicTitle : UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") {
            URLSession.shared.dataTask(with: url) { [self]
                data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
                        self.lyricsList = showLyricsDict(lyrics: parsedJSON.lyrics)
                        DispatchQueue.main.async { [self] in
                            self.artist?.text = parsedJSON.singer
                            self.muzicTitle?.text = parsedJSON.title
                        }
                        
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }}

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


