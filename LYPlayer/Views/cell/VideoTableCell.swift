//
//  VideoTableCell.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

class VideoTableCell: UITableViewCell {
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var unLikeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconImgV.layer.cornerRadius = 22.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var jsonModel : JSON = []{
        didSet{
            self.iconImgV.kf.setImage(with: URL.init(string: jsonModel["provider"]["icon"].stringValue), placeholder: #imageLiteral(resourceName: "defaultUserIcon"))
            self.nameLbl.text = jsonModel["provider"]["name"].stringValue
            self.titleLbl.text = jsonModel["title"].stringValue
            self.timeLbl.text = Date.dateStringFromDate(timeStamps: jsonModel["date"].stringValue)
        }
    }
    
}

/**
 {
 "id":5888,
 "date":1458576000000,
 "idx":1,
 "title":"风格互换：原来你我相爱",
 "description":"什么是爱情？Interflora 这支广告从某个层面给出了一个回答：爱，就是走哥特风的我为你变成普通青年，而回头发现，你却为我走了哥特风。这个结局倒令人想起欧亨利经典短篇小说「麦琪的礼物」。From @InterfloraTV",
 "category":"广告",
 "duration":60,
 "playUrl":"http://baobab.wdjcdn.com/14571455324031.mp4",
 "playInfo":[
 {
 "height":480,
 "width":854,
 "name":"标清",
 "type":"normal",
 "url":"http://baobab.wdjcdn.com/1457521866561_5888_854x480.mp4"
 },
 {
 "height":720,
 "width":1280,
 "name":"高清",
 "type":"high",
 "url":"http://baobab.wdjcdn.com/14571455324031.mp4"
 }
 ],
 "consumption":{
 "collectionCount":3523,
 "shareCount":6233,
 "playCount":0,
 "replyCount":124
 },
 "promotion":null,
 "waterMarks":null,
 "provider":{
 "name":"YouTube",
 "alias":"youtube",
 "icon":"http://img.wdjimg.com/image/video/fa20228bc5b921e837156923a58713f6_256_256.png"
 },
 "author":null,
 "adTrack":null,
 "shareAdTrack":null,
 "favoriteAdTrack":null,
 "webAdTrack":null,
 "coverForFeed":"http://img.wdjimg.com/image/video/cd47d8370569dbb9b223942674c41785_0_0.jpeg",
 "coverForDetail":"http://img.wdjimg.com/image/video/cd47d8370569dbb9b223942674c41785_0_0.jpeg",
 "coverBlurred":"http://img.wdjimg.com/image/video/2c6109cc56d98041f07ed5d6f9c79c72_0_0.jpeg",
 "coverForSharing":"http://img.wdjimg.com/image/video/cd47d8370569dbb9b223942674c41785_0_0.jpeg",
 "webUrl":"http://wandou.im/1m9aca",
 "rawWebUrl":"http://www.wandoujia.com/eyepetizer/detail.html?vid=5888"
 }
 */
