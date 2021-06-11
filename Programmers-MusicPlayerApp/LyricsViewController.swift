//
//  LyricsViewController.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/06.
//

import UIKit

class LyricsViewController: UIViewController {

    @IBAction func closeModal(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var artist : UILabel!
    @IBOutlet var muzicTitle : UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") {
            URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
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


