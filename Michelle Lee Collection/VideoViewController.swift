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

enum FileType: Int {
    case LOCAL
    case URL
}

public class CollectionViewCell: UICollectionViewCell{
    var imageView:UIImageView = UIImageView.init()
    let textLabel:UILabel = UILabel.init()
    var type:FileType = FileType.LOCAL
    
    dynamic var imageViewAlpha: NSNumber? {
        get { return self.imageView.alpha}
        set {
            if(self.type == FileType.URL){
                self.imageView.alpha =  CGFloat.init(newValue!)
            }
        }
    }
    
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
    var imageDicSingle:[String:CGImage] = [String:CGImage]()
    
    // Multi Section Main Data
    var mainDicMulti:NSMutableDictionary = NSMutableDictionary()
    var imageDicMulti:[String:[String:CGImage]] = [String:[String:CGImage]]()
    
    // Current Data
    var multiCurrentName:String = " "
    var pickerViewData:[String] = [String]()
    
    // Video Player State
    let Single_Rotate:NSInteger = 0
    let Multiple_Rotate:NSInteger = 1
    
    override func viewDidLoad() {
        
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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: Selector("updateFullScreenState"), userInfo: nil, repeats: true)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = []
        let inactiveButton:[UIButton] = [multipleRotateButton,singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    // MARK: - Get Individual Mp4 Image To Disply -
    
    // Setting up to get image from mp4
    func getImage(){
        if(mainDicSingle.count > 0){
            for (key,value) in mainDicSingle{
                if(value[0].isEqualToString("local")){
                    let url = NSURL(string: value.objectAtIndex(1) as! String)
                    self.captureFrame(url!, timeInSeconds: 12, key: key as! String, sectionKey: "")

                }
            }
        }else if(mainDicMulti.count > 0){
            for(title,value) in mainDicMulti{
                for(name,path) in value as! NSDictionary{
                    if((path as! NSArray).objectAtIndex(0).isEqualToString("local") == true){
                        let url = NSURL(string: path.objectAtIndex(1) as! String)
                        self.captureFrame(url!, timeInSeconds: 12, key: name as! String, sectionKey: title as! String)
                    }
                }
            }
        }
    }
    
    // Acutally getting the image
    func captureFrame(url:NSURL, timeInSeconds time:Int64, key:String, sectionKey:String) {
        let generator = AVAssetImageGenerator(asset: AVAsset(URL: url))
        let tVal = NSValue(CMTime: CMTimeMake(time, 1))
        generator.generateCGImagesAsynchronouslyForTimes([tVal], completionHandler: {(_, im:CGImage?, _, _, e:NSError?) in self.finshedCapture(im, key: key, error: e, sectionKey: sectionKey)})
    }
    
    // Save image in dictionary
    func finshedCapture(im:CGImage?, key:String, error:NSError?, sectionKey:String)  {
        if let img = im {
            if(mainDicSingle.count > 0){
                imageDicSingle[key] = img
            }else if(mainDicMulti.count > 0){
                var dict:[String:CGImage] = [String:CGImage]()
                if(imageDicMulti[sectionKey]?.count > 0){
                    dict = imageDicMulti[sectionKey]!
                }
                dict[key] = img
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
                cell.type = FileType.URL
            }else{
                cell.type = FileType.LOCAL
            }
        }else if(mainDicMulti.count > 0 && multiCurrentName == " "){
            name = (mainDicMulti.allKeys as NSArray).objectAtIndex(indexPath.row) as! String
        }else if(mainDicMulti.count > 0 ){
            name = ((mainDicMulti[multiCurrentName]?.allKeys)! as NSArray).objectAtIndex(indexPath.row) as! String
            if(mainDicMulti[multiCurrentName]![name]!![0] == "url"){
                cell.type = FileType.URL
            }else{
                cell.type = FileType.LOCAL
            }
        }
        cell.textLabel.text = name
        
        // Decide what image should be on collection view cell  depending on single or multiple
        var image:UIImage = UIImage(named: "loadingImage.png")!
        if(mainDicSingle.count > 0){
            if ((imageDicSingle[name]) != nil){
                let cgImage:CGImage = imageDicSingle[name]!
                image = UIImage(CGImage: cgImage)
            }

        }else if(imageDicMulti.count > 0 && multiCurrentName != " "){
            var dict:[String:CGImage] = [String:CGImage]()
            if (imageDicMulti[multiCurrentName] != nil){
                dict = imageDicMulti[multiCurrentName]!
            }
            if (dict[name] != nil){
                let cgImage:CGImage = dict[name]!
                image = UIImage(CGImage: cgImage)
            }
        }
        
        cell.imageView.image = image
    
        return cell
        
    }
    
    // MARK: - Actions When Collection View Cell Selected -
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         noResult.hidden = true
        if(mainDicMulti.count > 0 && multiCurrentName == " "){
            // Reload collection view data to individual sections
            let name:String = mainDicMulti.allKeys[indexPath.row] as! String

            multiCurrentName = name
            videoCollectionView.reloadData()
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
            
            // add video player view
            self.addChildViewController(videoPlayer.sharedInstance)
            self.view.addSubview(videoPlayer.sharedInstance.view)
            //videoPlayer.sharedInstance.player?.play()
            
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
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    // MARK: - Actions When Picker View Cell Selected -
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // decide which subsection are we in
        let name:String = pickerViewData[row];
        let subDict:NSDictionary = mainDicMulti[name] as! NSDictionary
        
        // set up video player for playing
        videoPlayer.sharedInstance.setMode(Multiple_Rotate)
        videoPlayer.sharedInstance.addObserverForVideo()
        
        // get the video path and pass it to video player
        videoPlayer.sharedInstance.setVideoData(subDict.allValues as! [NSArray], frame: videoPlayerView.frame)
        videoPlayer.sharedInstance.playVideo(subDict[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]! as! NSArray)

        
        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        //videoPlayer.sharedInstance.player?.play()

        
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
        
        let inactiveButton:[UIButton] = [singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func goHome(sender: AnyObject) {
        
        timer.invalidate()
        
        // Do the transiton
        self.performSegueWithIdentifier("videoToMain", sender: self)
        
        // Clear audio player
        videoPlayer.sharedInstance.clear()
        
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
        noResult.hidden = true
        backButton.hidden = true
        multiCurrentName = " "
        videoCollectionView.reloadData()
    }

    
    // MARK: - Search Video -
    
    @IBAction func searchVideo(sender: AnyObject) {
        var results:[String:AnyObject] = [String:AnyObject]()
        
        if(mainDicSingle.count > 0){
            for (name,path) in mainDicSingle{
                if(name as? String == txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())){
                    results[name as! String] = path as! NSArray
                }
            }

        }else if(mainDicMulti.count > 0){
            for(key,value) in mainDicMulti{
                for(name,path) in value as! NSDictionary{
                    if(name as? String == txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())){
                        let toBeDict:[String:NSArray] = [name as! String:path as! NSArray]
                        results[key as! String] = toBeDict
                    }
                }
            }
        }
        
        if(results.count == 1){
            // get video path and pass it to the video player
            if(mainDicSingle.count > 0){
                videoPlayer.sharedInstance.setVideoData(mainDicSingle.allValues as! [NSArray], frame: videoPlayerView.frame)
                videoPlayer.sharedInstance.playVideo(mainDicSingle[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]! as! NSArray)
            }else if(mainDicMulti.count > 0){
                let subDict:[String:NSArray] = mainDicMulti[Array(results.keys).first!]! as! [String : NSArray]
                videoPlayer.sharedInstance.videoData = [NSArray](subDict.values)
                videoPlayer.sharedInstance.playVideo(subDict[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!)
            }
            
            // set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
            
            // add video player view
            self.addChildViewController(videoPlayer.sharedInstance)
            self.view.addSubview(videoPlayer.sharedInstance.view)
            //videoPlayer.sharedInstance.player?.play()
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [singleRotateButton]
            let inactiveButton:[UIButton] = [multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }else if(results.count > 1){
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