//
//  DataDisplay.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/28/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import SwiftyBeaver


class MessagePlayer{
    
    static public var sharedInstance = MessagePlayer()
    private init(){
        
    }
    
    public var countMsgsPerSender: [String:Int] = [:]
    public var msgsPerSenderRevTS: [String:[JSQMessage]] = [:]
    
    
    public var msgDict:[String:ChatElement]!
    private var msgME:JSQMessageExtension!
    private var chatE:ChatElement!
   // private var msg:JSQMessageExtension!

    public var messages:NSMutableArray!
    
    
    func doM(messages: NSMutableArray){
        msgDict = [String:ChatElement]()
        
        for m in messages{
         msgME = (m as? JSQMessageExtension)!
            var tSenderId = ""
            if( msgME.senderId == AppData.sharedInstance.loggedInUserJid){
                tSenderId = msgME.to
            }else{
                tSenderId = msgME.senderId
            }
            
            if msgDict.index(forKey: tSenderId) != nil{
                let chatElement:ChatElement =  msgDict[tSenderId]!
                chatElement.lastMsg =  msgME.jsqMsgObject.text
                chatElement.lastMsgTS = msgME.date
                chatElement.messagesE.append(msgME)
                }else{
                let chatElement = ChatElement()
                chatElement.name = tSenderId.components(separatedBy: "@")[0].capitalized
                chatElement.senderId = tSenderId
                chatElement.messagesE = [JSQMessageExtension]()
                chatElement.messagesE.append(msgME)
                chatElement.lastMsgTS = msgME.date
                chatElement.lastMsg = msgME.jsqMsgObject.text
                
                msgDict.updateValue(chatElement, forKey: tSenderId)
            }
            
        }
    }
    
}

class ChatElement{
    public var name: String!
    public var lastMsg: String!
    public var lastMsgTS: NSDate!
    public var messagesE:[JSQMessageExtension]!
    public var senderId:String!

    
}
