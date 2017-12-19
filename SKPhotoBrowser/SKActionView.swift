//
//  SKOptionalActionView.swift
//  SKPhotoBrowser
//
//  Created by keishi_suzuki on 2017/12/19.
//  Copyright © 2017年 suzuki_keishi. All rights reserved.
//

import UIKit

class SKActionView: UIView {
    internal weak var browser: SKPhotoBrowser?
    internal var closeButton: SKCloseButton!
    internal var deleteButton: SKDeleteButton!
    
    // Action
    fileprivate var cancelTitle = "Cancel"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser

        configureCloseButton()
        configureDeleteButton()
    }
    
    func updateCloseButton(image: UIImage, size: CGSize? = nil) {
        configureCloseButton(image: image, size: size)
    }
    
    func updateDeleteButton(image: UIImage, size: CGSize? = nil) {
        configureDeleteButton(image: image, size: size)
    }
    
    func animate(hidden: Bool) {
        let closeFrame: CGRect = hidden ? closeButton.hideFrame : closeButton.showFrame
        let deleteFrame: CGRect = hidden ? deleteButton.hideFrame : deleteButton.showFrame
        UIView.animate(withDuration: 0.35,
                       animations: { () -> Void in
                        let alpha: CGFloat = hidden ? 0.0 : 1.0

                        if SKPhotoBrowserOptions.displayCloseButton {
                            self.closeButton.alpha = alpha
                            self.closeButton.frame = closeFrame
                        }
                        if SKPhotoBrowserOptions.displayDeleteButton {
                            self.deleteButton.alpha = alpha
                            self.deleteButton.frame = deleteFrame
                        }
        }, completion: nil)
    }
    
    @objc func closeButtonPressed(_ sender: UIButton) {
        browser?.determineAndClose()
    }
    
    @objc func deleteButtonPressed(_ sender: UIButton) {
        guard let browser = self.browser else { return }
        
        browser.delegate?.removePhoto?(browser, index: browser.currentPageIndex) { [weak self] in
            self?.browser?.deleteImage()
        }
    }
    
    @objc func actionButtonPressed(ignoreAndShare: Bool) {
        if let titles = SKPhotoBrowserOptions.actionButtonTitles {
            let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
            
            for idx in titles.indices {
                actionSheetController.addAction(UIAlertAction(title: titles[idx], style: .default, handler: { [unowned self] (_) -> Void in
                    guard let browser = self.browser else { return }
                    browser.delegate?.didDismissActionSheetWithButtonIndex?(idx, photoIndex: browser.currentPageIndex)
                }))
            }
            
            if UI_USER_INTERFACE_IDIOM() == .phone {
                browser?.present(actionSheetController, animated: true, completion: nil)
            } else {
                actionSheetController.modalPresentationStyle = .popover
                if let popoverController = actionSheetController.popoverPresentationController {
                    popoverController.sourceView = self
//                    popoverController.barButtonItem = toolbar.toolActionButton
                }
                browser?.present(actionSheetController, animated: true, completion: nil)
            }
            
        } else {
            browser?.popupShare()
        }
    }
}

extension SKActionView {
    func configureCloseButton(image: UIImage? = nil, size: CGSize? = nil) {
        if closeButton == nil {
            closeButton = SKCloseButton(frame: .zero)
            closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
            closeButton.isHidden = !SKPhotoBrowserOptions.displayCloseButton
            addSubview(closeButton)
        }

        guard let size = size else { return }
        closeButton.setFrameSize(size)
        
        guard let image = image else { return }
        closeButton.setImage(image, for: UIControlState())
    }
    
    func configureDeleteButton(image: UIImage? = nil, size: CGSize? = nil) {
        if deleteButton == nil {
            deleteButton = SKDeleteButton(frame: .zero)
            deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
            deleteButton.isHidden = !SKPhotoBrowserOptions.displayDeleteButton
            addSubview(deleteButton)
        }

        guard let size = size else { return }
        deleteButton.setFrameSize(size)
        
        guard let image = image else { return }
        deleteButton.setImage(image, for: UIControlState())
    }
}
