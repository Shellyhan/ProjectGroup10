//
//  ProfileViewExtension.swift
//  ACTIVESFU
//
//  An extension file that sets up the activity indicator when uploading a new profile picture or username.
//
//  Created by Nathan Cheung on 2017-03-27.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

extension ProfileViewController {
    
    
    func showActivityIndicator(uiView: UIView) {
        
        activityContainer.frame = uiView.frame
        activityContainer.center = uiView.center
        activityContainer.backgroundColor = UIColor(colorWithHexValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor(colorWithHexValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        
        loadingView.addSubview(activityIndicator)
        activityContainer.addSubview(loadingView)
        uiView.addSubview(activityContainer)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        activityContainer.removeFromSuperview()
    }
}
