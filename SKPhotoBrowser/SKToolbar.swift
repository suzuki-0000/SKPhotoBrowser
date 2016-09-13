//
//  SKToolbar.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/12.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = NSBundle(forClass: SKPhotoBrowser.self)

class SKToolbar: UIToolbar {
    var toolCounterLabel: UILabel!
    var toolCounterButton: UIBarButtonItem!
    var toolPreviousButton: UIBarButtonItem!
    var toolNextButton: UIBarButtonItem!
    var toolActionButton: UIBarButtonItem!
    
    private weak var browser: SKPhotoBrowser?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser
        
        setupApperance()
        setupPreviousButton()
        setupNextButton()
        setupCounterLabel()
        setupActionButton()
        setupToolbar()
    }
    
    func updateToolbar(currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        if browser.numberOfPhotos > 1 {
            toolCounterLabel.text = "\(currentPageIndex + 1) / \(browser.numberOfPhotos)"
        } else {
            toolCounterLabel.text = nil
        }
        
        toolPreviousButton.enabled = (currentPageIndex > 0)
        toolNextButton.enabled = (currentPageIndex < browser.numberOfPhotos - 1)
    }
}

private extension SKToolbar {
    func setupApperance() {
        backgroundColor = .clearColor()
        clipsToBounds = true
        translucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        
        // toolbar
        if !SKPhotoBrowserOptions.displayToolbar {
            hidden = true
        }
    }
    
    func setupToolbar() {
        guard let browser = browser else { return }
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        if browser.numberOfPhotos > 1 && SKPhotoBrowserOptions.displayBackAndForwardButton {
            items.append(toolPreviousButton)
        }
        if SKPhotoBrowserOptions.displayCounterLabel {
            items.append(flexSpace)
            items.append(toolCounterButton)
            items.append(flexSpace)
        } else {
            items.append(flexSpace)
        }
        if browser.numberOfPhotos > 1 && SKPhotoBrowserOptions.displayBackAndForwardButton {
            items.append(toolNextButton)
        }
        items.append(flexSpace)
        if SKPhotoBrowserOptions.displayAction {
            items.append(toolActionButton)
        }
        setItems(items, animated: false)
    }
    
    func setupPreviousButton() {
        let previousBtn = SKPreviousButton(frame: frame)
        previousBtn.addTarget(browser, action: #selector(SKPhotoBrowser.gotoPreviousPage), forControlEvents: .TouchUpInside)
        toolPreviousButton = UIBarButtonItem(customView: previousBtn)
    }
    
    func setupNextButton() {
        let nextBtn = SKNextButton(frame: frame)
        nextBtn.addTarget(browser, action: #selector(SKPhotoBrowser.gotoNextPage), forControlEvents: .TouchUpInside)
        toolNextButton = UIBarButtonItem(customView: nextBtn)
    }
    
    func setupCounterLabel() {
        toolCounterLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 95, height: 40))
        toolCounterLabel.textAlignment = .Center
        toolCounterLabel.backgroundColor = .clearColor()
        toolCounterLabel.font = SKPhotoBrowserOptions.toolbarFont
        toolCounterLabel.textColor = SKPhotoBrowserOptions.textAndIconColor
        toolCounterLabel.shadowColor = SKPhotoBrowserOptions.toolbarTextShadowColor
        toolCounterLabel.shadowOffset = CGSize(width: 0.0, height: 1.0)
        toolCounterButton = UIBarButtonItem(customView: toolCounterLabel)
    }
    
    func setupActionButton() {
        toolActionButton = UIBarButtonItem(barButtonSystemItem: .Action, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
        toolActionButton.tintColor = SKPhotoBrowserOptions.textAndIconColor
    }
}


class SKToolbarButton: UIButton {
    let insets: UIEdgeInsets = UIEdgeInsets(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
    
    func setup(imageName: String) {
        backgroundColor = .clearColor()
        tintColor = SKPhotoBrowserOptions.textAndIconColor
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        contentMode = .Center
        
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/\(imageName)",
                            inBundle: bundle, compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate) ?? UIImage()
        setImage(image, forState: .Normal)
    }
}

class SKPreviousButton: SKToolbarButton {
    let imageName = "btn_common_back_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}

class SKNextButton: SKToolbarButton {
    let imageName = "btn_common_forward_wh"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}