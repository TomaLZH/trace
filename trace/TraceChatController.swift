//
//  TraceChatController.swift
//  trace
//
//  Created by Justin Tey on 21/06/2019.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import MessageKit

class TraceChatController:
    MessagesViewController,
    MessagesDataSource,
    MessagesLayoutDelegate,
    MessagesDisplayDelegate,
    MessageInputBarDelegate
{

    var messages: [Message] = []
    var member: Member!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        member = Member(name: "Desmond", color: .green)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
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
    
    func configureAvatarView(_ avatarView: AvatarView,
                             for message: MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView)
    {
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }
    
    func inputBar(_ inputBar: MessageInputBar,
                  didPressSendButtonWith text: String) {
        let newMessage = Message(member: member, text: text, messageId: UUID().uuidString)
        
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}
