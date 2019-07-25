//
//  Views.swift
//  hermes
//
//  Created by Aidan Cline on 1/30/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit

class GroupScrollView: UIScrollView {
    
    func contentHeight() -> CGFloat {
        return contentHeight(at: limit(subviews.count - 1, min: 0))
    }
    
    func contentHeight(at index: Int) -> CGFloat {
        var result = CGFloat.zero
        for (i, view) in subviews.enumerated() {
            if i >= index {
                break
            } else {
                result += view.frame.height
            }
        }
        
        return result
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentSize.width = frame.width
        canCancelContentTouches = true
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        alignSubviews()
    }
    
    override func insertSubview(_ view: UIView, at index: Int) {
        super.insertSubview(view, at: index)
        alignSubviews()
    }
    
    func removeSubview(_ view: UIView) {
        view.removeFromSuperview()
        alignSubviews()
    }
    
    func addGap(height: CGFloat) {
        let view = UIView()
        view.frame.size.height = height
        addSubview(view)
    }
    
    func insertGap(height: CGFloat, at index: Int) {
        let view = UIView()
        view.frame.size.height = height
        insertSubview(view, at: index)
    }
    
    func alignSubviews() {
        for (i, view) in subviews.enumerated() {
            view.frame.origin.y = contentHeight(at: i)
        }
        contentSize.height = subviews.last?.frame.maxY ?? 0
    }
    
    func removeAllSubviews() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}

class DividerLine: UIView {
    
    private let lineView = UIView()
    var inset: CGFloat = 16 {
        didSet {
            lineView.frame.origin.x = inset
            lineView.frame.size.width = frame.width - inset*2
        }
    }
    
    var color = UIColor() {
        didSet {
            lineView.backgroundColor = color.withAlphaComponent(1/3)
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: inset, y: 0, width: frame.width - inset*2, height: 1)
        self.color = UIColor(white: 0.5, alpha: 1/3)
        addSubview(lineView)
    }
    
}

class CellButton: UIView {
    
    let button = UIButton()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let topDivider = DividerLine()
    let bottomDivider = DividerLine()
    
    let arrow = UIImageView()
    let highlightView = UIView()
    
    var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            layoutSubviews()
        }
    }
    
    var highlightColor = UIColor(white: 0.5, alpha: 1)
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.height = 50
        
        themeDidChange(animated: false)
        
        topDivider.inset = 0
        topDivider.alpha = 0
        bottomDivider.inset = 0
        bottomDivider.alpha = 0
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .left
        subtitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textAlignment = .left
        
        if #available(iOS 13, *) {
            arrow.image = UIImage(systemName: "chevron.right") // system icons not added til ios 13
        } else {
            arrow.image = UIImage(named: "arrow-right")
        }
        arrow.image = UIImage(named: "arrow-right")
        arrow.tintColor = UIColor(white: 0.5, alpha: 1)
        arrow.contentMode = .scaleAspectFit
        arrow.alpha = 0
        addSubview(arrow)
        addSubview(topDivider)
        addSubview(bottomDivider)
        addSubview(subtitleLabel)
        addSubview(titleLabel)
        addSubview(highlightView)
        addSubview(button)
        
        button.addTarget(self, action: #selector(self.wasPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(self.wasTapped(_:)), for: .primaryActionTriggered)
        button.addTarget(self, action: #selector(self.wasReleased(_:)), for: .touchUpOutside)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.themeDidChange(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = 50
        let paddedSize = CGSize(width: frame.width - padding.left - padding.right, height: frame.height - padding.top - padding.bottom)
        button.frame = bounds
        topDivider.frame = CGRect(x: padding.left, y: 0, width: paddedSize.width, height: 1)
        bottomDivider.frame = CGRect(x: padding.left, y: frame.height - 1, width: paddedSize.width, height: 1)
        arrow.frame = CGRect(x: paddedSize.width + padding.left - 16 - 8, y: padding.top + (paddedSize.height - 16)/2, width: 16, height: 16)
        titleLabel.frame = CGRect(x: padding.left + 8, y: padding.top + (paddedSize.height - 20 - ((subtitle != nil) ? 16 : 0))/2, width: paddedSize.width - arrow.frame.width - 8, height: 22)
        subtitleLabel.frame = CGRect(x: padding.left + 8, y: titleLabel.frame.maxY + 2, width: titleLabel.frame.width, height: 16)
        titleLabel.font = .systemFont(ofSize: (subtitle == nil) ? 18 : 16, weight: .semibold)
        highlightView.frame = bounds
    }
    
    func themeDidChange(animated: Bool) {
        UIView.animate(withDuration: (animated) ? 0.25 : 0) {
            self.titleLabel.textColor = interface.textColor
            self.subtitleLabel.textColor = interface.textColor.withAlphaComponent(0.5)
        }
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var subtitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            layoutSubviews()
            subtitleLabel.text = newValue?.uppercased()
        }
    }
    
    var isButtonActive: Bool = true {
        didSet {
            button.isUserInteractionEnabled = isButtonActive
        }
    }
    
    var showTopDivider: Bool = false {
        didSet {
            topDivider.alpha = (showTopDivider) ? 0.5 : 0
        }
    }
    
    var showBottomDivider: Bool = false {
        didSet {
            bottomDivider.alpha = (showBottomDivider) ? 0.5 : 0
        }
    }
    
    var showNavigationIndicator: Bool = false {
        didSet {
            arrow.alpha = (showNavigationIndicator) ? 1 : 0
        }
    }
    
    @objc func wasPressed(_ button: UIButton) {
        UIView.animate(withDuration: 0.125) {
            self.highlightView.backgroundColor = self.highlightColor.withAlphaComponent(1/3)
        }
        onPress?()
    }
    
    @objc func wasTapped(_ button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.highlightView.backgroundColor = .clear
        }
        onTap?()
    }
    
    @objc func wasReleased(_ button: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.highlightView.backgroundColor = .clear
        }
        onRelease?()
    }
    
    var onPress: (() -> Void)?
    var onTap: (() -> Void)?
    var onRelease: (() -> Void)?
    
}

class CellGroup: UIView {
    
    let mainView = UIView()
    var cells = [CellButton]()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainView)
        mainView.layer.cornerRadius = 20
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 0
        
        updateThemes(animated: false)
        
        NotificationCenter.default.addObserver(forName: .themeChanged, object: nil, queue: .main) { (notification) in
            self.updateThemes(animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.frame = CGRect(x: 16, y: 0, width: frame.width - 32, height: frame.height)
        mainView.frame.size.height = CGFloat(cells.count) * 50
        for cell in cells {
            cell.frame.size.width = mainView.frame.width
        }
    }
    
    func addCell(_ cell: CellButton) {
        cell.padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        cell.frame.size.width = mainView.frame.width
        cell.frame.origin.y = CGFloat(cells.count) * 50
        cells.append(cell)
        frame.size.height = CGFloat(cells.count) * 50
        mainView.addSubview(cell)
        for cell in cells {
            cell.showBottomDivider = !(cell == cells.last)
        }
    }
    
    func updateThemes(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.setThemes()
        }
    }
    
    func setThemes() {
        mainView.layer.borderColor = interface.textColor.withAlphaComponent(1/6).cgColor
        mainView.backgroundColor = interface.contentColor
    }
    
}
