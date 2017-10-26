//
//  VideoCollectionViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/23.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit
import SwiftyJSON

private let reuseIdentifier = "VideoCollectionCell"

class VideoCollectionViewController: UICollectionViewController {
    var dataArray = Array<JSON>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionView!.register(UINib.init(nibName: "VideoCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.setUpCollectionView()
        self.requestData()
    }
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let w = KScreenWidth / 2.0 - 3
        layout.itemSize = CGSize.init(width: w, height: w / 1.8 + 21)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        self.collectionView?.contentInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)
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
        let json = JSON(data:data!)
        self.dataArray = json["videoList"].arrayValue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionCell
        cell.jsonModel = self.dataArray[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionCell
        let playerModel = LYPlayerModel()
        playerModel.videoURL = cell.jsonModel["playUrl"].stringValue
        LYPlayerView.shared.playerControlView(cell.subView, playerModel)
    }
    
    
}
