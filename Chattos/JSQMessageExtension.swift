//
//  JSQMessageExtension.swift
//  Chattos
//
//  Created by Shalabh  Soni on 8/7/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class JSQMessageExtension: NSObject{
    public var to:String!
    public var status: Int!
    public var jsqMsgObject: JSQMessage!
    public var senderId : String!
    public var senderDisplayName:String!
    public var date: NSDate!
    public var id: String!
}
