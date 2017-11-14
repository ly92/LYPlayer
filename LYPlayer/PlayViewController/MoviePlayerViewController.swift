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
   var subView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.url)
        
        self.testPlay()
        
//        self.subView.frame = CGRect.init(x: 0, y: 88, width: KScreenWidth, height: 300)
        self.subView.backgroundColor = UIColor.purple
        self.view.addSubview(self.subView)
        self.subView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(100)
            make.height.equalTo(250)
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LYPlayerView.shared.isPresentOrPushed{
            LYPlayerView.shared.isPresentOrPushed = false
        }
//        self.view.safeAreaInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 视图是否自动旋转
    override var shouldAutorotate : Bool {
        get{
            return false
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        get{
//            return .portrait
//        }
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LYPlayerView.shared.isPresentOrPushed = true

    }
    
    func testPlay() {
        let playerModel = LYPlayerModel()
        playerModel.videoURL = self.url
//        LYPlayerView.shared.isAutoPlay = false
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
