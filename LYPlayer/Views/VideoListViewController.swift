//
//  VideoListViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class VideoListViewController: UITableViewController {

//    fileprivate let dataSource = ["http://7xqhmn.media1.z0.glb.clouddn.com/femorning-20161106.mp4",
//    "http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4",
//    "http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
//    "http://baobab.wdjcdn.com/14525705791193.mp4",
//    "http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
//    "http://baobab.wdjcdn.com/1455968234865481297704.mp4",
//    "http://baobab.wdjcdn.com/1455782903700jy.mp4",
//    "http://baobab.wdjcdn.com/14564977406580.mp4",
//    "http://baobab.wdjcdn.com/1456316686552The.mp4",
//    "http://baobab.wdjcdn.com/1456480115661mtl.mp4",
//    "http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
//    "http://baobab.wdjcdn.com/1455614108256t(2).mp4",
//    "http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
//    "http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
//    "http://baobab.wdjcdn.com/1456734464766B(13).mp4",
//    "http://baobab.wdjcdn.com/1456653443902B.mp4",
//    "http://baobab.wdjcdn.com/1456231710844S(24).mp4"]
    
    fileprivate let dataSource = ["http://musicdata.baidu.com/data2/video/566414577/356acf8f3ea388f9b212263db7b6d315/566414577.mp4",
        "http://musicdata.baidu.com/data2/video/566404453/209f8156aef486096810324fcc2e2b64/566404453.mp4",
        "http://musicdata.baidu.com/data2/video/566353844/ae89a0b5618bd77e39d1503f2ff1eec2/566353844.mp4",
        "http://musicdata.baidu.com/data2/video/566296095/0ab6259a6fe6476dc1064e4dbd76a8a6/566296095.mp4",
        "http://musicdata.baidu.com/data2/video/566295833/04ab59da9c679b1d564d004ebe56d511/566295833.mp4",
        "http://musicdata.baidu.com/data2/video/566268552/3eaba664b26021cd77f2e35aa9c08bd4/566268552.mp4",
        "http://musicdata.baidu.com/data2/video/566004777/a49845a492eb05b94bb001e10ff915fa/566004777.mp4",
        "http://musicdata.baidu.com/data2/video/566151616/0cfbcd79e621661aff5fc5c5d7cbaa8a/566151616.mp4",
        "http://musicdata.baidu.com/data2/video/566050530/82e3ce14df9831237a2adbd130a30d83/566050530.mp4",
        "http://musicdata.baidu.com/data2/video/566114598/4d6b6fdc573ff7b2604c8aab848222f9/566114598.mp4",
        "http://musicdata.baidu.com/data2/video/566052304/d81ce4b3bcb20e45ba653b9dbf4771b4/566052304.mp4",
        "http://musicdata.baidu.com/data2/video/566051516/01bde2d9036f3446f01d8c8715078a8f/566051516.mp4",
        "http://musicdata.baidu.com/data2/video/566052304/d81ce4b3bcb20e45ba653b9dbf4771b4/566052304.mp4",
        "http://musicdata.baidu.com/data2/video/565986152/fa888c7133dd62d39f3989891ae926ee/565986152.mp4",
        "http://musicdata.baidu.com/data2/video/565967842/eddcf892b35e9b2c9c0f62dd0db3a86c/565967842.mp4",
        "http://musicdata.baidu.com/data2/video/565860269/832856d58c1c51808ecfe065a2ab8d64/565860269.mp4",
        "http://musicdata.baidu.com/data2/video/565864961/e926c196eb6273e0e54d08e2aa02a5a9/565864961.mp4",
        "http://musicdata.baidu.com/data2/video/565879588/13f423b562249570501a1bf1e0e7c907/565879588.mp4",
        "http://musicdata.baidu.com/data2/video/565372149/6d70dd75d0b9634c898676c289251b03/565372149.mp4",
        "http://musicdata.baidu.com/data2/video/560520688/60c10b32f626c2c1e4feed8ab6ad0aa7/560520688.mp4",
        "http://musicdata.baidu.com/data2/video/565502630/00bc24745f3004efc66763c321c89475/565502630.mp4",
        "http://musicdata.baidu.com/data2/video/565003928/a9a1efc48d3a465d79d1683cb15b440e/565003928.mp4",
        "http://musicdata.baidu.com/data2/video/564186988/c01969bf0f1c9587f36485bcc8040440/564186988.mp4",
        "http://musicdata.baidu.com/data2/video/564384224/c32c66f01e9115e02f987587ec2b8c01/564384224.mp4",
        "http://musicdata.baidu.com/data2/video/564072004/5208efd0c72531eb064664c1532749ed/564072004.mp4",
        "http://musicdata.baidu.com/data2/video/564183182/1ec209c7e7fbe3e58a5192f1f55edda6/564183182.mp4",
        "http://musicdata.baidu.com/data2/video/564056475/4e68ea272e45d1532100934e395d439a/564056475.mp4",
        "http://musicdata.baidu.com/data2/video/564023092/9547c920c45ee6e4b71ab1d20c941ff3/564023092.mp4",
        "http://musicdata.baidu.com/data2/video/564012599/2bcaed7cfd3ec59f36aa72a5e7db2716/564012599.mp4",
        "http://musicdata.baidu.com/data2/video/562790583/3a910048c477911dc514af6d346d482e/562790583.mp4",
        "http://musicdata.baidu.com/data2/video/562365251/9a29c9a63fc36198297288c370e850c5/562365251.mp4",
        "http://musicdata.baidu.com/data2/video/562691631/127bb9d81bda064b86c58c7863cfccb6/562691631.mp4",
        "http://musicdata.baidu.com/data2/video/562658513/df24292f7cf749718dafda13bceba435/562658513.mp4",
        "http://musicdata.baidu.com/data2/video/562312402/f020e7f1d7d7614a6abb5470dbd04095/562312402.mp4",
        "http://musicdata.baidu.com/data2/video/562196864/e54a50177b7a617cf69f0f3cde7dd5de/562196864.mp4",
        "http://musicdata.baidu.com/data2/video/562198968/df4d7318cd2b77426cd407f4418ea478/562198968.mp4"]
    
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
