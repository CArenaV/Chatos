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
import UserNotificationsUI
import UserNotifications

class ViewChat: JSQMessagesViewController, ChatOnProtocol{
    var name:String = ""

    @IBOutlet weak var statusMessage: UIBarButtonItem!
    @IBOutlet weak var status: UIBarButtonItem!
    @IBOutlet var chatArea: UIView!
    var chatFor:String!
    @IBAction func backBtnPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        
    }
    
    func recievedMessage(additionalInfo: [String:Any])-> Void{
        
            var reciever = additionalInfo[Constants.RECIEVER_KEY] as? String
        reciever = reciever?.components(separatedBy: "/")[0]
        SwiftyBeaver.info("i'm here\(additionalInfo) \(self.senderId), Input Sender is : \(reciever)")
        var userEvent = additionalInfo[Constants.MESSAGE_SUBEVENT_KEY]
        if  (userEvent as? ChatOnXMPPEvents == ChatOnXMPPEvents.RECIEVE_MESSAGES_COMPOSING_EVENT){
            SwiftyBeaver.verbose("Logging Event : Composing for User \(reciever)")
            if(reciever == self.senderId){
                SwiftyBeaver.info("We are going to change the Status..")
                status.isEnabled = true
            status.title = "typing..."
            }
        
            
        }else if  (userEvent as? ChatOnXMPPEvents == ChatOnXMPPEvents.RECIEVE_MESSAGES_PAUSED_EVENT){
            SwiftyBeaver.verbose("Logging Event : Paused for User\(reciever)")
            if(reciever == self.senderId){
            status.title = "Online"
            }
           
            } else{
           // status.title = "Online"
            SwiftyBeaver.verbose("Logging Event : Message Recieved \(reciever) \(chatFor)")
            var chatElement = MessagePlayer.sharedInstance.msgDict[chatFor]
            messages = (chatElement?.messagesE)!
        JSQSystemSoundPlayer.jsq_playMessageReceivedSound() // 4
            if(reciever != chatFor){
                SwiftyBeaver.warning(" Going to Send the Notification")
                var msg:String = (additionalInfo[Constants.MESSAGE_CONTENT] as! String)
                var jsqMsgE = additionalInfo[Constants.MESSAGE_JSQ_EXT] as? JSQMessageExtension
                messages.append(jsqMsgE!)
                MessagePlayer.sharedInstance.msgDict.updateValue((chatElement)!, forKey: chatFor)
                triggerNotification(message: msg, sender: reciever!)
            }
            
            
        self.finishReceivingMessage()
        }
    }

    
    func triggerNotification(message: String, sender: String){
        
        print("notification will be triggered in five seconds..Hold on tight")
        let content = UNMutableNotificationContent()
        content.title = "New Chat Message!"
        content.subtitle = "\(sender) has sent a new message."
        content.body = message
        content.sound = UNNotificationSound.default()
        
        //To Present image in notification
//        if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
//            let url = URL(fileURLWithPath: path)
//            
//            do {
//                let attachment = try UNNotificationAttachment()
//                content.attachments = [attachment]
//            } catch {
//                print("attachment not found.")
//            }
//        }
//        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier:"chatMessageIncoming", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription)
            }
        }
    }
    
    
    @IBOutlet weak var chatTitle: UINavigationItem!
    @IBOutlet weak var imageBarBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    public var chatElement:ChatElement!
    public var user:XMPPUserCoreDataStorageObject!
    
    public var xmppvCardAvatarModule: XMPPvCardAvatarModule!
    var messages = [JSQMessageExtension]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
        override func viewDidLoad() {
        super.viewDidLoad()
            name = "ViewChat"
            SwiftyBeaver.error("Sender ID \(self.senderId)")
            status.isEnabled = false
            let fontSize:CGFloat = 10;
            let font:UIFont = UIFont.boldSystemFont(ofSize: fontSize);
            let attributes:[String : Any] = [NSFontAttributeName: font];
            status.setTitleTextAttributes(attributes, for: UIControlState.normal);
            

            status.title = ""
            
            chatElement = MessagePlayer.sharedInstance.msgDict[chatFor]
            ChatOnXMPPController.sharedInstance.registerForEvents(caller: self, event: ChatOnXMPPEvents.RECIEVE_MESSAGES_EVENT)
            self.edgesForExtendedLayout = []
            

         chatTitle.title = chatElement.name
            
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
            messages = chatElement.messagesE
       // var xx = JSQMessagesViewController()
       // xx.automaticallyScrollsToMostRecentMessage = true
        //userName.text = msgElement.name.components(separatedBy: "@")[0].capitalized
       //userPhoto.image = getPhotoForUser(user: user)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.init(width: 10, height: 10)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.init(width: 10, height: 10)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == AppData.sharedInstance.loggedInUserJid {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
  
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMsgObject
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        SwiftyBeaver.info("\(message) \(AppData.sharedInstance.loggedInUserJid)");
        if message.senderId == AppData.sharedInstance.loggedInUserJid {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        var sndr = messages[indexPath.item].senderId
        
        
        return  JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: (xmppvCardAvatarModule?.photoData(for: XMPPJID(string: messages[indexPath.item].senderId)))!), diameter: 10)
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
           let xmppProcessor = ChatOnXMPPController.sharedInstance
           let xmppStream = xmppProcessor.xmppStream

    

    let msg = XMPPMessage(type: "chat", to: XMPPJID(string: chatFor))
    //var message = "How are you my friend!!"
        status.title = "Online"
    msg?.addBody(text)
    SwiftyBeaver.info(msg)
    xmppStream?.send(msg);
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        var jsqMsgEx = Utils.convXMPPMsgToJSQMsgExt(xmppMessage: msg!)
        messages.append(jsqMsgEx)
        finishSendingMessage() // 5

        self.finishReceivingMessage()
        
    
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


extension ViewChat:UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        SwiftyBeaver.info("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == "chatMessageIncoming"{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

