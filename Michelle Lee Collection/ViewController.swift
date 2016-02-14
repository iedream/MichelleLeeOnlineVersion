//
//  ViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-07.
//  Copyright © 2015 Catherine. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    // Screen SetUp Property
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var background: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    
    // TableViewRelated Property
    let tableViewCellIdentifier = "tableViewCell"
    let mainTitleViewControllerData = ["mainToAbulm","mainToVideo","mainToVideo","mainToVideo","mainToVideo","mainToEditPage"]
    let mainTitleData = ["专辑","快乐女声","电视节目","晚会","演唱会","Edit Page"]
    var viewToSegueTo:String = " "

    let backGroundImageList:[String:String] = ["快乐女声":"background1.jpg","电视节目":"tvshowBackground.jpg","晚会":"actualtvshowBackground.jpg","演唱会":"concertBackground.jpg"]
    
    
    // Transfer to Video
    var currentName:String = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SetUp TableView
        mainTableView.backgroundColor = UIColor.clearColor()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table View Related Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainTitleData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        cell.textLabel?.text = mainTitleData[row]
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mainTableView.deselectRowAtIndexPath(indexPath, animated: true)
        currentName = mainTitleData[indexPath.row]
        viewToSegueTo = mainTitleViewControllerData[indexPath.row]
        self.performSegueWithIdentifier(mainTitleViewControllerData[indexPath.row], sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "mainToVideo"){
            let destView:VideoViewController = (segue.destinationViewController as?VideoViewController)!
            if(currentName != "快乐女声" && currentName != "晚会"){
                destView.mainDicMulti = NSMutableDictionary(dictionary: Variables.sharedInstance.allVideoPlayist[currentName]?.copy() as! NSDictionary)
                destView.imageName = backGroundImageList[currentName]!
                destView.getImage()
                
            }else{
                destView.mainDicSingle = NSMutableDictionary(dictionary:Variables.sharedInstance.allVideoPlayist[currentName]?.copy() as! NSDictionary)
                destView.imageName = backGroundImageList[currentName]!
                destView.getImage()
            }
            
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
            return UIInterfaceOrientationMask.Portrait
    }

}

