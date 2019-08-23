//
//  Home.swift
//  hermes
//
//  Created by Aidan Cline on 8/21/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class HomeViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(HomeRoot(), animated: false)
        isNavigationBarHidden = true
    }
}

class HomeRoot: TemplateViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var trendingVideos: [InvidiousVideo] = []
    var mainView: UICollectionView {
        return contentView as! UICollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.width * 9/16 + 60)
        
        contentView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        mainView.dataSource = self
        mainView.delegate = self
        mainView.register(LargeVideoCell.self, forCellWithReuseIdentifier: "LargeVideoCell")
        mainView.backgroundColor = .clear
        mainView.contentInset.top = 96
        mainView.contentInset.bottom = 50
        title = "Home"
        
        let videoRequest = InvidiousTrending()
        videoRequest.getData {
            self.trendingVideos = videoRequest.videos ?? []
            self.mainView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendingVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LargeVideoCell", for: indexPath) as! LargeVideoCell
        videoCell.video = trendingVideos[indexPath.section + indexPath.row]
        return videoCell
    }
    
}

/*class HomeRoot: TemplateViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trendingVideos: [InvidiousVideo] = []
    var mainView: UITableView {
        return contentView as! UITableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView = UITableView()
        mainView.clipsToBounds = false
        mainView.backgroundColor = .clear
        mainView.delegate = self
        mainView.dataSource = self
        mainView.frame = view.bounds
        mainView.contentInset = .init(top: 96, left: 0, bottom: 50, right: 0)
        mainView.register(LargeVideoCell.self, forCellReuseIdentifier: "video")
        mainView.separatorStyle = .none
        mainView.allowsSelection = false
        mainView.rowHeight = 150 + 16
        title = "Home"
        
        let videoRequest = InvidiousTrending()
        videoRequest.getData {
            self.trendingVideos = videoRequest.videos ?? []
            self.mainView.reloadData()
            self.mainView.beginUpdates()
            self.mainView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "video", for: indexPath) as! LargeVideoCell
        cell.video = trendingVideos[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingVideos.count
    }
    
}
*/
