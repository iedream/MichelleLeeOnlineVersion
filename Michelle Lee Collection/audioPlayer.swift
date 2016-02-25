//
//  audioPlayer.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-13.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

enum AudioPlayerState : Int{
    case Play_Single
    case Play_Multi
    case Pause_Single
    case Pause_Multi
    case Not_Init
}


class audioPlayer:UIViewController,AVAudioPlayerDelegate,NSURLConnectionDelegate
{
    
    // Singleton
    static let sharedInstance = audioPlayer()
    
    // Player
    var player : AVAudioPlayer! = nil
    var pathName:String = String()

    // Slider
    var slider = UISlider()
    
    // Spinner
    var blurView:UIVisualEffectView!
    var progressBar:UIProgressView!
    var connection:NSURLConnection?
    
    // States
    var currentMode:AudioPlayerState = AudioPlayerState.Not_Init
    
    // Time Lables
    var currentTimeLable = UILabel()
    var endTimeLable = UILabel()
    
    // Video MV Button
    var mvButton:UIButton = UIButton()
    var videoDic:NSDictionary = Variables.sharedInstance.allAmblumVideos.copy() as! NSDictionary

    // Timer
    var timer = NSTimer()
    
    // Data
    var mainData:NSDictionary = NSDictionary()
    var mainDataOrder:NSArray = NSArray()
    var currentPath:NSArray = NSArray()
    var localMusicArray:NSArray = NSArray()
    var responseData:NSMutableData!
    var downloadSize:Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUpUIForPlayer(name:String){
        // If there is video for it, enable the mv button
        if((videoDic[name]) != nil){
            mvButton.alpha = 1.0
            mvButton.userInteractionEnabled = true
        }else{
            mvButton.alpha = 0.3
            mvButton.userInteractionEnabled = false
        }
        
        // Set Up Slider
        slider.userInteractionEnabled = true
        slider.alpha = 1.0
        slider.maximumValue = Float32(self.player.duration)
        
        // Start Time Lable
        currentTimeLable.alpha = 1.0
        currentTimeLable.text = "00:00"
        
        // Set up End Time Lable
        let minute:Double = floor(Double(slider.maximumValue)/60)
        let second:Double = Double(slider.maximumValue) - (minute*60)
        var minuteToDisplay = String()
        var secondToDisplay = String()
        if(minute >= 10)
        {
            minuteToDisplay = String(format: "%.0f", minute)
        }
        if(minute < 10)
        {
            minuteToDisplay = String(format: "0%0.0f",minute)
        }
        if(second >= 10)
        {
            secondToDisplay = String(format: "%.0f", second)
        }
        if(second < 10)
        {
            secondToDisplay = String(format: "0%0.0f",second)
        }
        endTimeLable.alpha = 1.0
        endTimeLable.text = String(format:"%@:%@",minuteToDisplay,secondToDisplay)
        endTimeLable.adjustsFontSizeToFitWidth = true

        //actually play the audio
        self.setAutoMode()
        self.play()
    }
    
