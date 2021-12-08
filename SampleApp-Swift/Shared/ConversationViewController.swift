//
//  ConversationViewController.swift
//  SampleApp-Swift
//
//  Created by Nimrod Shai on 2/23/16.
//  Copyright © 2016 LivePerson. All rights reserved.
//

import Foundation
import LPMessagingSDK

class ConversationViewController: UIViewController {

    var accountNumber: String? = nil
    var conversationQueryProtocol: ConversationParamProtocol?
   
    private var popUpViewController = EmptyVC()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuButtonPressed))
    }
    
    //MARK: - Actions
    @objc func backButtonPressed() {
        if let accountNumber = self.accountNumber {
            self.conversationQueryProtocol = LPMessaging.instance.getConversationBrandQuery(accountNumber)
            if let conversationQuery = conversationQueryProtocol {
                LPMessaging.instance.removeConversation(conversationQuery)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func menuButtonPressed() {
        var style = UIAlertController.Style.actionSheet
        if UIDevice.current.userInterfaceIdiom == .pad {
            style = .alert
        }
        
        let alertController = UIAlertController(title: "Menu", message: "Choose an option", preferredStyle: style)
        
        /**
        is how to resolve a conversation
        */
        guard let conversationQuery = self.conversationQueryProtocol else {
            debugPrint("no conversationQuery found!!!")
            return
        }
   
        //resolve option
        let resolveAction = UIAlertAction(title: "Resolve", style: .default) { (alert: UIAlertAction) -> Void in
            LPMessaging.instance.resolveConversation(conversationQuery)
        }

        //urgent option
        let urgentTitle = LPMessaging.instance.isUrgent(conversationQuery) ? "Dismiss Urgent" : "Mark as Urgent"

        /**
        This is how to manage the urgency state of the conversation
        */
        let urgentAction = UIAlertAction(title: urgentTitle, style: .default) { (alert: UIAlertAction) -> Void in
            if LPMessaging.instance.isUrgent(conversationQuery) {
                LPMessaging.instance.dismissUrgent(conversationQuery)
            } else {
                LPMessaging.instance.markAsUrgent(conversationQuery)
            }
        }
        
        
        //cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //popup action
        let popUpAction = UIAlertAction(title: "Read More", style: .default) { _ in
            if self.conversationQueryProtocol != nil {
                let vc = EmptyVC() //change this to your class name
                let screenSize: CGRect = UIScreen.main.bounds
                self.popUpViewController.view.frame = CGRect(x: 0, y: 0, width: screenSize.width - 100 , height: screenSize.height - 100.0)
                self.navigationController?.pushViewController(self.popUpViewController, animated: true)
//                self.present(vc, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(resolveAction)
        alertController.addAction(urgentAction)
        alertController.addAction(cancelAction)
        alertController.addAction(popUpAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
