//
//  ViewController.swift
//  Chattos
//
//  Created by Shalabh  Soni on 7/23/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyBeaver

class ViewController: UIViewController,ChatOnProtocol{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var logoCos: UIImageView!
    @IBOutlet weak var domain: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    
    var xmppProcessor:ChatOnXMPPController!
    
    let squishPlayer: AVAudioPlayer!

    required init(coder aDecoder: NSCoder) {
        let squishPath = Bundle.main.path(forResource: "swoosh", ofType: "wav")
        let squishURL = URL(fileURLWithPath: squishPath!)
        try! squishPlayer = AVAudioPlayer(contentsOf: squishURL, fileTypeHint: "wav")
        squishPlayer.prepareToPlay()
        
        super.init(coder: aDecoder)!
        xmppProcessor = ChatOnXMPPController.sharedInstance
    }
    
    
    var _name:String = "ViewController"
    
    var name:String{
        return _name;
    }
    
     func loginSuccess() {
        SwiftyBeaver.info("[LOGGER]In Login Success for : \(self._name)")
        performSegue(withIdentifier: "toMainChatWindow", sender: nil)


        
    }
    
     func loginFailed(reason: String) {
        SwiftyBeaver.info("[LOGGER]Login Failed : VC \(reason)")
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden=true;
        self.errorLabel.text = reason;
    }
    
    func connectFailed(reason: String){
        SwiftyBeaver.info("[LOGGER]Connect Failed : VC \(reason)")
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden=true;
        self.errorLabel.text = reason;
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: "/Users/Shalabh/Documents/ios-logs/ChatOn/chaton.log");
        file.asynchronously = false;
        SwiftyBeaver.addDestination(file)
        SwiftyBeaver.info("in ViewDidLoad");
        activityIndicator.isHidden = true;
        activityIndicator.stopAnimating()
        domain.underlined();
        userName.underlined()
        password.underlined()
        
        let imageView = UIImageView();
        
        let imageUserName = UIImage(named: "username.png");
        let iconWidth = 20;
        let iconHeight = 20;
        
        imageView.image = imageUserName;
        imageView.frame = CGRect(x: 5, y: 0, width: iconWidth, height: iconHeight)
        userName.leftViewMode = UITextFieldViewMode.always
        userName.addSubview(imageView)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.userName.frame.height))
        userName.leftView = paddingView
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func loginBtnClicked(_ sender: Any) {
        self.errorLabel.text="";
        activityIndicator.isHidden = false;
        activityIndicator.startAnimating()
        try! xmppProcessor.build(jabberId: "\(userName.text!)@\(domain.text!)", password: password.text!)
        xmppProcessor.registerForEvents(caller: self, event: ChatOnXMPPEvents.CONNECT)
        xmppProcessor.registerForEvents(caller: self, event: ChatOnXMPPEvents.LOGIN_EVENT)
        xmppProcessor.connect()
        
    }
    
    func connectSuccess() {
        SwiftyBeaver.info("[LOGGER]In Connect Success for : \(self._name)")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftyBeaver.info("[LOGGER] i'm here:\(self.logoCos.center.x)")
        UIView.animate(withDuration: 3.0, delay: 0.5,
                                   usingSpringWithDamping: 0.3,
                                   initialSpringVelocity: 0.8,
                                   options: [], animations: {
                                    self.logoCos.center.x += self.view.bounds.width
        }, completion: nil)
        squishPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }


}
extension UITextField {
    
    func underlined(){
        SwiftyBeaver.info("[LOGGER]hello");
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }}
