//
//  ContentViews.swift
//  hermes
//
//  Created by Aidan Cline on 8/22/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import Kingfisher

var avatarURLs: [String: String] = [:]
func getAvatar(for channel: InvidiousChannel, _ completion: @escaping (String) -> Void) {
    if let identifier = channel.identifier {
        if let url = avatarURLs[identifier] {
            completion(url)
        } else {
            let data = InvidiousChannel(identifier: identifier)
            data.getData(fields: [.thumbnails]) {
                if let url = data.thumbnails?.medium {
                    avatarURLs[identifier] = url
                    completion(url)
                }
            }
        }
    }
}

class LargeVideoCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    let mainView = UIView()
    let contents = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    let thumbnailView = UIImageView()
    let backdropThumbnailView = UIImageView()
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
        backdropThumbnailView.contentMode = .scaleAspectFill
        backdropThumbnailView.clipsToBounds = true
        channelThumbnailView.layer.cornerRadius = 16
        channelThumbnailView.clipsToBounds = true
        channelThumbnailView.contentMode = .scaleAspectFill
        channelThumbnailView.image = UIImage(systemName: "person.crop.circle")
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        mainView.addInteraction(UIContextMenuInteraction(delegate: self))
        
        addSubview(mainView)
        mainView.addSubview(backdropThumbnailView)
        mainView.addSubview(contents)
        contents.contentView.addSubview(thumbnailView)
        contents.contentView.addSubview(titleLabel)
        contents.contentView.addSubview(channelLabel)
        contents.contentView.addSubview(channelThumbnailView)
        contents.contentView.addSubview(infoLabel)
        
        let gesture = UITapGestureRecognizer()
        mainView.addGestureRecognizer(gesture)
        gesture.addTargetClosure { (gestureRecognizer) in
            openVideo(self.video)
        }
        
        setTheme()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
        contents.frame = mainView.bounds
        thumbnailView.frame = CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.width * 9/16)
        backdropThumbnailView.frame = CGRect(x: 16, y: 16, width: thumbnailView.frame.width - 32, height: (thumbnailView.frame.width - 32) * 9/16)
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
        
        if let views = video?.views, let datePublished = video?.published {
            setInfoLabel(views: views, datePublished: datePublished)
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.views, .published]) {
                if let views = self.video?.views, let datePublished = self.video?.published {
                    self.setInfoLabel(views: views, datePublished: datePublished)
                }
            }
        }
        
        if let url = video?.thumbnails?.high {
            self.thumbnailView.kf.setImage(with: URL(string: url)!, options: [.transition(.fade(0.5))], completionHandler: { result in
                self.backdropThumbnailView.image = self.thumbnailView.image
            })
        } else {
            let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.thumbnails]) {
                self.video?.thumbnails = data.thumbnails
                if let url = data.thumbnails?.high {
                    if self.video?.identifier == data.identifier {
                        self.thumbnailView.kf.setImage(with: URL(string: url)!, options: [.transition(.fade(0.5))], completionHandler: { result in
                            self.backdropThumbnailView.image = self.thumbnailView.image
                        })
                    }
                }
            }
        }
        
        if let url = video?.channelThumbnails?.medium {
            self.channelThumbnailView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(systemName: "person.crop.circle"), options: [.transition(.fade(0.5))])
        } else {
            let channel = InvidiousChannel(identifier: video?.channelID)
            getAvatar(for: channel) { (url) in
                self.channelThumbnailView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(systemName: "person.crop.circle"), options: [.transition(.fade(0.5))])
            }
            
            /*let data = InvidiousVideo(identifier: video?.identifier)
            data.getData(fields: [.channelThumbnails]) {
                self.video?.channelThumbnails = data.channelThumbnails
                if let url = data.channelThumbnails?.high {
                    if self.video?.identifier == data.identifier {
                        //self.channelThumbnailView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(systemName: "person.crop.circle"), options: [.transition(.fade(0.5))])
                        avatar(for: url) { (image) in
                            UIView.transition(with: self.channelThumbnailView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.channelThumbnailView.image = image
                            }, completion: nil)
                        }
                    }
                }
            }*/
        }
    }
    
    func setInfoLabel(views: Int, datePublished: Date) {
        let viewsString = NSNumber(integerLiteral: views).formatUsingAbbrevation()
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.second, .minute, .hour, .day, .month, .year]
        timeFormatter.unitsStyle = .abbreviated
        timeFormatter.maximumUnitCount = 1
        let publishedString = timeFormatter.string(from: datePublished, to: Date())!
        self.infoLabel.text = "\(viewsString) VIEW\(views != 1 ? "S" : "")  •  \(publishedString) AGO".uppercased()
    }
    
    func setTheme() {
        mainView.backgroundColor = .clear
        titleLabel.textColor = .label
        channelLabel.textColor = .label
        infoLabel.textColor = .secondaryLabel
        thumbnailView.backgroundColor = .none
        channelThumbnailView.tintColor = .systemGray
        channelThumbnailView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (suggestedInteractions) -> UIMenu? in
            let actions = [
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { (action) in
                    let shareSheet = UIActivityViewController(activityItems: [URL(string: "https://www.youtube.com/watch?v=\(self.video?.identifier ?? "")")!], applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        self.viewController?.present(shareSheet, animated: true)
                    } else {
                        if let popover = shareSheet.popoverPresentationController {
                            popover.sourceView = self.mainView
                        }
                        
                        shareSheet.modalPresentationStyle = .pageSheet
                        self.viewController?.present(shareSheet, animated: true)
                    }
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
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            openVideo(self.video)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
        channelThumbnailView.image = nil
        backdropThumbnailView.image = nil
    }
    
}
