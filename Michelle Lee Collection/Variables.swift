//
//  Variables.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-01-21.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit

class Variables:UIViewController{
    
    // Singleton
    static let sharedInstance = Variables()
    
    // List Declarations
    var allAmblum = NSMutableDictionary()
    var allAmblumVideos = NSMutableDictionary()
    var allVideoPlayist = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // Read List from Plist
    func populatePlayListFromPlist(var list:String){
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(list)
        let fileMananger = NSFileManager.defaultManager()
        if(!fileMananger.fileExistsAtPath(fileURL.path!)){
            list = list.stringByReplacingOccurrencesOfString(".plist", withString: "")
            if let bundlePath = NSBundle.mainBundle().pathForResource(list, ofType: "plist"){
                do{
                    try fileMananger.copyItemAtPath(bundlePath, toPath: fileURL.path!)
                }catch{
                    
                }
            }
        }
        let resultDictionary:NSMutableArray = NSMutableArray(contentsOfFile: fileURL.path!)!
        allAmblum = resultDictionary.objectAtIndex(0) as! NSMutableDictionary
        allVideoPlayist = resultDictionary.objectAtIndex(1) as! NSMutableDictionary
        allAmblumVideos = resultDictionary.objectAtIndex(2) as! NSMutableDictionary
        
        if(list == "OriginalPlayist.plist"){
            sourceMethods.sharedInstance.populateLocalMusic()
            sourceMethods.sharedInstance.populateLocalVideo()
            writeToModifyPlist()
        }
    }
    
    
    // Write to Modified Plist
    func writeToModifyPlist(){
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("ModifiedPlayist.plist")
        let array:NSMutableArray = NSMutableArray.init(array: [allAmblum,allVideoPlayist,allAmblumVideos])
        array.writeToFile(fileURL.path!, atomically: false)
    }
}
