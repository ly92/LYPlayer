//
//  LYPlayerView.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class LYPlayerView: UIView {
    var videoUrl : String!
    var player : AVPlayer!
    
    
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
        let playerItem = AVPlayerItem.init(url: URL(string:self.videoUrl)!)
        
        self.player = AVPlayer.init(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        
        self.player.play()
        
    }
    
}
