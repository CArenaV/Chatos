import UIKit
import AVFoundation
import SwiftyBeaver
class RowModelMainScreen{
    private var _profileImage:UIImage!;
    private var _profileTitle:String;
    private var _messageText:String;
    private var _time:String;
    private var _senderId: String;
    
    init(profileImageURL: UIImage, profileName: String, messageText:String, time:String, senderId: String){
        _profileImage = profileImageURL
        _profileTitle = profileName
        _messageText = messageText
        _time = time
        _senderId = senderId
        
    }
    var senderId: String{
        return _senderId;
    }
    var profileImage: UIImage{
        return _profileImage;
    }
    var profileTitle: String{
        return _profileTitle;
    }
    var messageText: String{
        return _messageText;
    }
    var time: String{
        return _time;
    }
}
