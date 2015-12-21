//
//  listVoiceVC.swift
//  FinalWatch
//
//  Created by Tony on 15/12/7.
//  Copyright © 2015年 Tony. All rights reserved.
//

import UIKit
import AVFoundation

class listVoiceVC: UIViewController ,AVAudioPlayerDelegate ,UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var mytable: UITableView!
    var selectIndex:NSIndexPath?
    
    var audioPlayer:AVAudioPlayer!
    var db:SQLiteDB!
    let cellIdentifier = "myCell"
    var dataArr:NSMutableArray!
    var nowPlaynum:NSInteger!
    var lastPlaynum:NSInteger!
    var timer:NSTimer!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        db = SQLiteDB.sharedInstance()
        
        // UID, price, name, description, image, and category.
        db.execute("create table if not exists products(uid integer primary key,UIDS varchar(20),name varchar(200),price varchar(200),description varchar(200),image varchar(200),category varchar(200))")
        
        initproducts()
    }
    override func viewWillDisappear(animated: Bool)  {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        lastPlaynum = -1
        self.dataArr=NSMutableArray()
        self.mytable!.delegate = self
        self.mytable?.dataSource=self
        self.mytable!.registerNib(UINib(nibName: "VoiceCell", bundle:nil), forCellReuseIdentifier: cellIdentifier)
        let footview:UIView=UIView()
        self.mytable?.tableFooterView=footview
        nowPlaynum=0
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        self.view.addGestureRecognizer(swipeGesture)
        
        if (timer == nil){
            timer=NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "playProgress", userInfo: nil, repeats: true)
        }
        

        // Do any additional setup after loading the view.
    }

    func initproducts()
    {
        let data = self.db.query("select * from Listvoice")
        self.dataArr.removeAllObjects()
        
        if data.count > 0 {
            
            for index in 0...data.count-1  {
                let prducts1 = data[index] as SQLRow
                var dict1 = [String : String]()
                //(uid integer primary key,url varchar(200),name varchar(200),totaltime varchar(200))")
                
                
                let str=prducts1["url"]?.asString()
                
                let strArray = str!.componentsSeparatedByString("file://")
                
                if strArray.count>0
                {
                    
                    dict1["url"]=strArray[1]
                }
                
                dict1["name"]=prducts1["name"]?.asString()
                dict1["totaltime"]=prducts1["totaltime"]?.asString()
                dict1["play"]="0"
                dict1["uids"]=prducts1["uid"]?.asString()
                //                print(dict1)
                self.dataArr.addObject(dict1)
                
                
                
                
            }
           self.mytable!.reloadData()
        }
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataArr.count
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell : VoiceCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VoiceCell
        cell.backgroundColor=UIColor.clearColor()
        cell.selectionStyle=UITableViewCellSelectionStyle.None
        let dic=self.dataArr[indexPath.row] as! NSDictionary
        cell.tag=200000+indexPath.row
        
        var name:NSString=dic["name"] as! String
        name=name.stringByReplacingOccurrencesOfString(".caf", withString: "")
        var time:NSString=dic["totaltime"] as! String
        
        time=(time as String)+"   sec"
        cell.titleLab1.text=name as String
        
        cell.timeLab.text=time as String
        cell.progressV.progress=0;
        cell.playBtn.tag=100000+indexPath.row
        cell.playBtn.addTarget(self, action: "didTappedButton:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView:UITableView, canEditRowAtIndexPath indexPath:NSIndexPath) -> Bool
    {
        return true
    }
    
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            selectIndex=indexPath
            
            deleteAction()
            
            
        }
    }
    
    
    func deleteAction()
    {
        
        let index:Int=(selectIndex?.row)!
        
        let dic=self.dataArr[index] as! NSDictionary
        
        let name:NSString=dic["uids"] as! String
        
        let  flVal = ( name as NSString ).integerValue;
        let sql1 = "DELETE FROM Listvoice WHERE uid =\(flVal)"
        
        let result1 = self.db.execute(sql1)
        
        if result1==1{
            self.dataArr.removeObjectAtIndex(index)
            
            self.mytable!.deleteRowsAtIndexPaths([selectIndex!], withRowAnimation: UITableViewRowAnimation.Automatic)
            initproducts()
        }else{
            
        }
        
        
    }
    
    
    
    func didTappedButton(button: UIButton) {
        
        
        
        
        nowPlaynum=button.tag-100000
        
        
        let dic=self.dataArr[button.tag-100000] as! NSDictionary
        
        let name:NSString=dic["name"] as! String
        
        
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        
        let soundURL = documentDirectory.URLByAppendingPathComponent(name as String)
        let url:NSString=soundURL.absoluteString
        if lastPlaynum != nowPlaynum{
            self.mytable?.reloadData()
            
            if url.length>0{
                do {
                    let url1=NSURL(string: url as String )
                    //                print(url1)
                    try audioPlayer = AVAudioPlayer(contentsOfURL: url1!)
                    audioPlayer.delegate=self
                    audioPlayer.volume=1
                    audioPlayer.play()
                    
                    print("play!!")
                } catch {
                    
                }
            }
            
            
        }
        
        
        if button.selected
        {
            audioPlayer.stop()
            timer.fireDate=NSDate.distantFuture()
            
            button.selected=false
        }
        else{
            audioPlayer.play()
            timer.fireDate=NSDate()
            button.selected=true
            
        }
        lastPlaynum=nowPlaynum
        
    }
    
    
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        let  button=self.view.viewWithTag(nowPlaynum+100000) as! UIButton!
        button.selected=false
        
        
    }
    
    
    //划动手势
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        
        backACction()
        
        
    }
    func backACction()
    {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func playProgress()
    {
        
        let  cell=self.view.viewWithTag(nowPlaynum+200000) as! VoiceCell!
        
        if (audioPlayer != nil ){
            let f1:Double=audioPlayer.currentTime
            print(audioPlayer.currentTime)
            let f2:Double=audioPlayer.duration
            
            let f3:Double=f1/f2
            print(f3)
            let f5 : Float = Float(f3)
            
            cell.progressV.progress=f5
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
