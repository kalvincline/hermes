//
//  ContentViews.swift
//  hermes
//
//  Created by Aidan Cline on 8/22/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class LargeVideoCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    let mainView = UIView()
    let thumbnailView = UIImageView()
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let channelLabel = UILabel()
    let channelThumbnailView = UIImageView()
    
    var video: InvidiousVideo? {
        didSet {
            setData()
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        channelLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        infoLabel.font = .systemFont(ofSize: 11, weight: .regular)
        
        titleLabel.numberOfLines = 2
        titleLabel.frame.size.height = 20
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        channelThumbnailView.layer.cornerRadius = 16
        channelThumbnailView.clipsToBounds = true
        channelThumbnailView.contentMode = .scaleAspectFill
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        addSubview(mainView)
        mainView.addInteraction(UIContextMenuInteraction(delegate: self))
        mainView.addSubview(thumbnailView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(channelLabel)
        mainView.addSubview(channelThumbnailView)
        mainView.addSubview(infoLabel)
        setTheme(UITheme.current)
        UITheme.addHandler { (theme) in
            self.setTheme(theme)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
        thumbnailView.frame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.width * 9/16)
        titleLabel.frame = CGRect(x: 8, y: thumbnailView.frame.maxY + 8, width: mainView.frame.width - 16, height: (titleLabel.frame.height <= 20) ? 20 : 40)
        channelThumbnailView.frame = CGRect(x: 8, y: titleLabel.frame.maxY + 8, width: 32, height: 32)
        channelLabel.frame = CGRect(x: channelThumbnailView.frame.maxX + 8, y: channelThumbnailView.frame.origin.y, width: mainView.frame.width - 8 - channelThumbnailView.frame.maxX, height: 18)
        infoLabel.frame = CGRect(x: channelLabel.frame.origin.x, y: channelLabel.frame.maxY + 2, width: channelLabel.frame.width, height: 12)
        frame.size.height = infoLabel.frame.maxY + 8
    }
    
    func setData() {
        if let title = video?.title {
            titleLabel.text = title
            titleLabel.sizeToFit()
            layoutSubviews()
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.title]) {
                if let title = data.title {
                    self.titleLabel.text = title
                    self.titleLabel.sizeToFit()
                    self.layoutSubviews()
                }
            }
        }
        
        if let title = video?.channelTitle {
            channelLabel.text = title
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.channelTitle]) {
                if let title = data.channelTitle {
                    self.channelLabel.text = title
                }
            }
        }
        
        infoLabel.text = video?.identifier
        
        if let url = video?.thumbnails?.high {
            URLDataHandler.downloadImage(url: URL(string: url)!) { (image) in
                self.thumbnailView.image = image
            }
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.thumbnails]) {
                if let url = data.thumbnails?.high {
                    URLDataHandler.downloadImage(url: URL(string: url)!) { (image) in
                        self.thumbnailView.image = image
                    }
                }
            }
        }
        
        if let url = video?.channelThumbnails?.high {
            URLDataHandler.downloadImage(url: URL(string: url)!) { (image) in
                self.channelThumbnailView.image = image
            }
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.channelThumbnails]) {
                if let url = data.channelThumbnails?.high {
                    URLDataHandler.downloadImage(url: URL(string: url)!) { (image) in
                        self.channelThumbnailView.image = image
                    }
                }
            }
        }
    }
    
    func setTheme(_ theme: UITheme.Theme) {
        mainView.backgroundColor = theme.content
        titleLabel.textColor = theme.text
        channelLabel.textColor = theme.text
        infoLabel.textColor = theme.text.withAlphaComponent(0.5)
        backgroundColor = .clear
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (suggestedInteractions) -> UIMenu? in
            let actions = [
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (action) in
                    let shareSheet = UIActivityViewController(activityItems: [URL(string: "https://www.youtube.com/watch?v=\(self.video?.identifier ?? "")")!], applicationActivities: nil)
                    self.viewController?.present(shareSheet, animated: true)
                }),
                UIAction(title: "View channel", image: UIImage(systemName: "person.crop.circle"), handler: {
                    (action) in
                    
                }),
                UIMenu(title: "", options: .displayInline, children: [
                    UIMenu(title: "Report for...", image: UIImage(systemName: "flag"), options: .destructive, children: [
                        UIAction(title: "Sexual content", attributes: .destructive, handler: { (action) in
                            print("Reporting video...")
                        }),
                        UIAction(title: "Violent content", attributes: .destructive, handler: { (action) in
                            print("Reporting video...")
                        }),
                        UIAction(title: "Hateful content", attributes: .destructive, handler: { (action) in
                            print("Reporting video...")
                        }),
                        UIAction(title: "Harmful acts", attributes: .destructive, handler: { (action) in
                            print("Reporting video...")
                        }),
                        UIAction(title: "Spam", attributes: .destructive, handler: { (action) in
                            print("Reporting video...")
                        })
                    ])
                ])
            ]
            
            return UIMenu(title: "", children: actions)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            openVideo(self.video)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
        channelThumbnailView.image = nil
    }
    
}

extension UIView {
    var viewController: UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.viewController
        } else {
            return nil
        }
    }
}

/*class LargeVideoCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    let mainView = UIView()
    let thumbnailView = UIImageView()
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let channelTitle = UILabel()
    
    var video: InvidiousVideo? {
        didSet {
            setData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addSubview(mainView)
        mainView.addInteraction(interaction)
        mainView.addSubview(titleLabel)
        setTheme(UITheme.current)
        UITheme.addHandler { (theme) in
            self.setTheme(theme)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = 150 + 16
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height - 16)
        mainView.layer.cornerRadius = 20
        titleLabel.frame = CGRect(x: 8, y: mainView.frame.height - 20, width: mainView.frame.width - 16, height: 20)
    }
    
    func setData() {
        titleLabel.text = video?.title
    }
    
    func setTheme(_ theme: UITheme.Theme) {
        mainView.backgroundColor = theme.content
        backgroundColor = .clear
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (suggestedInteractions) -> UIMenu? in
            let actions = [
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (action) in
                    let shareSheet = UIActivityViewController(activityItems: [URL(string: "https://www.youtube.com/watch?v=\(self.video?.identifier ?? "")")!], applicationActivities: nil)
                    self.viewController?.present(shareSheet, animated: true)
                }),
                UIAction(title: "View channel", image: UIImage(systemName: "person.crop.circle"), handler: {
                    (action) in
                    
                }),
                UIAction(title: "Report", image: UIImage(systemName: "flag"), attributes: .destructive, handler: { (action) in
                    
                })
            ]
            
            return UIMenu(title: "", children: actions)
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            openVideo(self.video)
        }
    }
    
}*/
