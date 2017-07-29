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
    
    public var countMsgsPerSender: [String:Int] = [:]
    public var msgsPerSenderRevTS: [String:[JSQMessage]] = [:]
    public var msgs:[String:MessageElement]!
    public var msg:JSQMessage!
    public var messages:NSMutableArray!
    
    
    func doM(messages: NSMutableArray){
        msgs = [String:MessageElement]()
        
        
        for m in messages{
         msg = (m as? JSQMessage)!
            
           SwiftyBeaver.debug(msg.senderId)
            
            if msgs.index(forKey: msg.senderId) != nil{
                var mmm:MessageElement =  msgs[msg.senderId]!
                mmm.lastMsg = msg.text
                mmm.lastMsgTS = msg.date
                mmm.msgs.append(msg)
                }else{
                var me = MessageElement()
                me.name = (msg.senderDisplayName.components(separatedBy: "@")[0]).capitalized
                me.senderId = msg.senderId
                me.msgs = [JSQMessage]()
                me.msgs.append(msg)
                me.lastMsgTS = msg.date
                me.lastMsg = msg.text
                
                msgs.updateValue(me, forKey: msg.senderId)
            }
            
        }
    }
    
}

class MessageElement{
    public var name: String!
    public var lastMsg: String!
    public var lastMsgTS: Date!
    public var msgs:[JSQMessage]!
    public var senderId:String!

    
}
