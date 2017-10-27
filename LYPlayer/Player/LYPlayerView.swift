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
    enum LYPlayerState {
        case LYPlayerStateFailed     // 播放失败
        case LYPlayerStateBuffering  // 缓冲中
        case LYPlayerStatePlaying    // 播放中
        case LYPlayerStateStopped    // 停止播放
        case LYPlayerStatePause       // 暂停播放
    }
    
    
    //MARK: - 可外部调用属性
    var isPauseByUser = false//当前状态是否被用户暂停
    var isAutoPlay = true//是否自动播放
    var mute = false//是否静音
    //是否因切换页面而导致不在当前显示页面
    var playerPushedOrPresented = false{
        didSet{
            if playerPushedOrPresented{
                self.player?.pause()
            }else{
                if !self.isPauseByUser{
                    self.player?.play()
                }
            }
        }
    }
    
    
    //播放器的几种状态
    var state : LYPlayerState = .LYPlayerStateBuffering{
        didSet{
            if state == .LYPlayerStatePlaying || state == .LYPlayerStateBuffering{
                if self.isPauseByUser{
                    //如果用户暂停了播放
                    
                }else{
                    //可播放状态时如果是自动播放，则直接播放
                    if self.isAutoPlay{
                        self.player?.play()
                    }
                }
            }else if state == .LYPlayerStateFailed{
                
            }else if state == .LYPlayerStateStopped{
                //清理内存占用
                self.clean()
                
            }else if state == .LYPlayerStatePause{
                self.player?.pause()
                
            }
         }
    }
    
    
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
    var player : AVPlayer?//播放器
    //视频播放信息
    fileprivate var __playerItem : AVPlayerItem?
    fileprivate var playerItem : AVPlayerItem?{
        set{
            if __playerItem != nil{
                //有值且不为新值时先清除观察项
                if __playerItem == newValue {return}
                NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: __playerItem)
                __playerItem?.removeObserver(self, forKeyPath: "status")
                __playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
                __playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
                __playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            }
            __playerItem = newValue
            if __playerItem == nil{
                //赋予一个空值
                return
            }
            NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.moviePlayDidEnd(noti:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: __playerItem)
            __playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            __playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            // 缓冲区空了，需要等待数据
            __playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            // 缓冲区有足够数据可以播放了
            __playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        }
        get{
            return __playerItem
        }
    }
    fileprivate var playerLayer : AVPlayerLayer?//播放层
    fileprivate var urlAsset : AVURLAsset?//用于播放网络音视频资源
    fileprivate var videoGravity = AVLayerVideoGravity.resizeAspect//视频填充模式
    
    //视频控制器view
    fileprivate var controlView = LYPlayerControllerView()
    //视频信息
    fileprivate var playerModel = LYPlayerModel(){
        didSet{
            self.seekTime = playerModel.seekTime
            self.videoUrl = playerModel.videoURL
        }
    }
    
    
    deinit {
        if self.playerItem != nil{
            self.playerItem?.removeObserver(self, forKeyPath: "status")
            self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            self.playerItem = nil
        }
        
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    
    
    
    
    
    
    
    
}

//MARK: - 外部调用方法
extension LYPlayerView{
    
    /// 设置视频的控制层以及视频数据
    /// - Parameters:
    ///   - controlView: 控制层
    ///   - playerModel: 视频数据
    public func playerControlView(_ superView : UIView, _ playerModel : LYPlayerModel) {
        self.playerModel = playerModel
        self.setUpSuperView(superView)
    }
    
    //停止播放，需要清理播放器和移除观察者
    func stopPlay() {
        self.state = .LYPlayerStateStopped
        
    }
    //暂停播放
    func pause() {
        self.state = .LYPlayerStatePause
        self.isPauseByUser = true
    }
    //开始播放
    func play() {
        if self.state != .LYPlayerStatePlaying{
            self.state = .LYPlayerStatePlaying
        }
        self.isPauseByUser = false
    }
    
}


//MARK: - 内部私有方法
extension LYPlayerView{
    //setting player
    private func configLYPlayer() {
        self.urlAsset = AVURLAsset.init(url: URL(string:self.videoUrl)!)
        // 初始化playerItem
        self.playerItem = AVPlayerItem.init(asset: self.urlAsset!)
        // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
        self.player = AVPlayer.init(playerItem: self.playerItem)
        // 初始化playerLayer
        self.playerLayer = AVPlayerLayer.init(player: self.player!)
        self.playerLayer?.videoGravity = self.videoGravity
    }

