//
//  EditPageViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-01-30.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

enum CurrentFileType: Int {
    case Audio
    case Video
    case None
}

public class IpodLibraryCell: UITableViewCell {
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.frame = CGRectMake(50, 0, 85, 45)
        self.imageView?.frame = CGRectMake(0, 0, 45, 45)
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
    }
}

class EditPageViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource{
    
    // Views Declaration
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allow3GButton: UISwitch!
    @IBOutlet weak var tableViewForContent: UITableView!
    @IBOutlet weak var pickerViewForChoice: UIPickerView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    // Local Datas
    var currentDicAudio:NSDictionary = NSDictionary()
    var currentDicVideo:NSDictionary = NSDictionary()
    var videoImageDic:NSMutableDictionary = NSMutableDictionary()
    
    // Current State
    var currentState:CurrentFileType = CurrentFileType.None
    
    // Information Variables
    var pickerViewArr:NSMutableArray = NSMutableArray()
    var currentItem:String = String()
    var endDirectory:NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        // Set Up TableView
        tableViewForContent.backgroundColor = UIColor.grayColor()
        tableViewForContent.delegate = self
        tableViewForContent.dataSource = self
        tableViewForContent.hidden = true
        
        // Set Up PickerView
        pickerViewForChoice.delegate = self
        pickerViewForChoice.dataSource = self
        pickerViewForChoice.hidden = true
        selectButton.hidden = true
        
