//
//  MonitoringViewController.swift
//  SampleApp-Swift
//
//  Created by Nir Lachman on 12/02/2018.
//  Copyright © 2018 LivePerson. All rights reserved.
//

import UIKit
import LPMessagingSDK

class MonitoringViewController: UIViewController {
    
    //MARK: - UI Properties
    @IBOutlet var accountTextField: UITextField!
    @IBOutlet var appInstallIdentifierTextField: UITextField!
    
    //MARK: - Properties
    private var pageId: String?
    private var campaignInfo: LPCampaignInfo?
    
    private var conversationViewController: ConversationViewController?
    
    // Enter Your Consumer Identifier
    private let consumerID: String? = nil
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enter Your Account Number
        self.accountTextField.text = nil
        self.accountTextField.text = "15531115"//"85828820" //"6386664"
        
        // Enter Your App Install Identifier
        self.appInstallIdentifierTextField.text = nil
        self.appInstallIdentifierTextField.text = "a01d2e83-a96f-4738-a23a-c2059fca1e43" //"18f82096-ad2d-4e89-83e4-43750d246871"
    }

    // MARK: - IBActions
    @IBAction func initSDKsClicked(_ sender: Any) {
        defer { self.view.endEditing(true) }
        
        guard let accountNumber = self.accountTextField.text, !accountNumber.isEmpty else {
            print("missing account number!")
            return
        }
        
        guard let appInstallID = self.appInstallIdentifierTextField.text, !appInstallID.isEmpty  else {
            print("missing app install Identifier")
            return
        }
        
        initLPSDKwith(accountNumber: accountNumber, appInstallIdentifier: appInstallID)
    }
    
    @IBAction func getEngagementClicked(_ sender: Any) {
        let entryPoints = ["msta"]
        
        let engagementAttributes = [
            ["type": "purchase", "total": 20.0],
            ["type": "lead",
             "lead": ["topic": "luxury car test drive 2015",
                      "value": 22.22,
                      "leadId": "xyz123"]]
        ]

        getEngagement(entryPoints: entryPoints, engagementAttributes: engagementAttributes)
    }
    
    @IBAction func sendSDEClicked(_ sender: Any) {
        let entryPoints = ["http://www.liveperson-test.com",
                           "sec://Food",
                           "lang://De"]
        
        let engagementAttributes = [
            ["type": "purchase",
             "total": 11.7,
             "orderId": "DRV1534XC"],
            ["type": "lead",
             "lead": ["topic": "luxury car test drive 2015",
                      "value": 22.22,
                      "leadId": "xyz123"]]
        ]

        sendSDEwith(entryPoints: entryPoints, engagementAttributes: engagementAttributes)
    }
    
    @IBAction func showConversationWithCampaignClicked(_ sender: Any) {
        defer { self.view.endEditing(true) }
        
        guard let accountNumber = self.accountTextField.text, !accountNumber.isEmpty  else {
            print("Can't show conversation without valid account number")
            return
        }
        
        guard let campaignInfo = self.campaignInfo  else {
            print("Can't show conversation without valid campaignInfo")
            return
        }

        showConversationWith(accountNumber: accountNumber, campaignInfo: campaignInfo)
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        logoutLPSDK()
    }
}

// MARK: - LPMessagingSDK Helpers
extension MonitoringViewController {
    /**
     This method initialize with brandID (account number) and LPMonitoringInitParams (For monitoring)
     
     for more information on `initialize` see:
         https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-sdk-apis-messaging-api.html#initialize
     */
    private func initLPSDKwith(accountNumber: String, appInstallIdentifier: String) {
        let monitoringInitParams = LPMonitoringInitParams(appInstallID: appInstallIdentifier)
        
        do {
            try LPMessaging.instance.initialize(accountNumber, monitoringInitParams: monitoringInitParams)
        } catch let error as NSError {
            print("initialize error: \(error)")
        }
    }
    
    /**
     This method gets an engagement using LPMonitoingAPI
     - NOTE: CampaignInfo will be saved in the response in order to start a conversation later (showConversation method from LPMessagingSDK)
     
     for more information on `showconversation` see:
        https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-sdk-apis-monitoring-api.html#getengagement
    */
    private func getEngagement(entryPoints: [String], engagementAttributes: [[String:Any]]) {
        //resetting pageId and campaignInfo
        self.pageId = nil
        self.campaignInfo = nil
        
        let monitoringParams = LPMonitoringParams(entryPoints: entryPoints, engagementAttributes: engagementAttributes)
        let identity = LPMonitoringIdentity(consumerID: consumerID, issuer: nil)
        LPMessaging.instance.getEngagement(identities: [identity], monitoringParams: monitoringParams, completion: { [weak self] (getEngagementResponse) in
            print("received get engagement response with pageID: \(String(describing: getEngagementResponse.pageId)), campaignID: \(String(describing: getEngagementResponse.engagementDetails?.first?.campaignId)), engagementID: \(String(describing: getEngagementResponse.engagementDetails?.first?.engagementId))")
            // Save PageId for future reference
            self?.pageId = getEngagementResponse.pageId
            if let campaignID = getEngagementResponse.engagementDetails?.first?.campaignId,
                let engagementID = getEngagementResponse.engagementDetails?.first?.engagementId,
                let contextID = getEngagementResponse.engagementDetails?.first?.contextId,
                let sessionID = getEngagementResponse.sessionId,
                let visitorID = getEngagementResponse.visitorId {
                self?.campaignInfo = LPCampaignInfo(campaignId: campaignID, engagementId: engagementID, contextId: contextID, sessionId: sessionID, visitorId: visitorID)
            } else {
                print("no campaign info found!")
            }
        }) { (error) in
            print("get engagement error: \(error.userInfo.description)")
        }
    }
    
