//
//  LoginController.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import XMPPFramework

class LoginController: XMPPStreamDelegate {
    
    var xmppStream : XMPPStream!
    var password: String!
    var callerInstance:UIViewController
    
    init(xStream: XMPPStream, password:String, caller: UIViewController){
        self.xmppStream = xStream
        self.password = password
        self.callerInstance = caller
    }
    
    func xmppStreamDidConnect(_ stream: XMPPStream!) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        caller.
        
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("Stream: Not Authenticated \(error.stringValue!)")
        
    }
    
    
}
