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



enum LYPlayerState {
    case LYPlayerStateFailed     // 播放失败
    case LYPlayerStateBuffering  // 缓冲中
    case LYPlayerStateReadyPlay  //准备播放
    case LYPlayerStatePlaying    // 播放中
    case LYPlayerStatePause       // 暂停播放
    case LYPlayerStateStopped    // 停止播放，用户取消播放
    case LYPlayerStateEnd       //播放结束，自然结束
}

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
    
    //MARK: - 枚举
    enum LYPanDirection {
        case LYPanDirectionHorizontal//水平移动
        case LYPanDirectionVertical//垂直移动
    }
    
    //MARK: 可外部调用属性
    //当前状态是否被用户暂停
    var isPauseByUser = false{
        didSet{
            //            self.state = isPauseByUser ? .LYPlayerStatePause : .LYPlayerStatePlaying
        }
    }
    //当前页面消失
    var isPresentOrPushed = false{
        didSet{
            if self.isPresentOrPushed{
                self.state = .LYPlayerStatePause
            }else{
                if !self.isPauseByUser{
                    self.state = .LYPlayerStatePlaying
                }
            }
        }
    }
    //是否进入后台
    var didEnterBackground = false{
        didSet{
            if self.didEnterBackground{
                self.state = .LYPlayerStatePause
            }else{
                if !self.isPauseByUser && !self.isPresentOrPushed{
                    self.state = .LYPlayerStatePlaying
                }
            }
        }
    }
    var isAutoPlay = true//是否自动播放
    var mute = false//是否静音
    var player : AVPlayer?//播放器
    
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
            //设置控制层的状态
            self.controlView?.state = self.state
            if state == .LYPlayerStatePlaying{
                //取消用户的暂停
                self.isPauseByUser = false
                //开始播放
                self.player?.play()
            }else if state == .LYPlayerStateReadyPlay{
                //准备播放
                //可播放状态时如果是自动播放，则直接播放
                if self.isAutoPlay{
                    self.setState(.LYPlayerStatePlaying)
                }
                
            }else if state == .LYPlayerStateBuffering{
                
            }else if state == .LYPlayerStateFailed{
                
            }else if state == .LYPlayerStateStopped{
                //清理内存占用
                self.clean()
                
            }else if state == .LYPlayerStatePause{
                self.player?.pause()
                
            }else if state == .LYPlayerStateEnd{
                
            }
        }
    }
    
    func setState(_ state : LYPlayerState) {
        self.state = state
    }
    
    
    
    
    
    //MARK: 内部调用属性
    fileprivate var seekTime : NSInteger = 0//当前已播放时间
    fileprivate var playerLayer : AVPlayerLayer?//播放层
    fileprivate var urlAsset : AVURLAsset?//用于播放网络音视频资源
    fileprivate var videoGravity = AVLayerVideoGravity.resizeAspect//视频填充模式
    fileprivate var controlView : LYPlayerControllerView?//视频控制器view
    fileprivate var videoUrl : String!//视频地址
    fileprivate var isLocked = false//被锁定时不可改变进度和状态等，只能播放
    fileprivate var sumTime : CGFloat = 0//每次快进或着后退的时长
    fileprivate var panDirection : LYPanDirection = .LYPanDirectionHorizontal//手势方向
    fileprivate var isVolume = true//true表示调声音，false表示调亮度
    fileprivate var volumeViewSlider : UISlider?//声音
    fileprivate var isBuffering = false//是否正在缓存中
    fileprivate var timeObserver : Any?//检测播放进度
    fileprivate var fatherView = UIView()//父级视图
    fileprivate var isInCellSubView = false//是否存在于cell中
    fileprivate let kDownloadScheme = "lyPlayerScheme"//系统不能识别的scheme
    //是否拖拽中
    fileprivate var isDraging = false{
        didSet{
            self.controlView?.isDraging = isDraging
        }
    }
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
        self.playerLayer?.frame = self.bounds
        self.controlView?.frame = self.bounds
    }
}

//MARK: - 外部调用方法
extension LYPlayerView{
    
