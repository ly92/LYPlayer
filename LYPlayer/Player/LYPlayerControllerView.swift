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

class LYPlayerControllerView: UIView {
    /** 标题 */
    var titleLabel = UILabel()
    /** 开始播放按钮 */
    var startBtn = UIButton()
    /** 当前播放时长label */
    var currentTimeLabel = UILabel()
    /** 视频总时长label */
    var totalTimeLabel = UILabel()
    /** 缓冲进度条 */
    var progressView = UIProgressView()
    /** 滑杆 */
    var videoSlider = LYValueTrackingSlider()
    /** 全屏按钮 */
    var fullScreenBtn = UIButton()
    /** 锁定屏幕方向按钮 */
    var lockBtn = UIButton()
    /** 系统菊花 */

    /** 返回按钮*/
    var backBtn = UIButton()
    /** 关闭按钮*/
    var closeBtn = UIButton()
    /** 重播按钮 */
    var repeatBtn = UIButton()
    /** bottomView*/
    var bottomImageView = UIImageView()
    /** topView */
    var topImageView = UIImageView()
    /** 缓存按钮 */
    var downLoadBtn = UIButton()
    /** 切换分辨率按钮 */
    var resolutionBtn = UIButton()
    /** 分辨率的View */
    var resolutionView = UIView()
    /** 播放按钮 */
    var playeBtn = UIButton()
    /** 加载失败按钮 */
    var failBtn = UIButton()
    /** 快进快退View*/
    var fastView = UIView()
    /** 快进快退进度progress*/
    var fastProgressView = UIProgressView()
    /** 快进快退时间*/
    var fastTimeLabel = UILabel()
    /** 快进快退ImageView*/
    var fastImageView = UIImageView()
    /** 当前选中的分辨率btn按钮 */
    var resoultionCurrentBtn = UIButton()
    /** 占位图 */
    var placeholderImageView = UIImageView()
    /** 控制层消失时候在底部显示的播放进度progress */
    var bottomProgressView = UIProgressView()
    /** 分辨率的名称 */
    var resolutionArray = Array<Any>()
    
    /** 显示控制层 */
    var showing = false
    /** 小屏播放 */
    var shrink = false
    /** 在cell上播放 */
    var cellVideo = false
    /** 是否拖拽slider控制播放进度 */
    var dragged = false
    /** 是否播放结束 */
    var playeEnd = false
    /** 是否全屏播放 */
    var fullScreen = false
    
    
    
    init() {
        super.init(frame:CGRect.zero)
        
        self.addSubview(self.placeholderImageView)
        
        self.topImageView.addSubview(self.backBtn)
        self.topImageView.addSubview(self.titleLabel)
        self.topImageView.addSubview(self.resolutionBtn)
        self.topImageView.addSubview(self.downLoadBtn)
        self.addSubview(self.topImageView)
        
        self.bottomImageView.addSubview(self.startBtn)
        self.bottomImageView.addSubview(self.currentTimeLabel)
        self.bottomImageView.addSubview(self.progressView)
        self.bottomImageView.addSubview(self.videoSlider)
        self.bottomImageView.addSubview(self.totalTimeLabel)
        self.bottomImageView.addSubview(self.fullScreenBtn)
        self.addSubview(self.bottomImageView)
        
        self.addSubview(self.lockBtn)
//        self.addSubview(self.)
        self.addSubview(self.repeatBtn)
        self.addSubview(self.playeBtn)
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
        // 初始化时重置controlView
        self.playerResetControlView()
        
        // app退到后台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        // app进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.appDidEnterPlayground), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        //监听设备旋转通知
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(LYPlayerControllerView.onDeviceOrientationChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
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
        
        self.topImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(self.snp.top).offset(0)
            make.height.equalTo(50)
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
        
        self.bottomImageView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(0)
            make.height.equalTo(50)
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
        
        self.videoSlider.snp.makeConstraints { (make) in
            make.leading.equalTo(self.currentTimeLabel.snp.trailing).offset(4)
            make.trailing.equalTo(self.totalTimeLabel.snp.leading).offset(-4)
            make.centerY.equalTo(self.currentTimeLabel.snp.centerY).offset(-1)
            make.height.equalTo(30)
        }
        
        self.lockBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading).offset(15)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(32)
        }
        
        self.repeatBtn.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
        
        self.playeBtn.snp.makeConstraints { (make) in
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



