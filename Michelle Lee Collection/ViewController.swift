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
    let mainTitleData = ["专辑","快乐女声",/*"电视节目"*/"其他","晚会","演唱会","Edit Page"]
    var viewToSegueTo:String = " "

    // Video Data
    /*let competitonVideoMichelle:[String:String] = ["从开始到现在":"video1","说谎":"video2","白桦林":"video3","太想爱你":"video4","彩虹":"video5","记得":"video6","一路上由你":"video21","下沙":"video22","普通朋友":"video23","白月光":"video24","爸爸给的坚强":"video25","红豆":"video26","至少还有你":"video27","不可能错过你":"video28","说走就走":"video29","雪候鸟":"video30","青花瓷":"video31","最长的电影":"video32"]
    let tvshows:[String:[String:String]] = ["一起音乐吧":["can you feel my world":"video60","想把我唱给你听":"video61","心如刀割":"video62","月亮代表我的心":"video63","有一个姑娘":"video64","房间1501":"video65","白月光":"video66","化妆师":"video67","宽容":"video68","可能":"video69"],"歌声传奇":["思念":"video70","我的中国心":"video71","短发":"video72"],"其他":["一个人的精彩":"video73","三人游 流沙":"video74","串烧":"video75","听妈妈讲那过去的故事":"video76","寂寞的季节":"video77","彩虹":"video78","我的歌声里":"video79","最长的电影":"video80","爱我还是她":"video81","爱是一个字":"video82","过火":"video83","蜗牛":"video84"]]
    let nightShowMichelle:[String:String] = ["倔强":"video100","征服":"video101","祈祷":"video102","亲密爱人":"video103","离开地球表面":"video104","你看到的我是蓝色的":"video105"]
    let concertMichelle:[String:[String:String]] = ["快乐女声":["菊花台":"video110","落叶归根":"video111","翅膀":"video112","只对你说":"video113","搞笑":"video114"],"一唱":["整场纪录":"video115"]]
    var allVideoPlayist:[String:AnyObject] = [String:AnyObject]()*/
    let backGroundImageList:[String:String] = ["快乐女声":"background1.jpg",/*"电视节目"*/"其他":"tvshowBackground.jpg","晚会":"actualtvshowBackground.jpg","演唱会":"concertBackground.jpg"]
    
    
    // Transfer to Video
    var currentName:String = String()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SetUp TableView
        mainTableView.backgroundColor = UIColor.clearColor()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        //allVideoPlayist["快乐女声"] = competitonVideoMichelle
        //allVideoPlayist["电视节目"] = tvshows
        //allVideoPlayist["晚会"] = nightShowMichelle
        //allVideoPlayist["演唱会"] = concertMichelle
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

