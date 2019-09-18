//
//  DrawerController.swift
//  hermes
//
//  Created by Aidan Cline on 8/24/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import AVKit

class DrawerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let contentView = UITableView(frame: .zero, style: .insetGrouped)
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
    let gradientLayer = CAGradientLayer()
    let indicator = UIView()
    let player = VideoPlayer()
    
    var video: InvidiousVideo? {
        didSet {
            player.stop()
            if let video = video {
                if let videoURL = video.streamURLs?.quality144p, let audioURL = video.streamURLs?.audioOnly {
                    player.videoPlayer = AVPlayer(url: URL(string: videoURL)!)
                    player.audioPlayer = AVPlayer(url: URL(string: audioURL)!)
                    player.play()
                    print("set videos")
                } else {
                    print("downloading urls")
                    let video = InvidiousVideo(identifier: self.video?.identifier)
                    video.getData(fields: [.streamURLs]) {
                        if let videoURL = video.streamURLs?.quality144p, let audioURL = video.streamURLs?.audioOnly {
                            self.player.videoPlayer = AVPlayer(url: URL(string: videoURL)!)
                            self.player.audioPlayer = AVPlayer(url: URL(string: audioURL)!)
                            self.player.play()
                        } else {
                            print("failed download")
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        backgroundView.contentView.layer.addSublayer(gradientLayer)
        view.addSubview(contentView)
        backgroundView.contentView.addSubview(indicator)
        view.addSubview(player)
        contentView.separatorStyle = .none
        contentView.backgroundColor = .none
        contentView.contentInset.top += 40
        contentView.contentInset.top += view.frame.width * 9/16
        contentView.alwaysBounceVertical = true
        indicator.backgroundColor = .separator
        player.backgroundColor = .black
        player.videoPlayer = AVPlayer(url: URL(string: "https://r5---sn-ab5l6ndy.googlevideo.com/videoplayback?expire=1568747203&ei=Y9qAXa3XMsjDhwaLobXIDg&ip=2604%3Aa880%3A400%3Ad1%3A%3A8a4%3Ab001&id=o-AFb08g6IPjG9HCMdGFczt9qrWjyhH5KURhLCJG_B33XD&itag=137&aitags=133%2C134%2C135%2C136%2C137%2C160%2C242%2C243%2C244%2C247%2C248%2C278%2C394%2C395%2C396%2C397%2C398&source=youtube&requiressl=yes&mm=31%2C26&mn=sn-ab5l6ndy%2Csn-p5qlsndz&ms=au%2Conr&mv=m&mvi=4&pl=48&initcwndbps=226250&mime=video%2Fmp4&gir=yes&clen=15075608&dur=190.874&lmt=1543052954142358&mt=1568725496&fvip=5&keepalive=yes&fexp=23842631&c=WEB&txp=5533432&sparams=expire%2Cei%2Cip%2Cid%2Caitags%2Csource%2Crequiressl%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=ALgxI2wwRgIhANGPM8r2SJxn-3YyC4a23jn-MvUolECv9kNULyAsES7QAiEAiklFI_jruup-uuYLAEOVa9PxXBrAxpvVFtWPDoxXjB0%3D&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRgIhAORxWzFc2uTvCwrqpuq5-lx1UIzxzdcYFG9_Z3-kJGaPAiEAx7nZvJvVJ0o4qgUsMUlSuJoH0TMmv-KZMOy2g2kaZT4%3D&host=r5---sn-ab5l6ndy.googlevideo.com")!)
        player.audioPlayer = AVPlayer(url: URL(string: "https://r5---sn-ab5l6ndy.googlevideo.com/videoplayback?expire=1568747203&ei=Y9qAXa3XMsjDhwaLobXIDg&ip=2604%3Aa880%3A400%3Ad1%3A%3A8a4%3Ab001&id=o-AFb08g6IPjG9HCMdGFczt9qrWjyhH5KURhLCJG_B33XD&itag=140&source=youtube&requiressl=yes&mm=31%2C26&mn=sn-ab5l6ndy%2Csn-p5qlsndz&ms=au%2Conr&mv=m&mvi=4&pl=48&initcwndbps=226250&mime=audio%2Fmp4&gir=yes&clen=3092325&dur=190.984&lmt=1543052018286248&mt=1568725496&fvip=5&keepalive=yes&fexp=23842631&c=WEB&txp=5533432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&sig=ALgxI2wwRQIgXpe5D_Usdu7IZJkjcejkKdtMipvyRby1WtrT_nV0kJ0CIQCWHjoJ_amC3eft-7IWW5yEf6O1Vosjdq7JA1eJz8E_4w%3D%3D&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRgIhAORxWzFc2uTvCwrqpuq5-lx1UIzxzdcYFG9_Z3-kJGaPAiEAx7nZvJvVJ0o4qgUsMUlSuJoH0TMmv-KZMOy2g2kaZT4%3D&host=r5---sn-ab5l6ndy.googlevideo.com")!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.frame = CGRect(x: 0, y: view.layoutMargins.top, width: view.frame.width, height: view.frame.height - view.layoutMargins.top)
        gradientLayer.frame = contentView.bounds
        backgroundView.frame = contentView.frame
        indicator.frame = CGRect(x: (backgroundView.frame.width - 40)/2, y: (40 - 5)/2, width: 40, height: 5)
        indicator.layer.cornerRadius = indicator.frame.height/2
        player.frame = CGRect(x: 0, y: 40 + view.layoutMargins.top, width: view.frame.width, height: view.frame.width * 9/16)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        player.stop()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 10
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let section = indexPath.section
        let row = indexPath.section
        if section == 0 && row == 0 {
            cell.textLabel?.text = video?.title
        }
        
        return cell
    }
    
}