    func initializePlayerWithFile(name:String){
        if(currentPath[0].isEqualToString("url")){
            if(sourceMethods.sharedInstance.CellularNotAllow()){
                //pop up message telling user 3g is not allowed
                let alert:UIAlertView = UIAlertView(title: "3G not allowed", message: "Not allowed to play with 3G connection, please turn on allow 3G", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }else if(!sourceMethods.sharedInstance.ConnectionAvailable()){
                //pop up message saying no internet connection is detected
                let alert:UIAlertView = UIAlertView(title: "No Internet Connect", message: "Cannot detect WiFi or 3G, Please check your connection", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                //self.currentPathInvalid()
            }else if(sourceMethods.sharedInstance.ConnectionAvailable()){
                blurView.hidden = false
                progressBar.hidden = false
                progressBar.progress = 0.0
                connection?.cancel()
                self.clearResponseData()
                
                /*spinner.startAnimating()
                blurEffect.hidden = false
                
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue()) {
                    //put your code which should be executed with a delay here
                    let myURL:NSURL = NSURL(string: self.currentPath[1] as! String)!
                    let playerItem:NSData = NSData(contentsOfURL: myURL)!
                    do{
                        self.player = try AVAudioPlayer(data: playerItem)
                    }catch{
                        //Handle the error
                        let alert:UIAlertView = UIAlertView(title: "URL Connection Fail", message: "The URL for the mp3 is no longer valid", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                        //self.currentPathInvalid()
                    }
                    self.spinner.stopAnimating()
                    self.blurEffect.hidden = true
                    self.setUpUIForPlayer(name)
                }*/
                pathName = name
                let myURL:NSURL = NSURL(string: self.currentPath[1] as! String)!
                let request:NSURLRequest = NSURLRequest.init(URL: myURL)
                connection = NSURLConnection.init(request: request, delegate: self, startImmediately: true)!
            }
        }else if(currentPath[0].isEqualToString("local")){
            do{
                let myURL:NSURL = NSURL(string: currentPath[1] as! String)!
                player = try AVAudioPlayer(contentsOfURL: myURL)
            } catch{
                //Handle the error
                let alert:UIAlertView = UIAlertView(title: "Cannot found file", message: "Cannot find the mp3 in your local Ipod Library", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                //self.currentPathInvalid()
            }
            pathName = name
            self.setUpUIForPlayer(name)
        }
    }
    
    // Set Up player
    func setUpPlayer(name:String , objectToBePlay:NSArray, actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel, videoButton:UIButton,actSpinner:UIProgressView,actblurEffect:UIVisualEffectView){
        // Assign View Property
        slider = actSlider
        blurView = actblurEffect
        progressBar = actSpinner
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        mvButton = videoButton
        currentPath = objectToBePlay
        self.initializePlayerWithFile(name)
    }
    

    func setDatas(oriMainData:NSDictionary){
        if(!oriMainData.isEqual(mainData)){
            mainData = oriMainData
            mainDataOrder = mainData.allValues
            self.populatLocalSongs()
        }
    }
    
    func setAutoMode(){
        if( currentMode == AudioPlayerState.Not_Init){
            currentMode = AudioPlayerState.Play_Multi
        }else if(currentMode == AudioPlayerState.Pause_Single){
                currentMode = AudioPlayerState.Play_Single
        }else if(currentMode == AudioPlayerState.Pause_Multi){
                currentMode = AudioPlayerState.Play_Multi
        }
    }
    
    // Update the Current Time Lable
    func update(){
        // If not currently srubbing then update the slider to the right position
        if(currentMode == AudioPlayerState.Play_Single || currentMode == AudioPlayerState.Play_Multi){
            slider.value = Float(player.currentTime)
            
            // Converting to time formate
            var minute:Double   = Double(floorf(slider.value/60))
            let second:Double   = Double(slider.value) - (minute*60)
            var minuteToDisplay = String()
            var secondToDisplay = String()
            
            
            // Decide how to display
            
            if(roundf(Float(second)) == 60 )
            {
                secondToDisplay = "00"
                minute = minute + 1;
            }else if(roundf(Float(second)) >= 10)
            {
                secondToDisplay = String(format: "%.0f", second)
            }else if(roundf(Float(second)) < 10)
            {
                secondToDisplay = String(format: "0%.0f",second)
            }
            
            
            if(minute >= 10)
            {
                minuteToDisplay = String(format: "%.0f", minute)
            }else if(minute < 10)
            {
                minuteToDisplay = String(format: "0%.0f",minute)
            }
            
            // Update the Current Time lable
            currentTimeLable.text = String(format:"%@:%@",minuteToDisplay,secondToDisplay)
        }
    }
    
    // setMode
    func setMode(state:AudioPlayerState){
        if(state == AudioPlayerState.Pause_Single || state == AudioPlayerState.Pause_Multi){
            player.pause()
        }
       currentMode = state
    }
    
    // Play Audio
    func play(){
        // Set Player
        player.prepareToPlay()
        player.play()
        
        // Set Current Mode
        self.setAutoMode()
        
        // Set Delegate for Player
        player.delegate = self
        
        // Set up Timer to update Current Time Lable
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    // Pause Audio
    func pause(){
        player.pause()
        timer.invalidate()
    }
    
    func playAtTime(actSlider:UISlider){
        // assign slider
        slider = actSlider
        
        // Set Player
        player.prepareToPlay()
        player.currentTime = Double(slider.value)
        player.play()
        
        // Set Current Mode
        self.setAutoMode()
        
        // Set up Timer to update Current Time Lable
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.getNextSong()
    }
    
    /*func currentPathInvalid(){
        if(currentMode != AUDIO_PLAYER_PLAY_MULTIPLE && currentMode != AUDIO_PLAYER_PLAY_SINGLE){
            self.setAutoMode()
            self.getNextSong()
        }
    }*/
    
    private func getNextSong(){
        switch(currentMode){
        case AudioPlayerState.Play_Multi:
            
            if(!sourceMethods.sharedInstance.ConnectionAvailable()){
                // Get Current Index
                var begIndex:NSInteger = NSInteger()
                // Get Index of New Path
                var index:NSInteger = NSInteger()
                
                // Get Current Index
                if(localMusicArray.count >= 1){
                    if(localMusicArray.containsObject(currentPath)){
                        begIndex = localMusicArray.indexOfObject(currentPath)
                        index = getIndex(localMusicArray, currentIndex: begIndex)
                    }else{
                        index = 0
                    }
                    // Get Next Video Path and give it to the player to set the player up
                    currentPath = localMusicArray.objectAtIndex(index) as! NSArray
                    self.initializePlayerWithFile(mainData.allKeysForObject(currentPath).first as! String)
                }else{
                    let alert:UIAlertView = UIAlertView(title: "No Local Music", message: "No mp3 in the amblum is in your local Ipod Library", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    self.clearPlayer(slider, actCurrentLabel: currentTimeLable, actEndLabel: endTimeLable)
                }
                
            }else{
                // Get Current Index
                let begIndex:NSInteger = mainDataOrder.indexOfObject(currentPath)
                // Get Index of New Path
                let index:NSInteger = getIndex(mainDataOrder, currentIndex: begIndex)

                // Get Next Video Path and give it to the player to set the player up
                currentPath = mainDataOrder.objectAtIndex(index) as! NSArray
                self.initializePlayerWithFile(mainData.allKeysForObject(currentPath).first as! String)
            }
            
            break
        case AudioPlayerState.Play_Single:
            if(sourceMethods.sharedInstance.ConnectionAvailable()){
                // Give the current Video Path to the player and set the player up
                self.initializePlayerWithFile(mainData.allKeysForObject(currentPath).first as! String)
            }else{
                let alert:UIAlertView = UIAlertView(title: "Cannot Play Song", message: "The song you are playing requires internet connection.", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                self.clearPlayer(slider, actCurrentLabel: currentTimeLable, actEndLabel: endTimeLable)
            }
            break
        default:
            break
        }

    }
    
    func getIndex(data:NSArray,currentIndex:NSInteger) -> NSInteger{
        if(currentIndex+1 >= data.count){
            return 0
        }else{
            return currentIndex+1
        }
    }
    
    func populatLocalSongs(){
        //localMusicArray = NSMutableArray(array:mainData.allValues)
        let predicate: NSPredicate = NSPredicate { (AnyObject array, NSDictionary bindings) -> Bool in
            let mainDataArray:NSArray = array as! NSArray
            if(mainDataArray[0].isEqualToString("local")){
                return true
            }
            return false
        }
        localMusicArray = mainData.allValues.filter({predicate.evaluateWithObject($0)})

    }
        
    func setAudioAtBeginning(actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel, actSpinner:UIProgressView,actBlurEffect:UIVisualEffectView){
        // Assign View Property
        blurView = actBlurEffect
        progressBar = actSpinner
        slider = actSlider
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        
        // Set Up Slider
        slider.userInteractionEnabled = false
        slider.setValue(0, animated: true)
        slider.alpha = 0.3
        
        // Set Up Label
        currentTimeLable.text = ""
        endTimeLable.text = ""
        
        self.setMode(AudioPlayerState.Not_Init)
    }
    
    // Clear Audio Player
    func clearPlayer(actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel){
        slider = actSlider
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        
        self.setMode(AudioPlayerState.Not_Init)
        
        // Disable the Player
        player = nil
        
        // Remove Timer
        timer.invalidate()
        
        if(connection != nil){
            connection!.cancel()
        }
        self.clearResponseData()
        

        
        // Disable Slider
        slider.userInteractionEnabled = false
        slider.setValue(0, animated: true)
        
        // Clear Time Lable
        currentTimeLable.text = ""
        endTimeLable.text = ""
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        responseData = NSMutableData.init()
        
        let responseRes:NSHTTPURLResponse = response as! NSHTTPURLResponse
        
        if(responseRes.statusCode == 200){
            downloadSize = Float.init(responseRes.expectedContentLength)
        }else{
            connection.cancel()
            let alert:UIAlertView = UIAlertView(title: "Audio Source No Longer Exist", message: "The audio source no longer exist. Please contact app owner for an update.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            progressBar.hidden = true
            blurView.hidden = true
        }
    }

    func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
        // Append the recieved chunk of data to our data object
        responseData.appendData(conData)
        progressBar.progress =  Float.init(responseData.length)/downloadSize
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.connection = nil
        progressBar.hidden = true
        blurView.hidden = true
        do{
            let playerData = NSData.init(data: responseData)
            self.clearResponseData()
            self.player = try AVAudioPlayer(data: playerData)
        }catch{
            //Handle the error
            let alert:UIAlertView = UIAlertView(title: "Stream Audio Failed", message: "The Audio cannot be loaded.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }

        self.setUpUIForPlayer(pathName)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.connection = nil
        self.clearResponseData()
        progressBar.hidden = true
        blurView.hidden = true
        //Handle the error
        let alert:UIAlertView = UIAlertView(title: "Stream Audio Failed", message: "The Audio cannot be loaded.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func clearResponseData(){
        if(responseData != nil){
            responseData.length = 0
        }
    }
}

