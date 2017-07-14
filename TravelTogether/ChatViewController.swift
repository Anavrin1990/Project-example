//
//  ChatViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 14.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    let imagePicker = UIImagePickerController()
    var messages = [JSQMessage]()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.senderId = "1"
        self.senderDisplayName = "321"
        automaticallyScrollsToMostRecentMessage = true
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, text: text))
        self.keyboardController.textView.text = nil
        collectionView.reloadData()
        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if self.messages[indexPath.item].senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .red)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        return NSAttributedString(string: "123")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "321")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

}
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let photo = JSQPhotoMediaItem(image: image)
        
        self.messages.append(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: photo))
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
    
}
