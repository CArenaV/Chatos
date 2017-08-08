//
//  Utils.swift
//  Chattos
//
//  Created by Shalabh  Soni on 8/8/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import SwiftyBeaver
import XMPPFramework
import JSQMessagesViewController

class Utils{
    
    static func loadMessagesFromArchieve(xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?, jid: String) -> NSMutableArray{
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let retrievedMessages = NSMutableArray()
        var sortedRetrievedMessages = NSArray()
        
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            
            for message in results! {
                
                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                } catch _ {
                    element = nil
                }
                
                let body: String
                var sender: String
                let date: NSDate
                var msg = message as? XMPPMessageArchiving_Message_CoreDataObject
                date = msg?.timestamp as! NSDate
                
                if (message as AnyObject).body() != nil {
                    body = (message as AnyObject).body()
                } else {
                    body = ""
                }
                sender = ""
                if element.attributeStringValue(forName: "to").contains(jid){
                    var displayName = element.attributeStringValue(forName: "from")
                    if ((displayName == nil && ((element.attributeStringValue(forName: "to")).components(separatedBy: "/")[0] == AppData.sharedInstance.loggedInUserJid) ) || (displayName?.components(separatedBy: "/")[0] == (element.attributeStringValue(forName: "to")).components(separatedBy: "/")[0])){
                        continue
                    } else{
                        if(displayName == nil){
                            sender = AppData.sharedInstance.loggedInUserJid
                        }
                        sender = displayName!
                    }
                } else {
                    SwiftyBeaver.info(" To doesn't contain the JID")
                    sender = jid
                }
                
                
                var rng = sender.range(of: "/")
                if rng != nil{
                    SwiftyBeaver.info(rng)
                    sender = sender.components(separatedBy: "/")[0]
                    
                }
                let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date as Date!, text: body)
                var jsqFinal = JSQMessageExtension()
                jsqFinal.to = element.attributeStringValue(forName: "to")
                jsqFinal.jsqMsgObject = fullMessage
                jsqFinal.senderId = sender
                jsqFinal.senderDisplayName = sender.components(separatedBy: "@")[0]
                jsqFinal.date = date
                
                retrievedMessages.add(jsqFinal)
                let descriptor:NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true);
                let descriptor2:NSSortDescriptor = NSSortDescriptor(key: "senderId", ascending: true);
                
                sortedRetrievedMessages = retrievedMessages.sortedArray(using: [descriptor, descriptor2]) as NSArray!;
                
                
                
            }
        } catch _ {
            //catch fetch error here
        }
        return sortedRetrievedMessages.mutableCopy() as! NSMutableArray
    }
    
    static func syncMessages(){
        
    }
    
    static func convXMPPMsgArToJSQMsgExtAr(xmppMessages: [XMPPMessage]) -> [JSQMessageExtension]{
        var jsgMsgExtAr = [JSQMessageExtension]()
        for xmppMessage in xmppMessages{
            let msgText:String? = xmppMessage.forName("body")?.stringValue
            let msgFrom:String? = xmppMessage.attribute(forName: "from")?.stringValue
            let msgTo:String? = xmppMessage.attribute(forName: "to")?.stringValue
            let msgId:String? = xmppMessage.attribute(forName: "id")?.stringValue
            
            var jsqMsgExt = JSQMessageExtension()
            jsqMsgExt.senderId = msgFrom?.components(separatedBy: "/")[0]
            jsqMsgExt.to = msgTo?.components(separatedBy: "/")[0]
            jsqMsgExt.date = NSDate()
            jsqMsgExt.id = msgId

            var jsqMsg = JSQMessage(senderId: jsqMsgExt.senderId, senderDisplayName: jsqMsgExt.senderId.components(separatedBy: "@")[0].capitalized, date: jsqMsgExt.date as Date!, text: msgText)
            
            jsqMsgExt.jsqMsgObject = jsqMsg
            jsgMsgExtAr.append(jsqMsgExt)
        }
        return jsgMsgExtAr
    }
    
    static func convXMPPMsgToJSQMsgExt(xmppMessage: XMPPMessage) -> JSQMessageExtension{
            let msgText:String? = xmppMessage.forName("body")?.stringValue
            var msgFrom:String? = xmppMessage.attribute(forName: "from")?.stringValue
        if(msgFrom == nil){
            msgFrom = AppData.sharedInstance.loggedInUserJid
        }
            let msgTo:String? = xmppMessage.attribute(forName: "to")?.stringValue
            var msgId:String? = xmppMessage.attribute(forName: "id")?.stringValue
        if(msgId == nil){
            msgId = UUID.init().uuidString
        }
            var jsqMsgExt = JSQMessageExtension()
            jsqMsgExt.senderId = msgFrom?.components(separatedBy: "/")[0]
            jsqMsgExt.to = msgTo?.components(separatedBy: "/")[0]
            jsqMsgExt.date = NSDate()
            var jsqMsg = JSQMessage(senderId: jsqMsgExt.senderId, senderDisplayName: jsqMsgExt.senderId.components(separatedBy: "@")[0].capitalized, date: jsqMsgExt.date as Date!, text: msgText)
            jsqMsgExt.id = msgId
            jsqMsgExt.jsqMsgObject = jsqMsg
        
        return jsqMsgExt
    }

    
    
    
    static func playNotifications(){
        
    }
    
}
