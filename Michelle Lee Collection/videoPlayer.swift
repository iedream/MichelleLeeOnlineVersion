//
//  videoPlayer.swift
//  Michelle
//
//  Created by Catherine Zhao on 2015-06-29.
//  Copyright (c) 2015 Catherine. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AVKit
import MediaPlayer

enum AVPlayerActionAtItemEnd : Int {
    case Advance
    case Pause
    case None
}

class videoPlayer: AVPlayerViewController {
    
    // Singleton
    static let sharedInstance = videoPlayer()
    
    //video player
    var path = NSBundle.mainBundle().pathForResource("hi", ofType:"mp4")
    var timer:NSTimer = NSTimer()
    
    
    // Video Player Data
    var videoData:NSArray = NSArray()
    var videoObserver:NSObjectProtocol! = nil
    var currentPathName:NSArray = NSArray()
    var localVideoArray:NSArray = NSArray()
    
    // Video Player State
    let Single_Rotate:NSInteger = 0
    let Multiple_Rotate:NSInteger = 1
    var currentState:NSInteger = 2
    
    override func viewDidLoad() {
    }
    
    func setVideoData(videoData:NSArray, frame:CGRect){
        self.videoData = videoData
        self.populatLocalVideos()
        self.view.frame = frame
    }
    
    func playVideo(videoArr:NSArray){
        
        if(videoArr[0].isEqualToString("local")){
            currentPathName = videoArr
            let finalpath:NSURL = NSURL(string: videoArr[1] as! String)!
            player = AVPlayer(URL: finalpath)
            player?.play()
        }else{
            if( sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WWAN && sourceMethods.sharedInstance.allowWWAN == false){
                let alert:UIAlertView = UIAlertView(title: "3G not allowed", message: "Not allowed to play with 3G connection, please turn on allow 3G", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }else if(sourceMethods.sharedInstance.currentConnectionState == ConnectionState.NONE){
                let alert:UIAlertView = UIAlertView(title: "No Internet Connect", message: "Cannot detect WiFi or 3G, Please check your connection", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }else if((sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WWAN && sourceMethods.sharedInstance.allowWWAN == true) || (sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WIFI)){
                currentPathName = videoArr
                let myURL:NSURL = NSURL(string: videoArr[1] as! String)!
                player = AVPlayer(URL: myURL)
                player?.play()
            }
        }

    }
    
    func addObserverForVideo(){
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        videoObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { _ in
            
            var newRow:NSInteger = self.videoData.indexOfObject(self.currentPathName) + 1
            if( newRow >= self.videoData.count){
                newRow = 0
            }
            
            if((sourceMethods.sharedInstance.allowWWAN == true && sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WWAN) || sourceMethods.sharedInstance.currentConnectionState == ConnectionState.WIFI){
                if( self.currentState == self.Multiple_Rotate){
                    self.playVideo(self.videoData[newRow] as! NSArray)
                    self.player!.play()
                }else if(self.currentState == self.Single_Rotate){
                    self.playVideo(self.videoData[self.videoData.indexOfObject(self.currentPathName)] as! NSArray)
                    self.player!.play()
                }
            }else{
                if(self.currentState == self.Multiple_Rotate){
                    // Get Index of New Path
                    var index:NSInteger = NSInteger()
                    if(self.localVideoArray.count >= 1){
                        if(self.localVideoArray.containsObject(self.currentPathName)){
                            index = self.localVideoArray.indexOfObject(self.currentPathName) + 1
                            if(index >= self.localVideoArray.count){
                                index = 0
                            }
                        }else{
                            index = 0
                        }
                        // Get Next Video Path and give it to the player to set the player up
                        self.currentPathName = self.localVideoArray.objectAtIndex(index) as! NSArray
                        self.playVideo(self.currentPathName)
                    }else{
                        let alert:UIAlertView = UIAlertView(title: "No Local Music", message: "No mp3 in the amblum is in your local Ipod Library", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                }
                else if(self.currentState == self.Single_Rotate){
                    let alert:UIAlertView = UIAlertView(title: "Cannot Play Video", message: "The video you are playing requires internet connection.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
    
    func populatLocalVideos(){
        let predicate: NSPredicate = NSPredicate { (AnyObject array, NSDictionary bindings) -> Bool in
            let mainDataArray:NSArray = array as! NSArray
            if(mainDataArray[0].isEqualToString("local")){
                return true
            }
            return false
        }
        self.localVideoArray = self.videoData.filter({predicate.evaluateWithObject($0)})
    }
    
    
    func setMode(state:NSInteger){
        currentState = state
    }
    
    func clear(){
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        path = nil
        player?.replaceCurrentItemWithPlayerItem(nil)
        self.view.removeFromSuperview()
    }
}