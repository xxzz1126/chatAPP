//
//  RootViewController.swift
//  1234
//
//  Created by admin on 2016/11/2.
//  Copyright © 2015年 admin. All rights reserved.
//

import UIKit

let kScreenSize         =            UIScreen.mainScreen.bounds.size
let kScreenWidth        =            UIScreen.mainScreen.bounds.size.width
let kScreenHeight       =            UIScreen.mainScreen.bounds.size.height
let kMainScale:CGFloat  =            0.8
let kRightContentWidth:CGFloat =     100
let kLeftWidth:CGFloat  =            200

class RootViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var backImage:UIImageView!
    var tableView:UITableView?                          //左侧视图
    var backView:UIView?                                //蒙板
    var currentTranslateX:CGFloat?
    var contentView:UIView?                             //当前显示的视图
    
    var currentViewController:UIViewController = UIViewController(){
        willSet(newCurrentViewController){
            self.currentViewController.view.removeFromSuperview()
        }
        didSet(currentViewController){
            
            self.contentView!.addSubview(self.currentViewController.view)
        }
    }
    
    var viewControllers:Array<UIViewController> = []{
       
        willSet(newViewControllers){
            
        }
        didSet(newViewControllers){
            for viewController:UIViewController in newViewControllers {
                self.addChildViewController(viewController)
            }
        }
    }
    
    func closeLeftView(){
       
        UIView.transitionWithView(self.contentView!, duration: 0.15, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            self.contentView!.transform = CGAffineTransformMakeTranslation(0, 0)
            self.updateFrameWithTransX(0, maxTrans: kScreenWidth - 100 / kMainScale)
            
        }, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addViews()
        self.currentViewController = self.viewControllers[0]
        
    }
    
    func addViews(){
        
        backImage = UIImageView(frame: self.view.bounds)
        backImage.image = UIImage(named: "backImage")
        backImage.userInteractionEnabled = true
        self.view.addSubview(backImage)
        
        createLeftView()
        
        self.backView = UIView(frame: self.view.bounds)
        self.backView!.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.backView!)
        
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "showLeftView:")
        self.contentView = UIView(frame: self.view.bounds)
        self.contentView!.addGestureRecognizer(pan)
        self.view.addSubview(self.contentView!)
        
    }
    
  
    func createLeftView(){
        var leftView = UIView(frame: CGRectMake(0, 0, kScreenWidth - kRightContentWidth, kScreenHeight))
        
        var headerView = UIView(frame: CGRectMake(0, 20, self.view.bounds.size.width, 150))
        headerView.backgroundColor = UIColor.clearColor()
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapActon"))
        
        self.tableView = UITableView(frame: CGRectMake(0, CGRectGetMaxY(headerView.frame), self.view.bounds.size.width, self.view.bounds.size.height - 100 - CGRectGetMaxY(headerView.frame)), style: UITableViewStyle.Plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.view.addSubview(leftView)
        self.view.addSubview(headerView)
        self.view.addSubview(self.tableView!)
    }
    
    func showLeftView(sender:UIPanGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began {
            currentTranslateX = self.contentView!.transform.tx
            println(currentTranslateX)
        }
        
        if sender.state == UIGestureRecognizerState.Changed {
            var point:CGPoint = sender.translationInView(self.contentView!)
            var transX:CGFloat = point.x + currentTranslateX!
            
            if transX > 0 {
              
                var scale:CGFloat = 1 - transX * (1 - kMainScale) / (kScreenWidth - kRightContentWidth / kMainScale)
                sender.view!.transform = CGAffineTransformMake(scale, 0, 0, scale, transX, 0)
               
                self.updateFrameWithTransX(transX, maxTrans: kScreenWidth - 100 / kMainScale)
               
                if transX >= kScreenWidth - 100 / kMainScale{
                    sender.view!.transform = CGAffineTransformMake(kMainScale, 0, 0, kMainScale, kScreenWidth - kRightContentWidth / kMainScale, 0)
                }
                
            }else{
                sender.view!.transform = CGAffineTransformMakeTranslation(0, 0)
            }
        }
        if sender.state == UIGestureRecognizerState.Ended {
            if sender.view!.frame.origin.x >= kScreenWidth * 0.3 {
                UIView.transitionWithView(sender.view!, duration: 0.15, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    sender.view!.transform = CGAffineTransformMake(kMainScale, 0, 0, kMainScale, kScreenWidth - kRightContentWidth / kMainScale, 0)
                    self.updateFrameWithTransX(kScreenWidth - 100 / kMainScale, maxTrans: kScreenWidth - 100 / kMainScale)
                }, completion: { (Bool) -> Void in
                    
                })
            }else{
                UIView.transitionWithView(sender.view!, duration: 0.15, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    sender.view!.transform = CGAffineTransformMakeTranslation(0, 0)
                }, completion: nil)
            }
        }
    }
    
    func updateFrameWithTransX(transX:CGFloat,maxTrans:CGFloat){
        
        var scale:CGFloat = (1-kMainScale) * transX / maxTrans + kMainScale
        
        var transX1:CGFloat =  -(kScreenWidth / 2 + kLeftWidth) * scale + kScreenWidth / 2 + kLeftWidth
        
        var backAlpha:CGFloat = -(1 / (1 - kMainScale)) * scale + (1 / (1 - kMainScale))
        print(transX1)
        if(scale <= 1){
            self.tableView!.transform = CGAffineTransformMake(scale, 0, 0, scale, -transX1, 0);
            self.backView!.alpha = backAlpha
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String = "Mycell"
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
            cell!.backgroundColor = UIColor.clearColor()
        }
        cell!.textLabel?.text = "测试"
        cell!.textLabel?.textColor = UIColor.white
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.currentViewController = self.viewControllers[indexPath.row]
        self.closeLeftView()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

