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
import MediaPlayer

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

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var progressBar: UIProgressView!

    
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
    //var tableTitleArray:NSMutableArray = NSMutableArray()
    //var currentDic:NSMutableDictionary = NSMutableDictionary()
    var subTitle:String = ""
    var mainDic:NSDictionary!
    var objectToBePlayed:NSArray = NSArray()
    
    // Video Data
    @IBOutlet var mvButton: UIButton!
    @IBOutlet var clearVideoButton: UIButton!
    @IBOutlet var videoPlayerView: UIView!
    var isFullScreen:Bool = false
    var timer:NSTimer = NSTimer()
    @IBOutlet var noResult: UILabel!
    var videoObserver:NSObjectProtocol! = nil
    
    // Screen SetUp Property
    @IBOutlet var background: UIImageView!
    
    let commandCenter:MPRemoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: "connectionStateChange", object: nil)
        
        mainDic = Variables.sharedInstance.allAmblum
        //tableTitleArray = NSMutableArray.init(array: Variables.sharedInstance.allAmblum.allKeys)
        
        audioView.backgroundColor = UIColor.clearColor()
        audioView.layer.borderColor = UIColor.whiteColor().CGColor
        audioView.layer.borderWidth = 1.0
        
        currentTimeLabel.textColor = UIColor.whiteColor()
        endTimeLabel.textColor = UIColor.whiteColor()
        
        
        audioTableView.backgroundColor = UIColor.clearColor()
        audioTableView.delegate = self
        audioTableView.dataSource = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.hidden = true
        pickerView.backgroundColor = UIColor.clearColor()
        
        videoPlayerView.hidden = true
        clearVideoButton.hidden = true
    
        blurView.hidden = true
        progressBar.hidden = true
        
        noResult.adjustsFontSizeToFitWidth = true
        noResult.backgroundColor = UIColor.redColor()
        noResult.hidden = true
        
        
        // All Button Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton,mvButton]
        let activeButton:[UIButton] = [];
        self.buttonActiveandInactive(activeButton, inactiveButtons:inactiveButton)
        audioPlayer.sharedInstance.setAudioAtBeginning(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, actSpinner: progressBar, actBlurEffect: blurView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    // MARK: -Populate Table Methods -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(subTitle == ""){
            return mainDic.count
        }else{
            return (mainDic[subTitle]?.count)!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = audioTableView.dequeueReusableCellWithIdentifier("CustomAudioCell", forIndexPath: indexPath) as! CustomAudioCell
        let row = indexPath.row
        
        if(subTitle != ""){
            let keyArray:NSArray = (mainDic[subTitle]?.allKeys)!
            if(keyArray.count != 0){
                cell.textLabel?.text = keyArray[row] as? String
            }
            
            let valueArray:NSArray = (mainDic[subTitle]?.allValues)!
            if(valueArray.count != 0 && valueArray[row][0] == "url"){
                 cell.setCellAlpha(true)
            }else{
                 cell.setCellAlpha(false)
            }
        }else {
            let keyArray:NSArray = mainDic.allKeys
            if(keyArray.count != 0){
                cell.textLabel?.text = keyArray[row] as? String
            }
            cell.setCellAlpha(false)
        }
        
//        if(currentDic.count != 0 && (currentDic[tableTitleArray[row] as! String] as! NSArray)[0] as! String == "url"){
//            cell.setCellAlpha(true)
//        }else{
//            cell.setCellAlpha(false)
//        }
//       
//        if(tableTitleArray.count != 0){
//            cell.textLabel?.text = tableTitleArray.objectAtIndex(row) as? String
//        }
        
        return cell
    }
    
    // MARK: - Actions When Table View Cell Selected -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        audioTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        pickerView.hidden = true
        
        let row = indexPath.row
        
        let name:String!
        if(subTitle != ""){
            name = (mainDic[subTitle] as! NSDictionary).allKeys[row] as! String
        }else{
            name = mainDic.allKeys[row] as! String
        }
        
        //let name:String = tableTitleArray.objectAtIndex(row) as! String
        noResult.hidden = true
        
        // if the count equals, then still at main menu, so clear table view and populate it with sub menu, and assign correct properties
        // if the cound doesn't equals, then in sub menu, so set up player and properties, and change audio view
        if(subTitle == ""){
            subTitle = name
            audioTableView.reloadData()
        }else{
            objectToBePlayed = (mainDic[subTitle]?.objectForKey(name))! as! NSArray
            
            // Set Audio Player Property
            audioPlayer.sharedInstance.setDatas(mainDic[subTitle] as! NSDictionary)
            
            // Set Up Audio Player, Audio Player Mode, Audio Player Property
            audioPlayer.sharedInstance.setUpPlayer(name, objectToBePlay: objectToBePlayed, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: progressBar,actblurEffect: blurView)
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)

        }
        
        /*if(tableTitleArray.isEqualToArray(Variables.sharedInstance.allAmblum.allKeys)){ // Set Property
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
            audioPlayer.sharedInstance.setUpPlayer(name, objectToBePlay: objectToBePlayed, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: progressBar,actblurEffect: blurView)
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }*/
        
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
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let titleData:String = pickerViewData[row]
        let myTitle:UILabel = UILabel.init()
        myTitle.text = titleData
        myTitle.textColor = UIColor.whiteColor()
        myTitle.adjustsFontSizeToFitWidth = true
        
        return myTitle
    }
    
    // MARK: - Picker View Cell Selected -
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let name:String = pickerViewData[row];
        
        let nameArr = name.characters.split{$0 == "/"}.map(String.init)
        
        let subDict:NSDictionary = mainDic[nameArr[1]] as! NSDictionary
        
