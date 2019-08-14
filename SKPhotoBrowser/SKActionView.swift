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
    internal var menuButton: SKMenuButton!
    
    // Action
    fileprivate var cancelTitle = "Cancel"
    
    private var substrates: [UIView] = []
    
    private struct Constants {
        static let substrateHeight: CGFloat = 119
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser

        self.configureSubstrates()
        configureCloseButton()
        configureDeleteButton()
        configureMenuButton()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if closeButton.frame.contains(point) || deleteButton.frame.contains(point) || menuButton.frame.contains(point)  {
                return view
            }
            return nil
        }
        return nil
    }
    
    func updateFrame(frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
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
        let menuFrame: CGRect = hidden ? menuButton.hideFrame : menuButton.showFrame
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
                        if SKPhotoBrowserOptions.displayMenuButton {
                            self.menuButton.alpha = alpha
                            self.menuButton.frame = menuFrame
                        }
                        self.substrates.forEach { substrate in
                            substrate.transform = hidden
                                ? substrate.frame.minY <= 0
                                    ? CGAffineTransform(translationX: 0, y: -Constants.substrateHeight)
                                    : CGAffineTransform(translationX: 0, y: Constants.substrateHeight)
                                : .identity
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
    
    @objc func menuButtonPressed(_ sender: UIButton) {
        guard let browser = self.browser else { return }
        browser.delegate?.menuButtonDidTocuh?(browser)
        
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

        if let size = size {
            closeButton.setFrameSize(size)
        }
        
        if let image = image {
            closeButton.setImage(image, for: .normal)
        }
    }
    
    func configureDeleteButton(image: UIImage? = nil, size: CGSize? = nil) {
        if deleteButton == nil {
            deleteButton = SKDeleteButton(frame: .zero)
            deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
            deleteButton.isHidden = !SKPhotoBrowserOptions.displayDeleteButton
            addSubview(deleteButton)
        }
        
        if let size = size {
            deleteButton.setFrameSize(size)
        }
        
        if let image = image {
            deleteButton.setImage(image, for: .normal)
        }
    }
    
    func configureMenuButton(image: UIImage? = nil, size: CGSize? = nil) {
        if menuButton == nil {
            menuButton = SKMenuButton(frame: .zero)
            menuButton.addTarget(self, action: #selector(menuButtonPressed(_:)), for: .touchUpInside)
            menuButton.isHidden = !SKPhotoBrowserOptions.displayMenuButton
            addSubview(menuButton)
        }
        
        if let size = size {
            menuButton.setFrameSize(size)
        }
        
        if let image = image {
            menuButton.setImage(image, for: .normal)
        }
    }
    
    private func configureSubstrates() {
        let clearColor = UIColor.clear.cgColor
        let blackColor = UIColor(white: 0, alpha: 0.38).cgColor
        
        self.setupTopSubstrate(blackColor, clearColor)
        self.setupBottomSubstrate(clearColor, blackColor)
    }

    private func setupTopSubstrate(_ colors: CGColor...) {
        let topSubstrateFrame = CGRect(
            x: 0, y: 0,
            width: self.bounds.width, height: Constants.substrateHeight)
        self.setupSubstrateView(frame: topSubstrateFrame, colors)
    }
    
    private func setupBottomSubstrate(_ colors: CGColor...) {
        let bottomSubstrateFrame = CGRect(
            x: 0, y: self.bounds.height - Constants.substrateHeight,
            width: self.bounds.width, height: Constants.substrateHeight)
        self.setupSubstrateView(frame: bottomSubstrateFrame, colors)
    }
    
    fileprivate func setupSubstrateView(frame substrateFrame: CGRect, _ colors: [CGColor]) {
        let substrate = UIView(frame: substrateFrame)
        let substrateLayer = self.gradientLayer(with: substrate.bounds, colors: colors)
        substrate.layer.insertSublayer(substrateLayer, at: 0)
        self.addSubview(substrate)
        self.substrates.append(substrate)
    }
    
    private func gradientLayer(with bounds: CGRect, colors: [CGColor]) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = bounds
        gradient.colors = colors
        return gradient
    }
}
