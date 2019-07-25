//
//  VolumeView.swift
//  hermes
//
//  Created by Aidan Cline on 2/22/19.
//  Copyright © 2019 Aidan Cline. All rights reserved.
//

import UIKit
import MediaPlayer

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone Xs"
            case "iPhone11,4", "iPhone11,6":                return "iPhone Xs Max"
            case "iPhone11,8":                              return "iPhone Xr"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
    enum UIScreenSizes {
        case square
        case compact
        case bezeless
        case undefined
    }
    
    static let screenType: UIScreenSizes = {
        let model = UIDevice.modelName
        switch model {
        case "iPhone 5", "iPhone 5s", "iPhone SE":
            return .compact
        case "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus", "iPhone 8", "iPhone 8 Plus":
            return .square
        case "iPhone X", "iPhone Xs", "iPhone Xs Max", "iPhone Xr":
            return .bezeless
        default:
            return .undefined
        }
    }()
    
}

class VolumeView: UIVisualEffectView {
    
    var volume: CGFloat {
        let audioSession = AVAudioSession()
        do {
            try audioSession.setActive(true)
            try audioSession.setCategory(.playback, options: .mixWithOthers)
        } catch {
            print("error activating audioSession")
        }
        return CGFloat(audioSession.outputVolume)
    }
    
    let systemVolumeView = MPVolumeView(frame: .zero)
    private var timer = Timer()
    
    let sliderBackground = UIView()
    let sliderFill = UIView()
    let volumeIcon = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var offset: CGFloat = 0
        switch UIDevice.screenType {
        case .bezeless:
            offset = 100
        case .square, .compact:
            offset = 50
        case .undefined:
            offset = 0
        }
        
        isUserInteractionEnabled = false        
        clipsToBounds = true
        effect = UIBlurEffect(style: .dark)
        frame = CGRect(x: -16, y: safeArea.top + offset, width: 47, height: 162)
        alpha = 0.01
        layer.cornerRadius = 18
        
        sliderBackground.frame = CGRect(x: (47-5)/2, y: 14, width: 5, height: 100)
        sliderBackground.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        sliderBackground.layer.cornerRadius = 2.5
        sliderBackground.clipsToBounds = true
        sliderFill.frame = CGRect(x: 0, y: 100 - volume*100, width: 5, height: volume*100)
        sliderFill.backgroundColor = UIColor(white: 1.0, alpha: 0.75)
        sliderFill.layer.cornerRadius = 2.5
        sliderFill.clipsToBounds = true
        
        volumeIcon.frame = CGRect(x: 16, y: 16+100+14, width: 16, height: 16)
        volumeIcon.image = icon(forVolume: volume)
        volumeIcon.tintColor = UIColor(white: 1.0, alpha: 0.75)
        
        systemVolumeView.showsVolumeSlider = true
        systemVolumeView.isUserInteractionEnabled = false
        systemVolumeView.showsRouteButton = true
        systemVolumeView.alpha = 0.001
        
        contentView.addSubview(systemVolumeView)
        contentView.addSubview(sliderBackground)
        contentView.addSubview(volumeIcon)
        sliderBackground.addSubview(sliderFill)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidUpdate), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    @objc func volumeDidUpdate() {
        timer.invalidate()
        frame.origin.x = 16
        UIView.animate(withDuration: 0.125) {
            self.alpha = 1
        }
        UIView.animate(withDuration: 0.25) {
            self.sliderFill.frame = CGRect(x: 0, y: 100 - self.volume*100, width: 5, height: self.volume*100)
            if self.icon(forVolume: self.volume) == UIImage(named: "volumem") {
                self.volumeIcon.frame.origin.x = 18
            } else {
                self.volumeIcon.frame.origin.x = 16
            }
        }
        UIView.transition(with: self.volumeIcon, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.volumeIcon.image = self.icon(forVolume: self.volume)
        }, completion: nil)
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
            if timer.isValid {
                UIView.animate(withDuration: 0.5, animations: {
                    self.frame.origin.x = -16
                    self.alpha = 0.001
                })
            }
        })
    }
    
    func icon(forVolume volume: CGFloat) -> UIImage? {
        var image: UIImage?
        image = UIImage(named: "volume3")
        image = (volume <= 0.75) ? UIImage(named: "volume2") : image
        image = (volume <= 0.5) ? UIImage(named: "volume1") : image
        image = (volume <= 0.25) ? UIImage(named: "volume0") : image
        image = (volume <= 0) ? UIImage(named: "volumem") : image
        return image
    }
    
}
