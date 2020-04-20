//
//  Videovc.swift
//  PresentationDismission
//
//  Created by Eslam on 4/18/20.
//  Copyright © 2020 Eslam. All rights reserved.
//

import UIKit
import AVKit

class VideoVC: UIViewController {

    @IBOutlet weak var CurrentLabel: UILabel!
    @IBOutlet weak var FullLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var is_playing = true
    var is_sliding = false
    
    @IBAction func pauseStartButton(_ sender: UIButton) {
        if is_playing {
            is_playing = !is_playing
            sender.setBackgroundImage(UIImage(systemName: "zzz"), for: .normal)
            player.pause()
        } else {
            is_playing = !is_playing
           sender.setBackgroundImage(UIImage(systemName: "zzz"), for: .normal)
            player.play()
        }
        
    }
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
    }


}
//MARK: - timeObserver & getCurrentTime
extension VideoVC {
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] (time) in
            guard let currentItem = self?.player.currentItem else { return }
            guard currentItem.status.rawValue == AVPlayerItem.Status.readyToPlay.rawValue else { return }
            self?.videoSlider.minimumValue = 0
            self?.videoSlider?.maximumValue = Float(currentItem.duration.seconds)
            if self?.is_sliding == true {
                self?.videoSlider.value = (self?.videoSlider.value)!
            } else {
                self?.videoSlider.value = Float(currentItem.currentTime().seconds)
                /*
                 the auto play next code will be here
                 */
                if self?.videoSlider.value == Float(currentItem.duration.seconds) {
                    print("The end")
                }
            }
            self?.CurrentLabel.text = self?.getTimeString(time: currentItem.currentTime())
        })
    }
    //MARK: - Get Full Time Func
    func getTimeString(time : CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let mints = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return "\(hours):\(mints):\(seconds)"
        } else {
            return "\(mints):\(seconds)"
        }
    }
}


//MARK: - Video Tracking Methods
extension VideoVC {
        //MARK: - Video Slider Began Tracking
        @objc func sliderBeganTracking() {
            is_sliding = true
        }
        
        //MARK: - VideoSlider is Moving
        @objc func sliderISMoving() {
            
            player.pause()
            if let sender_value = videoSlider?.value {
            //Turn Slider Value into Time To Display
            let hours = Int(sender_value/3600)
            let mints = Int(sender_value/60) % 60
            let seconds = Int(sender_value.truncatingRemainder(dividingBy: 60))
            if hours > 0 {
                self.CurrentLabel.text = "\(hours):\(mints):\(seconds)"
            } else {
                self.CurrentLabel.text = "\(mints):\(seconds)"
            }
        }
        }
        
        //MARK: - Video Slider Ended Tracking
        @objc func sliderEndedTracking() {
            
            is_sliding = false
            if let sender_value = videoSlider?.value {
            player.seek(to: CMTimeMake(value: Int64(sender_value * 1000), timescale: 1000))
    //        videoSlider.value = videoSlider.value
            player.play()
            //videoView.Start_Pause?.setImage(#imageLiteral(resourceName: "pause_white"), for: .normal)
            }
        }
        
        //MARK: - Observer
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "duration" , let duration = player.currentItem?.duration.seconds , duration > 0.0 {
                ActivityIndicator?.stopAnimating()
                ActivityIndicator?.alpha = 0.0
                self.FullLabel?.text = getTimeString(time: player.currentItem!.duration)
                //videoView.ControlsView?.alpha = 1
            }
        }
        
        //MARK: - Forward Video
        @objc func Video_Forward() {
            guard let duration = player.currentItem?.duration else { return }
            let currenttime = CMTimeGetSeconds(player.currentTime())
            let nextTime = currenttime + 5
            if nextTime < (CMTimeGetSeconds(duration) - 5.0) {
                player.seek(to: CMTimeMake(value: Int64(nextTime * 1000), timescale: 1000))
            }
        }
        
        //MARK: - Backward Video
       @objc func Video_Backward() {
            player.pause()
            let currenttime = CMTimeGetSeconds(player.currentTime())
            let nextTime = currenttime - 5
            if nextTime < 0 {
                player.seek(to: CMTimeMake(value: Int64(0 * 1000), timescale: 1000))
            } else {
                player.seek(to: CMTimeMake(value: Int64(nextTime * 1000), timescale: 1000))
            }
            player.play()
        }
    //MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        player.play()
    }
    
    //MARK: - ViewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        playerLayer.frame = videoView!.bounds
    }
}


//MARK: - Load Video
extension VideoVC {
    func loadVideo() {
        ActivityIndicator.startAnimating()
        player = AVPlayer.init(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.videoGravity = .resize
        self.videoView.layer.addSublayer(playerLayer!)
        //MARK: - Adding Video Observer
        player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new , .initial], context: nil)
        //Time Function
        addTimeObserver()
        //MARK: - videoSlider Targets
        videoSlider.addTarget(self, action: #selector(sliderBeganTracking), for: .touchDown)
        videoSlider.addTarget(self, action: #selector(sliderEndedTracking), for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(sliderEndedTracking), for: .touchUpOutside)
        videoSlider.addTarget(self, action: #selector(sliderISMoving), for: .touchDragInside)
        
    }
}
