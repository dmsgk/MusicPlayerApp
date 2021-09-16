//
//  LyricsViewController.swift
//  MusicPlayer
//
//  Created by Johyeon Yoon on 2021/08/27.
//
import UIKit

class LyricsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var viewModel = PlayerViewModel.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var currTime: UILabel!
    @IBOutlet var totalTime: UILabel!
    @IBOutlet var seekbar: UISlider!
    @IBOutlet var playPauseBtn: UIButton!
    
    @IBAction func touchUpPlayPauseMusic(_ sender: UIButton) {
        sender.isSelected = self.playPauseBtn.isSelected ? false : true
        viewModel.isNowPlaying.value = !viewModel.isNowPlaying.value
        viewModel.playPauseMusic()

    }
    
    @IBAction func moveSeekbar(_ sender: UISlider) {
        viewModel.moveSeekBar(sender.value)
    }
    
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchLyrics()
        viewModel.switchStatus.value = true

        tableView.delegate = self
        tableView.dataSource = self
        
        getPlayerData()
    
    }
    
    func getPlayerData() {
        viewModel.currTime.bind { [weak self] time in
            self?.currTime.text = time
        }
        
        viewModel.totalTime.bind { [weak self] time in
            self?.totalTime.text = time
        
        }
        self.seekbar.minimumValue = 0
        viewModel.currLocation.bind { [weak self] currLocation in
            self?.seekbar.value = currLocation
        }
        
        viewModel.maxLocation.bind { [weak self] maxLoaction in
            self?.seekbar.maximumValue = maxLoaction
        }
        
        viewModel.isNowPlaying.bind { [weak self] isNowPlaying in
            self?.playPauseBtn.isSelected = isNowPlaying
        }
        
    }
       
    
    // MARK: - TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.lyricsArr.count + 1 // 전체 가사의 개수 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let toggleCell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! SwitchTableViewCell
            return toggleCell
        }
        else {
            let lyricsCell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath)
            
            let target = viewModel.lyricsArr[indexPath.row-1][1]
            lyricsCell.textLabel?.text = target
            return lyricsCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 0  {
            // 여기에 뷰모델 함수. 
            
            let targetTime = viewModel.lyricsArr[indexPath.row-1][0]
            // 타겟타임을 보낸다. -> cmtime으로 변환한다.
            if viewModel.switchStatus.value {
                viewModel.movePlayerToLyricsPart(targetTime)
            }
            else {
                dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    

}
