//
//  LYPlayerControllerView.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import SnapKit

protocol LYPlayerControllerViewDelegate {
    func ly_playerControllerViewPlay()
    func ly_playerControllerViewPause()
    func ly_playerControllerViewRepeat()
    func ly_playerControllerViewFullScreen(_ isFull:Bool)
    func ly_playerControllerViewDownload()
    func ly_playerControllerViewResolution()
    func ly_playerControllerViewBack()
    func ly_playerControllerViewClose()
    func ly_playerControllerViewLock(_ isLock:Bool)
}

class LYPlayerControllerView: UIView {
    
   
    var delegate : LYPlayerControllerViewDelegate?
    //播放器的几种状态
    var state : LYPlayerState = .LYPlayerStateBuffering{
        didSet{
            self.repeatBtn.isHidden = true
            self.failBtn.isHidden = true
            self.playBtn.isHidden = true
            self.startBtn.isSelected = false
            self.placeholderImageView.isHidden = true
            
            if state == .LYPlayerStatePlaying{
                self.startBtn.isSelected = true

            }else if state == .LYPlayerStateBuffering{
                self.startBtn.isSelected = true

            }else if state == .LYPlayerStateFailed{
                self.placeholderImageView.isHidden = false
                self.failBtn.isHidden = false

            }else if state == .LYPlayerStateStopped{
                self.repeatBtn.isHidden = false
                
            }else if state == .LYPlayerStatePause{
                self.playBtn.isHidden = false
                
            }else if state == .LYPlayerStateEnd{
                self.repeatBtn.isHidden = false
                
            }
        }
    }
    
    
    //视频信息
    var playerModel = LYPlayerModel(){
        didSet{
            self.titleLabel.text = playerModel.title
            self.placeholderImageView.image = playerModel.placeholderImage
        }
    }
    
    /** 标题 */
    fileprivate var titleLabel = UILabel()
    /** 开始播放按钮 */
    fileprivate var startBtn = UIButton()
    /** 当前播放时长label */
    fileprivate var currentTimeLabel = UILabel()
    /** 视频总时长label */
    fileprivate var totalTimeLabel = UILabel()
    /** 缓冲进度条 */
    fileprivate var progressView = UIProgressView()
    /** 滑杆 */
    //    var videoSlider = LYValueTrackingSlider()
    /** 全屏按钮 */
    fileprivate var fullScreenBtn = UIButton()
    /** 锁定屏幕方向按钮 */
    fileprivate var lockBtn = UIButton()
    /** 系统菊花 */
    
    /** 返回按钮*/
    fileprivate var backBtn = UIButton()
    /** 关闭按钮*/
    fileprivate var closeBtn = UIButton()
    /** 重播按钮 */
    fileprivate var repeatBtn = UIButton()
    /** bottomImageView*/
    fileprivate var bottomImageView = UIImageView()
    /** topImageView */
    fileprivate var topImageView = UIImageView()
    /** bottomView*/
    fileprivate var bottomView = UIView()
    /** topView */
    fileprivate var topView = UIView()
    /** 缓存按钮 */
    fileprivate var downLoadBtn = UIButton()
    /** 切换分辨率按钮 */
    fileprivate var resolutionBtn = UIButton()
    /** 分辨率的View */
    fileprivate var resolutionView = UIView()
    /** 播放按钮 */
    fileprivate var playBtn = UIButton()
    /** 加载失败按钮 */
    fileprivate var failBtn = UIButton()
    /** 快进快退View*/
    fileprivate var fastView = UIView()
    /** 快进快退进度progress*/
    fileprivate var fastProgressView = UIProgressView()
    /** 快进快退时间*/
    fileprivate var fastTimeLabel = UILabel()
    /** 快进快退ImageView*/
    fileprivate var fastImageView = UIImageView()
    /** 当前选中的分辨率btn按钮 */
    fileprivate var resoultionCurrentBtn = UIButton()
    /** 占位图 */
    fileprivate var placeholderImageView = UIImageView()
    /** 控制层消失时候在底部显示的播放进度progress */
    fileprivate var bottomProgressView = UIProgressView()
    /** 分辨率的名称 */
    fileprivate var resolutionArray = Array<Any>()
    
