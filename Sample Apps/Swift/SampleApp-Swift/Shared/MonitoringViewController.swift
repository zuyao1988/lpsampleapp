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
    
    // Enter Your Consumer Identifier
    private let consumerID: String? = "auth0|5fa21a1e7c07e60069f23382"
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enter Your Account Number
        self.accountTextField.text = nil
        self.accountTextField.text = "15531115"
        
        // Enter Your App Install Identifier
        self.appInstallIdentifierTextField.text = nil
        self.appInstallIdentifierTextField.text = "a01d2e83-a96f-4738-a23a-c2059fca1e43"
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
    
    @IBAction func fakePnPressed(_ sender:UIButton!) {
   
        var fakePN = [String : Any]()
        
        let eventPayload: [String: Any]? = [
            "content": [
                "elements": (
                    [
                        "text": " actual text replace the 3",
                        "type": "text"
                    ],
                    [
                        "click": [
                            "actions": (
                                [
                                    "name": "https://avvanest.s3-ap-southeast-1.amazonaws.com/little+planet+bedok.JPG",
                                    "type": "link",
                                    "uri": "http://profile.avvanest.com/"
                                ]
                            ),
                        ],
                        "type": "image",
                        "url": "https://avvanest.s3-ap-southeast-1.amazonaws.com/little+planet+bedok.JPG"
                    ]
                ),
                "type": "vertical"
            ],
            "type": "RichContentEvent"
        ]

        fakePN["event"] = eventPayload
        
        fakePN["leCampaignId"] = "1406378070"
        fakePN["lookBackPeriod"] = 2592000000
        fakePN["leEngagementId"] = "1414973670"
        fakePN["agentPid"] = "0ee32b27-af1d-5036-b0b9-5731276e0aad"
        fakePN["messageId"] = "c69e0978-036f-4c02-95a3-4d8f68ad2afe"
        fakePN["outboundMessagingSupport"] = 1
        fakePN["isProactivePush"] = 1
        fakePN["expirationEpochTime"] = 1635556619120
        fakePN["backendService"] = "prmsg"
        fakePN["brandId"] = "15531115"
        fakePN["transactionId"] = "d293f85e-8888-37de-9855-680c277f9288"
        fakePN["aps"] = ["alert": "Generic pn 2 replace the 2", "sound": "default"]
            
        fakePN["externalConsumerId"] = "auth0|5fa21a1e7c07e60069f23382"
        
        print(fakePN)
        
//        LPMessaging.instance.handlePush(fakePN)
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
        
        let configurations = LPConfig.defaultConfiguration
        configurations.enableInAppProcessingForActiveState = true
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
        
        let controlParam = LPConversationHistoryControlParam(historyConversationsStateToDisplay: .all, historyConversationsMaxDays: -1, historyMaxDaysType: .startConversationDate)
        //LPWelcomeMessageParam
        let welcomeMessageParam = LPWelcomeMessage(message: "How can i help you today? #md#[Apple](https://www.apple.com)#/md#", frequency: .everyConversation)
        
        let vc = ConversationViewController()
        vc.accountNumber = "15531115"
        
        let conversationQuery = LPMessaging.instance.getConversationBrandQuery(accountNumber, campaignInfo: campaignInfo)
//        let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, isViewOnly: false)
        let conversationViewParam = LPConversationViewParams(conversationQuery: conversationQuery, containerViewController: vc, isViewOnly: false, conversationHistoryControlParam: controlParam, welcomeMessage: welcomeMessageParam)
        
//        LPMessaging.instance.showConversation(conversationViewParam)
        
        //implicit flow
        let jwtAuthenticationParams = LPAuthenticationParams(authenticationCode: nil, jwt: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5Ea3lSRGRGUXpRNU5VSkVRemhDTjBJMlJVUTBSREpGTnpNeE9Ua3pNREl6UkRCR016TXpNQSJ9.eyJpc3MiOiJodHRwczovL2Rldi1pemthbzQtdi5hdS5hdXRoMC5jb20vIiwic3ViIjoiYXV0aDB8NjA4OTI1NDczZWE0NWIwMDZhNWYwYjE2IiwiYXVkIjoiaUhiSExPRnB0YzFjRGpQaEF1a3pMQVZ4cjRlNTJwQVEiLCJpYXQiOjE2MzQwODYzNDAsImV4cCI6MTYzNDE3NjM0MH0.lHNRaIqiOftAybSAJR0S-cOz7eHOsgYxf-WPbfbVrqK37zRmx68oRUMlRRoNMnQcahhrlzSN6nsVabiPHNaWkttRQWiopkVWzsDpdt6_Z_WYXvaT-LlHLPkubp5uiKkPtdGzko3lhqSaJr4tGKfR5zHzt3fpSi8qX3PfBTbNe6A-Qf-PgLiq2Ebhmaj88H9yeIRzrdjkQdLse-KG_nnGLw1a6fSsR9-SnLgsm9z4QUC8yZmI5X-IoIdzpUPNmDevkY3m77wTwEJw2k90iEd_zQaeR99Mw1-5raM6FTh46Zg2HS9_qeRG7oI7kNB6acFLgniUutQv-mHYESTbUjE9XQ", redirectURI: nil, certPinningPublicKeys: nil, authenticationType: .authenticated)
        
        LPMessaging.instance.showConversation(conversationViewParam, authenticationParams: jwtAuthenticationParams)
        
        self.navigationController?.pushViewController(vc, animated: true)
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
