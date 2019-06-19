//
//  SKVideoPlayerView.swift
//  SKPhotoBrowser
//
//  Created by Елизаров Владимир Алексеевич on 05/06/2019.
//

import Foundation
import AVKit
import AVFoundation

class SKVideoPlayerView: UIView, PresentableViewType {
    
    var imageFrame: CGRect {
        return self.frame
    }
    
    var captionView: SKCaptionView!
    
    var photo: SKPhotoProtocol! {
        didSet {
            if photo != nil && photo.underlyingImage != nil {
                displayImage(complete: true)
                return
            }
            if photo != nil {
                displayImage(complete: false)
            }
            guard let video = self.photo
                , let videoURL = video.videoStreamURL
                , let url = URL(string: videoURL) else {
                return
            }
            let header = SKPhotoBrowserOptions.sessionConfiguration.httpAdditionalHeaders
            let asset: AVURLAsset = AVURLAsset.init(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": header as Any])
            let playerItem = AVPlayerItem(asset: asset)
            self.playerController.player = AVPlayer(playerItem: playerItem)
            self.setObservation(in: self.playerController.player!)
            self.playerController.player?.allowsExternalPlayback = true
            self.playerController.showsPlaybackControls = false
        }
    }

    private var playButtonImageView: SKDetectingView!
    
    var contentOffset: CGPoint {
        return .zero
    }
    
    var presentableType: MediaType {
        return .video
    }
    
    private weak var browser: SKPhotoBrowser?
    
    private var indicatorView: SKIndicatorView!
    
    private var playerController = AVPlayerViewController()
    
    // MARK: -
    
    convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser
        setup()
    }
    
    deinit {
        self.playerController.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
        self.unsubscribeFromPlayToEndNotification()
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        
    }
    
    func prepareForReuse() {
        self.playerController.removeFromParent()
        self.playerController.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
        self.playerController.player?.pause()
        self.playerController.player = nil
        self.playerController.showsPlaybackControls = false
        if self.playButtonImageView.isHidden {
            self.playButtonImageView.isHidden = false
        }
    }
    
    func displayImage(_ image: UIImage) {
        
    }
    
    func displayImageFailure() {
        
    }

    func displayImage(complete flag: Bool) {
        
        if !flag {
            if photo.underlyingImage == nil {
                indicatorView.startAnimating()
            }
            photo.loadUnderlyingImageAndNotify()
        } else {
            indicatorView.stopAnimating()
        }
        indicatorView.stopAnimating()
        if let image = photo.underlyingImage, photo != nil {
            displayImage(image)
        }
    }
    
    open override func layoutSubviews() {
        self.indicatorView.frame = bounds
        
        super.layoutSubviews()
        
        guard self.playButtonImageView != nil else {
            return
        }
        
        self.playButtonImageView.frame = self.bounds
        self.playButtonImageView.subviews.forEach {
            $0.center = self.playButtonImageView.center
        }
    }
    
    // MARK: - Private
    
    private func setObservation(in player: AVPlayer) {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
        self.unsubscribeFromPlayToEndNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    private func unsubscribeFromPlayToEndNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        self.playerController.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.rate) {
            if self.playerController.player?.rate == 0 {
                if self.browser?.areControlsHidden() ?? false {
                    self.browser?.toggleControls()
                }
                self.playerController.showsPlaybackControls = false
                self.playButtonImageView.isHidden = false
            } else {
                self.browser?.hideControls()
                self.playerController.showsPlaybackControls = true
                self.playButtonImageView.isHidden = true
            }
        }
    }
    
    fileprivate func setupImageView() {
        // image
        self.playButtonImageView = SKDetectingView(frame: frame)
        self.playButtonImageView.delegate = self
        self.playButtonImageView.contentMode = .bottom
        self.playButtonImageView.backgroundColor = .clear
        addSubview(self.playButtonImageView)
        
        let bundle = Bundle(for: SKPhotoBrowser.self)
        let image = UIImage(named: "SKPhotoBrowser.bundle/images/ic_PlayVideo", in: bundle, compatibleWith: nil)
        let imgView = UIImageView(image: image)
        imgView.center = playButtonImageView.center
        self.playButtonImageView.addSubview(imgView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideAndPlay))
        imgView.addGestureRecognizer(tapGesture)
    }
    
    private func setup() {
        
        self.addSubview(playerController.view)
        self.playerController.showsPlaybackControls = false
        
        self.setupImageView()
        // indicator
        self.indicatorView = SKIndicatorView(frame: frame)
        addSubview(self.indicatorView)
    }
    
    private func playVideo() {
        guard let playURL = self.photo.videoStreamURL
            , let url = URL(string: playURL) else {
            return
        }
        
        if let oldPlayer = self.playerController.player {
            oldPlayer.play()
            return
        }
        
        let player = AVPlayer(url: url)
        self.playerController.player = player
        UIView.performWithoutAnimation {
            self.playerController.player?.play()
        }
    }
    
    @objc private func hideAndPlay() {
        self.playButtonImageView.isHidden = true
        self.playerController.showsPlaybackControls = true
        self.playVideo()
        self.hideControlls()
    }
}

extension SKVideoPlayerView: SKDetectingViewDelegate {
    
    func handleSingleTap(_ view: UIView, touch: UITouch) {
        self.toggleControlls()
    }
    
    func handleDoubleTap(_ view: UIView, touch: UITouch) {
        self.toggleControlls()
    }
    
    private func toggleControlls() {
        self.browser?.toggleControls()
    }
    
    private func hideControlls() {
        self.browser?.hideControls()
    }
}

