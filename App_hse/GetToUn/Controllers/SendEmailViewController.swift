//
//  SendEmailViewController.swift
//  App_hse
//
//  Created by Vladislava on 16/04/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import UIKit
import MessageUI

class SendEmailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBAction func sendEmail(_ sender: UIButton) {
       
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            //let root = UIApplication.shared.keyWindow?.rootViewController
            //root?.present(mailComposeViewController, animated: true, completion: nil)
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["vlada-vakulenko@mail.ru"]) //studsovet.trilistnik@gmail.com
        mailComposerVC.setSubject("Complain")
        mailComposerVC.setMessageBody("Your text here..", isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
