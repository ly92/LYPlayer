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
        // /Users/ly/Library/Developer/CoreSimulator/Devices/F74FC8DA-0C29-4D46-896C-2AFEA35A2272/data/Containers/Data/Application/AACACB27-140E-409C-8E72-6130F551BD41/Library/Caches566353844.mp4
//        let _ = LYHttpRequest.init(url: URL.init(string: self.url)!)
//
//        return
        let playerModel = LYPlayerModel()
        playerModel.videoURL = self.url
        
        LYDownloadManager.share().downloadFileUrl(url: self.url, fileName: (self.url as NSString).lastPathComponent, fileImage: nil)
        
//        playerModel.videoURL = "/Users/ly/Library/Developer/CoreSimulator/Devices/F74FC8DA-0C29-4D46-896C-2AFEA35A2272/data/Containers/Data/Application/0C549169-EC14-43E8-924B-D2A87E098A74/Library/Caches/566052304.mp4"
        playerModel.resolutionArray = [["高清":"http://baobab.wdjcdn.com/14571455324031.mp4"],["标清":"http://baobab.wdjcdn.com/1457521866561_5888_854x480.mp4"]]
//        LYPlayerView.shared.isAutoPlay = false
        LYPlayerView.shared.playerControlView(self.subView, playerModel)
    }
///Users/ly/Library/Developer/CoreSimulator/Devices/F74FC8DA-0C29-4D46-896C-2AFEA35A2272/data/Containers/Data/Application/0C549169-EC14-43E8-924B-D2A87E098A74/Library/Caches
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        LYPlayerView.shared.stopPlay()
    }
}
