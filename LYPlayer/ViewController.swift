//
//  ViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

let KScreenWidth = UIScreen.main.bounds.size.width
let KScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Date{
    //时间戳转换为时间字符串
    static func dateStringFromDate(format: String? = "yyyy-MM-dd HH:mm", timeStamps: String) -> String {
        if format!.isEmpty || timeStamps.isEmpty{
            return ""
        }
        
        let whiteSpace = CharacterSet.whitespacesAndNewlines
        if format!.trimmingCharacters(in: whiteSpace).isEmpty || timeStamps.trimmingCharacters(in: whiteSpace).isEmpty{
            return ""
        }
        
        if format! == "0" || timeStamps == "0"{
            return ""
        }
        
        func splitLength(preStr : String) -> String{
            var str = preStr
            if str.characters.count > 10{
                str.characters.removeLast()
                return splitLength(preStr: str)
            }
            return str
        }
        if Double(splitLength(preStr: timeStamps)) != nil{
            let date = Date(timeIntervalSince1970: Double(splitLength(preStr: timeStamps))!)
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = format
            let dateString = dateFormat.string(from: date)
            return dateString
        }
        return timeStamps
    }
}
