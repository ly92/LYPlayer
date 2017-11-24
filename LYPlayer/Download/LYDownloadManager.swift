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
    func allowNextRequest()//处理一个窗口内连续下载多个文件且重复下载的情况
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
    var downloadingList : Array<LYHttpRequest> = Array<LYHttpRequest>()
    /** 未下载完成的临时文件数组（文件对象) */
    var fileList : Array<LYFileModel> = Array<LYFileModel>()
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
        for request in self.downloadingList {
            //            if request.isExecuting(){
            request.cancel()
            //            }
        }
        self.saveFinishedFile()
        self.downloadingList.removeAll()
        self.finishedList.removeAll()
        self.fileList.removeAll()
    }
    
    /**
     * 清除所有正在下载的请求
     */
    func clearAllRquests(){
        for request in self.downloadingList{
            request.cancel()
            guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
                continue
            }
            let configPath = fileInfo.tempPath + ".plist"
            try! FileManager.default.removeItem(atPath: fileInfo.tempPath)
            try! FileManager.default.removeItem(atPath: configPath)
        }
        self.downloadingList.removeAll()
        self.finishedList.removeAll()
    }
    /**
     * 清除所有下载完的文件
     */
    func clearAllFinished(){
        self.finishedList.removeAll()
    }
    /**
     * 恢复下载
     */
    func resumeRequest(request : LYHttpRequest){
        guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
            return
        }
        var downingcount = 0
        var indexMax = -1
        for file in self.fileList{
            if file.downloadState == .LY_Downloading{
                downingcount += 1
                if downingcount == self.maxCount{
                    indexMax = fileList.index(of: file)!
                }
            }
        }
        // 此时下载中数目是否是最大，并获得最大时的位置Index 中止一个进程使其进入等待
        if downingcount == self.maxCount{
            let file2 = self.fileList[indexMax]
            if file2.downloadState == .LY_Downloading{
                file2.downloadState = .LY_WillDownload
            }
        }
        //开始下载恢复的这个
        for file in self.fileList{
            if file.fileName == fileInfo.fileName{
                file.downloadState = .LY_Downloading
                file.error = nil
            }
        }
        // 重新开始此下载
        self.startLoad()
    }
    /**
     * 删除这个下载请求
     */
    func deleteRequest(request : LYHttpRequest) {
        request.cancel()
        guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
            return
        }
        let configPath = fileInfo.tempPath + ".plist"
        try! FileManager.default.removeItem(atPath: fileInfo.tempPath)
        try! FileManager.default.removeItem(atPath: configPath)
        
        var delindex = -1
        for file in self.fileList{
            if file.fileName == fileInfo.fileName{
                delindex = self.fileList.index(of: file)!
                break
            }
        }
        if delindex != -1{
            self.fileList.remove(at: delindex)
        }
        let requestIndex = self.downloadingList.index(of: request)
        if requestIndex != nil{
            self.downloadingList.remove(at: requestIndex!)
        }
        self.startLoad()
        self.count = self.fileList.count
    }
    /**
     * 停止这个下载请求
     */
    func stopRequest(request : LYHttpRequest) {
        request.cancel()
        guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
            return
        }
        for file in self.fileList{
            if file.fileName == fileInfo.fileName{
                file.downloadState = .LY_StopDownload
                break
            }
        }
        var downingcount = 0
        for file in self.fileList{
            if file.downloadState == .LY_Downloading{
                downingcount += 1
            }
        }
        if downingcount < self.maxCount{
            for file in self.fileList{
                if file.downloadState == .LY_WillDownload{
                    file.downloadState = .LY_Downloading
                    break
                }
            }
        }
        self.startLoad()
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
    func downloadFileUrl(url : String, fileName name : String?, fileImage image : UIImage?) {
        self.fileInfo = LYFileModel()
        var name = name
        self.fileInfo.fileUrl = url
        if name == nil{name = (self.fileInfo.fileUrl as NSString).lastPathComponent}
        if name == nil{return}
        self.fileInfo.time = LYCommonHelper.dateToString(Date())
        self.fileInfo.fileType = (self.fileInfo.fileUrl as NSString).pathExtension
        self.fileInfo.fileImage = image
        self.fileInfo.downloadState = .LY_Downloading
        self.fileInfo.error = nil
        self.fileInfo.tempPath = LYCommonHelper.TEMP_PATH(name!)
        if LYCommonHelper.isExistFile(LYCommonHelper.FILE_PATH(name!)){
            // 已经下载过一次
            /**
             alert
             */
            return
        }
        // 存在于临时文件夹里
        let tempFilePath = LYCommonHelper.TEMP_PATH(name!) + ".plist"
        if LYCommonHelper.isExistFile(tempFilePath){
            /**
             alert
             */
            return
        }
        // 若不存在文件和临时文件，则是新的下载
        self.fileList.append(self.fileInfo)
        // 开始下载
        self.startLoad()
        if self.VCdelegate != nil{
            self.VCdelegate?.allowNextRequest()
        }else{
            /**
             alert
             */
        }
        
    }
    
    /**
     * 开始任务
     */
    func startLoad(){
        var num = 0
        for file in self.fileList {
            if num >= self.maxCount{
                file.downloadState = .LY_WillDownload
            }else{
                num += 1
            }
        }
        
        if num < self.maxCount{
            for file in self.fileList{
                if file.error == nil{
                    num += 1
                    if num > self.maxCount{
                        break
                    }
                    file.downloadState = .LY_Downloading
                }
            }
        }
        
        for file in self.fileList{
            if file.error == nil{
                if file.downloadState == .LY_Downloading{
                    self.beginRequest(fileInfo: file, isBeginDown: true)
                    file.startTime = Date()
                }else{
                    self.beginRequest(fileInfo: file, isBeginDown: false)
                }
            }
        }
        self.count = self.fileList.count
    }
    /**
     * 全部开始（等于最大下载个数，超过的还是等待下载状态）
     */
    func startAllDownloads(){
        for request in self.downloadingList{
            request.cancel()
            guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
                continue
            }
            fileInfo.downloadState = .LY_Downloading
        }
        self.startLoad()
    }
    /**
     * 全部暂停
     */
    func pauseAllDownloads(){
        for request in self.downloadingList{
            request.cancel()
            guard let fileInfo = request.userInfo["File"] as? LYFileModel else {
                continue
            }
            fileInfo.downloadState = .LY_StopDownload
        }
        self.startLoad()
    }
    
    //MARK: - 下载开始
    func beginRequest(fileInfo : LYFileModel, isBeginDown : Bool) {
        for tempRequest in self.downloadingList {
            /**
             * 注意这里判读是否是同一下载的方法，asihttprequest有三种url： url，originalurl，redirectURL
             * 经过实践，应该使用originalurl,就是最先获得到的原下载地址
             **/
            if tempRequest.url.lastPathComponent == (fileInfo.fileUrl as NSString).lastPathComponent{
                if !isBeginDown{
                    tempRequest.userInfo = ["File" : fileInfo]
                    tempRequest.cancel()
                    self.downloadDelegate?.updateCellProgress(request: tempRequest)
                    return
                }
            }
        }
        
        self.saveDownloadFile(fileInfo: fileInfo)
        // 按照获取的文件名获取临时文件的大小，即已下载的大小
        let fileManager = FileManager.default
        let fileData = fileManager.contents(atPath: fileInfo.tempPath)
        let receivedDataLength = fileData?.count ?? 0
        fileInfo.fileReceivedSize = String.init(format: "%zd", receivedDataLength)
        
        let midRequest = LYHttpRequest.init(url: URL.init(string: fileInfo.fileUrl)!)
        midRequest.downloadDestinationPath = LYCommonHelper.FILE_PATH(fileInfo.fileName)
        midRequest.temporaryFileDownloadPath = fileInfo.tempPath
        midRequest.delegate = self
        midRequest.userInfo = ["File" : fileInfo]
        if isBeginDown{midRequest.task.resume()}
        
        // 如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
        var exit = false
        for tempRequest in self.downloadingList {
            if tempRequest.url.lastPathComponent == (fileInfo.fileUrl as NSString).lastPathComponent{
                let index = self.downloadingList.index(of: tempRequest)!
                self.downloadingList.insert(midRequest, at: index)
                self.downloadingList.remove(at: index + 1)
                exit = true
                break
            }
        }
        if !exit{
            self.downloadingList.append(midRequest)
        }
        self.downloadDelegate?.updateCellProgress(request: midRequest)
        
    }
    
    //存储下载信息到一个plist文件
    func saveDownloadFile(fileInfo : LYFileModel) {
        var fileDic : Dictionary<String,Any> = Dictionary<String,Any>()
        fileDic["filename"] = fileInfo.fileName
        fileDic["fileurl"] = fileInfo.fileUrl
        fileDic["time"] = fileInfo.time
        fileDic["filesize"] = fileInfo.fileSize
        fileDic["filerecievesize"] = fileInfo.fileReceivedSize
        if fileInfo.fileImage != nil{
            let imageData = UIImagePNGRepresentation(fileInfo.fileImage!)
            if imageData != nil{
                fileDic["fileimage"] = imageData!
            }
        }
        let plistPath = fileInfo.tempPath + ".plist"
        let dict = NSDictionary.init(dictionary: fileDic)
        dict.write(toFile: plistPath, atomically: true)
        
    }
    
    //MARK: 从这里获取上次未完成下载的信息
    /*
     将本地的未下载完成的临时文件加载到正在下载列表里,但是不接着开始下载
     */
    func loadTempfiles() {
        var fileArr = Array<LYFileModel>()
        do {
            let fileList = try FileManager.default.contentsOfDirectory(atPath: LYCommonHelper.TEMP_FOLDER)
            for file in fileList{
                let fileType = (file as NSString).pathExtension
                if fileType == "plist"{
                    fileArr.append(self.getTempfile(path: LYCommonHelper.TEMP_PATH(file)))
                }
            }
            let arr = self.sortbyTime(array: fileArr)
            for file in arr {
                self.fileList.append(file)
            }
            self.startLoad()
        }catch{
            
        }
    }
    
    func getTempfile(path : String) -> LYFileModel {
        guard let dict = NSDictionary.init(contentsOfFile: path) else{
            return LYFileModel()
        }
        let file = LYFileModel()
        file.fileName = dict["filename"] as! String
        file.fileType = (file.fileName as NSString).pathExtension
        file.fileUrl = dict["fileurl"] as! String
        file.fileSize = dict["filesize"] as! String
        file.fileReceivedSize = dict["filerecievesize"] as! String
        file.tempPath = LYCommonHelper.TEMP_PATH(file.fileName)
        file.time = dict["time"] as! String
        let imageData = dict["fileimage"]
        if imageData != nil{
            file.fileImage = UIImage.init(data: imageData as! Data)
        }
        file.downloadState = .LY_StopDownload
        file.error = nil
        let fileData = FileManager.default.contents(atPath: file.tempPath)
        file.fileReceivedSize = String.init(format: "%zd", fileData?.count ?? 0)
        return file
    }
    
    func sortbyTime(array : Array<LYFileModel>) -> Array<LYFileModel> {
        let sort = array.sorted { (obj1, obj2) -> Bool in
            let date1 = LYCommonHelper.makeDate(obj1.time)
            let date2 = LYCommonHelper.makeDate(obj2.time)
            let compare = date1.compare(date2)
            if compare == .orderedDescending{
                return true
            }else{
                return false
            }
        }
        return sort
    }
}

extension LYDownloadManager : LYHttpRequestDelegate{
    func requestStarted(request: LYHttpRequest, response: URLResponse) {
        
    }
    
    func request(request: LYHttpRequest, didReceiveData data: Data) {
        
    }
    
    func requestFinished(request: LYHttpRequest) {
        
    }
    
    func requestFailed(request: LYHttpRequest) {
        
    }
    
    
    
    
}
