//
//  LYPlayerView.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class LYPlayerView: UIView {
    var videoUrl : String!
    var player : AVPlayerViewController!
    
    
    init(frame: CGRect, url : String) {
        self.videoUrl = url
        super.init(frame: frame)
        self.configLYPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    //setting player
    func configLYPlayer() {
        self.player = AVPlayerViewController()
        self.player.view.frame = self.frame
        self.player.player = AVPlayer.init(url: URL(string:self.videoUrl)!)
        self.addSubview(self.player.view)
        self.player.player?.play()
        
        
    }
    
}
