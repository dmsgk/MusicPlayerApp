//
//  LyricsViewController.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/06.
//

import UIKit

class LyricsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lyricsList : [String]!
    var lyricsDict : [String: String]!
    var toggleSwitch = true
    
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if toggleSwitch == true {
            let seletedLyrics = self.lyricsList[indexPath.row - 1]
            print(seletedLyrics)
            
            // 가사 터치할 때 해당 부분으로 넘어가도록
            
        }
        else {
            if indexPath.row > 0 {
                dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    
    @IBAction func onOffToggle(_ sender : UISwitch){
        if sender.isOn {
            print("switch is on")
            self.toggleSwitch = true
        }
        else {
            print("switch is off")
            self.toggleSwitch = false
        }
    }
    
   
    
   
    
    func showLyricsList(lyrics: String) -> [String] {
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
                        self.lyricsList = showLyricsList(lyrics: parsedJSON.lyrics)
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