    /** 显示控制层 */
    var isShow = false//当前是否显示
    /** 小屏播放 */
    fileprivate var shrink = false
    /** 在cell上播放 */
    fileprivate var cellVideo = false
    /** 是否拖拽slider控制播放进度 */
    fileprivate var dragged = false
    /** 是否播放结束 */
    fileprivate var playeEnd = false
    /** 是否全屏播放 */
    fileprivate var fullScreen = false
    //当前是否操作中
    fileprivate var __isOperationing = false
    fileprivate var isOperationing : Bool{
        set{
            //如果设置当前为操作状态且旧值为false，5秒后自动变为非操作状态，设置当前为非操作状态时询问隐藏
            if newValue{
                if (!__isOperationing){
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
                        self.isOperationing = false
                    }
                }
            }else{
                self.hideControlView()
            }
            __isOperationing = newValue
        }
        get{
            return __isOperationing
        }
    }
    
    
    
    init() {
        super.init(frame:CGRect.zero)
        
        self.addSubview(self.placeholderImageView)
        //        self.placeholderImageView.image = UIImage(named: "LYPlayer.bundle/LYPlayer_loading_bgView")
        
        self.addSubview(self.topImageView)
        self.topView.addSubview(self.backBtn)
        self.topView.addSubview(self.titleLabel)
        self.topView.addSubview(self.resolutionBtn)
        self.topView.addSubview(self.downLoadBtn)
        self.addSubview(self.topView)
        
        self.addSubview(self.bottomImageView)
        self.bottomView.addSubview(self.startBtn)
        self.bottomView.addSubview(self.currentTimeLabel)
        self.bottomView.addSubview(self.progressView)
        //        self.bottomView.addSubview(self.videoSlider)
        self.bottomView.addSubview(self.totalTimeLabel)
        self.bottomView.addSubview(self.fullScreenBtn)
        self.addSubview(self.bottomView)
        
        self.addSubview(self.lockBtn)
        //        self.addSubview(self.)
        self.addSubview(self.repeatBtn)
        self.addSubview(self.playBtn)
        self.addSubview(failBtn)
        self.addSubview(self.closeBtn)
        self.addSubview(self.bottomProgressView)
        
        
        self.fastView.addSubview(self.fastImageView)
        self.fastView.addSubview(self.fastTimeLabel)
        self.fastView.addSubview(self.fastProgressView)
        self.addSubview(self.fastView)
        
        
        self.makeSubViewsConstraints()
        
        self.downLoadBtn.isHidden = true
        self.resolutionBtn.isHidden = true
        self.closeBtn.isHidden = true
        self.repeatBtn.isHidden = true
        self.fastView.isHidden = true
        
        // 初始化时重置controlView
        self.playerResetControlView()
        
        // app退到后台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        // app进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.appDidEnterPlayground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        //监听设备旋转通知
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.onDeviceOrientationChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.setUpDefaultViewAttribute()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension LYPlayerControllerView{
    //MARK: - 约束
    func makeSubViewsConstraints() {
        self.placeholderImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        self.closeBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing).offset(7)
            make.top.equalTo(self.snp.top).offset(-7)
            make.width.height.equalTo(20)// 设置宽、高
        }
        
        self.topView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(self.snp.top).offset(0)
            make.height.equalTo(50)
        }
        
        self.topImageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.height.equalTo(self.topView)
        }
        
        self.backBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.topImageView.snp.leading).offset(10)
            make.top.equalTo(self.topImageView.snp.top).offset(3)
            make.width.height.equalTo(40)
        }
        
        self.downLoadBtn.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(49)
            make.trailing.equalTo(self.topImageView.snp.trailing).offset(-10)
            make.centerY.equalTo(self.backBtn.snp.centerY)
        }
        
        self.resolutionBtn.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(25)
            make.trailing.equalTo(self.downLoadBtn.snp.leading).offset(-20)
            make.centerY.equalTo(self.backBtn.snp.centerY)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.backBtn.snp.trailing).offset(5)
            make.trailing.equalTo(self.resolutionBtn.snp.leading).offset(-10)
            make.centerY.equalTo(self.backBtn.snp.centerY)
        }
        
        self.bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        
        self.bottomImageView.snp.makeConstraints { (make) in
            //            make.leading.trailing.bottom.equalTo(0)
            //            make.height.equalTo(50)
            make.leading.trailing.bottom.height.equalTo(self.bottomView)
        }
        
        self.startBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.bottomImageView.snp.leading).offset(5)
            make.bottom.equalTo(self.bottomImageView.snp.bottom).offset(-5)
            make.width.equalTo(30)
        }
        
        self.currentTimeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.startBtn.snp.trailing).offset(-3)
            make.centerY.equalTo(self.startBtn.snp.centerY)
            make.width.equalTo(43)
        }
        
        self.fullScreenBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.bottomImageView.snp.trailing).offset(-5)
            make.width.equalTo(30)
            make.centerY.equalTo(self.startBtn.snp.centerY)
        }
        
        self.totalTimeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.fullScreenBtn.snp.leading).offset(3)
            make.centerY.equalTo(self.startBtn.snp.centerY)
            make.width.equalTo(43)
        }
        
        self.progressView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.currentTimeLabel.snp.trailing).offset(4)
            make.trailing.equalTo(self.totalTimeLabel.snp.leading).offset(-4)
            make.centerY.equalTo(self.startBtn.snp.centerY)
        }
        
        //        self.videoSlider.snp.makeConstraints { (make) in
        //            make.leading.equalTo(self.currentTimeLabel.snp.trailing).offset(4)
        //            make.trailing.equalTo(self.totalTimeLabel.snp.leading).offset(-4)
        //            make.centerY.equalTo(self.currentTimeLabel.snp.centerY).offset(-1)
        //            make.height.equalTo(30)
        //        }
        
        self.lockBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading).offset(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(32)
        }
        
        self.repeatBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        
        self.playBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.height.equalTo(50)
        }
        
        //        self
        
        self.failBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(130)
            make.height.equalTo(33)
        }
        
        self.fastView.snp.makeConstraints { (make) in
            make.width.equalTo(125)
            make.height.equalTo(80)
            make.center.equalTo(self)
        }
        
        self.fastImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.top.equalTo(5)
            make.centerX.equalTo(self.fastView.snp.centerX)
        }
        
        self.fastTimeLabel.snp.makeConstraints { (make) in
            make.leading.width.trailing.equalTo(0)
            make.top.equalTo(self.fastImageView.snp.bottom).offset(2)
        }
        
        self.fastProgressView.snp.makeConstraints { (make) in
            make.leading.equalTo(12)
            make.trailing.equalTo(-12)
            make.top.equalTo(self.fastTimeLabel.snp.bottom).offset(10)
        }
        
        self.bottomProgressView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if currentOrientation.isPortrait{
            self.setOrientationPortraitConstraint()
        }else{
            self.setOrientationLandscapeConstraint()
        }
    }
    
    //MARK: - 重置页面数据
    func playerResetControlView() {
        
    }
    
    func setUpDefaultViewAttribute() {
        self.backBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_back_full"), for: .normal)
        self.downLoadBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_download"), for: .normal)
        self.resolutionBtn.setTitle("|高清|", for: .normal)
        self.topImageView.image = UIImage(named: "LYPlayer.bundle/LYPlayer_top_shadow")
        
        self.startBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_play"), for: .normal)
        self.startBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_pause"), for: .selected)
        self.currentTimeLabel.text = "0:00"
        self.currentTimeLabel.textColor = UIColor.white
        self.currentTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.totalTimeLabel.text = "10:24"
        self.totalTimeLabel.textColor = UIColor.white
        self.totalTimeLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.fullScreenBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_fullscreen"), for: .normal)
        self.fullScreenBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_shrinkscreen"), for: .selected)
        self.bottomImageView.image = UIImage(named: "LYPlayer.bundle/LYPlayer_bottom_shadow")
        
        self.lockBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_unlock_nor"), for: .normal)
        self.lockBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_lock_nor"), for: .selected)
        self.repeatBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_repeat_video"), for: .normal)
        self.failBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_repeat_video"), for: .normal)
        self.closeBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_close"), for: .normal)
        self.playBtn.setImage(UIImage(named: "LYPlayer.bundle/LYPlayer_play_btn"), for: .normal)
        
        
        self.lockBtn.addTarget(self, action: #selector(LYPlayerControllerView.lockBtnAction), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(LYPlayerControllerView.closeBtnAction), for: .touchUpInside)
        self.fullScreenBtn.addTarget(self, action: #selector(LYPlayerControllerView.fullScreenBtnAction), for: .touchUpInside)
        self.startBtn.addTarget(self, action: #selector(LYPlayerControllerView.playBtnAction), for: .touchUpInside)
        self.playBtn.addTarget(self, action: #selector(LYPlayerControllerView.playBtnAction), for: .touchUpInside)
        self.resolutionBtn.addTarget(self, action: #selector(LYPlayerControllerView.resolutionBtnAction), for: .touchUpInside)
        
        self.repeatBtn.addTarget(self, action: #selector(LYPlayerControllerView.repeatBtnAction), for: .touchUpInside)
        self.failBtn.addTarget(self, action: #selector(LYPlayerControllerView.repeatBtnAction), for: .touchUpInside)
        self.downLoadBtn.addTarget(self, action: #selector(LYPlayerControllerView.downloadBtnAction), for: .touchUpInside)
        self.backBtn.addTarget(self, action: #selector(LYPlayerControllerView.backBtnAction), for: .touchUpInside)
        
        self.showControlView()
    }
    
    //app进入后台
    @objc func appDidEnterBackground() {
        
    }
    //app进入前台
    @objc func appDidEnterPlayground() {
        
    }
    //屏幕旋转
    @objc func onDeviceOrientationChange() {
        
    }
    
    //设置竖屏约束
    func setOrientationPortraitConstraint() {
        
    }
    
    //设置横屏约束
    func setOrientationLandscapeConstraint() {
        
    }
    
    //点击切换分别率按钮
    func changeResolution(sender:UIButton) {
        sender.isSelected = true
        if sender.isSelected{
            sender.backgroundColor = UIColor.RGB(r: 86, g: 143, b: 232)
        }else{
            sender.backgroundColor = UIColor.clear
        }
        self.resoultionCurrentBtn.isSelected = false
        self.resoultionCurrentBtn.backgroundColor = UIColor.clear
        self.resoultionCurrentBtn = sender
        //隐藏分辨率View
        self.resolutionView.isHidden = true
        //分辨率Btn改为normal状态
        self.resolutionBtn.isSelected = false
        // topImageView上的按钮的文字
        self.resolutionBtn.setTitle(sender.titleLabel?.text, for: .normal)
        /**
         
         */
        //   _
        //  | |      /\   /\
        //  | |      \ \_/ /
        //  | |       \_~_/
        //  | |        / \
        //  | |__/\    [ ]
        //  |_|__,/    \_/
        //
    }
    
    
}

//MARK: - 按钮点击事件
extension LYPlayerControllerView{
    //锁定屏幕，解锁
    @objc func lockBtnAction() {
        self.isOperationing = true
        self.lockBtn.isSelected = !self.lockBtn.isSelected
        if self.isShow{
            self.isShow = false
            self.showControlView()
        }
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewLock(self.lockBtn.isSelected)
        }
    }
    //重播
    @objc func repeatBtnAction() {
        self.isOperationing = true
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewRepeat()
        }
    }
    //左下角的播放按钮事件
    @objc func playBtnAction() {
        self.isOperationing = true
        self.startBtn.isSelected = !self.startBtn.isSelected
        if self.startBtn.isSelected{
            if self.delegate != nil{
                self.delegate?.ly_playerControllerViewPlay()
            }
        }else{
            if self.delegate != nil{
                self.delegate?.ly_playerControllerViewPause()
            }
        }
    }
    //右下角的全屏按钮事件
    @objc func fullScreenBtnAction() {
        self.isOperationing = true
        self.fullScreenBtn.isSelected = !self.fullScreenBtn.isSelected
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewFullScreen(self.fullScreen)
        }
    }
    //左上角返回
    @objc func backBtnAction() {
        self.isOperationing = true
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewBack()
        }
    }
    //右上角关闭
    @objc func closeBtnAction() {
        self.isOperationing = true
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewClose()
        }
    }
    //右上角切换清晰度
    @objc func resolutionBtnAction() {
        self.isOperationing = true
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewResolution()
        }
    }
    //右上角下载
    @objc func downloadBtnAction() {
        self.isOperationing = true
        if self.delegate != nil{
            self.delegate?.ly_playerControllerViewDownload()
        }
    }
    
}




//MARK: - 外部调用方法
extension LYPlayerControllerView{
    //设置隐藏
    func hideControlView() {

        if !self.isShow || self.isOperationing{
            return//已隐藏
        }
        self.isShow = !self.isShow
        UIView.animate(withDuration: 0.5) {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
            self.lockBtn.alpha = 0
        }
        
    }
    
    //显示按钮
    func showControlView() {
        if self.isShow{
            return//已展示
        }
        self.isShow = !self.isShow
        self.lockBtn.alpha = 1
        if self.lockBtn.isSelected{
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }else{
            self.topView.alpha = 1
            self.bottomView.alpha = 1
        }
        //3秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.hideControlView()
        }
    }
    
    
}