        // Set Up Blurview
        blurEffectView.hidden = true
    }
    
    // Populate Current Dic with Local Ipod Files
    private func getIpodLibraryInformation(){
        if(currentState == CurrentFileType.Audio && currentDicAudio.count == 0){
            let dic:NSMutableDictionary = NSMutableDictionary()
            let mainQuery:MPMediaQuery = MPMediaQuery.init()
            let typePredicate = MPMediaPropertyPredicate(value: MPMediaType.AnyAudio.rawValue, forProperty: MPMediaItemPropertyMediaType)
            mainQuery.addFilterPredicate(typePredicate)
            for (item) in mainQuery.items! {
                dic[item.valueForProperty(MPMediaItemPropertyTitle) as! String] = item.valueForProperty(MPMediaItemPropertyAssetURL)?.absoluteString
            }
            currentDicAudio = dic.copy() as! NSDictionary
        }else if(currentState == CurrentFileType.Video && currentDicVideo.count == 0){
            let dic:NSMutableDictionary = NSMutableDictionary()
            let mainQuery:MPMediaQuery = MPMediaQuery.init()
            let typePredicate = MPMediaPropertyPredicate(value: MPMediaType.AnyVideo.rawValue, forProperty: MPMediaItemPropertyMediaType)
            mainQuery.addFilterPredicate(typePredicate)
            for (item) in mainQuery.items! {
                dic[item.valueForProperty(MPMediaItemPropertyTitle) as! String] = item.valueForProperty(MPMediaItemPropertyAssetURL)?.absoluteString
            }
            currentDicVideo = dic.copy() as! NSDictionary
            self.getImage()
        }
    }
    
    // MARK: - Table View Methods-
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(currentState == CurrentFileType.Audio){
            return currentDicAudio.allKeys.count
        }else if(currentState == CurrentFileType.Video){
            return currentDicVideo.allKeys.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableViewForContent.dequeueReusableCellWithIdentifier("IpodLibraryCell", forIndexPath: indexPath) as UITableViewCell
         let row = indexPath.row
        
        // Set Up Cell Text and Cell Image
        if(currentState == CurrentFileType.Audio){
            cell.textLabel?.text = ((currentDicAudio.allKeys as NSArray).objectAtIndex(row) as! String)
            cell.imageView?.image = nil
        }else if(currentState == CurrentFileType.Video){
            cell.textLabel?.text = ((currentDicVideo.allKeys as NSArray).objectAtIndex(row) as! String)
            cell.imageView?.image = UIImage(CGImage:((videoImageDic.allValues as NSArray).objectAtIndex(row)) as! CGImage)
        }
        
        // Set Up Cell Properties
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - Actions When Table View Cell Selected -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewForContent.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Get Information
        let row = indexPath.row
        var name:String!
        //let name:String = (currentDic.allKeys as NSArray).objectAtIndex(row) as! String
        if(currentState == CurrentFileType.Audio){
            name = (currentDicAudio.allKeys as NSArray).objectAtIndex(row) as! String
        }else if(currentState == CurrentFileType.Video){
            name = (currentDicVideo.allKeys as NSArray).objectAtIndex(row) as! String
        }
        
        // Assign Current Video Item
        currentItem = name
        
        // Set up PickerView to display Folder Names
        pickerViewArr = NSMutableArray.init(array:endDirectory.allKeys , copyItems: true)
        pickerViewForChoice.hidden = false
        pickerViewForChoice.reloadAllComponents()
    }

    
    // MARK: - Populate Picker View Methods -
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewArr.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewArr[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewArr[row]
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }

    // MARK: - Picker View Cell Selected -
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Get Information
        let name:String = pickerViewArr[row] as! String
        endDirectory = endDirectory[name] as! NSMutableDictionary
        
        // If there is no more folder after current one, allow user to select current folder
        if(endDirectory.allValues.first is NSArray){
            selectButton.hidden = false
        // If there is folers after current one, display those
        }else{
            pickerViewArr = NSMutableArray.init(array: endDirectory.allKeys, copyItems: true)
            pickerViewForChoice.reloadAllComponents()
        }
        
    }

    // MARK: - Button Methods -
    
    // Add Video To Playist
    @IBAction func addToVideo(sender: AnyObject) {
        spinnerView.startAnimating()
        blurEffectView.hidden = false
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            // Populate Informations
            self.currentState = CurrentFileType.Video
            self.endDirectory = Variables.sharedInstance.allVideoPlayist
            self.getIpodLibraryInformation()
            
            // Set Up views
            self.spinnerView.stopAnimating()
            self.blurEffectView.hidden = true
            self.tableViewForContent.hidden = false
            self.tableViewForContent.reloadData()
        }
        
    }
    
    // Add Audio To Playist
    @IBAction func addToAudio(sender: AnyObject) {
        spinnerView.startAnimating()
        blurEffectView.hidden = false
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            // Populate Informations
            self.currentState = CurrentFileType.Audio
            self.endDirectory = Variables.sharedInstance.allAmblum
            self.getIpodLibraryInformation()
            
            // Set Up views
            self.spinnerView.stopAnimating()
            self.blurEffectView.hidden = true
            self.tableViewForContent.hidden = false
            self.tableViewForContent.reloadData()
        }
    }
    
    
    // Set Allow 3G
    @IBAction func set3G(sender: AnyObject) {
        sourceMethods.sharedInstance.SetCelluar(allow3GButton.on)
    }
    
    
    // Actually Do the Adding
    @IBAction func selectDonePressed(sender: AnyObject) {
        // Write Current Item to Apporiate Folders
        if(currentState == CurrentFileType.Audio){
            endDirectory[currentItem] = ["local",currentDicAudio[currentItem] as! String]
        }else if(currentState == CurrentFileType.Video){
            endDirectory[currentItem] = ["local",currentDicVideo[currentItem] as! String]
        }
        
        // Write Change to Modified Plist
        Variables.sharedInstance.writeToModifyPlist()
        
        // Clear Views
        self.clearAllData()
    }
    
    @IBAction func clearData(sender: AnyObject) {
        // Clear Views
        self.clearAllData()
    }
    @IBAction func scanAllAudio(sender: AnyObject) {
        // Overwrite Everything with Original Plist
        spinnerView.startAnimating()
        blurEffectView.hidden = false
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            // Populate Informations
            Variables.sharedInstance.populatePlayListFromPlist("OriginalPlayist.plist")
            sourceMethods.sharedInstance.populateLocalMusic()
            sourceMethods.sharedInstance.populateLocalVideo()
            
            // Set Up views
            self.spinnerView.stopAnimating()
            self.blurEffectView.hidden = true
        }
    }
    
    // Hide Certain Vies
    func clearAllData(){
        self.tableViewForContent.hidden = true
        self.pickerViewForChoice.hidden = true
        self.selectButton.hidden = true
    }

    // MARK: - Get Individual Mp4 Image To Disply -
    
    // Setting up to get image from mp4
    func getImage(){
        if(currentDicVideo.count > 0){
            for (key,value) in currentDicVideo{
                    let url = NSURL(string: value as! String)
                    self.captureFrame(url!, timeInSeconds: 12, key: key as! String, sectionKey: "")
                
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
            videoImageDic[key] = img
        }
    }

    
}
