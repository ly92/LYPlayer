//
//  LYFileModel.swift
//  LYPlayer
//
//  Created by ly on 2017/11/21.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

enum LYDownloadState {
    case LY_Downloading//下载中
    case LY_WillDownload//等待下载
    case LY_StopDownload//停止状态
}



class LYFileModel: NSObject {
    /** 文件名 */
    var fileName = ""
    /** 文件的总长度 */
    var fileSize = ""
    /** 文件的类型(文件后缀,比如:mp4)*/
    var fileType = ""
    /** 是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加 */
    var isFirstReceived = true
    /** 文件已下载的长度 */
    var fileReceivedSize = ""
    /** 接受的数据 */
    var fileReceivedData : NSMutableData?
    /** 下载文件的URL */
    var fileUrl = ""
    /** 下载时间 */
    var time = ""
    /** 临时文件路径 */
    var tempPath = ""
    /** 下载速度 */
    var speed = ""
    /** 开始下载的时间 */
    var startTime = Date()
    /** 剩余下载时间 */
    var remainingTime = ""
    
    /*下载状态的逻辑是这样的：三种状态，下载中，等待下载，停止下载
     *当超过最大下载数时，继续添加的下载会进入等待状态，当同时下载数少于最大限制时会自动开始下载等待状态的任务。
     *可以主动切换下载状态
     *所有任务以添加时间排序。
     */
    var downloadState : LYDownloadState = .LY_WillDownload
    /** 是否下载出错 */
    var error : Error?
    /** md5 */
    var MD5 = ""
    /** 文件的附属图片 */
    var fileImage : UIImage?
}
