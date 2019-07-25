//
//  SearchController.swift
//  hermes
//
//  Created by Aidan Cline on 2/1/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import PopMenu

class Search: NavigationController {
    
    override func viewDidLoad() {
        root = SearchViewController()
        super.viewDidLoad()
    }
    
}

class SearchViewController: BaseViewController, UISearchBarDelegate {
    
    let searchBar = UISearchBar()
    let searchBarBack = UIVisualEffectView()
    let tintView = UIView()
    let loadingWheel = UIActivityIndicatorView()
    let channelView = HorizontalView()
    var categoryButton = UIButton()
    var downArrow = UIImageView()
    
    let errorView = UILabel()
    
    var category = InvidiousSearch.ResultType.all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        showBackButton = false
        
        categoryButton = UIButton(frame: CGRect(x: 28, y: 0, width: scrollView.frame.width - 32, height: 24))
        categoryButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold) // if you change the font size, god save your soul
        categoryButton.setTitleColor(interface.textColor, for: .normal)
        categoryButton.imageView?.contentMode = .scaleAspectFit
        categoryButton.contentHorizontalAlignment = .left
        downArrow = UIImageView(image: UIImage(named: "arrow-down"))
        downArrow.contentMode = .scaleAspectFit
        downArrow.tintColor = interface.textColor
        downArrow.frame = CGRect(x: categoryButton.titleLabel!.frame.width + 8, y: 4, width: 16, height: 16)
        categoryButton.addSubview(downArrow)
        categoryButton.frame.size.width = downArrow.frame.maxX
        categoryButton.addTarget(self, action: #selector(changeCategory(_:)), for: .touchUpInside)
        
        tintView.frame = scrollView.frame
        tintView.backgroundColor = .clear
        tintView.isUserInteractionEnabled = false
        view.insertSubview(tintView, at: 0)
        view.sendSubviewToBack(scrollView)
        
        loadingWheel.startAnimating()
        loadingWheel.frame = CGRect(x: (scrollView.frame.width - 39)/2, y: 32, width: 39, height: 39)
        
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = interface.textColor
        searchBarBack.frame = CGRect(x: 0, y: header.frame.height, width: scrollView.frame.width, height: 50)
        searchBar.frame = CGRect(x: 8, y: 0, width: searchBarBack.frame.width - 16, height: 44)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "YouTube"
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBarBack.contentView.addSubview(searchBar)
        view.addSubview(searchBarBack)
        scrollView.contentInset.top += searchBarBack.frame.height
        scrollView.scrollIndicatorInsets.top += searchBarBack.frame.height

        NotificationCenter.default.addObserver(forName: .changeDrawer, object: nil, queue: .main) { (notification) in
            self.searchBar.endEditing(true)
        }
    }
    
    var isLoading = false
    var isFinishedLoadingVideos = false
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        let offset = scrollView.contentOffset.y + scrollView.contentInset.top
        searchBarBack.frame.origin.y = limit(header.frame.height, min: safeArea.top + 50)
        searchBarBack.contentView.backgroundColor = header.contentView.backgroundColor
        searchBar.endEditing(true)
        
        var shouldLoadVideos = false
        if !isLoading && hasResults {
            let loadingDistance: CGFloat = 200
            print("offset: \(offset)")
            print("difference: \(scrollView.contentSize.height - loadingDistance - loadingWheel.frame.height - scrollView.contentInset.top)")
            if offset >= scrollView.contentSize.height - loadingDistance - loadingWheel.frame.height - scrollView.contentInset.top {
                shouldLoadVideos = true
            } else {
                shouldLoadVideos = false
            }
            if shouldLoadVideos && isFinishedLoadingVideos {
                addVideos()
                shouldLoadVideos = false
                print("should add videos")
            }
        }
    }
    
    override func setThemes() {
        super.setThemes()
        categoryButton.setTitleColor(interface.textColor, for: .normal)
        downArrow.tintColor = interface.textColor
        searchBarBack.effect = interface.blurEffect
        searchBarBack.contentView.backgroundColor = interface.blurEffectBackground
        searchBar.barStyle = .default
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = interface.textColor
        searchBar.keyboardAppearance = (interface.style == .light) ? .light : .dark
        loadingWheel.style = interface.loadingIndicatorStyle
        errorView.textColor = interface.textColor
    }
    
    @objc func changeCategory(_ button: UIButton) {
        let chooser = PopMenuViewController(sourceView: downArrow, actions: [
            PopMenuDefaultAction(title: "All results", image: nil, color: nil, didSelect: { (action) in
                self.category = .all
                self.searchBarSearchButtonClicked(self.searchBar)
            }),
            PopMenuDefaultAction(title: "Videos", image: nil, color: nil, didSelect: { (action) in
                self.category = .videos
                self.searchBarSearchButtonClicked(self.searchBar)
            }),
            PopMenuDefaultAction(title: "Channels", image: nil, color: nil, didSelect: { (action) in
                self.category = .channels
                self.searchBarSearchButtonClicked(self.searchBar)
            }),
            PopMenuDefaultAction(title: "Playlists", image: nil, color: nil, didSelect: { (action) in
                self.category = .playlists
                self.searchBarSearchButtonClicked(self.searchBar)
            })
            ]
        )
        
        chooser.appearance.popMenuColor.backgroundColor = .solid(fill: interface.contentColor)
        chooser.appearance.popMenuColor.actionColor = .tint(interface.textColor)
        chooser.appearance.popMenuStatusBarStyle = nil
        UIHapticFeedback.generate(style: .impact)
        
        present(chooser, animated: true)
    }
    
    func addVideos() {
        isLoading = true
        isFinishedLoadingVideos = false
        search.page += 1
        search.getData {
            self.isLoading = false
            if let results = self.search.results {
                if results.count > 0 {
                    for result in results {
                        self.scrollView.addGap(height: 8)
                        if let result = (result as? InvidiousVideo) {
                            let view = SmallVideoView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0))
                            view.video = result
                            view.isIndividual = false
                            self.scrollView.addSubview(view)
                        } else if let result = (result as? InvidiousChannel) {
                            let view = ChannelView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0), channel: result)
                            view.isIndividual = (self.category != .channels)
                            self.scrollView.addSubview(view)
                        } else if let id = (result as? InvidiousPlaylist)?.identifier {
                            let view = SmallVideoView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0))
                            view.video = InvidiousVideo(identifier: id)
                            view.isIndividual = false
                            self.scrollView.addSubview(view)
                        }
                    }
                    
                    self.isFinishedLoadingVideos = true
                    if results.count == 20 {
                        self.scrollView.removeSubview(self.loadingWheel)
                        self.loadingWheel.frame.origin.y = 0
                        self.scrollView.addSubview(self.loadingWheel)
                    }
                } else {
                    self.scrollView.removeSubview(self.loadingWheel)
                    self.loadingWheel.frame.origin.y = 0
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" || searchBar.text == nil {
            hasResults = false
            scrollView.removeAllSubviews()
            scrollView.addSubview(headerDivider)
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" || searchBar.text == nil {
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        category = .all
        UIView.animate(withDuration: 0.25) {
            self.tintView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        UIView.animate(withDuration: 0.25) {
            self.tintView.backgroundColor = .clear
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        hasResults = false
        scrollView.removeAllSubviews()
        scrollView.addSubview(headerDivider)
    }
    
    var search = InvidiousSearch(query: nil)
    var hasResults = false
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let string = searchBar.text {
            if string != "" && string != settings.searchHistory.last ?? "" {
                settings.searchHistory.append(string)
                print(settings.searchHistory)
            }
        }
        
        scrollView.removeAllSubviews()
        scrollView.addSubview(headerDivider)
        searchBar.endEditing(true)
        loadingWheel.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 100)
        scrollView.addSubview(loadingWheel)
        
        search = InvidiousSearch(query: searchBar.text)
        search.sort = .relevance
        search.resultType = category
        search.getData {
            if let results = self.search.results {
                if self.loadingWheel.superview != nil {
                    self.scrollView.removeSubview(self.loadingWheel)
                }
                
                self.scrollView.addGap(height: 16)
                self.categoryButton.frame.origin.y = 0
                self.scrollView.addSubview(self.categoryButton)
                
                switch self.category {
                case .all:
                    self.categoryButton.setTitle("All results", for: .normal)
                case .videos:
                    self.categoryButton.setTitle("Videos", for: .normal)
                case .channels:
                    self.categoryButton.setTitle("Channels", for: .normal)
                case .playlists:
                    self.categoryButton.setTitle("Playlists", for: .normal)
                }
                
                self.categoryButton.titleLabel?.sizeToFit()
                self.downArrow.frame.origin.x = self.categoryButton.titleLabel!.frame.width + 8
                self.categoryButton.frame.size.width = self.downArrow.frame.maxX
                self.isFinishedLoadingVideos = results.count < 20
                
                if results.count > 0 {
                    self.hasResults = true
                    self.scrollView.addGap(height: 8)
                    for result in results {
                        self.scrollView.addGap(height: 8)
                        if let result = (result as? InvidiousVideo) {
                            let view = SmallVideoView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0))
                            view.video = result
                            view.isIndividual = false
                            self.scrollView.addSubview(view)
                        } else if let result = (result as? InvidiousChannel) {
                            let view = ChannelView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0), channel: result)
                            view.isIndividual = (self.category != .channels)
                            self.scrollView.addSubview(view)
                        } else if let result = (result as? InvidiousPlaylist) {
                            let view = SmallVideoView(frame: CGRect(x: 0, y: 8, width: self.scrollView.frame.width, height: 0))
                            view.video = InvidiousVideo(identifier: result.identifier)
                            view.isIndividual = false
                            self.scrollView.addSubview(view)
                        }
                    }
                } else {
                    var item = "thing"
                    switch self.category {
                    case .all:
                        item = "thing"
                    case .videos:
                        item = " videos"
                    case .channels:
                        item = " channels"
                    case .playlists:
                        item = " playlists"
                    }
                    self.errorView.frame = CGRect(x: 32, y: 0, width: self.scrollView.frame.width - 64, height: 75)
                    self.errorView.text = "Couldn't find any\(item) called \"\(self.search.query!)\"."
                    self.errorView.font = .systemFont(ofSize: 16, weight: .medium)
                    self.errorView.textAlignment = .center
                    self.errorView.numberOfLines = 2
                    self.errorView.alpha = 0.75
                    self.scrollView.addSubview(self.errorView)
                }
            } else {
                self.errorView.frame = CGRect(x: 32, y: 0, width: self.scrollView.frame.width - 64, height: 75)
                self.errorView.text = "Oof, there was a problem getting search results."
                self.errorView.font = .systemFont(ofSize: 16, weight: .medium)
                self.errorView.textAlignment = .center
                self.errorView.numberOfLines = 2
                self.errorView.alpha = 0.75
                self.scrollView.addSubview(self.errorView)
            }
        }
    }
    
}

class UIGradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var colors: [Any]? {
        get {
            return (self.layer as! CAGradientLayer).colors
        }
        set {
            (self.layer as! CAGradientLayer).colors = newValue
        }
    }
    
    var locations: [NSNumber]? {
        get {
            return (self.layer as! CAGradientLayer).locations
        }
        set {
            (self.layer as! CAGradientLayer).locations = newValue
        }
    }
}
