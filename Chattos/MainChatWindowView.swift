////
////  MainChatWindowView.swift
////  Chattos
////
////  Created by Shalabh  Soni on 7/25/17.
////  Copyright © 2017 Shalabh  Soni. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SwiftyBeaver
//import XMPPFramework
//import CocoaLumberjack
//import JSQMessagesViewController
//import CoreData
//
//class MainChatWindowView: UIViewController,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, XMPPRosterDelegate, XMPPStreamDelegate{
//    var msgP = MessagePlayer.sharedInstance
//    @IBOutlet weak var broadcastListView: UIView!
//    @IBOutlet weak var topView: UIView!
//    var groups: [XMPPGroupCoreDataStorageObject]!;
//    var xmppProcessor: ChatOnXMPPController!;
//    var xmppStream: XMPPStream!
//    var moc: NSManagedObjectContext!
//    var xmppvCardStorage: XMPPvCardCoreDataStorage!
//    public var xmppRosterStorage: XMPPRosterCoreDataStorage!
//    var xmppRoster: XMPPRoster!
//    var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage!
//    var xmppMessageArchiving: XMPPMessageArchiving!
//    var xmppvCardTempModule: XMPPvCardTempModule!
//    var xmppvCardAvatarModule: XMPPvCardAvatarModule!
//    static let sharedInstance = MainChatWindowView();
//
//    @IBOutlet weak var tableView: UITableView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        DDLog.add(DDTTYLogger.sharedInstance, with: DDLogLevel.all)
//
//        xmppProcessor = ChatOnXMPPController.sharedInstance
//        xmppStream = xmppProcessor.xmppStream
//        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
//        xmppRosterStorage = XMPPRosterCoreDataStorage()
//        ObjectContainer.sharedInstance.xmppRosterStorage = xmppRosterStorage
//        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
//        xmppRoster.autoFetchRoster = true
//        xmppRoster.allowRosterlessOperation = true
//        xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
//        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
//        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
//        
//        
//        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage.sharedInstance()
//        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
//        xmppMessageArchiving?.clientSideMessageArchivingOnly = false
//        xmppMessageArchiving?.activate(xmppStream)
//        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
//        
//
//        moc = xmppRosterStorage.mainThreadManagedObjectContext
//        ObjectContainer.sharedInstance.moc = moc
//        ObjectContainer.sharedInstance.xmppRoster = xmppRoster
//        
//        SwiftyBeaver.info(xmppStream)
//        SwiftyBeaver.info(xmppStream.isConnected())
//        SwiftyBeaver.info(xmppRoster)
//        
////        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
////        SwiftyBeaver.info(entity);
////        let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
////        let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
////        
////        let sortDescriptors = [sd1, sd2]
////        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
////        fetchRequest.entity = entity
////        fetchRequest.sortDescriptors = sortDescriptors
////        fetchRequest.fetchBatchSize = 10
////        SwiftyBeaver.info(fetchRequest)
////        var fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
////        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
////        xmppRoster!.activate(xmppStream)
////        xmppvCardTempModule!.activate(xmppStream)
////        xmppvCardAvatarModule!.activate(xmppStream)
////
////        xmppRoster.fetch()
////        // xmppRoster.fetch()
////        SwiftyBeaver.error(xmppRoster)
////        fetchedResultsControllerVar.delegate = self
////        do {
////           let result = try fetchedResultsControllerVar.performFetch()
////            SwiftyBeaver.info("Result of Fetch: \(result)")
////        } catch let error as NSError {
////            SwiftyBeaver.error("Error: \(error.localizedDescription)")
////            abort()
////        }
//        
//        //
////        SwiftyBeaver.info(" The Size of Fetched Results : \(fetchedResultsControllerVar.fetchedObjects?.count)" )
////        for x in fetchedResultsControllerVar.fetchedObjects!  {
////            var y = x as! XMPPUserCoreDataStorageObject
////            SwiftyBeaver.info(y.jid)
////        }
//        var xmppPresence: XMPPPresence
//        xmppPresence = XMPPPresence()
//        xmppStream.send(xmppPresence)
//
//        var messages: NSMutableArray
//        messages = loadArchivedMessagesFrom(jid: xmppStream.myJID.bare(), thread: "")
//        
//        SwiftyBeaver.info("---->\(messages.count)")
//        msgP.doM(messages: messages)
//        ObjectContainer.sharedInstance.messagePlayer = msgP
//            //SwiftyBeaver.info("Messages!!! : \(msgP.msgs.) ")
//        
//        
//    self.topView.layer.borderWidth = 1
//    self.topView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
//    self.broadcastListView.layer.borderWidth = 1
//    self.broadcastListView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
//    
//}
//
//
//
////    public func controllerDidChangeContent(controller : NSFetchedResultsController<NSFetchRequestResult>) {
////        SwiftyBeaver.info("I'm called here cdcc")
////    }
//    
//    public func configurePhotoForCell(cell: ChatMainTableViewCell, user: XMPPUserCoreDataStorageObject) {
//        if user.photo != nil {
//            cell.profileImageURL!.image = user.photo!;
//        } else {
//            let photoData = xmppvCardAvatarModule?.photoData(for: user.jid)
//            
//            if let photoData = photoData {
//                cell.profileImageURL!.image = UIImage(data: photoData)
//            } else {
//                cell.profileImageURL!.image = UIImage(named: "defaultPerson")
//            }
//        }
//    }
//    
//    
//    
//    
//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    if let cell = tableView.dequeueReusableCell(withIdentifier: "chatMainWindow", for: indexPath) as? ChatMainTableViewCell{
//        var msgPDict = msgP.msgDict
//        let chatElement:ChatElement = Array(msgPDict!.values)[indexPath.row] as! ChatElement
//        
//        SwiftyBeaver.info("Table View : \(string: msgPDict?[indexPath.row].key)")
//        var user = xmppRosterStorage.user(for: XMPPJID(string: msgPDict?[indexPath.row].key) , xmppStream: xmppStream, managedObjectContext: moc!)
//
//        var x = RowModelMainScreen(profileImageURL: UIImage(), profileName: chatElement.name
//            , messageText: chatElement.lastMsg, time: chatElement.lastMsgTS.description, senderId: chatElement.senderId)
//        configurePhotoForCell(cell: cell, user: user!)
//        print("--------\(x.profileTitle)")
//        cell.updateUI(data: x)
//        return cell;
//    }else{
//        return UITableViewCell()
//    }
//    
//    
//    
//       }
//
//    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ChatMainTableViewCell
//        var chatFor = cell?.model.senderId
//        var senderId = AppData.sharedInstance.loggedInUserJid
//        var me:ChatElement = msgP.msgDict[senderId!]!
//        var data:[String:Any?]!
//        var user = xmppRosterStorage.user(for: XMPPJID(string: chatFor ) , xmppStream: xmppStream, managedObjectContext: moc!)
//        data = [:]
//        
//        SwiftyBeaver.info("\(senderId)")
//        data.updateValue(me, forKey: "ChatElement")
//        data.updateValue(user, forKey: "User")
//        data.updateValue(xmppvCardAvatarModule, forKey: "xmppvCardAvatarModule")
//        data.updateValue(chatFor, forKey :"chatFor")
//        performSegue(withIdentifier: "showChat", sender: data)
//
//        
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showChat" {
//            let navVC = segue.destination as! UINavigationController
//            
//            let destinationVC = navVC.topViewController as! ViewChat
//            let sender_ = sender as? [String:Any]
//            SwiftyBeaver.info(sender_?["chatFor"])
//            SwiftyBeaver.info(sender_?["senderId"])
//            destinationVC.chatElement = sender_?["ChatElement"] as? ChatElement!
//            destinationVC.user = sender_?["User"] as? XMPPUserCoreDataStorageObject!
//            destinationVC.xmppvCardAvatarModule = sender_?["xmppvCardAvatarModule"] as? XMPPvCardAvatarModule!
//            destinationVC.senderId = AppData.sharedInstance.loggedInUserJid
//            destinationVC.senderDisplayName = destinationVC.chatElement.name.components(separatedBy: "@")[0].capitalized
//            destinationVC.chatFor = sender_?["chatFor"] as? String!
//
//        }
//    }
//
//func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return msgP.msgDict.count;
//}
// 
//    
//    
//    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
//        let presenceType = presence.type()
//        let myUsername = sender.myJID.user
//        let presenceFromUser = presence.from().user
//        SwiftyBeaver.info(presenceType)
//        SwiftyBeaver.info(myUsername)
//        SwiftyBeaver.info(presenceFromUser)
//        if presenceFromUser! != myUsername {
//            print("Did receive presence from \(presenceFromUser)")
//            if presenceType == "available" {
//                SwiftyBeaver.info(" Presence Recieved : \(myUsername)")
//            } else if presenceType == "unavailable" {
//                SwiftyBeaver.info(" Presence Recieved : \(myUsername)")
//            }
//        }
//    }
//    
//    
//    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster?) {
//        SwiftyBeaver.info("Invoked")
//        let jidList = xmppRosterStorage!.jids(for: xmppStream)
//        SwiftyBeaver.info(" jid LIst lenght : \(String(describing: jidList?.count))")
//        
//        for y in jidList!{
//            let user = xmppRosterStorage.user(for: y as! XMPPJID, xmppStream: xmppStream, managedObjectContext: moc!)
//            let message = "Yo!"
//            let senderJID = y
//            let msg = XMPPMessage(type: "chat", to: senderJID as! XMPPJID)
//            msg?.addBody(message)
//
//            xmppStream.send(msg);
//
//            
//        }
//        
//    }
//    
//    public func loadArchivedMessagesFrom( jid: String, thread: String) -> NSMutableArray {
//        let sortedRetrievedMessages = Utils.loadMessagesFromArchieve(xmppMessageStorage: xmppMessageStorage, jid: jid)
//       return sortedRetrievedMessages
//    }
//    
//    @IBAction func backToMainChatView(segue:UIStoryboardSegue) {
//    }
//    
//    
//    
//}
//extension Dictionary {
//    subscript(i:Int) -> (key:Key,value:Value) {
//        get {
//            return self[index(startIndex, offsetBy: i)];
//        }
//    }
//}
//
//	
