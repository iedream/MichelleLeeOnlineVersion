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
    
    // Ipod Library Files
    private let mainQuery:MPMediaQuery = MPMediaQuery.init()
    
    // Connection Related Properties
    private var currentConnectionState:ConnectionState = ConnectionState.NONE
    var allowWWAN:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Setters For Current State
    func setCurrentConnectState(state:ConnectionState){
        if(state == ConnectionState.NONE && (currentConnectionState == ConnectionState.WIFI || currentConnectionState == ConnectionState.WWAN)){
            NSNotificationCenter.defaultCenter().postNotificationName("connectionStateChange", object: nil)
        }else if((state == ConnectionState.WIFI || state == ConnectionState.WWAN) && currentConnectionState == ConnectionState.NONE){
            NSNotificationCenter.defaultCenter().postNotificationName("connectionStateChange", object: nil)
        }
        currentConnectionState = state
    }
    
    // Getters For Current State
    func ConnectionAvailable() -> Bool{
        if((currentConnectionState == ConnectionState.WWAN && allowWWAN == true) || currentConnectionState == ConnectionState.WIFI){
            return true
        }
        return false
    }
    
    func CellularNotAllow() -> Bool{
        if(currentConnectionState == ConnectionState.WWAN && !allowWWAN){
            return true
        }
        return false
    }
    
    // Goes through all Ipod Library Files and grab what we need to put be dictionary
    private func runSearch(dic:NSMutableDictionary,title:String,type:MPMediaType,query:MPMediaQuery){
        
        for name in dic.allKeys{
            
            // Declare different type of predicate
            let namePredicate = MPMediaPropertyPredicate(value: name, forProperty: MPMediaItemPropertyTitle)
            let typePredicate = MPMediaPropertyPredicate(value: type.rawValue as NSNumber, forProperty: MPMediaItemPropertyMediaType)
            let playlistPredicate = MPMediaPropertyPredicate(value:title , forProperty: MPMediaItemPropertyAlbumTitle)
            
            // Add different predicate to filter
            query.addFilterPredicate(typePredicate)
            query.addFilterPredicate(namePredicate)
            
            // Variable declaration
            var result:MPMediaItem!
            var resultURL:NSURL = NSURL()
            
            // If there is more than one result, check for albulm title, if find, populate Result
            if(query.items?.count > 1){
                query.addFilterPredicate(playlistPredicate)
                if(query.items?.count == 1){
                    result = query.items![0]
                }
            // If there is one result, populate Result
            }else if( query.items?.count == 1){
                result = query.items![0]
            }
            // Add result to dic
            if(result != nil){
                resultURL = result.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
                dic.setValue(["local",resultURL.absoluteString], forKey: name as! String)
            }
            
            // Remove all filter so query is back to original
            query.removeFilterPredicate(playlistPredicate)
            query.removeFilterPredicate(typePredicate)
            query.removeFilterPredicate(namePredicate)
        }
        
    }

    // Check for Local Audio Source
    func populateLocalMusic(){
        for (title,subdic) in Variables.sharedInstance.allAmblum{
            runSearch(subdic as! NSMutableDictionary, title: title as! String, type: MPMediaType.Music, query: mainQuery)
        }
    }
    
    func populateMusicVideo() {
        runSearch(Variables.sharedInstance.allAmblumVideos, title: "", type: MPMediaType.AnyVideo, query: mainQuery)
    }
    
    // Check for Local Video Source
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
}

