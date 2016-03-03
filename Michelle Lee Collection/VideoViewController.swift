//
//  VideoViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-17.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import MediaPlayer

enum FileType: Int {
    case LOCAL
    case URL
}

class VideoViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    // Background Image Related
    @IBOutlet var backGroundImage: UIImageView!
     var imageName:String = String()
    
    // Storyboard Views that need to be populated
    @IBOutlet var videoCollectionView: UICollectionView!
    @IBOutlet var pickerView: UIPickerView!
    
    // Video Player View
    @IBOutlet var videoPlayerView: UIView!
    var isFullScreen:Bool = false
    var timer:NSTimer = NSTimer()
    
    // Search Field
    @IBOutlet var txtField: UITextField!
    
    // Storyboard Buttons
    @IBOutlet var singleRotateButton: UIButton!
    @IBOutlet var multipleRotateButton: UIButton!
    @IBOutlet var backButton: UIButton!
   
    // No Result View
    @IBOutlet var noResult: UILabel!
    
    // Single Section Main Data
    var mainDicSingle:NSMutableDictionary = NSMutableDictionary()
    var imageDicSingle:[String:UIImage] = [String:UIImage]()
    
    // Multi Section Main Data
    var mainDicMulti:NSMutableDictionary = NSMutableDictionary()
    var imageDicMulti:[String:[String:UIImage]] = [String:[String:UIImage]]()
    
    // Current Data
    var multiCurrentName:String = " "
    var pickerViewData:[String] = [String]()
    
    // Video Player State
    let Single_Rotate:NSInteger = 0
    let Multiple_Rotate:NSInteger = 1
    
    //var loadImageDone:Bool = true
    let queue:NSOperationQueue = NSOperationQueue.init()
     let alert:UIAlertController = UIAlertController.init(title: "Network Glitch", message: "An problem occured to load images of videos. Please choose to continue to cancel.", preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: "connectionStateChange", object: nil)
        
        let addAction:UIAlertAction = UIAlertAction.init(title: "Continue", style: UIAlertActionStyle.Default, handler: {(action) in
            
        })
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{(action) in
            self.queue.cancelAllOperations()
        })
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        

        
        super.viewDidLoad()
        
        // Set Up Background Image
        backGroundImage.image = UIImage(named: imageName)
        
        // Set up collection view
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.backgroundColor = UIColor.clearColor()
        videoCollectionView.layer.borderColor = UIColor.blackColor().CGColor
        videoCollectionView.layer.borderWidth = 1.0
        
        // Set up picker view
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.hidden = true
        
        // Buttons and Views that need to be hidden
        videoPlayerView.hidden = true
        backButton.hidden = true
        noResult.adjustsFontSizeToFitWidth = true
        noResult.backgroundColor = UIColor.redColor()
        noResult.hidden = true
        
        // add video player view
        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        videoPlayer.sharedInstance.view.hidden = true
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = []
        let inactiveButton:[UIButton] = [multipleRotateButton,singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        
        queue.maxConcurrentOperationCount = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        if(mainDicSingle.count > 0){
            self.generateOnlineImage()
        }
    }
    
    // MARK: - Get Individual Mp4 Image To Disply -
    
    // Setting up to get image from mp4
    func getImage(){
        if(mainDicSingle.count > 0){
            for (key,value) in mainDicSingle{
                if(value.objectAtIndex(0) as! String == "local"){
                    let url = NSURL(string: value.objectAtIndex(1) as! String)
                    self.captureFrame(url!, timeInSeconds: 20, key: key as! String, sectionKey: "")
                }
            }
        }else if(mainDicMulti.count > 0 && multiCurrentName != " "){
            for(name,path) in mainDicMulti[multiCurrentName] as! NSDictionary{
                if(path.objectAtIndex(0) as! String == "local"){
                    let url = NSURL(string: path.objectAtIndex(1) as! String)
                    self.captureFrame(url!, timeInSeconds: 20, key: name as! String, sectionKey: multiCurrentName)
                }
            }
        }
    }
    
    func generateOnlineImage(){
        if(mainDicSingle.count > 0){
            for (key,value) in mainDicSingle{
                
                var imageExist:Bool = false
                if(imageDicSingle.count > 0){
                    if( imageDicSingle[key as! String] != nil){
                        imageExist = true
                    }
                }
                
                if(value.objectAtIndex(0) as! String == "url" && !imageExist && sourceMethods.sharedInstance.ConnectionAvailable()){
                    
                    queue.addOperationWithBlock({
                        let url = NSURL(string: value.objectAtIndex(1) as! String)
                        let imageGenerator = AVAssetImageGenerator(asset: AVAsset(URL: url!))
                        imageGenerator.appliesPreferredTrackTransform = true
                        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
                        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
                        let time:CMTime = CMTimeMake(60, 600)
                        
                        do{
                            let imageRef:CGImageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                            let image:UIImage = UIImage.init(CGImage: imageRef)
                            self.imageDicSingle[key as! String] = image
                        }catch{
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                if(self.presentedViewController == nil){
                                    self.presentViewController(self.alert, animated: true, completion: nil)
                                }
                            })
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.videoCollectionView.reloadData()
                        })
                    })
                    
                }
            }
        }else if(mainDicMulti.count > 0 && multiCurrentName != " "){
            for(name,path) in mainDicMulti[multiCurrentName] as! NSDictionary{
                
                var imageExist:Bool = false
                if(imageDicMulti[multiCurrentName]?.count > 0){
                    let actDic:[String:UIImage] = imageDicMulti[multiCurrentName]!
                    if( actDic[name as! String] != nil){
                        imageExist = true
                    }
                }
                
                if(path.objectAtIndex(0) as! String == "url" && !imageExist && sourceMethods.sharedInstance.ConnectionAvailable()){
                
                    queue.addOperationWithBlock({
                        let url = NSURL(string: path.objectAtIndex(1) as! String)
                        let imageGenerator = AVAssetImageGenerator(asset: AVAsset(URL: url!))
                        imageGenerator.appliesPreferredTrackTransform = true
                        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
                        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
                        let time:CMTime = CMTimeMake(60, 600)
                        
                        do{
                            let imageRef:CGImageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                            let image:UIImage = UIImage.init(CGImage: imageRef)
                            var dict:[String:UIImage] = [String:UIImage]()
                            if(self.imageDicMulti.count > 0 && self.imageDicMulti[self.multiCurrentName] != nil){
                                dict = self.imageDicMulti[self.multiCurrentName]!
                            }
                            dict[name as! String] = image
                            self.imageDicMulti[self.multiCurrentName] = dict
                        }catch{
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                if(self.presentedViewController == nil){
                                    self.presentViewController(self.alert, animated: true, completion: nil)
                                }
                            })
                        }
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.videoCollectionView.reloadData()
                        })
                    })
                    
                }
            }
        }

    }
    
    // Acutally getting the image
    func captureFrame(url:NSURL, timeInSeconds time:Int64, key:String, sectionKey:String) {
        let imageGenerator = AVAssetImageGenerator(asset: AVAsset(URL: url))
        let tVal = NSValue(CMTime: CMTimeMake(time, 1))
        imageGenerator.generateCGImagesAsynchronouslyForTimes([tVal], completionHandler: {(_, im:CGImage?, _, _, e:NSError?) in self.finshedCapture(im, key: key, error: e, sectionKey: sectionKey)})
    }

    // Save image in dictionary
    func finshedCapture(im:CGImage?, key:String, error:NSError?, sectionKey:String)  {
        if let img = im {
            if(mainDicSingle.count > 0){
                imageDicSingle[key] = UIImage.init(CGImage: img)
            }else if(mainDicMulti.count > 0){
                var dict:[String:UIImage] = [String:UIImage]()
                if(imageDicMulti[sectionKey]?.count > 0){
                    dict = imageDicMulti[sectionKey]!
                }
                dict[key] = UIImage.init(CGImage: img)
                imageDicMulti[sectionKey] = dict
            }
        }
    }
    
    // MARK: -Populate Collection View Methods -
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(mainDicSingle.count > 0){
            return mainDicSingle.count
        }else if(multiCurrentName != " "){
            return (mainDicMulti[multiCurrentName]?.count)!
        }else{
            return mainDicMulti.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        
        // Populate text label name depending on single or multiple section
        var name:String = String()
        if(mainDicSingle.count > 0){
            name = (mainDicSingle.allKeys as NSArray).objectAtIndex(indexPath.row) as! String
            if(mainDicSingle[name]![0] == "url"){
                cell.setCellAlpha(true)
            }else{
                cell.setCellAlpha(false)
            }
        }else if(mainDicMulti.count > 0 && multiCurrentName == " "){
            name = (mainDicMulti.allKeys as NSArray).objectAtIndex(indexPath.row) as! String
            cell.setCellAlpha(false)
        }else if(mainDicMulti.count > 0 ){
            name = ((mainDicMulti[multiCurrentName]?.allKeys)! as NSArray).objectAtIndex(indexPath.row) as! String
            if(mainDicMulti[multiCurrentName]![name]!![0] == "url"){
                cell.setCellAlpha(true)
            }else{
                cell.setCellAlpha(false)
            }
        }
        cell.textLabel.text = name
        
        // Decide what image should be on collection view cell  depending on single or multiple
        var image:UIImage = UIImage(named: "loadingImage.png")!
        if(mainDicSingle.count > 0){
            if ((imageDicSingle[name]) != nil){
                image = imageDicSingle[name]!
            }

        }else if(imageDicMulti.count > 0 && multiCurrentName != " "){
            var dict:[String:UIImage] = [String:UIImage]()
            if (imageDicMulti[multiCurrentName] != nil){
                dict = imageDicMulti[multiCurrentName]!
            }
            if (dict[name] != nil){
                image = dict[name]!
            }
        }
        
        cell.imageView.image = image
    
        return cell
        
    }
    
    // MARK: - Actions When Collection View Cell Selected -
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         noResult.hidden = true
         pickerView.hidden = true
        if(mainDicMulti.count > 0 && multiCurrentName == " "){
            // Reload collection view data to individual sections
            let name:String = mainDicMulti.allKeys[indexPath.row] as! String
            
            multiCurrentName = name
            self.getImage()
            videoCollectionView.reloadData()
            self.generateOnlineImage()
            backButton.hidden = false
        }else{
            // Set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
            
            // Grab the video path and pass it to the video player
            if(mainDicMulti.count > 0){
                videoPlayer.sharedInstance.setVideoData(mainDicMulti[multiCurrentName]?.allValues as! [NSArray], frame: videoPlayerView.frame)
                videoPlayer.sharedInstance.playVideo(mainDicMulti[multiCurrentName]!.allValues! [indexPath.row] as! NSArray)
            }else if(mainDicSingle.count > 0){
                videoPlayer.sharedInstance.setVideoData(mainDicSingle.allValues as! [NSArray], frame: videoPlayerView.frame)
                videoPlayer.sharedInstance.playVideo(mainDicSingle.allValues[indexPath.row] as! NSArray)
            }
        
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [singleRotateButton]
            let inactiveButton:[UIButton] = [multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }
        
    }
    
     // MARK: -Populate Picker View Methods -
    
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
    
    // MARK: - Actions When Picker View Cell Selected -
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // decide which subsection are we in
        let name:String = pickerViewData[row];
        
        if(mainDicMulti.count > 0){
            let nameArr = name.characters.split{$0 == "/"}.map(String.init)

            let subDict:NSDictionary = mainDicMulti[nameArr[1]] as! NSDictionary
        
            // set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
        
            // get the video path and pass it to video player
            videoPlayer.sharedInstance.setVideoData(subDict.allValues as! [NSArray], frame: videoPlayerView.frame)
            videoPlayer.sharedInstance.playVideo(subDict[nameArr[0]] as! NSArray)
        }else{
            
            let subDict:NSDictionary = mainDicSingle
            
            // set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
            
            // get the video path and pass it to video player
            videoPlayer.sharedInstance.setVideoData(subDict.allValues as! [NSArray], frame: videoPlayerView.frame)
            videoPlayer.sharedInstance.playVideo(subDict[name] as! NSArray)
        }

        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [singleRotateButton]
        let inactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        
        // remove pickerView after picking
        pickerViewData.removeAll()
        pickerView.reloadComponent(0)
        pickerView.hidden = true
        
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
    
    // MARK: - Buttons Methods -
    
    @IBAction func singeRotate(sender: AnyObject) {
        videoPlayer.sharedInstance.setMode(Single_Rotate)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [multipleRotateButton]
        let inactiveButton:[UIButton] = [singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func multipleRotate(sender: AnyObject) {
        videoPlayer.sharedInstance.setMode(Multiple_Rotate)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [singleRotateButton]
        let inactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)

    }
    
    @IBAction func clearVideo(sender: AnyObject) {
        videoPlayer.sharedInstance.clear()
        pickerView.hidden = true
        let inactiveButton:[UIButton] = [singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func goHome(sender: AnyObject) {
        
        timer.invalidate()
        queue.cancelAllOperations()
        
        // Do the transiton
        self.performSegueWithIdentifier("videoToMain", sender: self)
        
        // Clear audio player
        videoPlayer.sharedInstance.clear()
        videoPlayer.sharedInstance.removeFromParentViewController()
        videoPlayer.sharedInstance.view.removeFromSuperview()
        
        // Clear data
        multiCurrentName = " "
        mainDicMulti.removeAllObjects()
        mainDicSingle.removeAllObjects()
        imageDicMulti.removeAll()
        imageDicSingle.removeAll()
        videoCollectionView.reloadData()
        
        // All Buttons Inactive
        let inactiveButton:[UIButton] = [singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func backToHomeMenu(sender: AnyObject) {
        queue.cancelAllOperations()
        noResult.hidden = true
        backButton.hidden = true
        multiCurrentName = " "
        videoCollectionView.reloadData()
    }

    
    // MARK: - Search Video -
    
    @IBAction func searchVideo(sender: AnyObject) {
        var results:[String:AnyObject] = [String:AnyObject]()
        
        let searchText:String = (txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
        
        if(mainDicSingle.count > 0){
            for (name,path) in mainDicSingle {
                if(name.containsString(searchText)){
                    results[name as! String] = path as! NSArray
                }
            }
        }else if(mainDicMulti.count > 0){
            for(key,value) in mainDicMulti{
                for(name,path) in value as! NSDictionary{
                    if(name.containsString(searchText)){
                        let finalName:String = (name as! String) + "/" + (key as! String)
                        results[finalName] = path as! NSArray
                    }
                }
            }
        }
        
        if(results.count >= 1){
            // Populate picker view and show it
            pickerView.hidden = false
            pickerViewData = [String](results.keys)
            pickerView.reloadComponent(0)
        }else if(results.count == 0){
            // display no result label
            noResult.text = "No Result For " + (txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            noResult.hidden = false
        }
        txtField.resignFirstResponder()
    }

    
    override func viewWillAppear(animated: Bool) {
        videoCollectionView.reloadData()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldReturn(sender: AnyObject){
        sender.resignFirstResponder()
    }
    
    func refreshData() {
        videoCollectionView.reloadData()
    }
    
    func restrictRotation(restriction:Bool){
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.restrictRotation = restriction
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "videoBounds"){
            if(videoPlayer.sharedInstance.videoBounds.width >= UIScreen.mainScreen().fixedCoordinateSpace.bounds.width){
                self.restrictRotation(false)
            }else if( !(videoPlayer.sharedInstance.videoBounds.width == 0 && videoPlayer.sharedInstance.videoBounds.origin.x < 0)){
                videoCollectionView.reloadData()
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
        self.performSelector("playInBackground", withObject: nil, afterDelay: 0.01)
    }
    
    func playInBackground(){
        videoPlayer.sharedInstance.player?.play()
    }
    
    override func viewDidDisappear(animated: Bool) {
        videoPlayer.sharedInstance.player?.pause()
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        switch (event!.subtype){
        case UIEventSubtype.RemoteControlTogglePlayPause:
            if(videoPlayer.sharedInstance.player?.rate == 0){
                videoPlayer.sharedInstance.player?.play()
            }else{
                videoPlayer.sharedInstance.player?.pause()
            }
            break
        case UIEventSubtype.RemoteControlPlay:
            videoPlayer.sharedInstance.player?.play()
            break
        case UIEventSubtype.RemoteControlPause:
            videoPlayer.sharedInstance.player?.pause()
            break
        case UIEventSubtype.RemoteControlPreviousTrack:
            videoPlayer.sharedInstance.playPrevSong()
            break
        case UIEventSubtype.RemoteControlNextTrack:
            videoPlayer.sharedInstance.playNextSong()
            break
        default:
            break
        }
    }
    
}