//
//  AppearanceControl.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-02-12.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit

struct AppearanceControl {
    static func grayOutTableCell(){
        if(sourceMethods.sharedInstance.currentConnectionState == ConnectionState.NONE || (sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WWAN && sourceMethods.sharedInstance.allowWWAN)){
            
            AudioCell.appearance().imageViewAlpha = 0.3
            CollectionViewCell.appearance().imageViewAlpha = 0.4
        }else{
            AudioCell.appearance().imageViewAlpha = 1.0
            CollectionViewCell.appearance().imageViewAlpha = 1.0
        }
    }
}