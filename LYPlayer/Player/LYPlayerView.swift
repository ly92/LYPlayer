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
    
    /**
     *  单例，用于列表cell上多个视频
     */
    static let shared = LYPlayerView()
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    fileprivate var seekTime : NSInteger = 0
    
    fileprivate var videoUrl : String!//视频地址
    fileprivate var player : AVPlayer!//播放器
    //视频播放信息
    var __playerItem : AVPlayerItem?
    fileprivate var playerItem : AVPlayerItem?{
        set{
            if __playerItem != nil{
                //有值且不为新值时先清除观察项
                if __playerItem == newValue {return}
                __playerItem!.removeObserver(self, forKeyPath: "status")
                __playerItem!.removeObserver(self, forKeyPath: "loadedTimeRanges")
                __playerItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
                __playerItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            }
            __playerItem = newValue
            if __playerItem == nil{
                //赋予一个空值
                return
            }
            NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.moviePlayDidEnd(noti:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem!)
            playerItem?.addObserver(self, forKeyPath: "ststus", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            // 缓冲区空了，需要等待数据
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            // 缓冲区有足够数据可以播放了
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        }
        get{
            return __playerItem
        }
    }
    fileprivate var playerLayer : AVPlayerLayer?//播放层
    //视频控制器view
    fileprivate var controlView = UIView(){
        didSet{
            self.frame = controlView.bounds
            controlView.addSubview(self)
//            self.addSubview(controlView)
//            controlView.snp.makeConstraints { (make) in
//                make.edges.equalTo(UIEdgeInsets.zero)
//            }
        }
    }
    //视频信息
    fileprivate var playerModel = LYPlayerModel(){
        didSet{
            self.seekTime = playerModel.seekTime
            self.videoUrl = playerModel.videoURL
            
        }
    }
    
    
    deinit {
        if self.playerItem != nil{
            self.playerItem!.removeObserver(self, forKeyPath: "status")
            self.playerItem!.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            self.playerItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            self.playerItem = nil
        }
        
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.bounds
        
        self.configLYPlayer()
    }
    
    //setting player
    func configLYPlayer() {
        self.resetPlayer()

        let playerItem = AVPlayerItem.init(url: URL(string:self.videoUrl)!)
        
        self.player = AVPlayer.init(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer.frame = self.bounds
        self.playerLayer = playerLayer
        self.layer.addSublayer(playerLayer)
        
        self.player.play()
        
    }
    
    func resetPlayer() {
        self.playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)

    }
    
    
    
    
    /// 设置视频的控制层以及视频数据
    /// - Parameters:
    ///   - controlView: 控制层
    ///   - playerModel: 视频数据
    public func playerControlView(_ controlView : UIView?, _ playerModel : LYPlayerModel) {
        if controlView != nil{
            self.controlView = controlView!
        }else{
            let defaultControlView = LYPlayerControllerView()
            self.controlView = defaultControlView
        }
        self.playerModel = playerModel
        self.configLYPlayer()
    }
    
    
    
}

//MARK: - 外部调用方法
extension LYPlayerView{
    
    
    
}


//MARK: - 内部私有方法
extension LYPlayerView{
    @objc private func moviePlayDidEnd(noti:NotificationCenter) {
        print(noti)
    }
}


