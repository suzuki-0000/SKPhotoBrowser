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
}


extension SKToolbar {
    
    func setControlsHidden(hidden: Bool) {
        let alpha: CGFloat = hidden ? 0.0 : 1.0
        
        UIView.animate(withDuration: 0.35,
                       animations: { self.alpha = alpha },
                       completion: nil)
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
        toolActionButton = self.barBattonItem(imageName: "SKPhotoBrowser.bundle/images/btn_common_action_wh",
                                              selector: #selector(actionButtonPressed(_:)))
        
        var items = [UIBarButtonItem]()
        if SKPhotoBrowserOptions.displayAction {
            items.append(toolActionButton)
        }
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        
        let deleteItem = self.barBattonItem(imageName: "SKPhotoBrowser.bundle/images/btn_common_delete_wh",
                                            selector: #selector(deleteButtonPressed(_:)))
        items.append(deleteItem)
        setItems(items, animated: false)
        
    }
    
    func setupActionButton() {
    }
    
    @objc func deleteButtonPressed(_ sender: UIButton) {
        guard let browser = self.browser else { return }
        
        browser.delegate?.removePhoto?(browser, index: browser.currentPageIndex) { [weak self] in
            self?.browser?.deleteImage()
        }
    }
    
    @objc func actionButtonPressed(_ sender: UIButton) {
        self.browser?.actionButtonPressed(ignoreAndShare: true)
    }
    
    private func barBattonItem(imageName: String, selector: Selector) -> UIBarButtonItem {
        let bundle = Bundle.init(for: SKToolbar.self)
        let deleteImage = UIImage(named: imageName, in: bundle, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)
        let deleteButton = UIButton(type: .custom)
        deleteButton.addTarget(self, action: selector, for: .touchUpInside)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        deleteButton.tintColor = .white
        return UIBarButtonItem(customView: deleteButton)
    }
}

