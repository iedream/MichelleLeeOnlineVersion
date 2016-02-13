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
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allow3GButton: UISwitch!
    @IBOutlet weak var tableViewForContent: UITableView!
    @IBOutlet weak var pickerViewForChoice: UIPickerView!
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    var currentDic:NSMutableDictionary = NSMutableDictionary()
    var videoImageDic:NSMutableDictionary = NSMutableDictionary()
    var pickerViewArr:NSMutableArray = NSMutableArray()
    var currentItem:String = String()
    var endDirectory:NSMutableDictionary = NSMutableDictionary()
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        tableViewForContent.backgroundColor = UIColor.grayColor()
        tableViewForContent.delegate = self
        tableViewForContent.dataSource = self
        tableViewForContent.hidden = true
        
        pickerViewForChoice.delegate = self
        pickerViewForChoice.dataSource = self
        pickerViewForChoice.hidden = true
        selectButton.hidden = true
        
        blurEffectView.hidden = true
    }
    
    func getIpodLibraryInformation(type:UInt){
        let mainQuery:MPMediaQuery = MPMediaQuery.init()
        let typePredicate = MPMediaPropertyPredicate(value: type, forProperty: MPMediaItemPropertyMediaType)
        mainQuery.addFilterPredicate(typePredicate)
        for (item) in mainQuery.items! {
            currentDic[item.valueForProperty(MPMediaItemPropertyTitle) as! String] = item.valueForProperty(MPMediaItemPropertyAssetURL)?.absoluteString
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDic.allKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableViewForContent.dequeueReusableCellWithIdentifier("IpodLibraryCell", forIndexPath: indexPath) as UITableViewCell
         let row = indexPath.row
        
        if(currentDic.allKeys.count != 0){
            cell.textLabel?.text = ((currentDic.allKeys as NSArray).objectAtIndex(row) as! String)
        }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        
        if(videoImageDic.count > 0){
            cell.imageView?.image = UIImage(CGImage:((videoImageDic.allValues as NSArray).objectAtIndex(row)) as! CGImage)
        }else{
            cell.imageView?.image = nil
        }
        return cell
    }
    
    // MARK: - Actions When Table View Cell Selected -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewForContent.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        let name:String = (currentDic.allKeys as NSArray).objectAtIndex(row) as! String
        currentItem = name
        
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
        let name:String = pickerViewArr[row] as! String
        endDirectory = endDirectory[name] as! NSMutableDictionary
        if(endDirectory.allValues.first is NSArray){
            selectButton.hidden = false
        }else{
            pickerViewArr = NSMutableArray.init(array: endDirectory.allKeys, copyItems: true)
            pickerViewForChoice.reloadAllComponents()
        }
        
    }

    
    @IBAction func addToVideo(sender: AnyObject) {
        spinnerView.startAnimating()
        blurEffectView.hidden = false
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.clearAllData()
            
            self.endDirectory = Variables.sharedInstance.allVideoPlayist
            
            self.getIpodLibraryInformation(MPMediaType.AnyVideo.rawValue)
            self.getImage()
            
            self.spinnerView.stopAnimating()
            self.blurEffectView.hidden = true
            self.tableViewForContent.hidden = false
            self.tableViewForContent.reloadData()
        }
        
    }
    @IBAction func addToAudio(sender: AnyObject) {
        spinnerView.startAnimating()
        blurEffectView.hidden = false
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.clearAllData()
            
            self.endDirectory = Variables.sharedInstance.allAmblum

           
            self.getIpodLibraryInformation(MPMediaType.AnyAudio.rawValue)
            
            self.spinnerView.stopAnimating()
            self.blurEffectView.hidden = true
             self.tableViewForContent.hidden = false
            self.tableViewForContent.reloadData()
        }
    }
    
    @IBAction func set3G(sender: AnyObject) {
    }
    @IBAction func selectDonePressed(sender: AnyObject) {
        endDirectory[currentItem] = ["local",currentDic[currentItem] as! String]
        Variables.sharedInstance.writeToModifyPlist()
        self.clearAllData()
    }
    
    @IBAction func clearData(sender: AnyObject) {
        self.clearAllData()
    }
    @IBAction func scanAllAudio(sender: AnyObject) {
        Variables.sharedInstance.populatePlayListFromPlist("OriginalPlayist.plist")
    }
    
    func clearAllData(){
        self.currentDic.removeAllObjects()
        self.videoImageDic.removeAllObjects()
        self.tableViewForContent.hidden = true
        self.pickerViewForChoice.hidden = true
        self.selectButton.hidden = true
    }

    // MARK: - Get Individual Mp4 Image To Disply -
    
    // Setting up to get image from mp4
    func getImage(){
        if(currentDic.count > 0){
            for (key,value) in currentDic{
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
            if(currentDic.count > 0){
                videoImageDic[key] = img
            }
        }
    }

    
}