    /// 设置视频的控制层以及视频数据
    /// - Parameters:
    ///   - controlView: 控制层
    ///   - playerModel: 视频数据
    public func playerControlView(_ superView : UIView, _ playerModel : LYPlayerModel) {
        self.isInCellSubView = false
        self.playerModel = playerModel
        self.fatherView = superView
        self.setUpSuperView()
    }
    
    public func playerControlCellView(cellSubView : UIView, _ playerModel : LYPlayerModel) {
        self.isInCellSubView = true
        self.playerModel = playerModel
        self.fatherView = cellSubView
        self.setUpSuperView()
    }
    
    //停止播放，需要清理播放器和移除观察者
    func stopPlay() {
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isLandscape{
            UIApplication.shared.statusBarOrientation = .portrait
        }
        self.state = .LYPlayerStateStopped
        
    }
    //暂停播放
    func pause() {
        self.state = .LYPlayerStatePause
        self.isPauseByUser = true
    }
    //开始播放
    func play() {
        
        if self.state != .LYPlayerStatePlaying && self.state != .LYPlayerStateFailed{
            self.state = .LYPlayerStatePlaying
        }
        self.isPauseByUser = false
    }
    
}


//MARK: - 内部私有方法
extension LYPlayerView{
    //setting player
    private func configLYPlayer() {
        self.clean()
        self.backgroundColor = UIColor.red
        self.alpha = 0.8
        self.urlAsset = AVURLAsset.init(url: URL(string:self.videoUrl)!)
//        self.urlAsset = AVURLAsset.init(url: URL.init(fileURLWithPath: "/Users/ly/Library/Developer/CoreSimulator/Devices/F74FC8DA-0C29-4D46-896C-2AFEA35A2272/data/Containers/Data/Application/0C549169-EC14-43E8-924B-D2A87E098A74/Library/Caches/566052304.mp4"))
        // 初始化playerItem
        self.playerItem = AVPlayerItem.init(asset: self.urlAsset!)
        // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
        self.player = AVPlayer.init(playerItem: self.playerItem)
        // 初始化playerLayer
        self.playerLayer = AVPlayerLayer.init(player: self.player!)
        self.playerLayer?.videoGravity = self.videoGravity
        
        // 添加播放进度计时器
        self.createPlayerTimer()
        // 获取系统音量
        self.configureVolume()
        
        //添加通知
        self.addNotification()
    }
    
    //清理占用内存的所有，组件和通知
    private func clean() {
        //清理播放组件
        self.playerLayer?.removeFromSuperlayer()
        self.controlView?.removeFromSuperview()
        self.controlView = nil
        self.removeFromSuperview()
        self.playerItem = nil//顺带清理观察
        self.urlAsset = nil
        if self.timeObserver != nil{
            self.player?.removeTimeObserver(self.timeObserver!)
            self.timeObserver = nil
        }
        self.player = nil
        self.playerLayer = nil
        self.isLocked = false
        self.volumeViewSlider = nil
        // 移除通知
        NotificationCenter.default.removeObserver(self)
        //结束监听屏幕旋转
        //        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    // 添加播放进度计时器
    func createPlayerTimer() {
        self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: nil) { (time) in
            guard let currentItem = self.player?.currentItem else{
                return
            }
            let loadedRanges = currentItem.seekableTimeRanges
            if loadedRanges.count > 0 && currentItem.duration.timescale != 0{
                let currentTime = CGFloat(currentItem.currentTime().seconds)
                let totalTime = CGFloat(currentItem.duration.value) / CGFloat(currentItem.duration.timescale)
                let value = currentTime / totalTime
                self.controlView?.setPlayerSchedule(value: value, totalTime: totalTime)
            }
        }
    }
    
    
    //设置player的控制层view和superview
    private func setUpSuperView(){
        //保证播放组件不为空
        self.configLYPlayer()
        self.controlView = LYPlayerControllerView()
        self.controlView?.playerModel = self.playerModel
        self.controlView?.delegate = self
        self.controlView?.urlAsset = self.urlAsset
        //添加view和layer
        self.transform = CGAffineTransform.identity
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation.isPortrait{
            self.fatherView.addSubview(self)
            self.snp.makeConstraints({ (make) in
                make.leading.top.equalTo(0)
                make.size.equalTo(self.fatherView.snp.size)
            })
            self.controlView?.setUpFullScreenValue(false)
        }else{
            //
            guard let keyWindow = UIApplication.shared.keyWindow else{
                //设置状态栏方向
                UIApplication.shared.statusBarOrientation = .portrait
                self.setUpSuperView()
                return
            }
            self.controlView?.setUpFullScreenValue(true)
            keyWindow.addSubview(self)
            self.snp.makeConstraints({ (make) in
                make.height.equalTo(KScreenWidth)
                make.width.equalTo(KScreenHeight)
                make.center.equalTo(keyWindow.snp.center)
            })
            self.transform = self.getTransformRotation()
        }
        
        self.controlView?.frame = self.bounds
        self.playerLayer?.frame = self.bounds
        self.layer.addSublayer(self.playerLayer!)
        
        //添加手势
        self.createGesture()
        
        //3秒后变透明
        self.addSubview(self.controlView!)
    }
    