    /**
     This method sends a new SDE using LPMonitoringAPI
     - NOTE: PageID in the response will be saved for future request for SDE
     
     for more information on `showconversation` see:
        https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-sdk-apis-monitoring-api.html#sendsde
     */
    private func sendSDEwith(entryPoints: [String], engagementAttributes: [[String:Any]]) {
        let monitoringParams = LPMonitoringParams(entryPoints: entryPoints, engagementAttributes: engagementAttributes, pageId: self.pageId)
        let identity = LPMonitoringIdentity(consumerID: consumerID, issuer: nil)
        LPMessaging.instance.sendSDE(identities: [identity], monitoringParams: monitoringParams, completion: { [weak self] (sendSdeResponse) in
            print("received send sde response with pageID: \(String(describing: sendSdeResponse.pageId))")
            // Save PageId for future reference
            self?.pageId = sendSdeResponse.pageId
        }) { [weak self] (error) in
            self?.pageId = nil
            print("send sde error: \(error.userInfo.description)")
        }
    }
    
    /**
     This method starts a new messaging conversation with account number and CampaignInfo (which was obtain from getEngagement)
     
     for more information on `showconversation` see:
         https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-sdk-apis-messaging-api.html#showconversation
     */
    private func showConversationWith(accountNumber: String, campaignInfo: LPCampaignInfo) {
        let conversationQuery = LPMessaging.instance.getConversationBrandQuery(accountNumber, campaignInfo: campaignInfo)
        let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false)
        
        
        //for ViewController Mode ONLY
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "ConversationViewController")
//        guard let convoViewController = controller as? ConversationViewController else { return }
//        self.conversationViewController = convoViewController
        
        
        self.conversationViewController = ConversationViewController()
        let screenSize: CGRect = UIScreen.main.bounds
        self.conversationViewController?.view.frame = CGRect(x: 0, y: 0, width: screenSize.width - 100 , height: screenSize.height - 100.0)
        self.navigationController?.pushViewController(self.conversationViewController!, animated: true)
        self.conversationViewController?.accountNumber = accountNumber
        self.conversationViewController?.conversationQueryProtocol = conversationQuery
        
        let controlParam = LPConversationHistoryControlParam(historyConversationsStateToDisplay: .all, historyConversationsMaxDays: -1, historyMaxDaysType: .startConversationDate)
        //LPWelcomeMessageParam
        let welcomeMessageParam = LPWelcomeMessage(message: "How can i help you today? #md#[Apple](https://www.apple.com)#/md#", frequency: .FirstTimeConversation)
        let conversationViewParams = LPConversationViewParams(conversationQuery: conversationQuery,
                                                              containerViewController: self.conversationViewController,
                                                              isViewOnly: false,
                                                              conversationHistoryControlParam: controlParam,
                                                              welcomeMessage: welcomeMessageParam)
        
        //implicit flow
        let jwtAuthenticationParams = LPAuthenticationParams(authenticationCode: nil, jwt: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5Ea3lSRGRGUXpRNU5VSkVRemhDTjBJMlJVUTBSREpGTnpNeE9Ua3pNREl6UkRCR016TXpNQSJ9.eyJpc3MiOiJodHRwczovL2Rldi1pemthbzQtdi5hdS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjFhN2ZkZGU5N2UwNjMwMDY5ZjI3Yjc0IiwiYXVkIjoiaUhiSExPRnB0YzFjRGpQaEF1a3pMQVZ4cjRlNTJwQVEiLCJpYXQiOjE2Mzg5MjM3NDQsImV4cCI6MTY0NzkyMzc0NH0.U9GNJouQgQATbDsdQD3uWoxitblXBqFp8fHhMRozk80dLPDoxvk19A3C1lhxJrW-ojU7lGEKBiJ5nw4nsGBFCxThUfTCe-0jacRPFl8QtSr0qGCaVvxZNrPX7UeWhoomUCS95YNjyUd0JdWPsKwaW7iW19P3Xatmp-GiG7yZnfc-yVdw5MbNRUlS5eChOflMfp451xIM0Zt4FPnakql8PoAmjCR7yZmSAqRB8tLg46miGMMp8DyHhiM8bZsRx94QLBGFkDtdmdTAJSvNY1vWlRvVuIdPAxs1z7dI4sgBu2wg0ErSTkCUq1Rp5a9M8lBDBZLCmRv-b_Yn8Gpgh-t8JA", redirectURI: nil, certPinningPublicKeys: nil, authenticationType: .authenticated)
        
//        LPMessaging.instance.showConversation(conversationViewParam)
        LPMessaging.instance.showConversation(conversationViewParams, authenticationParams: jwtAuthenticationParams)

    }
    
    /**
     This method logouts from Monitoring and Messaging SDKs - all the data will be cleared
     
     for more information on `logout` see:
        https://developers.liveperson.com/mobile-app-messaging-sdk-for-ios-methods-logout.html
     */
    private func logoutLPSDK() {
        LPMessaging.instance.logout(unregisterType: .all, completion: {
            print("successfully logout from MessagingSDK")
        }) { (errors) in
            print("failed to logout from MessagingSDK - error: \(errors)")
        }
    }
}
