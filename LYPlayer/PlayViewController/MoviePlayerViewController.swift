//
//  MoviePlayerViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class MoviePlayerViewController: UIViewController {

    var url = ""
    @IBOutlet weak var subView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.url)
        
        self.testPlay()
        
        self.subView.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 300)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LYPlayerView.shared.isPauseByUser{
            LYPlayerView.shared.play()
        }
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LYPlayerView.shared.pause()
    }
    
    func testPlay() {
        let playerModel = LYPlayerModel()
        playerModel.videoURL = self.url
        LYPlayerView.shared.playerControlView(self.subView, playerModel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        LYPlayerView.shared.stopPlay()
    }
}
