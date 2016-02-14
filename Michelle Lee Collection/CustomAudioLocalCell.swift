//
//  CustomAudioLocalCell.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-02-13.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit

public class CustomAudioCell: UITableViewCell{
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.textColor = UIColor.whiteColor()
    }
    
    public func setCellAlpha(set:Bool){
        if(!sourceMethods.sharedInstance.ConnectionAvailable() && set){
            self.textLabel?.alpha = 0.3
        }else{
            self.textLabel?.alpha = 1.0
        }
    }
}

/*public class CustomAudioURLCell: UITableViewCell{
    public override func layoutSubviews() {
        super.layoutSubviews()
        if( sourceMethods.sharedInstance.ConnectionAvailable()){
            self.alpha = 1.0
        }else{
            self.alpha = 0.3
        }
        self.backgroundColor = UIColor.clearColor()
        self.textLabel?.backgroundColor = UIColor.clearColor()
        self.textLabel?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.textColor = UIColor.whiteColor()
    }
}*/

public class CollectionViewCell: UICollectionViewCell{
    var imageView:UIImageView = UIImageView.init()
    let textLabel:UILabel = UILabel.init()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create text label
        textLabel.textColor = UIColor.whiteColor()
        textLabel.backgroundColor  = UIColor.clearColor()
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.bounds.height - self.contentView.bounds.height/4, self.contentView.bounds.width, self.contentView.bounds.height/4)
        
        // Create image view
        imageView.frame = self.contentView.bounds
        imageView.addSubview(textLabel)
        self.contentView.addSubview(imageView)
    }
    
    public func setCellAlpha(set:Bool){
        if(!sourceMethods.sharedInstance.ConnectionAvailable() && set){
            self.alpha = 0.3
        }else{
            self.alpha = 1.0
        }
    }
}

