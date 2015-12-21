//
//  ViewController.swift
//  FinalWatch
//
//  Created by Tony on 15/12/7.
//  Copyright © 2015年 Tony. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var im2: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var namestr = ""
    var urlstr:NSURL!
    var db:SQLiteDB!
    var timer:NSTimer!
    ////定义音频的编码参数，这部分比较重要，决定录制音频文件的格式、音质、容量大小等，建议采用AAC的编码方式
    let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),//声音采样率
        AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),//编码格式
        AVNumberOfChannelsKey : NSNumber(int: 1),//采集音轨
        AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))]//音频质量
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        im2.hidden=true
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: self.directoryURL()!,
                settings: recordSettings)//初始化实例
            audioRecorder.prepareToRecord()//准备录音
        } catch {
            
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        db = SQLiteDB.sharedInstance()
        // UID, price, name, description, image, and category.
        db.execute("create table if not exists Listvoice(uid integer primary key,url varchar(200),name varchar(200),totaltime varchar(200))")

        

        //左划
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left //不设置是右
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        let longpress=UILongPressGestureRecognizer(target: self, action: "handlepress:")
        
        self.playBtn.addGestureRecognizer(longpress)
        
        
        

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    //划动手势
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        gotoNextVC()
        
        
    }
    
    func  handlepress(sender:UILongPressGestureRecognizer)
    {
        //        print(sender.state)
        if sender.state == UIGestureRecognizerState.Began{
            print("开始")
            
            
            timer=NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "detectionVoice", userInfo: nil, repeats: true)
            
            playAction()
            im2.hidden=false
            
            let btnimage=UIImage(imageLiteral: "select_yes")
            self.playBtn.setBackgroundImage(btnimage, forState: UIControlState.Normal)
        }
        
        
        if sender.state==UIGestureRecognizerState.Ended{
            im2.hidden=true
            timer.invalidate()
            finishPlayAction()
            let btnimage=UIImage(imageLiteral: "select_no")
             self.playBtn.setBackgroundImage(btnimage, forState: UIControlState.Normal)
            print("结束")
        }
    }
    
    
    
    func directoryURL() -> NSURL? {
        //定义并构建一个url来保存音频，音频文件名为ddMMyyyyHHmmss.caf
        //根据时间来设置存储文件名
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".caf"
        namestr=recordingName
        
        print(namestr)
        
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent(recordingName)
        //        print(soundURL)
        urlstr=soundURL
        return soundURL
    }
    
    func didTappedButton(button: UIButton) {
        
        
        print(button.selected)
        if button.selected
        {
            finishPlayAction()
            
            button.selected=false
        }
        else{
            
            playAction()
            button.selected=true
            
        }
    }
    
    
    func playAction()
    {
        //开始录音
        
        timer=NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "detectionVoice", userInfo: nil, repeats: true)
        
        
        if !audioRecorder.recording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                //开启音量检测
                audioRecorder.meteringEnabled = true
                print("record!")
            } catch {
            }
        }
        
    }
    
    
    func finishPlayAction()
    {
        //结束录音
        
        timer.invalidate()
        print(audioRecorder.currentTime)
        let timestr:NSString =  NSString(format: "%.02f", audioRecorder.currentTime)
        print(timestr)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
            print("stop!!")
        } catch {
        }
        //        url varchar(20),name varchar(200),totaltime varchar(200))")
        let sql1 = "insert into Listvoice(url,name,totaltime) values('\(urlstr)','\(namestr)','\(timestr)')"
        
        let result1 = self.db.execute(sql1)
        print(result1)
        
        gotoNextVC()
        
    }
    
    func gotoNextVC()
    {
        
        
        
        let myStoryBoard = UIStoryboard(name:"Main", bundle: nil)
        //        let listController = sb.instantiateViewControllerWithIdentifier("demoList") as! DemoListViewController
        //        self.presentViewController(listController, animated: true, completion: nil)
        
        
        let twovc:UIViewController=myStoryBoard.instantiateViewControllerWithIdentifier("post") as UIViewController
       
        twovc.modalTransitionStyle=UIModalTransitionStyle.FlipHorizontal
        self.presentViewController(twovc, animated: true, completion: nil)
//        let tow_vc = listVoiceVC()
//        tow_vc.modalTransitionStyle=UIModalTransitionStyle.FlipHorizontal
//        self.presentViewController(tow_vc, animated: true, completion: nil)
//        
//        
        
        
    }
    
    func   detectionVoice()
    {
        
        
        audioRecorder!.updateMeters() // 刷新音量数据
        
        let averageV:Float = audioRecorder!.averagePowerForChannel(0) //获取音量的平均值
        let maxV:Float = audioRecorder!.peakPowerForChannel(0) //获取音量最大值
        let lowPassResults:Double = pow(Double(10), Double(0.05*maxV))
        print(maxV)
        
        
        print("你好")
        
        //最大50  0
        //图片 小-》大
        if lowPassResults < 0 {
            print("0.0000")
        }
        else if lowPassResults  < 0.06  {
            print("0.06")
            let image1=UIImage(imageLiteral: "record_animate_01.png")
            im2.image=image1
        }
        else if lowPassResults  < 0.13{
            print("0.13")
            let image1=UIImage(imageLiteral: "record_animate_02.png")
            im2.image=image1
        }
        else if lowPassResults  < 0.20{
            
            let image1=UIImage(imageLiteral: "record_animate_03.png")
            im2.image=image1
        }
        else if lowPassResults  < 0.27{
            
            let image1=UIImage(imageLiteral: "record_animate_04.png")
            im2.image=image1
        }
        else if lowPassResults  < 0.34{
            
            let image1=UIImage(imageLiteral: "record_animate_05.png")
            im2.image=image1
        }
        else if lowPassResults  < 0.41{
            
            let image1=UIImage(imageLiteral: "record_animate_06.png")
            im2.image=image1
        }else if lowPassResults  < 0.48{
            
            let image1=UIImage(imageLiteral: "record_animate_07.png")
            im2.image=image1
        }else if lowPassResults  < 0.55{
            
            let image1=UIImage(imageLiteral: "record_animate_08.png")
            im2.image=image1
            
        }else if lowPassResults  < 0.62{
            
            let image1=UIImage(imageLiteral: "record_animate_09.png")
            im2.image=image1
            
        }
        else if lowPassResults  < 0.69{
            
            let image1=UIImage(imageLiteral: "record_animate_10.png")
            im2.image=image1
            
        }
        else if lowPassResults  < 0.76{
            
            let image1=UIImage(imageLiteral: "record_animate_11.png")
            im2.image=image1
            
        }
        else if lowPassResults  < 0.83{
            
            let image1=UIImage(imageLiteral: "record_animate_12.png")
            im2.image=image1
            
        }
        else if lowPassResults  < 0.90{
            
            let image1=UIImage(imageLiteral: "record_animate_13.png")
            im2.image=image1
            
        }
        else{
            let image1=UIImage(imageLiteral: "record_animate_14.png")
            im2.image=image1
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

