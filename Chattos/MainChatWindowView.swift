//
//  MainChatWindowView.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/25/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import UIKit
import SwiftyBeaver
import XMPPFramework
import CocoaLumberjack
import JSQMessagesViewController
import CoreData

class MainChatWindowView: UIViewController,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, XMPPRosterDelegate, XMPPStreamDelegate{
    var msgP = MessagePlayer()
    @IBOutlet weak var broadcastListView: UIView!
    @IBOutlet weak var topView: UIView!
    var groups: [XMPPGroupCoreDataStorageObject]!;
    var xmppProcessor: ChatOnXMPPController!;
    var xmppStream: XMPPStream!
    var moc: NSManagedObjectContext!
    var xmppvCardStorage: XMPPvCardCoreDataStorage!
    public var xmppRosterStorage: XMPPRosterCoreDataStorage!
    var xmppRoster: XMPPRoster!
    var xmppMessageStorage: XMPPMessageArchivingCoreDataStorage?
    var xmppMessageArchiving: XMPPMessageArchiving?
    var xmppvCardTempModule: XMPPvCardTempModule!
    var xmppvCardAvatarModule: XMPPvCardAvatarModule!
    @IBOutlet weak var bottomBarVie3: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DDLog.add(DDTTYLogger.sharedInstance, with: DDLogLevel.all)

        xmppProcessor = ChatOnXMPPController.sharedInstance
        xmppStream = xmppProcessor.xmppStream
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRosterStorage = XMPPRosterCoreDataStorage()
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.autoFetchRoster = true
        xmppRoster.allowRosterlessOperation = true
        xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        xmppvCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
        xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
        
        
        xmppMessageStorage = XMPPMessageArchivingCoreDataStorage()
        xmppMessageArchiving = XMPPMessageArchiving(messageArchivingStorage: xmppMessageStorage)
        xmppMessageArchiving?.clientSideMessageArchivingOnly = true
        xmppMessageArchiving?.activate(xmppStream)
        xmppMessageArchiving?.addDelegate(self, delegateQueue: DispatchQueue.main)
        

        moc = xmppRosterStorage.mainThreadManagedObjectContext
        
        SwiftyBeaver.info(xmppStream)
        SwiftyBeaver.info(xmppStream.isConnected())
        SwiftyBeaver.info(xmppRoster)
        
        let entity = NSEntityDescription.entity(forEntityName: "XMPPUserCoreDataStorageObject", in: moc!)
        SwiftyBeaver.info(entity);
        let sd1 = NSSortDescriptor(key: "sectionNum", ascending: true)
        let sd2 = NSSortDescriptor(key: "displayName", ascending: true)
        
        let sortDescriptors = [sd1, sd2]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 10
        SwiftyBeaver.info(fetchRequest)
        var fetchedResultsControllerVar = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc!, sectionNameKeyPath: "sectionNum", cacheName: nil)
        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster!.activate(xmppStream)
        xmppvCardTempModule!.activate(xmppStream)
        xmppvCardAvatarModule!.activate(xmppStream)

        xmppRoster.fetch()
        // xmppRoster.fetch()
        SwiftyBeaver.error(xmppRoster)
        fetchedResultsControllerVar.delegate = self
        do {
           let result = try fetchedResultsControllerVar.performFetch()
            SwiftyBeaver.info("Result of Fetch: \(result)")
        } catch let error as NSError {
            SwiftyBeaver.error("Error: \(error.localizedDescription)")
            abort()
        }
        
        //
