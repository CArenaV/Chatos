//
//  MessageViewOutgoing.swift
//  Chattos
//
//  Created by Shalabh  Soni on 8/4/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessageViewOutgoing: JSQMessagesCollectionViewCellOutgoing {
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func nib() -> UINib {
        return UINib (nibName: "MessageViewOutgoing", bundle: Bundle.main)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "MessageViewOutgoing"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return "MessageViewOutgoing_JSQMedia"
    }
    
}
