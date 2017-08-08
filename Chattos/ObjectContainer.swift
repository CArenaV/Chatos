//
//  ObjectContainer.swift
//  Chattos
//
//  Created by Shalabh  Soni on 8/3/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import XMPPFramework

class ObjectContainer{
    public static let sharedInstance = ObjectContainer()
    public var xmppStream:XMPPStream!
    public var moc: NSManagedObjectContext!
    public var xmppRosterStorage: XMPPRosterCoreDataStorage!
    public var messagePlayer: MessagePlayer!
    public var xmppRoster: XMPPRoster!
    private init(){
        
    }
    
    
    
}
