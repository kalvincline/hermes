//
//  SmallVideoCell.swift
//  hermes
//
//  Created by Aidan Cline on 9/18/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import Kingfisher

class SmallVideoCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    let mainView = UIView()
    
    var video: InvidiousVideo? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        
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
    
}
