//
//  VideoTableViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import SwiftyJSON

class VideoTableViewController: UITableViewController {

    var dataArray = Array<JSON>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib.init(nibName: "VideoTableCell", bundle: Bundle.main), forCellReuseIdentifier: "VideoTableCell")
        
        self.requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func requestData() {

        guard let path = Bundle.main.path(forResource: "videoData", ofType: "json") else{
            return
        }
        let url = URL.init(fileURLWithPath: path)
        
        let data = try? Data.init(contentsOf: url)
        if data == nil{
            return
        }
        //        do {
        ////            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        //            print(json["videoList"].arrayValue.count)
        //        }catch{
        //            return
        //        }
        let json = JSON(data:data!)
        self.dataArray = json["videoList"].arrayValue
    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        get{
//            return .portrait
//        }
//    }
    // 视图是否自动旋转
    override var shouldAutorotate : Bool {
        get{
            return false
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableCell", for: indexPath) as! VideoTableCell
        cell.jsonModel = self.dataArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124 + KScreenWidth/1.8
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! VideoTableCell
        let playerModel = LYPlayerModel()
        playerModel.videoURL = cell.jsonModel["playUrl"].stringValue
        LYPlayerView.shared.playerControlView(cell.subView, playerModel)
        
    }

}
