//
//  MoviePlayerViewController.swift
//  LYPlayer
//
//  Created by ly on 2017/10/9.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

class MoviePlayerViewController: UIViewController {

    var url = ""
    @IBOutlet weak var subView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.url)
        
        
        self.testPlay()
    }
    
    func testPlay() {
        let playerView = LYPlayerView.init(frame: self.subView.bounds, url:self.url)
        self.subView.addSubview(playerView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
