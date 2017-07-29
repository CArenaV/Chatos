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


enum XMPPControllerError: Error {
    case wrongUserJID
}

public class ChatOnXMPPController: NSObject{
    
    var hostName: String!
    var jabberId: XMPPJID!
    var hostPort: UInt16!
    var password: String!
    //let domain:String!
    
    static let sharedInstance = ChatOnXMPPController();
        /*
     Central XMPP Interface between Application and XMPP Server for Messaging.
     */
    
    var listeners: [Int:[ChatOnProtocol?]] = [:];
    var xmppStream:XMPPStream!
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream!)  {
        
    }
    
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!){
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.INT_CONNECT_TIMEOUT, error: "There was an issue connecting to the domain: \(self.hostName!)")
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!){
        SwiftyBeaver.info("[LOGGER ] Not authenitcated : \(error)");
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.INT_LOGIN_FAILURE, error: error.stringValue!)
    }
    
    func registerForEvents(caller: ChatOnProtocol, event: ChatOnXMPPEvents){
        SwiftyBeaver.info("[LOGGER]In registerForEvents");
        var existingObjects = listeners[event.rawValue] as? [ChatOnProtocol]
        
        if(existingObjects != nil){
            existingObjects?.append(caller)
            
            SwiftyBeaver.info("[LOGGER]Registering \(caller.name), for Event: \(event) - Queue Size = \(String(describing: existingObjects?.count))")
        }else{
            
            listeners.updateValue([caller], forKey: event.rawValue)
            SwiftyBeaver.info("[LOGGER]Registering \(caller.name), for Event: \(event) via an Update Operation")
        }
    }
    
    
    
    func build(jabberId :String, password:String) throws{
        guard let userJID = XMPPJID(string: jabberId) else {
            throw XMPPControllerError.wrongUserJID
        }
        self.hostName = Constants.hostName
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
    
    
    
    func invokeRegisteredListeners(forEvent : ChatOnXMPPEvents, error: String) -> Void{
        
        SwiftyBeaver.info("[LOGGER] Invoking registered listeners for \(forEvent)")
        switch forEvent.rawValue {
        case ChatOnXMPPEvents.CONNECT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == forEvent.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        i?.connectSuccess();
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
                        i?.loginSuccess();
                        
                        
                    }
                }
                
            }
            
            
            break;
        case ChatOnXMPPEvents.MESSAGES_EVENT.rawValue:
            for (event, callers) in listeners {
                SwiftyBeaver.info("[LOGGER]----- \(event) \(callers)")
                if(event == forEvent.rawValue)
                {
                    for i in callers{
                        SwiftyBeaver.info("[LOGGER]Invoking \(forEvent) for \(String(describing: i?.name))")
                        //i.message();
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
                        i?.loginFailed(reason:error);
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
                        i?.loginFailed(reason: error);
                    }
                }
                
            }
            
            break;
            
            
        default:
            SwiftyBeaver.info("[LOGGER] IN Default Case");
            break;
        }
        
        
    }
    
    func xmppStreamDidConnect(_ stream: XMPPStream!) {
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.CONNECT,error: "");
        try! stream.authenticate(withPassword: self.password)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        invokeRegisteredListeners(forEvent: ChatOnXMPPEvents.LOGIN_EVENT,error: "");
    }
    
    
    
    
    
}







