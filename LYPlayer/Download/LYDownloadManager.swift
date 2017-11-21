//
//  LYDownloadManager.swift
//  LYPlayer
//
//  Created by ly on 2017/11/21.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

protocol LYDownloadDelegate {
    func startDownload(request : LYHttpRequest)
    func updateCellProgress(request : LYHttpRequest)
    func finishDownload(request : LYHttpRequest)
    func allNextRequest()//处理一个窗口内连续下载多个文件且重复下载的情况
}

let kMaxRequestCount = "kMaxRequestCount"


class LYDownloadManager: NSObject {
    /** 获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用 */
    var VCdelegate : LYDownloadDelegate?
    /** 下载列表delegate */
    var downloadDelegate : LYDownloadDelegate?
    /** 设置最大的并发下载个数 */
    var maxCount : NSInteger = 3{
        didSet{
            
        }
    }
    /** 本地临时文件夹文件的个数 */
    var count : NSInteger = 0
    /** 已下载完成的文件列表（文件对象） */
    var finishedList : Array<LYFileModel> = Array<LYFileModel>()
    /** 正在下载的文件列表(ASIHttpRequest对象) */
    var requestList : Array<LYHttpRequest> = Array<LYHttpRequest>()
    /** 未下载完成的临时文件数组（文件对象) */
    var downloadingList : Array<LYFileModel> = Array<LYFileModel>()
    /** 下载文件的模型 */
    var fileInfo : LYFileModel!
    
    
    /** 单例 */
    let shareMgr = LYDownloadManager()
    func share() -> LYDownloadManager {
        return shareMgr
    }
    
    override init() {
        super.init()
        let userDefaults = UserDefaults.standard
        var max = userDefaults.value(forKey: kMaxRequestCount)
        if max == nil{
            userDefaults.set("3", forKey: kMaxRequestCount)
            max = "3"
        }
        userDefaults.synchronize()
        self.maxCount = (max as! String).intValue
        
        
    }
    
    
    
    
    
}

extension LYDownloadManager{
    
    /**
     *
     */
    func cleanLastInfo() {
        for request in self.requestList {
            if request.isExecuting(){
                request.cancel()
            }
        }
    }
    
    /**
     * 清除所有正在下载的请求
     */
    func clearAllRquests(){
        
    }
    /**
     * 清除所有下载完的文件
     */
    func clearAllFinished(){
        
    }
    /**
     * 恢复下载
     */
    func resumeRequest(request : LYHttpRequest){
        
    }
    /**
     * 删除这个下载请求
     */
    func deleteRequest(request : LYHttpRequest) {
        
    }
    /**
     * 停止这个下载请求
     */
    func stopRequest(request : LYHttpRequest) {
        
    }
    /**
     * 保存下载完成的文件信息到plist
     */
    func saveFinishedFile() {
        
    }
    /**
     * 删除某一个下载完成的文件
     */
    func deleteFinishFile(file : LYFileModel) {
        
    }
    /**
     * 下载视频时候调用
     */
    func downloadFileUrl(url : String, fileName name : String, fileImage image : UIImage) {
        
    }
    
    /**
     * 开始任务
     */
    func startLoad(){
        
    }
    /**
     * 全部开始（等于最大下载个数，超过的还是等待下载状态）
     */
    func startAllDownloads(){
        
    }
    /**
     * 全部暂停
     */
    func pauseAllDownloads(){
        
    }
}
