//
//  HJSocket.swift
//  Client
//
//  Created by MrHuang on 17/8/2.
//  Copyright © 2017年 Mrhuang. All rights reserved.
//

import UIKit

protocol HJSocketDelegate : class{
    
    func socket(_ socket : HJSocket, JoinRoom user : UserInfo)
    func socket(_ socket : HJSocket, LeaveRoom user : UserInfo)
    func socket(_ socket : HJSocket, TextMessage : TextMessage)
    func socket(_ socket : HJSocket, GiftMessage : GiftMessage)
}

class HJSocket: NSObject {
    
    weak var delegate : HJSocketDelegate?
    
    fileprivate var clientSocket : TCPClient
    
    fileprivate lazy var userInfo : UserInfo.Builder = {
        
        let userInfo = UserInfo.Builder()
        userInfo.name = "name\(arc4random_uniform(10))"
        userInfo.level = 10
       
            return userInfo
    }()
    
    init(addr: String, port: Int) {
        
       clientSocket = TCPClient(addr: addr, port: port)
    }
    
}

extension HJSocket {
    
    //是否链接到服务器
    func connectServer() -> Bool {
        
       return clientSocket.connect(timeout: 5).0
        
    }
    
    // 客户端开始接收服务器发送的消息
    func startReadMessages() {
        
        DispatchQueue.global().async {
            
            while true  {
                
                guard let message = self.clientSocket.read(4) else {
                    
                    continue
                }
                    // 1.读取消息长度
                    let HeadMsgData = Data(bytes: message, count: 4)
                    var lenght : Int = 0
                    (HeadMsgData as NSData).getBytes(&lenght, length: 4)
                    
                    // 2. 读取消息类型
                    var type : Int = 0
                    guard let typeMsg = self.clientSocket.read(2) else {
                        return
                }
                
                    let typeData = Data(bytes: typeMsg, count: 2)
                    var typelenght : Int = 0
                    (typeData as NSData).getBytes(&typelenght, length: 2)
                    
                    // 3. 根据长度 读取真实消息
                    guard let Msg = self.clientSocket.read(lenght) else {
                        return
                    }
                    
                    let MsgData = Data(bytes: Msg, count: lenght)
                
                  // 4. 消息处理
                DispatchQueue.main.async {
                    
                    self.handleMessage(type: type, data: MsgData)
                    
                }

           }
                
        }
        
    }
    
    func handleMessage(type : Int,data : Data){
    
        switch type {
            
        case 0, 1:
            let user = try! UserInfo.parseFrom(data: data)
            print(user.name)
            print(user.level)
            type == 0 ? delegate?.socket(self, JoinRoom: user) : delegate?.socket(self, LeaveRoom: user)
            
        case 2:
            let TextMsg = try! TextMessage.parseFrom(data: data)
            print(TextMsg.text)
            delegate?.socket(self, TextMessage: TextMsg)
            
        case 3:
            let GiftMsg = try! GiftMessage.parseFrom(data: data)
            print(GiftMsg.giftname)
            print(GiftMsg.giftUrl)
            print(GiftMsg.giftCount)
            delegate?.socket(self, GiftMessage: GiftMsg)
            
        default:
            print("未知类型")
        }

        
    }

   }

extension HJSocket {
    
    func sendJoinRoom(){
        
       // 1.获取消息长度
        let msgData = (try! userInfo.build()).data()
       // 2. 发送消息
        sendMsg(data: msgData, type:0)
    
    }
    func sendLeaveRoom(){
        
        // 1.获取消息长度
        let msgData = (try! userInfo.build()).data()
        // 2. 发送消息
        sendMsg(data: msgData, type:1)
        
    
    }
    func sendTextMsg(message : String){
        
        // 1.创建TextMessage的类型
        let textMsg = TextMessage.Builder()
        textMsg.text = message
        // 2.获取对应的Data
        let TextMsgData = (try! textMsg.build()).data()
      
        // 3. 发送消息
        sendMsg(data: TextMsgData, type:2)

    
    }
    func sendGiftMsg(giftName : String,giftURL : String,giftCount : Int){
        
        // 1.创建GiftMessage
        let giftMsg = GiftMessage.Builder()
        giftMsg.giftname = giftName
        giftMsg.giftUrl = giftURL
        giftMsg.giftCount = String(giftCount)
        
        // 2.获取Data
        let GiftMsgData = (try! giftMsg.build()).data()
        // 3.发送消息
        sendMsg(data: GiftMsgData, type: 3)
    }
    
    //发送消息
    func sendMsg(data : Data, type : Int) {
        
        // 2.将消息长度写入到data
        var lenght = data.count
        let HeaderData = Data(bytes: &lenght, count: 4)
        
        // 3.消息类型
        var Temptype = type
        let typeData = Data(bytes: &Temptype, count: 2)
        
        // 4. 发送真实消息
        let totalData = HeaderData + typeData + data
    
        // 如果不需要返回值 则可以在方法中加入 @discardableResult 可遗弃的结果
        clientSocket.send(data: totalData)
        
    }
    


}