    //MARK: 处理通知
    //添加通知
    func addNotification() {
        // app退到后台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        // app进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.appDidEnterPlayground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // 监听耳机插入和拔掉通知
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.audioRouteChangeListenerCallback(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        //开始监听屏幕旋转
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // 监测设备方向
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.onDeviceOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //状态条变化
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerView.onStatusBarOrientationChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
    }
    
    //视频播放结束的通知
    @objc private func moviePlayDidEnd(noti:NotificationCenter) {
        print(noti)
        self.state = .LYPlayerStateEnd
    }
    // app将退到后台
    @objc private func appWillResignActive() {
        self.didEnterBackground = true
    }
    
    // app进入前台
    @objc private func appDidEnterPlayground() {
        self.didEnterBackground = false
    }
    
    // 监听耳机插入和拔掉通知
    @objc func audioRouteChangeListenerCallback(_ noti : Notification) {
        guard let value = noti.userInfo?["AVAudioSessionRouteChangeReasonKey"] else {
            return
        }
        guard let type = value as? Int else {
            return
        }
        if type == 1{
            //插入
            //自动降低声音
            if (self.volumeViewSlider?.value)! > Float(0.4){
                self.volumeViewSlider?.setValue(0.4, animated: true)
            }
        }else if type == 2{
            //拔出
            
        }
    }
    
    //MARK:全屏以及小屏幕播放
    // 监测设备方向
    @objc private func onDeviceOrientationChange() {
        if self.isLocked {return}
        if self.isPresentOrPushed{return}
        if self.didEnterBackground{return}
        
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isPortrait{
            self.toOrientation(.portrait)
        }else if deviceOrientation == .landscapeRight{
            self.toOrientation(.landscapeLeft)
        }else if deviceOrientation == .landscapeLeft{
            self.toOrientation(.landscapeRight)
        }
    }
    
    //状态条变化
    @objc private func onStatusBarOrientationChange() {
        let orientation = UIApplication.shared.statusBarOrientation
        print(orientation)
        //        self.toOrientation(orientation)
        //        if currentOrientation.isPortrait{
        //
        //        }else{
        //
        //        }
    }
    
    //改变屏幕
    func toOrientation(_ orientation : UIInterfaceOrientation) {
        //当前状态
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation == orientation{
            //如果要转的方向与当前方向一致则取消
            return
        }
        
        
        if orientation.isLandscape{
            //横屏播放
            if currentOrientation.isPortrait{
                //如果当前已是竖屏,则需更改superview；如果当前已是横屏,则只需更改transfer即可
                guard let keyWindow = UIApplication.shared.keyWindow else{
                    return
                }
                self.controlView?.setUpFullScreenValue(true)
                self.removeFromSuperview()
                keyWindow.addSubview(self)
                self.snp.makeConstraints({ (make) in
                    make.height.equalTo(KScreenWidth)
                    make.width.equalTo(KScreenHeight)
                    make.center.equalTo(keyWindow.snp.center)
                })
            }
        }else{
            //竖屏播放
            self.controlView?.setUpFullScreenValue(false)
            self.removeFromSuperview()
            self.fatherView.addSubview(self)
            self.snp.makeConstraints({ (make) in
                make.leading.top.equalTo(0)
                make.size.equalTo(self.fatherView.snp.size)
            })
        }
        
        //设置状态栏方向
        UIApplication.shared.statusBarOrientation = orientation
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        //首先设置原旋转角度，因为旋转是叠加的
        self.transform = CGAffineTransform.identity
        //旋转视频的方向
        self.transform = self.getTransformRotation()
        //        self.playerLayer?.frame = self.bounds
        //        self.controlView?.frame = self.bounds
        UIView.commitAnimations()
    }
    
    
    //页面应该旋转的角度
    func getTransformRotation() -> CGAffineTransform {
        
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .landscapeLeft:
            return CGAffineTransform.init(rotationAngle: -CGFloat(Double.pi / 2.0))
        case .landscapeRight:
            return CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 2.0))
        default:
            return CGAffineTransform.identity
        }
    }
    
}


