//
//  ViewController.swift
//  Programmers-MusicPlayerApp
//
//  Created by Johyeon Yoon on 2021/06/04.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var player: AVPlayer!
    var timer: Timer!
    
    @IBOutlet var singer : UILabel!
    @IBOutlet var album : UILabel!
    @IBOutlet var musicTitle : UILabel!
    @IBOutlet var albumCoverImageView : UIImageView!
    @IBOutlet var progressSlider : UISlider!
    @IBOutlet var playPauseButton : UIButton!
    @IBOutlet var currentTime : UILabel!
    @IBOutlet var totalTime : UILabel!
    
    
    // MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let url = URL(string: "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/song.json") {
           URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let parsedJSON = try jsonDecoder.decode(MusicData.self, from: data)
//                    let fileUrl = parsedJSON.file
                    let imageUrl = parsedJSON.image
                    guard let imageData = try? Data(contentsOf: imageUrl) else {
                        return
                    }
                    let image = UIImage(data: imageData)
                   
                    DispatchQueue.main.async { [self] in
                        
                        let resizedImage = image?.resizedImage(newWidth:  self.albumCoverImageView.frame.width)

                        self.singer?.text = parsedJSON.singer
                        self.musicTitle?.text = parsedJSON.title
                        self.album?.text = parsedJSON.album
                        self.albumCoverImageView.contentMode = .scaleAspectFit
                        self.albumCoverImageView?.image = resizedImage
                    }
                   
                } catch {
                    print(error)
                }
            }
           }.resume()
            
        }
    }


}


extension UIImage {
   func resizedImage(newWidth: CGFloat) -> UIImage {
       guard size.width > newWidth else { return self }
       let scale = newWidth / self.size.width
       let newHeight = self.size.height * scale
       let newSize = CGSize(width: newWidth, height: newHeight)
       let renderer = UIGraphicsImageRenderer(size: newSize)
       let image = renderer.image { (context) in
           self.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
       }
       return image
   }
}
