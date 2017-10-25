//
//  LYPlayerModel.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class LYPlayerModel: NSObject {
    
    /** 视频标题 */
    var title = ""
    /** 视频URL */
    var videoURL = ""
    /** 视频封面本地图片 */
    var placeholderImage = UIImage(named: "LYPlayer.bundle/ZFPlayer_loading_bgView")
    /** 播放器View的父视图（非cell播放使用这个）*/
    var fatherView = UIView()
    
    /**
     * 视频封面网络图片url
     * 如果和本地图片同时设置，则忽略本地图片，显示网络图片
     */
    var placeholderImageURLString = ""
    /**
     * 视频分辨率字典, 分辨率标题与该分辨率对应的视频URL.
     * 例如: @{@"高清" : @"https://xx/xx-hd.mp4", @"标清" : @"https://xx/xx-sd.mp4"}
     */
    var resolutionDic = Dictionary<String,String>()
    /** 从xx秒开始播放视频(默认0) */
    var seekTime : NSInteger = 0
    // cell播放视频，以下属性必须设置值
    let scrollView : UIScrollView? = nil
    /** cell所在的indexPath */
    var indexPath : NSIndexPath?
    /**
     * cell上播放必须指定
     * 播放器View的父视图tag（根据tag值在cell里查找playerView加到哪里)
     */
    var fatherViewTag : NSInteger?
    
}