//        SwiftyBeaver.info(" The Size of Fetched Results : \(fetchedResultsControllerVar.fetchedObjects?.count)" )
//        for x in fetchedResultsControllerVar.fetchedObjects!  {
//            var y = x as! XMPPUserCoreDataStorageObject
//            SwiftyBeaver.info(y.jid)
//        }
        var xmppPresence: XMPPPresence
        xmppPresence = XMPPPresence()
        xmppStream.send(xmppPresence)

        var messages: NSMutableArray
        messages = loadArchivedMessagesFrom(jid: xmppStream.myJID.bare(), thread: "")
        
        SwiftyBeaver.info("---->\(messages.count)")
        msgP.doM(messages: messages)
            //SwiftyBeaver.info("Messages!!! : \(msgP.msgs.) ")
        
        
    self.topView.layer.borderWidth = 1
    self.topView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
    self.broadcastListView.layer.borderWidth = 1
    self.broadcastListView.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
    self.bottomBarVie3.layer.borderWidth = 1
    self.bottomBarVie3.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
}



    public func controllerDidChangeContent(controller : NSFetchedResultsController<NSFetchRequestResult>) {
        SwiftyBeaver.info("I'm called here cdcc")
    }
    
    public func configurePhotoForCell(cell: ChatMainTableViewCell, user: XMPPUserCoreDataStorageObject) {
        // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
        // We only need to ask the avatar module for a photo, if the roster doesn't have it.
        if user.photo != nil {
            cell.profileImageURL!.image = user.photo!;
        } else {
            let photoData = xmppvCardAvatarModule?.photoData(for: user.jid)
            
            if let photoData = photoData {
                cell.profileImageURL!.image = UIImage(data: photoData)
            } else {
                cell.profileImageURL!.image = UIImage(named: "defaultPerson")
            }
        }
    }
    
    
    
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "chatMainWindow", for: indexPath) as? ChatMainTableViewCell{
        var n = msgP.msgs
        let msgElement:MessageElement = Array(n!.values)[indexPath.row] as! MessageElement
        var user = xmppRosterStorage.user(for: XMPPJID(string: msgElement.senderId ) , xmppStream: xmppStream, managedObjectContext: moc!)

        var x = RowModelMainScreen(profileImageURL: UIImage(), profileName: msgElement.name
            , messageText: msgElement.lastMsg, time: msgElement.lastMsgTS.description, senderId: msgElement.senderId)
        configurePhotoForCell(cell: cell, user: user!)
        

        
        
        
      //  var cc = ChatMainTableViewCell()
        print("--------\(x.profileTitle)")
        cell.updateUI(data: x)
        return cell;
    }else{
        return UITableViewCell()
    }
    
    
    
       }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as? ChatMainTableViewCell
        var senderId = cell?.model.senderId
        var me: MessageElement = msgP.msgs[senderId!]!
        var data:[String:Any?]!
        var user = xmppRosterStorage.user(for: XMPPJID(string: me.senderId ) , xmppStream: xmppStream, managedObjectContext: moc!)
        data = [:]
        
        data.updateValue(me, forKey: "MessageElement")
        data.updateValue(user, forKey: "User")
        data.updateValue(xmppvCardAvatarModule, forKey: "xmppvCardAvatarModule")
        performSegue(withIdentifier: "showChat", sender: data)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChat" {
            let navVC = segue.destination as! UINavigationController
            
            let destinationVC = navVC.topViewController as! ViewChat
            let sender_ = sender as? [String:Any]
            destinationVC.msgElement = sender_?["MessageElement"] as? MessageElement!
            destinationVC.user = sender_?["User"] as? XMPPUserCoreDataStorageObject!
            destinationVC.xmppvCardAvatarModule = sender_?["xmppvCardAvatarModule"] as? XMPPvCardAvatarModule!
            destinationVC.senderId = destinationVC.msgElement.senderId
            destinationVC.senderDisplayName = destinationVC.msgElement.name.components(separatedBy: "@")[0].capitalized

        }
    }

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(msgP.msgs.count)
    return msgP.msgs.count;
}
 
    
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        SwiftyBeaver.info(presenceType)
        SwiftyBeaver.info(myUsername)
        SwiftyBeaver.info(presenceFromUser)
        if presenceFromUser != myUsername {
            print("Did receive presence from \(presenceFromUser)")
            if presenceType == "available" {
               // delegate.buddyWentOnline("\(presenceFromUser)")
                SwiftyBeaver.info(" Presence Recieved : \(myUsername)")
            } else if presenceType == "unavailable" {
                //delegate.buddyWentOffline("\(presenceFromUser)")
                SwiftyBeaver.info(" Presence Recieved : \(myUsername)")
            }
        }
    }
    
    
    public func xmppRosterDidEndPopulating(_ sender: XMPPRoster?) {
        SwiftyBeaver.info("Invoked")
        let jidList = xmppRosterStorage!.jids(for: xmppStream)
        SwiftyBeaver.info(" jid LIst lenght : \(String(describing: jidList?.count))")
        
        for y in jidList!{
            let user = xmppRosterStorage.user(for: y as! XMPPJID, xmppStream: xmppStream, managedObjectContext: moc!)
            let message = "Yo!"
            let senderJID = y
            let msg = XMPPMessage(type: "chat", to: senderJID as! XMPPJID)
            msg?.addBody(message)

            xmppStream.send(msg);

            
        }
        
    }
    
    public func loadArchivedMessagesFrom( jid: String, thread: String) -> NSMutableArray {
        let moc = xmppMessageStorage?.mainThreadManagedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "XMPPMessageArchiving_Message_CoreDataObject", in: moc!)
        let request = NSFetchRequest<NSFetchRequestResult>()
        let predicateFormat = "bareJidStr like %@ ANd thread like %@"
        let predicate = NSPredicate(format: predicateFormat, jid, thread)
        let retrievedMessages = NSMutableArray()
        var sortedRetrievedMessages = NSArray()
        
        // request.predicate = predicate
        request.entity = entityDescription
        
        do {
            let results = try moc?.fetch(request)
            SwiftyBeaver.error(" results :\(results)")

            for message in results! {
                SwiftyBeaver.error(" message :\(message)")

                var element: DDXMLElement!
                do {
                    element = try DDXMLElement(xmlString: (message as AnyObject).messageStr)
                    SwiftyBeaver.error(" ELEMENT :\(element)")
                } catch _ {
                    element = nil
                }
                
                let body: String
                var sender: String
                let date: NSDate
                var msg = message as? XMPPMessageArchiving_Message_CoreDataObject
                date = msg?.timestamp as! NSDate
                
                if (message as AnyObject).body() != nil {
                    body = (message as AnyObject).body()
                } else {
                    body = ""
                }
                sender = ""
                if element.attributeStringValue(forName: "to").contains(jid){
                    var displayName = element.attributeStringValue(forName: "from")
                    if displayName == nil {
                        displayName = jid
                        sender = displayName!
                    }else{
                    sender = displayName!
                    }
                } else {
                    sender = jid
                }
                
                
                var rng = sender.range(of: "/")
                if rng != nil{
                SwiftyBeaver.info(rng)
                    sender = sender.components(separatedBy: "/")[0]
                   // var d = sender.distance(from: (rng?.lowerBound)!, to: (rng?.upperBound)!)
               // sender = sender.substring(to: (d.-1))
                }
                let fullMessage = JSQMessage(senderId: sender, senderDisplayName: sender, date: date as Date!, text: body)
                retrievedMessages.add(fullMessage)
                
                
                let descriptor:NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true);
                let descriptor2:NSSortDescriptor = NSSortDescriptor(key: "senderId", ascending: true);

                sortedRetrievedMessages = retrievedMessages.sortedArray(using: [descriptor, descriptor2]) as NSArray!;
                
                
                
            }
        } catch _ {
            //catch fetch error here
        }
        return sortedRetrievedMessages.mutableCopy() as! NSMutableArray
    }
    
    @IBAction func backToMainChatView(segue:UIStoryboardSegue) {
    }
    
    
    
}

