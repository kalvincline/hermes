//
//  ContentViews.swift
//  hermesforyoutube
//
//  Created by Aidan Cline on 7/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class LargeVideo: UITableViewCell {
    
    let mainView = UIView()
    let titleLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        mainView.layer.cornerRadius = 20
        addSubview(mainView)
        
        frame.size.height = frame.size.width * 9/16 + 100
        
        UIInterface.addThemeHandler { (theme) in
            self.mainView.backgroundColor = theme.contentColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
    }
    
}
