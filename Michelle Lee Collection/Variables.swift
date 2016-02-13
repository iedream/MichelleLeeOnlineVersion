//
//  Variables.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2016-01-21.
//  Copyright © 2016 Catherine. All rights reserved.
//

import Foundation
import UIKit

class Variables:UIViewController{
    
    // Singleton
    static let sharedInstance = Variables()
    
    // All Audio Data
    /*let mainTitleData = ["专辑","快乐女声","电视节目","晚会","演唱会"]
    let amblum1:NSMutableDictionary = NSMutableDictionary.init(dictionary:["你看到的我是蓝色的":"http://url.mcvmc.com/xiami.php/1769581822.mp3","习惯":"","爸爸给的坚强":"","被剧中的音符":"","灯":"","我没那么狠心":"","微笑练习":"","你不在的时候":"","沉淀":"","我为谁而来":""])
    let amblum2:NSMutableDictionary = NSMutableDictionary.init(dictionary:["可能":"","房间1501":"","你说的对":"","化妆师":"","私游":"","口袋里的练习曲":"","sorry day":""])
    let amblum3:NSMutableDictionary = NSMutableDictionary.init(dictionary:["沉淀":""])
    let amblum4:NSMutableDictionary = NSMutableDictionary.init(dictionary:["恋爱世纪":""])
    
    // All Video Data
    let competitonVideoMichelle:NSMutableDictionary = NSMutableDictionary.init(dictionary:["从开始到现在":"","说谎":"","白桦林":"","太想爱你":"","彩虹":"","记得":"","一路上由你":"","下沙":"","普通朋友":"","白月光":"","爸爸给的坚强":"","红豆":"","至少还有你":"","不可能错过你":"","说走就走":"","雪候鸟":"","青花瓷":"","最长的电影":""])
    let tvshows:NSMutableDictionary = NSMutableDictionary.init(dictionary:["一起音乐吧":NSMutableDictionary.init(dictionary:["can you feel my world":"","想把我唱给你听":"","心如刀割":"","月亮代表我的心":"","有一个姑娘":"","房间1501":"","白月光":"","化妆师":"","宽容":"","可能":""]),"歌声传奇":NSMutableDictionary.init(dictionary:["思念":"","我的中国心":"","短发":""]),"其他":NSMutableDictionary(dictionary:["一个人的精彩":"","三人游 流沙":"","串烧":"","听妈妈讲那过去的故事":"","寂寞的季节":"","彩虹":"","我的歌声里":"","最长的电影":"","爱我还是她":"","爱是一个字":"","过火":"","蜗牛":""])])
    let nightShowMichelle:NSMutableDictionary = NSMutableDictionary.init(dictionary:["倔强":"","征服":"","祈祷":"","亲密爱人":"","离开地球表面":"","你看到的我是蓝色的":""])
    let concertMichelle:NSMutableDictionary = NSMutableDictionary.init(dictionary:["快乐女声":NSMutableDictionary.init(dictionary:["菊花台":"","落叶归根":"","翅膀":"","只对你说":"","搞笑":""]),"一唱":NSMutableDictionary.init(dictionary:["整场纪录":""])])*/
    
    // List Declarations
    var allAmblum = NSMutableDictionary()
    var allAmblumVideos = NSMutableDictionary()
    var allVideoPlayist = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //allAmblum = NSMutableDictionary.init(dictionary: ["快乐女声":amblum3, "你看到的我是蓝色的":amblum1, "可能":amblum2, "恋爱世纪":amblum4])
        //allVideoPlayist = NSMutableDictionary.init(dictionary:["快乐女声":competitonVideoMichelle,"电视节目":tvshows,"晚会":nightShowMichelle,"演唱会":concertMichelle])
    }
    
    func populatePlayListFromPlist(var list:String){
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(list)
        let fileMananger = NSFileManager.defaultManager()
        if(!fileMananger.fileExistsAtPath(fileURL.path!)){
            list = list.stringByReplacingOccurrencesOfString(".plist", withString: "")
            if let bundlePath = NSBundle.mainBundle().pathForResource(list, ofType: "plist"){
                do{
                    try fileMananger.copyItemAtPath(bundlePath, toPath: fileURL.path!)
                }catch{
                    
                }
            }
        }
        let resultDictionary:NSMutableArray = NSMutableArray(contentsOfFile: fileURL.path!)!
        allAmblum = resultDictionary.objectAtIndex(0) as! NSMutableDictionary
        allVideoPlayist = resultDictionary.objectAtIndex(1) as! NSMutableDictionary
        
        if(list == "OriginalPlayist.plist"){
            sourceMethods.sharedInstance.populateLocalMusic()
            sourceMethods.sharedInstance.populateLocalVideo()
            //allAmblumVideos = resultDictionary.objectAtIndex(2) as! NSMutableDictionary
            writeToModifyPlist()
        }
    }
    
    func writeToModifyPlist(){
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent("ModifiedPlayist.plist")
        let array:NSMutableArray = NSMutableArray.init(array: [allAmblum,allVideoPlayist])
        array.writeToFile(fileURL.path!, atomically: false)
    }
    

}
