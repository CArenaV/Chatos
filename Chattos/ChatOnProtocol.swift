//
//  ChatOnProtocol.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation


protocol ChatOnProtocol{
    
    func loginSuccess()->Void
    func loginFailed(reason: String)-> Void
    func connectSuccess() -> Void
    func connectFailed(reason: String)-> Void
    var name: String { get }

}
