//
//  ChatOnProtocol.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation


@objc protocol ChatOnProtocol{
    
    @objc optional func loginSuccess()->Void
    @objc optional func loginFailed(reason: String)-> Void
    @objc optional func connectSuccess() -> Void
    @objc optional func connectFailed(reason: String)-> Void
    @objc optional func recievedMessage(additionalInfo: [String:Any])-> Void
    var name: String { get }

}
