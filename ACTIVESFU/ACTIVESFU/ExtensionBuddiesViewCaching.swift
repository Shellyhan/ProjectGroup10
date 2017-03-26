//
//  BuddiesViewCaching.swift
//  ACTIVESFU
//
//
//
//  Caches all images in buddiesview so the app is not constantly downloading + leading to bugs
//
//  Created by Nathan Cheung on 2017-03-26.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    

    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            
            self.image = cachedImage as! UIImage
            return
        }
        
        //otherwise, new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
                
            }
            
        }).resume()
        
    }
}
