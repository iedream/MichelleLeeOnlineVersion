//
//  sourceMethods.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-01-21.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

enum ConnectionState: Int{
    case WIFI
    case WWAN
    case NONE
}

class sourceMethods:UIViewController,AVAudioPlayerDelegate {
    
    // Singleton
    static let sharedInstance = sourceMethods()
    
    let mainQuery:MPMediaQuery = MPMediaQuery.init()
    
    var currentConnectionState:ConnectionState = ConnectionState.NONE
    var allowWWAN:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateLocalMusic()
        Variables.sharedInstance.writeToModifyPlist()
    }
    
    func runSearch(dic:NSMutableDictionary,title:String,type:MPMediaType,query:MPMediaQuery){
        
        for name in dic.allKeys{
            let namePredicate = MPMediaPropertyPredicate(value: name, forProperty: MPMediaItemPropertyTitle)
            let typePredicate = MPMediaPropertyPredicate(value: type.rawValue as NSNumber, forProperty: MPMediaItemPropertyMediaType)
            let playlistPredicate = MPMediaPropertyPredicate(value:title , forProperty: MPMediaItemPropertyAlbumTitle)
            query.addFilterPredicate(typePredicate)
            query.addFilterPredicate(namePredicate)
            var result:MPMediaItem = MPMediaItem()
            var resultURL:NSURL = NSURL()
            if(query.items?.count > 1){
                query.addFilterPredicate(playlistPredicate)
                if(query.items?.count == 1){
                    result = query.items![0]
                }
                resultURL = result.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
                dic.setValue(["local",resultURL.absoluteString], forKey: name as! String)
            }else if( query.items?.count == 1){
                result = query.items![0]
                resultURL = result.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
                dic.setValue(["local",resultURL.absoluteString], forKey: name as! String)
            }
            
            query.removeFilterPredicate(playlistPredicate)
            query.removeFilterPredicate(typePredicate)
            query.removeFilterPredicate(namePredicate)
        }
        
    }

    
    func populateLocalMusic(){
       
        
        for (title,subdic) in Variables.sharedInstance.allAmblum{
            runSearch(subdic as! NSMutableDictionary, title: title as! String, type: MPMediaType.Music, query: mainQuery)
        }
        
    }
    
    func populateLocalVideo(){
        
        for (name,subdic) in Variables.sharedInstance.allVideoPlayist{
            if(subdic.allValues[0] is NSArray){
                runSearch(subdic as! NSMutableDictionary, title: name as! String, type:MPMediaType.AnyVideo, query: mainQuery)
                
            }else if(subdic.allValues[0] is NSMutableDictionary){
                for (key,bottomDic) in subdic as! NSMutableDictionary{
                    runSearch(bottomDic as! NSMutableDictionary, title: key as! String, type: MPMediaType.AnyVideo, query: mainQuery)
                }
               
            }
        
            
        }
        
    }
        
    func populateOnlineMusic(){
        
    }
    
    func populateOnLineVideo(){
        
    }
    
    
}

