//
//  TraceChatController.swift
//  trace
//
//  Created by Justin Tey on 21/06/2019.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import ApiAI
import AVFoundation
import FirebaseDatabase





var ref: DatabaseReference?
var databaseHandle: DatabaseHandle?


class TraceChatController:
    MessagesViewController,
    MessagesDataSource,
    MessagesLayoutDelegate,
    MessagesDisplayDelegate,
    InputBarAccessoryViewDelegate
{
    
    
    var newpost = [String]()
    

    
    var messages: [Message] = []
    var member: Member!
    var memberTrace = Member(name: "Trace", color: .red)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tabBarController!.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.tabBarController!.tabBar.isHidden = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        member = Member(name: "Sender", color: .blue)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // Hiding the avatar view ////////////////////////
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int
    {
        return messages.count
    }
    
    func currentSender() -> SenderType
    {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType
    {
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType,
                               at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        return 12
    }
    
    func messageTopLabelAttributeText(for message: MessageType,
                                      at indexPath: IndexPath) -> NSAttributedString
    {
        return NSAttributedString(string: message.sender.displayName,
                                  attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat
    {
        return 0
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        let newMessage = Message(member: member, text: text, messageId: "0")
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
        requestDialogFlow(message: newMessage.text)
    }
    
    func requestDialogFlow(message: String?)
    {
        let request = ApiAI.shared().textRequest()
        
        if let text = message, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech {
                let traceReply = Message(member: self.memberTrace, text: textResponse, messageId: "1")
                self.messages.append(traceReply)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
                
                self.speechAndText(text: textResponse)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
    }
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        
        // Show reply by Trace
        
        // Read out reply
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        
    }
}
