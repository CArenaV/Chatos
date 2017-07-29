//
//  XMPPController.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import XMPPFramework

enum XMPPControllerError: Error {
    case wrongUserJID
}

class XMPPController: NSObject {
    var xmppStream: XMPPStream!
    let hostName: String!
    let userJID: XMPPJID!
    let hostPort: UInt16!
    let password: String!
    
     
    
    
    init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String)throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPControllerError.wrongUserJID
        }
        self.hostName = hostName
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password
        
        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        
        super.init()
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    
    func addDeletageXMPPStream(caller: XMPPStreamDelegate)->Void{
        self.xmppStream.addDelegate(caller, delegateQueue: DispatchQueue.main)
    }
    
    
    func connect() {
        if !self.xmppStream.isDisconnected() {
            return
        }
        
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
    
    
    
}


extension XMPPController: XMPPStreamDelegate {
    
    func xmppStreamDidConnect(_ stream: XMPPStream!) {
        SwiftyBeaver.info"Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        SwiftyBeaver.info"Stream: Authenticated")
    }
}