//MARK: - 播放进度以及播放状态
extension LYPlayerView : UIGestureRecognizerDelegate, LYPlayerControllerViewDelegate{
    
    //MARK: 控制层代理方法
    func ly_playerControllerViewLock(_ isLock: Bool) {
        self.isLocked = isLock
    }
    
    func ly_playerControllerViewSliderClick(_ value: CGFloat) {
        if value > 1 || value < 0{
            //超出播放范围
            return
        }
        
        if self.state != .LYPlayerStatePlaying && self.state != .LYPlayerStatePause && self.state != .LYPlayerStateReadyPlay{
            return
        }
        // 需要限定sumTime的范围
        guard let durationTime = self.playerItem?.duration else {
            return
        }
        let totalTime = CGFloat(durationTime.value) / CGFloat(durationTime.timescale)
        //更改播放进度
        self.seekToTime(dragedSeconds: totalTime * value, completionHandler: nil)
    }
    
    
    func ly_playerControllerViewPlay() {
        self.state = .LYPlayerStatePlaying
    }
    
    func ly_playerControllerViewPause() {
        self.state = .LYPlayerStatePause
        self.isPauseByUser = true
    }
    
    func ly_playerControllerViewRepeat() {
        //更改播放进度
        let dragedCMTime = CMTime.init(value: CMTimeValue(0), timescale: 1)
        self.player?.seek(to: dragedCMTime, toleranceBefore: CMTime.init(value: 1, timescale: 1), toleranceAfter: CMTime.init(value: 1, timescale: 1), completionHandler: { (finish) in
        })
        self.player?.play()
        self.state = .LYPlayerStatePlaying
    }
    
    func ly_playerControllerViewFullScreen(_ isFull: Bool) {
        if isFull{
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation == .landscapeRight{
                self.toOrientation(.landscapeLeft)
            }else {
                self.toOrientation(.landscapeRight)
            }
        }else{
            self.toOrientation(.portrait)
        }
    }
    
    func ly_playerControllerViewDownload() {
        let components = NSURLComponents.init(url: URL(string:self.videoUrl)!, resolvingAgainstBaseURL: false)
        components?.scheme = "lyPlayer"//注意，不加这一句不能执行到回调操作
        self.urlAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
    }
    
    func ly_playerControllerViewResolution(_ videoUrl: String) {
        if videoUrl == self.videoUrl{return}
        self.videoUrl = videoUrl
        let currentTime = NSInteger(self.player?.currentTime().seconds ?? 0)
        self.clean()
        self.setUpSuperView()
        self.seekTime = currentTime
    }
    
    
    func ly_playerControllerViewBack() {
        self.stopPlay()
    }
    
