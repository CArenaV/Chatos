//
//  ViewChat.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/28/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import UIKit
import SwiftyBeaver
import XMPPFramework
import CocoaLumberjack
import JSQMessagesViewController
import CoreData

class ViewChat: JSQMessagesViewController{
    @IBOutlet var chatArea: UIView!
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        
    }
    @IBOutlet weak var chatTitle: UINavigationItem!
    @IBOutlet weak var imageBarBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    public var msgElement:MessageElement!
    public var user:XMPPUserCoreDataStorageObject!
    
    public var xmppvCardAvatarModule: XMPPvCardAvatarModule!
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
        override func viewDidLoad() {
        super.viewDidLoad()
            
           
         chatTitle.title = msgElement.name
            
            let button = UIButton.init(type: .custom)
            button.setImage(getPhotoForUser(user: user), for: UIControlState.normal)
            
            DispatchQueue.main.async{
                do{
                    
                    DispatchQueue.global().sync{
                        button.layer.cornerRadius = button.frame.size.width / 2;
                        button.clipsToBounds = true;
                        //self.profileImageURL.image = data.profileImage
                        
                    }
                }catch {
                    
                }
            }
            button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
            imageBarBtn.customView = button
            messages = msgElement.msgs
        var xx = JSQMessagesViewController()
        xx.automaticallyScrollsToMostRecentMessage = true
        //userName.text = msgElement.name.components(separatedBy: "@")[0].capitalized
       //userPhoto.image = getPhotoForUser(user: user)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.init(width: 10, height: 10)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.init(width: 10, height: 10)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
  
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var sndr = messages[indexPath.item].senderId
        
        
        return  JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: (xmppvCardAvatarModule?.photoData(for: XMPPJID(string: senderId)))!), diameter: 10)
    }
    
    public func getPhotoForUser(user: XMPPUserCoreDataStorageObject) -> UIImage {
        
        if user.photo != nil {
            return user.photo
        } else {
            let photoData = xmppvCardAvatarModule?.photoData(for: user.jid)
            
            if let photoData = photoData {
                return UIImage(data: photoData)!
            } else {
                return UIImage(named: "defaultPerson")!
            }
        }
    }
    
    
    
    
}
