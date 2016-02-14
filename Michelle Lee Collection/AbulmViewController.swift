//
//  AbulmViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-12.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AbulmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate {
    
    // AudioPlayerProperty
    @IBOutlet var audioView: UIView!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var singleRotateButton: UIButton!
    @IBOutlet var multipleRotateButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!


    
    // AudioPlayer States
    var currentMode:AudioPlayerState = AudioPlayerState.Not_Init
    
    // Table View Property
    //let tableViewCellIdentifier = "audioTableViewCell"
    @IBOutlet var audioTableView: UITableView!
    
    // Picker View Property
    @IBOutlet var pickerView: UIPickerView!
    var pickerViewData:[String] = [String]()
    
    // Search View
    @IBOutlet var txtFiled: UITextField!
    
    // Table Data
    var tableTitleArray:NSMutableArray = NSMutableArray()
    var currentDic:NSMutableDictionary = NSMutableDictionary()
    var objectToBePlayed:NSArray = NSArray()
    
    // Video Data
    @IBOutlet var mvButton: UIButton!
    @IBOutlet var clearVideoButton: UIButton!
    @IBOutlet var videoPlayerView: UIView!
    var isFullScreen:Bool = false
    var timer:NSTimer = NSTimer()
    @IBOutlet var noResult: UILabel!
    //let videoDic:[String:String] = ["你看到的我是蓝色的":"video121","可能":"video120","沉淀":"video122","习惯":"video123"]
    var videoObserver:NSObjectProtocol! = nil
    
    // Screen SetUp Property
    @IBOutlet var background: UIImageView!
    
    
    override func viewDidLoad() {
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            
        }
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        super.viewDidLoad()
        
        tableTitleArray = NSMutableArray.init(array: Variables.sharedInstance.allAmblum.allKeys)
        
        audioView.backgroundColor = UIColor.clearColor()
        audioView.layer.borderColor = UIColor.whiteColor().CGColor
        audioView.layer.borderWidth = 1.0
        
        currentTimeLabel.textColor = UIColor.whiteColor()
        endTimeLabel.textColor = UIColor.whiteColor()
        
        
        audioTableView.backgroundColor = UIColor.clearColor()
        audioTableView.delegate = self
        audioTableView.dataSource = self
        //audioTableView.registerClass(CustomAudioLocalCell.classForCoder(), forCellReuseIdentifier: "AudioLocal")
        //audioTableView.registerClass(CustomAudioURLCell.classForCoder(), forCellReuseIdentifier: "AudioURL")
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.hidden = true
        
        videoPlayerView.hidden = true
        clearVideoButton.hidden = true
    
        
        noResult.adjustsFontSizeToFitWidth = true
        noResult.backgroundColor = UIColor.redColor()
        noResult.hidden = true
        
        blurEffectView.hidden = true

        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("updateFullScreenState"), userInfo: nil, repeats: true)
        
        // All Button Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton,mvButton]
        let activeButton:[UIButton] = [];
        self.buttonActiveandInactive(activeButton, inactiveButtons:inactiveButton)
        audioPlayer.sharedInstance.setAudioAtBeginning(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, actSpinner: spinnerView, actBlurEffect: blurEffectView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -Populate Table Methods -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = audioTableView.dequeueReusableCellWithIdentifier("CustomAudioCell", forIndexPath: indexPath) as! CustomAudioCell
        let row = indexPath.row
        if(currentDic.count != 0 && (currentDic[tableTitleArray[row] as! String] as! NSArray)[0] as! String == "url"){
            cell.setCellAlpha(true)
        }else{
            cell.setCellAlpha(false)
        }
        if(tableTitleArray.count != 0){
            cell.textLabel?.text = tableTitleArray.objectAtIndex(row) as? String
        }
        
        return cell
    }
    
    // MARK: - Actions When Table View Cell Selected -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        audioTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        let name:String = tableTitleArray.objectAtIndex(row) as! String
        noResult.hidden = true
        
        // if the count equals, then still at main menu, so clear table view and populate it with sub menu, and assign correct properties
        // if the cound doesn't equals, then in sub menu, so set up player and properties, and change audio view
        if(tableTitleArray.count == Variables.sharedInstance.allAmblum.count){ // Set Property
            currentDic.removeAllObjects()
            currentDic = NSMutableDictionary.init(dictionary:Variables.sharedInstance.allAmblum.objectForKey(name) as! NSDictionary )
            
            // Set Audio Player Property
            audioPlayer.sharedInstance.setDatas(currentDic.copy() as! NSDictionary)
            
            // Clear Table View and Reload
            tableTitleArray.removeAllObjects()
            tableTitleArray = NSMutableArray.init(array: ((Variables.sharedInstance.allAmblum.objectForKey(name))?.allKeys)!)
            audioTableView.reloadData()
        }else{
            objectToBePlayed = currentDic.objectForKey(name) as! NSArray
            
            
            // Set Up Audio Player, Audio Player Mode, Audio Player Property
            audioPlayer.sharedInstance.setUpPlayer(name, objectToBePlay: objectToBePlayed, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: spinnerView,actblurEffect: blurEffectView)
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }
        
        
        
    }
    
    // MARK: - Populate Picker View Methods -
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    // MARK: - Picker View Cell Selected -
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let name:String = pickerViewData[row];
        let subDict:NSDictionary = Variables.sharedInstance.allAmblum.objectForKey(name) as! NSDictionary
        currentDic.removeAllObjects()
        currentDic = NSMutableDictionary.init(dictionary:subDict)
        
        // Set Audio Player Property
        audioPlayer.sharedInstance.setDatas(currentDic)
        
        // Set Up Audio Player, Audio Player Mode, Audio Player Property
        let subName:String = (txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
        audioPlayer.sharedInstance.setUpPlayer(subName, objectToBePlay: subDict.objectForKey(subName) as! NSArray, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: spinnerView,actblurEffect: blurEffectView)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [pauseButton,singleRotateButton]
        let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        
        pickerViewData.removeAll()
        pickerView.reloadComponent(0)
        pickerView.hidden = true
        
    }
    
    // MARK: - Function Button Method -
    
    // Go Back to main screen and reset everything in this screen
    @IBAction func goHome(sender: UIButton) {
        
        timer.invalidate()
        
        // Clear Video Player
        videoPlayer.sharedInstance.clear()
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        
        // Clear audio player
        audioPlayer.sharedInstance.clearPlayer(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel)
        
        // All Buttons Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    // Go Back to main menu
    @IBAction func backToHomeMenu(sender: AnyObject) {
        noResult.hidden = true
        tableTitleArray.removeAllObjects()
        currentDic.removeAllObjects()
        tableTitleArray = NSMutableArray.init(array:Variables.sharedInstance.allAmblum.allKeys)
        audioTableView.reloadData()
    }
    
    // MARK: - Audio Player Button Method -
    
    // call play audio method in audio player class
    @IBAction func playAudio(sender: AnyObject) {
        // set audio player
        audioPlayer.sharedInstance.play()
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [pauseButton]
        let unactiveButton:[UIButton] = [playButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // call pause audio method in audio player class
    @IBAction func pauseAudio(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Play_Multi){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Multi)
        }else if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Pause_Single){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Single)
        }
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [playButton]
        let unactiveButton:[UIButton] = [pauseButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set multiple rotation in audio player class
    @IBAction func setMultipleRotateMode(sender: AnyObject) {
        // assign audio player mode
        audioPlayer.sharedInstance.setMode(AudioPlayerState.Play_Multi)
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [singleRotateButton]
        let unactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set single rotation in audio player class
    @IBAction func setSingleRotateMode(sender: AnyObject) {
        // assign audio player mode
        audioPlayer.sharedInstance.setMode(AudioPlayerState.Play_Single)
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [multipleRotateButton]
        let unactiveButton:[UIButton] = [singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set user scrubbing in audio player class
    @IBAction func userScrubbing(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Play_Multi){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Multi)
        }else if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Play_Single){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Single)
        }
    }
    
    // set player to play from a certain time in audio player class
    @IBAction func setCurrentAudioTime(sender: AnyObject) {
        audioPlayer.sharedInstance.playAtTime(slider)
    }
    
    // MARK: -  search for songs -
    
    // search for songs
    @IBAction func searchForSongs(sender: AnyObject) {
        let txtFieldText:String = (txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
        var results:[String:[String:NSArray]] = [String:[String:NSArray]]()
        for(key,value) in Variables.sharedInstance.allAmblum{
            for(name,path) in value as! NSMutableDictionary{
                if(name as! String == txtFieldText){
                    results[key as! String] = [name as! String:path as! NSArray]
                }
            }
        }
        
        // if there is only one result, then play that one
        if(results.count == 1){
            let resultsDic:[String:NSArray] = Array(results.values).first!
            let dict:[String:NSArray] = [String:NSArray](dictionaryLiteral: resultsDic.first!)
            
            currentDic.removeAllObjects()
            currentDic = NSMutableDictionary.init(dictionary: Variables.sharedInstance.allAmblum.objectForKey(results.keys.first!)! as! NSDictionary)
            
            // Set Up Audio Player, Audio Player Mode, Audio Player Property
            audioPlayer.sharedInstance.setDatas(currentDic)
            audioPlayer.sharedInstance.setUpPlayer(txtFieldText, objectToBePlay: dict[txtFieldText]!, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: spinnerView,actblurEffect: blurEffectView)
    
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }else if(results.count > 1){
            pickerView.hidden = false
            pickerViewData = [String](results.keys)
            pickerView.reloadComponent(0)
        }else if(results.count == 0){
            noResult.text = "No Result For " + (txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            noResult.hidden = false
        }
        txtFiled.resignFirstResponder()
    }
    
    // MARK: - video Button Method -
    
    @IBAction func playVideo(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Play_Multi){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Multi)
        }else if(audioPlayer.sharedInstance.currentMode == AudioPlayerState.Play_Single){
            audioPlayer.sharedInstance.setMode(AudioPlayerState.Pause_Single)
        }
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [playButton]
        let unactiveButton:[UIButton] = [pauseButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
        
        clearVideoButton.hidden = false
        
        let name:String = currentDic.allKeysForObject(objectToBePlayed).first as! String
        videoPlayer.sharedInstance.playVideo(Variables.sharedInstance.allAmblumVideos[name] as! NSArray)
        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        videoPlayer.sharedInstance.player?.play()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        videoObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { _ in
            
            videoPlayer.sharedInstance.player?.replaceCurrentItemWithPlayerItem(nil)
            videoPlayer.sharedInstance.view.removeFromSuperview()
            videoPlayer.sharedInstance.path = nil
            self.clearVideoButton.hidden = true
        }
    }
    
    @IBAction func clearVideo(sender: AnyObject) {
        videoPlayer.sharedInstance.clear()
        clearVideoButton.hidden = true
    }
    
    
    // MARK: - Helper Methods -
    func buttonActiveandInactive(activeButtons:[UIButton], inactiveButtons:[UIButton]){
        for button:UIButton in activeButtons{
            button.alpha = 1.0
            button.userInteractionEnabled = true
        }
        for button:UIButton in inactiveButtons{
            button.alpha = 0.3
            button.userInteractionEnabled = false
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldReturn(sender: AnyObject){
        sender.resignFirstResponder()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if(isFullScreen){
            if(UIDevice.currentDevice().orientation.isLandscape){
                return UIInterfaceOrientationMask.Landscape
            }else{
                return UIInterfaceOrientationMask.Portrait
            }
            
        }else{
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    func rotateScreenBackToPortrait(){
        
        videoPlayer.sharedInstance.view.removeFromSuperview()
        videoPlayer.sharedInstance.view.frame = videoPlayerView.frame
        self.view.addSubview(videoPlayer.sharedInstance.view)
    }
    
    func updateFullScreenState(){
        
        var fullScreenView:Bool = false
        if(videoPlayer.sharedInstance.videoBounds.width == self.view.frame.width){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.width == self.view.frame.height){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.height == self.view.frame.width){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.height == self.view.frame.height){
            fullScreenView = true
        }
        
        
        if(videoPlayer.sharedInstance.view != nil && fullScreenView ){
            isFullScreen = true
            
        }else{
            if(isFullScreen && UIDevice.currentDevice().orientation.isLandscape){
                isFullScreen = false
                UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
                _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("rotateScreenBackToPortrait"), userInfo: nil, repeats: false)
            }else if(isFullScreen && UIDevice.currentDevice().orientation.isPortrait){
                isFullScreen = false
                rotateScreenBackToPortrait()
            }
        }
    }

    
}
