//
//  LYHttpRequest.swift
//  LYPlayer
//
//  Created by ly on 2017/11/21.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import Foundation

//


@objc protocol LYHttpRequestDelegate {
    
    func requestStarted(request : LYHttpRequest, response : URLResponse)
//    func request(request : LYHttpRequest, didReceiveResponseHeaders responseHeaders : NSDictionary)
    func request(request : LYHttpRequest, didReceiveData data : Data)
    func requestFinished(request : LYHttpRequest)
    func requestFailed(request : LYHttpRequest)
//    @objc optional func request(request : LYHttpRequest, willRedirectToURL newURL : URL)
}


class LYHttpRequest: NSObject {
    var delegate : LYHttpRequestDelegate?
    

    var url : URL!
    var originalURL : URL?
    var userInfo = Dictionary<String,Any>()
    var tag : NSInteger?
    var downloadDestinationPath : String = ""
    var temporaryFileDownloadPath : String = ""
    var error : Error?
    
    
    var request : URLRequest!
    var session : URLSession!
    var task : URLSessionDataTask!
    //    var stream : OutputStream!
    
    init(url:URL) {
        super.init()
        self.url = url
        
        self.request = URLRequest.init(url: self.url)
        self.session = URLSession.init(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.task = self.session.dataTask(with: self.url)
        
        
        let fileName = "/" + self.url.lastPathComponent
        let filePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last?.appending(fileName)
        print(filePath ?? "------------filePath----------")
//        self.stream = OutputStream.init(toFileAtPath: filePath!, append: true)
        self.task.resume()
        
    }
    
    func startAsynchronous() {
//       self.task.resume()
    }
    
    func isFinished() -> Bool {
        
        return false
    }
    
    func isExecuting() -> Bool {
        return false
    }
    
    func cancel() {
        self.task.cancel()
    }
}

extension LYHttpRequest : URLSessionDataDelegate{
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if self.delegate != nil{
            self.delegate?.requestStarted(request: self, response: response)
        }
        
        print(dataTask.taskIdentifier)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if self.delegate != nil{
            self.delegate?.request(request: self, didReceiveData: data)
        }
        print(String.init(format: "%d/%d=%.2f", dataTask.progress.completedUnitCount,dataTask.progress.totalUnitCount,dataTask.progress.completedUnitCount/dataTask.progress.totalUnitCount))
//        dataTask.progress.fractionCompleted
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if self.delegate != nil{
            if error != nil{
                self.delegate?.requestFailed(request: self)
            }else{
                self.delegate?.requestFinished(request: self)
            }
        }
    }
    
    
}

//extension LYHttpRequest : NSURLRequest