    func ly_playerControllerViewClose() {
        self.stopPlay()
    }
    
    
    //MARK: 单击双击手势
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
        if self.controlView!.isShow{
            self.controlView?.hideControlView()
        }else{
            self.controlView?.showControlView()
        }
    }
    //双击，播放，暂停
    @objc func doubleTapAction() {
        if self.isLocked{ return }
        if self.state == .LYPlayerStatePlaying{
            self.state = .LYPlayerStatePause
            self.isPauseByUser = true
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
    
    
    
    
    //MARK: 手势操作，控制音量、亮度、快进快退
    @objc func panDirection(_ pan:UIPanGestureRecognizer) {
        if self.isLocked{ return }
        let velocity = pan.velocity(in: self)//移动速度
        let location = pan.location(in: self)//开始位置
        switch pan.state {
        case .began:
            if abs(velocity.x) > abs(velocity.y){
                //水平方向
                self.panDirection = .LYPanDirectionHorizontal
                guard let cmTime = self.playerItem?.currentTime() else{
                    return
                }
                self.sumTime = CGFloat(cmTime.value) / CGFloat(cmTime.timescale)
                self.isDraging = true
            }else if abs(velocity.x) < abs(velocity.y){
                //垂直方向
                self.panDirection = .LYPanDirectionVertical
                if location.x < self.frame.size.width / 2.0{
                    //调亮度
                    self.isVolume = false
                }else{
                    //调声音
                    self.isVolume = true
                }
            }
            
        case .changed:
            if self.panDirection == .LYPanDirectionVertical{
                self.verticalMoved(value: velocity.y)
            }else{
                self.horizontalMoved(value: velocity.x)
            }
        case .ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            if self.panDirection == .LYPanDirectionHorizontal{
                self.isPauseByUser = false
                self.seekToTime(dragedSeconds: self.sumTime, completionHandler: nil)
                self.sumTime = 0
                self.isDraging = false
            }else{
                
            }
            
            
        default:
            print(pan.state)
        }
    }
    
    //音量，亮度
    func verticalMoved(value : CGFloat) {
        if self.isVolume && self.volumeViewSlider != nil{
            self.volumeViewSlider?.value = self.volumeViewSlider!.value - Float(value / 10000)
        }else{
            UIScreen.main.brightness = UIScreen.main.brightness - value / 10000
        }
    }
    //播放进度
    func horizontalMoved(value : CGFloat) {
        if self.state != .LYPlayerStatePlaying && self.state != .LYPlayerStatePause && self.state != .LYPlayerStateReadyPlay{
            return
        }
        // 每次滑动需要叠加时间
        self.sumTime = self.sumTime + value / 200
        // 需要限定sumTime的范围
        guard let durationTime = self.playerItem?.duration else {
            return
        }
        if durationTime.timescale == 0{return}
        let totalTime = CGFloat(durationTime.value) / CGFloat(durationTime.timescale)
        
        if self.sumTime > totalTime {
            self.sumTime = totalTime
        }else if self.sumTime < 0{
            self.sumTime = 0
        }
        
        if value > 0{
            self.controlView?.changeDragSections(dragSec: self.sumTime, totalTime: totalTime, type: true)
        }else if value < 0{
            self.controlView?.changeDragSections(dragSec: self.sumTime, totalTime: totalTime, type: false)
        }
    }
    
    //从xx秒开始播放视频跳转，dragedSeconds视频跳转的秒数
    func seekToTime(dragedSeconds : CGFloat, completionHandler finished : ((Bool) -> Void)?) {
        if (self.state == .LYPlayerStatePlaying || self.state == .LYPlayerStatePause) && self.player?.currentItem?.status == .readyToPlay{
            // seekTime:completionHandler:不能精确定位
            // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
            // 转换成CMTime才能给player来控制播放进度
            self.player?.pause()
            let dragedCMTime = CMTime.init(value: CMTimeValue(dragedSeconds), timescale: 1)
            self.player?.seek(to: dragedCMTime, toleranceBefore: CMTime.init(value: 1, timescale: 1), toleranceAfter: CMTime.init(value: 1, timescale: 1), completionHandler: { (finish) in
                // 视频跳转回调
                if finished != nil{
                    finished!(finish)
                }
                if self.state == .LYPlayerStatePlaying{
                    self.player?.play()
                }
            })
        }
    }
    
    //MARK: 获取声音
    func configureVolume() {
        let volumeView = MPVolumeView()
        self.volumeViewSlider = nil
        for view in volumeView.subviews {
            if ((view as? UISlider) != nil){
                self.volumeViewSlider = view as? UISlider
            }
        }
        // 设置声音变大 - 播放声音的时候需要大
        let session = AVAudioSession.sharedInstance()
        if session.category != AVAudioSessionCategoryPlayback{
            try! session.setCategory(AVAudioSessionCategoryPlayback)
            try! session.setActive(true)
        }
    }
    //
    
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
                        self.state = .LYPlayerStateReadyPlay
                        
                        // 加载完成后，再添加平移手势
                        // 添加平移手势，用来控制音量、亮度、快进快退
                        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(LYPlayerView.panDirection(_:)))
                        pan.delegate = self
                        pan.maximumNumberOfTouches = 1
                        pan.delaysTouchesBegan = true
                        pan.delaysTouchesEnded = true
                        pan.cancelsTouchesInView = true
                        self.addGestureRecognizer(pan)
                        
                        if self.seekTime > 0 && NSInteger((self.playerItem?.duration.seconds)!) > self.seekTime{
                            self.seekToTime(dragedSeconds: CGFloat(self.seekTime), completionHandler: nil)
                        }
                        self.player?.isMuted = self.mute
                    }else if self.player?.currentItem?.status == .failed{
                        self.state = .LYPlayerStateFailed
                    }
                }else if keyPath! == "loadedTimeRanges"{
                    // 计算缓冲进度
                    let timeInterval = self.availableDuration()
                    guard let duration = self.playerItem?.duration.seconds else{
                        return
                    }
                    let value = Float(timeInterval / duration)
                    self.controlView?.setUpBufferProgressValue(value)
                }else if keyPath! == "playbackBufferEmpty"{
                    // 当缓冲是空的时候
                    //                    print("###############")
                    //                    print(self.player?.currentItem?.currentTime() ?? "self.player?.currentItem?.currentTime()")
                    if (self.playerItem?.isPlaybackBufferEmpty)!{
                        self.bufferingSomeSecond()
                    }
                    
                }else if keyPath! == "playbackLikelyToKeepUp"{
                    // 当缓冲好的时候
                    if self.playerItem!.isPlaybackLikelyToKeepUp && self.state != .LYPlayerStatePlaying && self.state != .LYPlayerStatePause{
                        self.state = .LYPlayerStatePlaying
                    }
                }
            }
        default:
            print("default")
        }
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
        if self.state == .LYPlayerStateEnd {return}
        print("-------------------------1")
        self.state = .LYPlayerStateBuffering
        // playbackBufferEmpty会反复进入，因此在bufferingSomeSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        if self.isBuffering{
            return
        }
        print("-------------------------2")
        self.isBuffering = true
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        self.player?.pause()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            print("-------------------------3")
            // 如果此时用户已经暂停了，则不再需要开启播放了
            if self.isPauseByUser{
                self.isBuffering = false
                return
            }
            
            self.player?.play()
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            self.isBuffering = false
            if self.playerItem == nil{return}
            if self.playerItem!.isPlaybackLikelyToKeepUp{
                self.bufferingSomeSecond()
            }
        }
        
    }
}

//MARK: - 缓存视频
extension LYPlayerView : AVAssetResourceLoaderDelegate{
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        //获取系统中不能处理的URL
        guard let resourceUrl = loadingRequest.request.url else{
            return false
        }
        //判断这个URL是否遵守URL规范和其是否是我们所设定的URL
        if resourceUrl.scheme == kDownloadScheme{
            //判断当前的URL网络请求是否已经被加载过了，如果缓存中里面有URL对应的网络加载器(自己封装，也可以直接使用NSURLRequest)，则取出来添加请求，每一个URL对应一个网络加载器，loader的实现接下来会说明
//            let loader =
            return true
        }else{
            return false
        }
    }
    
   
}
