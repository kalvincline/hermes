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
    let refreshControl = UIRefreshControl()
    var mainView: UICollectionView {
        return contentView as! UICollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        contentView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        mainView.dataSource = self
        mainView.delegate = self
        mainView.register(LargeVideoCell.self, forCellWithReuseIdentifier: "LargeVideoCell")
        mainView.backgroundColor = .clear
        mainView.contentInset.top = 96
        mainView.contentInset.bottom = 50
        mainView.refreshControl = refreshControl
        mainView.alwaysBounceVertical = true
        refreshControl.addTarget(self, action: #selector(self.loadData), for: .primaryActionTriggered)
        title = "Home"
        
        loadData()
    }
    
    @objc func loadData() {
        let videoRequest = InvidiousTrending()
        videoRequest.getData {
            self.trendingVideos = videoRequest.videos ?? []
            self.mainView.reloadData()
            self.refreshControl.endRefreshing()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let videosPerRow = limit(Int(view.frame.width / 400), min: 1)
        let width = CGFloat(Int(view.frame.width / CGFloat(videosPerRow)))
        
        let testTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width - 32, height: 20))
        testTitleLabel.numberOfLines = 2
        testTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        testTitleLabel.text = self.trendingVideos[indexPath.section + indexPath.row].title
        testTitleLabel.sizeToFit()
        testTitleLabel.frame.size.height = (testTitleLabel.frame.height <= 20) ? 20 : 40
        
        return CGSize(width: width, height: (width * 9/16) + testTitleLabel.frame.height + 40)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainView.reloadData()
    }
    
}
