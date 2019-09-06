//
//  SKToolbar.swift
//  SKPhotoBrowser
//
//  Created by keishi_suzuki on 2017/12/20.
//  Copyright © 2017年 suzuki_keishi. All rights reserved.
//

import Foundation

// helpers which often used
private let bundle = Bundle(for: SKPhotoBrowser.self)

class SKToolbar: UIToolbar {
    var toolActionButton: UIBarButtonItem!
    fileprivate weak var browser: SKPhotoBrowser?
    
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
        setupToolbar()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if SKMesurement.screenWidth - point.x < 50 { // FIXME: not good idea
                return view
            }
        }
        return nil
    }
}

private extension SKToolbar {
    func setupApperance() {
        backgroundColor = .clear
        clipsToBounds = true
        isTranslucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }
    
    func setupToolbar() {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "SKPhotoBrowser.bundle/images/savePhoto", in: bundle, compatibleWith: nil) ?? UIImage(), for: .normal)
        btn.addTarget(browser, action: #selector(SKPhotoBrowser.actionButtonPressed), for: .touchUpInside)
        btn.bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 40))
        btn.contentHorizontalAlignment = .right
//        toolActionButton = UIBarButtonItem(barButtonSystemItem: .save, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
        toolActionButton = UIBarButtonItem(customView: btn)
        toolActionButton.tintColor = UIColor.white
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        if SKPhotoBrowserOptions.displayAction {
            items.append(toolActionButton)
        }
        setItems(items, animated: false)
    }
    
    func setupActionButton() {
    }
}

