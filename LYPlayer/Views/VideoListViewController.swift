//
//  VideoListViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class VideoListViewController: UITableViewController {

    fileprivate let dataSource = ["http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4",
    "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
    "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
    "http://baobab.wdjcdn.com/14525705791193.mp4",
    "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
    "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
    "http://baobab.wdjcdn.com/1455782903700jy.mp4",
    "http://baobab.wdjcdn.com/14564977406580.mp4",
    "http://baobab.wdjcdn.com/1456316686552The.mp4",
    "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
    "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
    "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
    "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
    "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
    "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
    "http://baobab.wdjcdn.com/1456653443902B.mp4",
    "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // 视图是否自动旋转
    override var shouldAutorotate : Bool {
        get{
            return false
        }
    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        get{
//            return .portrait
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VideoListViewCell")
        if cell == nil{
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "VideoListViewCell")
        }
        cell?.textLabel?.text = "网络视频\(indexPath.row)"
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if self.dataSource.count > indexPath.row{
            self.performSegue(withIdentifier: "ViewListsegue", sender: self.dataSource[indexPath.row])
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let movieVC = segue.destination as! MoviePlayerViewController
        movieVC.url = sender as! String
    }
    

}
