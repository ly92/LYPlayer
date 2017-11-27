//
//  LYCommonHelper.swift
//  LYPlayer
//
//  Created by ly on 2017/11/21.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class LYCommonHelper: NSObject {
    // 下载文件的总文件夹
    static let BASE = "/LYDownLoad"
    // 完整文件路径
    static let TARGET = "/CacheList"
    // 临时文件夹名称
    static let TEMP = "/Temp"
    // 缓存主目录
    static let CACHES_DIRECTORY = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    // 临时文件夹的路径
    class var TEMP_FOLDER : String {
        get{
            return CACHES_DIRECTORY + BASE + TEMP
        }
    }
    // 临时文件的路径
    class func TEMP_PATH(_ name : String) -> String {
        return self.createFolder(TEMP_FOLDER) + name
    }
    
    // 下载文件夹路径
    class var FILE_FOLDER : String{
        get{
            return CACHES_DIRECTORY + BASE + TARGET
        }
    }
    // 下载文件的路径
    class func FILE_PATH(_ name : String) -> String {
        return self.createFolder(FILE_FOLDER) + name
    }
    
    // 文件信息的Plist路径
    class var PLIST_PATH : String {
        return CACHES_DIRECTORY + BASE + "/FinishedPlist.plist"
    }

    //创建文件夹
    class func createFolder(_ filePath : String) -> String {
        let fm = FileManager.default
        if !fm.fileExists(atPath: filePath){
            do{
                try fm.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                print(error)
            }
        }
        return filePath + "/"
    }
    
    /** 将文件大小转化成M单位或者B单位 */
    class func getFileSizeString(_ size : String) -> String {
        if size.floatValue >= 1024 * 1024{
            //大于1M，则转化成M单位的字符串
            return String.init(format: "%.2fM", size.floatValue/1024.0/1024.0)
        }else if size.floatValue >= 1024{
            //不到1M,但是超过了1KB，则转化成KB单位
            return String.init(format: "%.2fK", size.floatValue/1024.0)
        }else{
            //剩下的都是小于1K的，则转化成B单位
            return String.init(format: "%.2fB", size.floatValue)
        }
    }
    
//    /** 经文件大小转化成不带单位的数字 */
//    func getFileSizeNumber(size : String) -> Float {
//
//    }
    
    /** 字符串格式化成日期 */
    class func makeDate(_ birthday : String) -> Date{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = df.date(from: birthday)else{
            return Date()
        }
        return date
    }

    /** 日期格式化成字符串 */
    class func dateToString(_ date : Date) -> String{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = df.string(from: date)
        return dateStr
    }

    /** 检查文件名是否存在 */
    class func isExistFile(_ fileName : String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: fileName)
    }

    class func calculateFileSizeInUnit(contentLength : CLongLong) -> Float{
        if Double(contentLength) >= pow(1024, 3){
            return Float(contentLength) / pow(1024, 3)
        }else if Double(contentLength) >= pow(1024, 2){
            return Float(contentLength) / pow(1024, 2)
        }else if Double(contentLength) >= 1024{
            return Float(contentLength) / 1024
        }else {
            return Float(contentLength)
        }
    }
    
    class func calculateUnit(contentLength : CLongLong) -> String{
        if Double(contentLength) >= pow(1024, 3){
            return "GB"
        }else if Double(contentLength) >= pow(1024, 2){
            return "MB"
        }else if Double(contentLength) >= 1024{
            return "KB"
        }else {
            return "B"
        }
    }
    
}




//MARK: - 数值
extension String{
    
    var trim : String{
        var str = self
        if str.isEmpty{
            return ""
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        return str
    }
    
    var floatValue : Float {
        var str = self.trim
        if str.isEmpty{
            return 0
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("-"){
            str.remove(at: str.startIndex)
            let pattern = "^[0-9]\\d*?\\.?[0-9]*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return -Float(str)!
            }
        }else{
            let pattern = "^[0-9]\\d*?\\.?[0-9]*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return Float(str)!
            }
        }
        return 0
    }
    
    var intValue : Int {
        var str = self.trim
        if str.isEmpty{
            return 0
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.contains("."){
            let array = str.components(separatedBy: ".")
            str = array[0]
        }
        if str.hasPrefix("-"){
            str.remove(at: str.startIndex)
            let pattern = "^[0-9]\\d*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return -Int(str)!
            }
        }else{
            let pattern = "^[0-9]\\d*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return Int(str)!
            }
        }
        return 0
    }
    
    var doubleValue : Double {
        var str = self.trim
        if str.isEmpty{
            return 0
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("-"){
            str.remove(at: str.startIndex)
            let pattern = "^[0-9]\\d*?\\.?[0-9]*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return -Double(str)!
            }
        }else{
            let pattern = "^[0-9]\\d*?\\.?[0-9]*?"
            let regrxtest = NSPredicate(format:"SELF MATCHES %@",pattern)
            if regrxtest.evaluate(with: str){
                return Double(str)!
            }
        }
        return 0
    }
    
    
}

