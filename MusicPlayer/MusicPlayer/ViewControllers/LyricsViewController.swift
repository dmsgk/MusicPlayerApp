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
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchLyrics()
        viewModel.switchStatus.value = true

        tableView.delegate = self
        tableView.dataSource = self
    
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
