//
//  ViewController.swift
//  Client
//
//  Created by MrHuang on 17/8/2.
//  Copyright © 2017年 Mrhuang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate lazy var socket : HJSocket = HJSocket(addr: "192.168.0.7", port: 8888)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if socket.connectServer() {
            print("链接上服务器")
            socket.startReadMessages()
//            socket.delegate = self
        }
    }
    
    //离开房间则是页面要消失的时候
    override func viewDidDisappear(_ animated: Bool) {
        socket.sendLeaveRoom()
    }
    
    /*
     进入房间 = 0
     离开房间 = 1
     文本 = 2
     礼物 = 3
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func JoinRoom(_ sender: UIButton) {
        
        socket.sendJoinRoom()
    }
    
    @IBAction func LeaveRoom(_ sender: UIButton) {
        socket.sendLeaveRoom()
        
    }
    
    @IBAction func SendTTextMessage(_ sender: UIButton) {
        let msg = "这是一个文本消息"
        socket.sendTextMsg(message: msg)
    }
    
    @IBAction func SendGift(_ sender: UIButton) {
        
        socket.sendGiftMsg(giftName: "火箭", giftURL: "baidu.com", giftCount: 100)
        
    }
}