//        let subDict:NSDictionary = Variables.sharedInstance.allAmblum.objectForKey(nameArr[1]) as! NSDictionary
//        currentDic.removeAllObjects()
//        currentDic = NSMutableDictionary.init(dictionary:subDict)
        
        // Set Audio Player Property
        audioPlayer.sharedInstance.setDatas(subDict)
        //audioPlayer.sharedInstance.setDatas(currentDic)
        
        // Set Up Audio Player, Audio Player Mode, Audio Player Property
        audioPlayer.sharedInstance.setUpPlayer(nameArr[0], objectToBePlay: subDict.objectForKey(nameArr[0]) as! NSArray, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton, actSpinner: progressBar,actblurEffect: blurView)
        
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
        commandCenter.playCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.previousTrackCommand.removeTarget(self)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
        
        // Do the transiton
        self.performSegueWithIdentifier("abulmtomain", sender: self)
        
        // Clear Video Player
        videoPlayer.sharedInstance.clear()
        videoPlayer.sharedInstance.removeFromParentViewController()
        videoPlayer.sharedInstance.view.removeFromSuperview()
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        
        // Clear audio player
        audioPlayer.sharedInstance.clearPlayer(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel)
        pickerView.hidden = true
        
        // All Buttons Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    // Go Back to main menu
    @IBAction func backToHomeMenu(sender: AnyObject) {
        noResult.hidden = true
        pickerView.hidden = true
        subTitle = ""
        //tableTitleArray.removeAllObjects()
        //currentDic.removeAllObjects()
        //tableTitleArray = NSMutableArray.init(array:Variables.sharedInstance.allAmblum.allKeys)
        audioTableView.reloadData()
    }
    
    // MARK: - Audio Player Button Method -
    
    func playPrev() {
        if(!videoPlayer.sharedInstance.view.hidden){
            self.clearVideo(clearVideoButton)
            audioPlayer.sharedInstance.setAutoMode()
        }
        audioPlayer.sharedInstance.getPrevSong()
    }
    
    func playNext() {
        if(!videoPlayer.sharedInstance.view.hidden){
            self.clearVideo(clearVideoButton)
            audioPlayer.sharedInstance.setAutoMode()
        }
        audioPlayer.sharedInstance.getNextSong()
    }
    
    func playRemote() {
        if(!videoPlayer.sharedInstance.view.hidden){
            videoPlayer.sharedInstance.player?.play()
        }else{
            self.playAudio(playButton)
        }
    }
    
    func pauseRemote() {
        if(!videoPlayer.sharedInstance.view.hidden){
            videoPlayer.sharedInstance.player?.pause()
        }else{
            self.pauseAudio(playButton)
        }
    }
    
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
        var results:[String:NSArray] = [String:NSArray]()
        for(key,value) in Variables.sharedInstance.allAmblum{
            for(name,path) in value as! NSMutableDictionary{
                if(name.containsString(txtFieldText)){
                    let finalName:String = (name as! String) + "/" + (key as! String)
                    results[finalName] = (path as! NSArray)
                }
            }
        }
        
        if(results.count >= 1){
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
        
        let dict:NSDictionary = mainDic.objectForKey(subTitle) as! NSDictionary
        let name:String = dict.allKeysForObject(objectToBePlayed).first as! String
        //mainDic[subTitle]?.allKeysForObject(objectToBePlayed).first as! String
        //let name:String = currentDic.allKeysForObject(objectToBePlayed).first as! String

        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        videoPlayer.sharedInstance.view.hidden = false
        videoPlayer.sharedInstance.view.frame = videoPlayerView.frame

        videoPlayer.sharedInstance.playVideo(Variables.sharedInstance.allAmblumVideos[name] as! NSArray)
        videoPlayer.sharedInstance.addObserver(self, forKeyPath: "videoBounds", options: NSKeyValueObservingOptions.New, context: nil)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        videoObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { _ in
            
            videoPlayer.sharedInstance.clear()
        }
    }
    
    @IBAction func clearVideo(sender: AnyObject) {
        videoPlayer.sharedInstance.clear()
        videoPlayerView.hidden = true
        clearVideoButton.hidden = true
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
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
    
    func refreshData() {
        audioTableView.reloadData()
    }
    
    func restrictRotation(restriction:Bool){
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.restrictRotation = restriction
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "videoBounds"){
            if(videoPlayer.sharedInstance.videoBounds.width >= UIScreen.mainScreen().fixedCoordinateSpace.bounds.width ){
                self.restrictRotation(false)
            }else if( !(videoPlayer.sharedInstance.videoBounds.width == 0 && videoPlayer.sharedInstance.videoBounds.origin.x < 0)){
                self.restrictRotation(true)
                UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
                videoPlayer.sharedInstance.view.frame = videoPlayerView.frame
            }
        }
    }
    
    func applicationDidEnterBackground(notification:NSNotification){
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }catch{
            NSLog("can't play in background")
        }
        if(!videoPlayer.sharedInstance.view.hidden){
            self.performSelector("playInBackground", withObject: nil, afterDelay: 0.01)
        }
    }
    
    
    func playInBackground(){
        videoPlayer.sharedInstance.player?.play()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        switch (event!.subtype){
        case UIEventSubtype.RemoteControlTogglePlayPause:
            if(audioPlayer.sharedInstance.player.rate == 0){
                self.playRemote()
            }else{
                self.pauseRemote()
            }
            break
        case UIEventSubtype.RemoteControlPlay:
            self.playRemote()
            break
        case UIEventSubtype.RemoteControlPause:
            self.pauseRemote()
            break
        case UIEventSubtype.RemoteControlPreviousTrack:
            self.playPrev()
            break
        case UIEventSubtype.RemoteControlNextTrack:
            self.playNext()
            break
        default:
            break
        }
    }


}
