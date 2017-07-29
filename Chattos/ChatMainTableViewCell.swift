//
//  ChatMainTableViewCell.swift
//  Whatsapp
//
//  Created by Shalabh  Soni on 7/18/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import UIKit
import SwiftyBeaver

class ChatMainTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImageURL: UIImageView!
    
    public var model:RowModelMainScreen!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateUI(data: RowModelMainScreen){
        model = data
        print("UpdateUI : \(data.profileTitle)")
        profileName.text = "\(data.profileTitle)"
        message.text =  "\(data.messageText)"
        timeStamp.text = "\(data.time)"
        
       
        DispatchQueue.main.async{
            do{
                
                DispatchQueue.global().sync{
                    self.profileImageURL.layer.cornerRadius = self.profileImageURL.frame.size.width / 2;
                    self.profileImageURL.clipsToBounds = true;
                    //self.profileImageURL.image = data.profileImage
                    
                }
            }catch {
                
            }
        }
    }
    
}
