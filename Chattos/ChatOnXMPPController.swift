//
//  ChatOnXMPPController.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import XMPPFramework
import CocoaLumberjack
import SwiftyBeaver
import JSQMessagesViewController


enum XMPPControllerError: Error {
    case wrongUserJID
}

public class ChatOnXMPPController: NSObject, XMPPStreamDelegate{
    
    var hostName: String!
    var jabberId: XMPPJID!
    var hostPort: UInt16!
    var password: String!
    var _isIQSent: Bool!
    //let domain:String!
    
    static let sharedInstance = ChatOnXMPPController();
    
    private override init(){
        _isIQSent = false
    }
        /*
     Central XMPP Interface between Application and XMPP Server for Messaging.
     */
    
    var listeners: [Int:[ChatOnProtocol?]] = [:];
    var xmppStream:XMPPStream!
    
    public func xmppStreamConnectDidTimeout(_ sender: XMPPStream!)  {
        
    }
    
    
    public func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!){
        var oA:[String:Any?] = [String:Any]();
        
        oA["error"] = "There was an issue connecting to the domain: \(self.hostName!)"
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.INT_CONNECT_TIMEOUT, optionalAttribs:oA)
    }
    
    public func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!){
        var oA:[String:Any?] = [String:Any]();
        oA["error"] = "\(error.stringValue!)"
        SwiftyBeaver.info("[LOGGER ] Not authenitcated : \(error)");
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.INT_LOGIN_FAILURE, optionalAttribs: oA)
    }
    
    func registerForEvents(caller: ChatOnProtocol, event: ChatOnXMPPEvents){
        SwiftyBeaver.info(caller)
        SwiftyBeaver.error(listeners)
        SwiftyBeaver.info("[LOGGER]In registerForEvents \(caller.name)");
        
        var existingObjects = listeners[event.rawValue]
        if(existingObjects != nil){
            if(type(of:caller) == ViewChat.self){
              existingObjects?.removeAll()
                
                existingObjects?.append(caller)
                
                SwiftyBeaver.info(existingObjects)
                    listeners[event.rawValue] = existingObjects

            }
            SwiftyBeaver.info("[LOGGER]Registering \(caller.name), for Event: \(event) - Queue Size = \(String(describing: existingObjects?.count))")
            listeners[event.rawValue] = existingObjects
        }else{
            listeners.updateValue([caller], forKey: event.rawValue)
            SwiftyBeaver.info("[LOGGER]Registering \(caller.name), for Event: \(event) via an Update Operation")
            
        }
        SwiftyBeaver.warning(listeners)

    }
    
    
    
    func build(jabberId :String, password:String, ip: String) throws{
        guard let userJID = XMPPJID(string: jabberId) else {
            throw XMPPControllerError.wrongUserJID
        }
        
        self.hostName = ip
        self.jabberId = userJID
        self.hostPort = Constants.port
        self.password = password
        
        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        DDLog.add(DDTTYLogger.sharedInstance, with: DDLogLevel.all)
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
    }
    
    func connect() {
        print ("[LOGGER]IN Connect");
        if !self.xmppStream.isDisconnected() {
            return
        }
        do{
            try self.xmppStream.connect(withTimeout: 1);
        }catch is Error{
            SwiftyBeaver.info( "[LOGGER]-------\(Error.self)")
        }
    }
    
    
    
    func invokeRegisteredListeners(forEvent : ChatOnXMPPEvents, optionalAttribs : [String:Any]) -> Void{
        
        SwiftyBeaver.info("[LOGGER] Invoking registered listeners for \(forEvent)")
        switch forEvent.rawValue {
        case ChatOnXMPPEvents.CONNECT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == forEvent.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        i?.connectSuccess!();
                    }
                }
            }
            break;
            
            
        case ChatOnXMPPEvents.LOGIN_EVENT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == forEvent.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        i?.loginSuccess!();
                        
                        
                    }
                }
                
            }
            
            
            break;
        case ChatOnXMPPEvents.RECIEVE_MESSAGES_EVENT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers), Reciever Key: \(optionalAttribs[Constants.RECIEVER_KEY])")
                if(event == forEvent.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        if(optionalAttribs[Constants.MESSAGE_SUBEVENT_KEY] != nil){
                            var oA = [String:Any]()
                            oA[Constants.MESSAGE_SUBEVENT_KEY] = optionalAttribs[Constants.MESSAGE_SUBEVENT_KEY]
                            oA[Constants.RECIEVER_KEY] = optionalAttribs[Constants.RECIEVER_KEY]
                        i?.recievedMessage!(additionalInfo: oA);
                        }else{
                            var oA = [String:Any]()

                            oA[Constants.RECIEVER_KEY] = optionalAttribs[Constants.RECIEVER_KEY]
                            oA[Constants.MESSAGE_SUBEVENT_KEY] = "RECIEVE_MESSAGES_EVENT"
                            oA[Constants.MESSAGE_CONTENT] = optionalAttribs[Constants.MESSAGE_CONTENT]
                                oA[Constants.MESSAGE_JSQ_EXT] = optionalAttribs[Constants.MESSAGE_JSQ_EXT]
                                i?.recievedMessage!(additionalInfo: oA);
                        }
                    }
                }
                
            }
            
            break;
        case ChatOnXMPPEvents.INT_LOGIN_FAILURE.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == ChatOnXMPPEvents.LOGIN_EVENT.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        i?.loginFailed!(reason:optionalAttribs["error"] as! String);
                    }
                }
                
            }
            
            break;
        case ChatOnXMPPEvents.INT_CONNECT_TIMEOUT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == ChatOnXMPPEvents.CONNECT.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        i?.loginFailed!( reason:optionalAttribs["error"] as! String);
                    }
                }
                
            }
            
            break;
            
            
        default:
            SwiftyBeaver.info("[LOGGER] IN Default Case");
            break;
        }
        
        
    }
    
    func knownUserForJid(jidStr: String!) -> Bool{
        if  (ObjectContainer.sharedInstance.messagePlayer.msgDict.index(forKey: jidStr) != nil){
            return true
        }
        return false
        
    }
    
    public func xmppStreamDidConnect(_ stream: XMPPStream!) {
        var oA:[String:Any?] = [String:Any]();
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.CONNECT,optionalAttribs: oA);
        try! stream.authenticate(withPassword: self.password)
    }
    
    func addUserToChatList(senderJidStr: String!,recieverJidStr:String!,  message: JSQMessageExtension){
        let senderUserJID = XMPPJID.init(string: senderJidStr)
        let recieverUserJID = XMPPJID.init(string: recieverJidStr)

        ObjectContainer.sharedInstance.xmppRoster.addUser(senderUserJID!, withNickname: senderJidStr)
        if  ObjectContainer.sharedInstance.messagePlayer.msgDict.index(forKey: recieverJidStr) == nil{
            SwiftyBeaver.warning("Here 1")
            var chatElement = ChatElement()
            chatElement.lastMsg = message.jsqMsgObject.text
            chatElement.messagesE
                = [message]
            
            chatElement.name = ObjectContainer.sharedInstance.xmppRosterStorage.user(for: senderUserJID, xmppStream: xmppStream, managedObjectContext: ObjectContainer.sharedInstance.moc!).displayName
            chatElement.senderId = senderJidStr
            chatElement.lastMsgTS = message.date
            ObjectContainer.sharedInstance.messagePlayer.msgDict.updateValue(chatElement, forKey: recieverJidStr)
        }else{
            SwiftyBeaver.warning("Here 2")

            var chatElement =  ObjectContainer.sharedInstance.messagePlayer.msgDict[recieverJidStr]

            chatElement?.lastMsg = message.jsqMsgObject.text
            chatElement?.lastMsgTS = message.date
            chatElement?.messagesE.append(message)
            ObjectContainer.sharedInstance.messagePlayer.msgDict.updateValue(chatElement!, forKey: recieverJidStr)
        }
    }
    
 
    func getAllRegisteredUsers()
    {
        SwiftyBeaver.info("GetAllRegUsers Invoked")
    var query = try? XMLElement(xmlString: "<query xmlns='http://jabber.org/protocol/disco#items' node='all users'/>")
        
     var iq =   XMPPIQ(type: "get", to: XMPPJID(string:"localhost"), elementID:
            xmppStream.generateUUID(), child: query)
        SwiftyBeaver.debug(iq);
        _isIQSent = true
        xmppStream.send(iq)

    }

    

    public func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        var queryElement: XMLElement? = iq.forName("query", xmlns: "http://jabber.org/protocol/disco#items")
        var itemElements = queryElement?.elements(forName: "item")
        if itemElements == nil{
            SwiftyBeaver.info("IQ Empty Elements")
            return true
        }
        _isIQSent = false
        var mArray = NSMutableArray()
        for i in itemElements!{
            var t = i as? DDXMLElement
            SwiftyBeaver.info(t)
        var jid = t?.attribute(forName: "jid")
            SwiftyBeaver.info(jid)
            SwiftyBeaver.error("Here we are : \(knownUserForJid(jidStr: jid?.stringValue))")
        mArray.add(jid)

        }

        
        return true
        
        print("End receive IQ")

    }
    
    
    
     public func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage) {
        
        SwiftyBeaver.info("Recieved Message : \(message.from())");
        SwiftyBeaver.error("Message \(ObjectContainer.sharedInstance.moc)")
        
        if(ObjectContainer.sharedInstance.moc != nil){
            SwiftyBeaver.warning("MOC is Not Nil")
            if message.isMessageWithBody(){
               // getAllRegisteredUsers()
                let user = ObjectContainer.sharedInstance.xmppRosterStorage.user(for: message.from(), xmppStream: xmppStream, managedObjectContext: ObjectContainer.sharedInstance.moc)
                if let msg: String = message.forName("body")?.stringValue {
                    if let from: String = message.attribute(forName: "from")?.stringValue {
                        let updatedFrom = from.components(separatedBy: "/")[0]
                        let messageX = JSQMessage(senderId: updatedFrom, senderDisplayName: updatedFrom, date: NSDate() as Date!, text: msg)
                        let recieverJidStr = (message.attribute(forName: "to")?.stringValue?.components(separatedBy: "/")[0])
                        SwiftyBeaver.warning("Message to : \(recieverJidStr)")
                         var jsqMsgEx = Utils.convXMPPMsgToJSQMsgExt(xmppMessage: message)
                        addUserToChatList(senderJidStr: user?.jidStr, recieverJidStr: recieverJidStr, message: jsqMsgEx)
                        var oA:[String:Any?] = [String:Any]();
                        oA[Constants.RECIEVER_KEY] = recieverJidStr
                        oA[Constants.MESSAGE_CONTENT] = msg
                       
                        oA[Constants.MESSAGE_JSQ_EXT] = jsqMsgEx

   invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.RECIEVE_MESSAGES_EVENT, optionalAttribs: oA)
                        
                    }
                }
                
                
                
            }else if message.forName("composing")?.stringValue != nil{
                let recieverJidStr = (message.attribute(forName: "to")?.stringValue?.components(separatedBy: "/")[0])

                var oA:[String:Any? ] = [String:Any]();
                let from: String = (message.attribute(forName: "from")?.stringValue)!
                oA[Constants.MESSAGE_SUBEVENT_KEY]=ChatOnXMPPEvents.RECIEVE_MESSAGES_COMPOSING_EVENT
                oA[Constants.RECIEVER_KEY] = recieverJidStr
                invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.RECIEVE_MESSAGES_EVENT, optionalAttribs: oA)
                
            }else if message.forName("paused")?.stringValue != nil{
                var oA:[String:Any?] = [String:Any]();
                let recieverJidStr = (message.attribute(forName: "to")?.stringValue?.components(separatedBy: "/")[0])


                oA[Constants.MESSAGE_SUBEVENT_KEY]=ChatOnXMPPEvents.RECIEVE_MESSAGES_PAUSED_EVENT
                oA[Constants.RECIEVER_KEY] = recieverJidStr
                invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.RECIEVE_MESSAGES_EVENT, optionalAttribs: oA)
                
            }
        
        
            
         
        }
    }
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        var oA:[String:Any? ] = [String:Any]();
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.LOGIN_EVENT,optionalAttribs: oA);
    }
    
    
    
    
    
}







