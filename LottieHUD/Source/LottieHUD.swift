//
//  LottieHUD.swift
//  LottieHUD
//
//  Created by Ahmed Raad on 12/17/17.
//  Copyright © 2017 Ahmed Raad. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class LottieHUD {
    
    struct Constants {
        static let lottieSideHeight: CGFloat = 200
        
        static let shadow: CGFloat = 0.7
        static let animationDuration: TimeInterval = 0.3
    }

    private var backgroundView: UIView = {
        let bg = UIView()
        bg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bg.backgroundColor = UIColor.black.withAlphaComponent(Constants.shadow)
        bg.isUserInteractionEnabled = false
        bg.alpha = 0.0
        return bg
    }()
    
    public var contentMode: UIViewContentMode = .scaleAspectFit {
        didSet {
            self._lottie.contentMode = contentMode
        }
    }
    
    public var frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
    
    private var _lottie: LOTAnimationView = {
        var lt = LOTAnimationView()
        lt.loopAnimation = true
        return lt
    }()
    
    init(_ name: String, loop: Bool = true) {
        self._lottie = LOTAnimationView(name: name)
        self._lottie.loopAnimation = loop
    }
    
    init(_ lottie: LOTAnimationView) {
        self._lottie = lottie
    }
    
    public func showHUD(with delay: TimeInterval = 0.0, loop: Bool = true) {
        _lottie.loopAnimation = loop
        createHUD(delay: delay)
    }
    
    public func stopHUD() {
        clearHUD()
    }
    
    private func createHUD(delay: TimeInterval = 0.0) {
        DispatchQueue.main.async {
            self.addLottieToHierarchy()
            
            UIView.animate(withDuration: Constants.animationDuration, delay: delay, options: .curveEaseIn, animations: {
                self.backgroundView.alpha = 1.0
            }, completion: nil)
            
            self._lottie.play(completion: { _ in
                self.clearHUD()
            })
        }
    }
    
    private func clearHUD() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseIn, animations: {
                self.backgroundView.alpha = 0.0
            }) { finished in
                UIApplication.shared.keyWindow!.isUserInteractionEnabled = true
                self.backgroundView.removeFromSuperview()
                self._lottie.stop()
            }
        }
    }
    
    private func addLottieToHierarchy() {
        UIApplication.shared.keyWindow!.isUserInteractionEnabled = false
        backgroundView.addSubview(_lottie)
        backgroundView.frame = keyWindow.view.bounds
        keyWindow.view.addSubview(backgroundView)
        
        _lottie.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: _lottie,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .height,
                               multiplier: 1,
                               constant: Constants.lottieSideHeight),
            NSLayoutConstraint(item: _lottie,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .width,
                               multiplier: 1,
                               constant: Constants.lottieSideHeight),
            NSLayoutConstraint(item: _lottie,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: backgroundView,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0),
            NSLayoutConstraint(item: _lottie,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: backgroundView,
                               attribute: .centerY,
                               multiplier: 1,
                               constant: 0)
            ])
    }
    
    private var keyWindow: UIViewController {
        return UIApplication.topViewController()!
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