    //清理占用内存的所有，组件和通知
    private func clean() {
        //清理播放组件
        self.playerLayer?.removeFromSuperlayer()
        self.controlView.removeFromSuperview()
        self.removeFromSuperview()
        self.playerItem = nil//顺带清理观察
        self.urlAsset = nil
        self.player = nil
        self.playerLayer = nil
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    //视频播放结束的通知
    @objc private func moviePlayDidEnd(noti:NotificationCenter) {
        print(noti)
    }
    
    //设置player的控制层view和superview
    private func setUpSuperView(_ superView : UIView){
        //保证播放组件不为空
        self.configLYPlayer()
        //添加view和layer
        self.frame = superView.bounds
        self.controlView.frame = self.bounds
        self.playerLayer?.frame = self.bounds
        self.layer.addSublayer(self.playerLayer!)
        superView.addSubview(self)
        self.createGesture()
        
        //3秒后变透明
        self.addSubview(self.controlView)
    }
    
    
    
}


//MARK: - 播放进度以及播放状态
extension LYPlayerView : UIGestureRecognizerDelegate{
    
    //MARK: 创建手势
    func createGesture() {
        //单击
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(LYPlayerView.singleTapAction))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.delegate = self
        self.addGestureRecognizer(singleTap)
        
        //双击，播放，暂停
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(LYPlayerView.doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        doubleTap.delegate = self
        self.addGestureRecognizer(doubleTap)
        
        // 解决点击当前view时候响应其他控件事件
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        // 双击失败响应单击事件
        singleTap.require(toFail: doubleTap)
    }
    //单击
    @objc func singleTapAction() {
        if self.controlView.alpha == 0{
            self.controlView.alpha = 1
        }else{
            self.controlView.alpha = 0
        }
    }
    //双击，播放，暂停
    @objc func doubleTapAction() {
        if self.state == .LYPlayerStatePlaying{
            self.state = .LYPlayerStatePause
        }else{
            self.state = .LYPlayerStatePlaying
        }
    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else{
//            return
//        }
//        if touch.tapCount == 1{
//            self.singleTapAction()
//        }else if touch.tapCount == 2{
//            self.doubleTapAction()
//        }
//    }
    
    //MARK: 观察playeritem的可播放状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //空对象时不做处理
        if object == nil{ return }
        
        switch object {
        case _ as AVPlayerItem:
            if keyPath != nil && change != nil && self.playerItem != nil{
                if keyPath == "status"{
                    if self.player?.currentItem?.status == .readyToPlay{
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                        self.state = .LYPlayerStatePlaying
                        
                        // 加载完成后，再添加平移手势
                        // 添加平移手势，用来控制音量、亮度、快进快退
                        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(LYPlayerView.panDirection(_:)))
                        pan.delegate = self
                        pan.maximumNumberOfTouches = 1
                        pan.delaysTouchesBegan = true
                        pan.delaysTouchesEnded = true
                        pan.cancelsTouchesInView = true
                        self.addGestureRecognizer(pan)
                        
//                        if self.seekTime{
//                            self
//                        }
                        self.player?.isMuted = self.mute
                    }else if self.player?.currentItem?.status == .failed{
                        self.state = .LYPlayerStateFailed
                    }
                }else if keyPath! == "loadedTimeRanges"{
                    // 计算缓冲进度
//                    let timeInterval = self.availableDuration()
//                    let duration = self.playerItem?.duration.seconds
                    
                }else if keyPath! == "playback BufferEmpty"{
                    // 当缓冲是空的时候
                    if (self.playerItem?.isPlaybackBufferEmpty)!{
                        self.state = .LYPlayerStateBuffering
                    }
                }else if keyPath! == "playbackLikelyToKeepUp"{
                    // 当缓冲好的时候
                    
                }
            }
        default:
            print("default")
        }
    }
    
    //手势操作，控制音量、亮度、快进快退
    @objc func panDirection(_ pan:UIPanGestureRecognizer) {
        
    }
    
    
    
    //MARK: 当前已缓冲的进度
    func availableDuration() -> TimeInterval {
        guard let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges else{
            return 0
        }
        // 获取缓冲区域
        guard let timeRange = loadedTimeRanges.first?.timeRangeValue else{
            return 0
        }
        let startSeconds = timeRange.start.seconds
        let durationSeconds = timeRange.duration.seconds
        // 计算缓冲总进度
        let result = startSeconds + durationSeconds
        return result
    }
    
    //缓冲较差时候
    func bufferingSomeSecond() {
        self.state = .LYPlayerStateBuffering
        // playbackBufferEmpty会反复进入，因此在bufferingSomeSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        
    }
}

