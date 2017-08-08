//
//  ChatOnXMPPEvents.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation


enum ChatOnXMPPEvents:Int{
    case CONNECT,LOGIN_EVENT,RECIEVE_MESSAGES_EVENT,INT_LOGIN_FAILURE,INT_CONNECT_TIMEOUT
    case RECIEVE_MESSAGES_COMPOSING_EVENT,RECIEVE_MESSAGES_PAUSED_EVENT
        
    
    }
