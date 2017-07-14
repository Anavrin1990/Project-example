//
//  ChatViewController.swift
//  TravelTogether
//
//  Created by Dmitry on 14.07.17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SwiftyJSON
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    let imagePicker = UIImagePickerController()
    
    var messages = [JSQMessage]() {
        didSet {
            endIndex = Int(self.messages[0].date.timeIntervalSince1970)
        }
    }
    
    var lastIndex: Int?
    var endIndex: Int?
    
    var user: User? {
        didSet {
            navigationItem.title = user?.person?.name
            observeMessages()
        }
    }    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = User.uid
        self.senderDisplayName = User.person?.name
        
        imagePicker.delegate = self
    }
    
    func observeMessages() {
        guard let uid = User.uid, let toId = user?.uid else {return}
        Request.singleRequest(reference: Request.ref.child("UserMessages").child(uid).child(toId).queryLimited(toFirst: 1), type: .value) { (snapshot, error) in
            
            var lastIndex: Int?
            
            if let snap = snapshot?.value as? NSDictionary {
                let json = JSON(snap).first
                lastIndex = json?.1["timestamp"].intValue
            }
            Request.observeRequest(reference: Request.ref.child("UserMessages").child(uid).child(toId).queryLimited(toLast: reqLimit), type: .childAdded) { (snapshot, error) in
                guard error == nil else {return}
                
                guard let dictionary = snapshot?.value as? [String: AnyObject] else {return}
                
                let message = Message(dictionary: dictionary)
                
                let date = Date(timeIntervalSince1970: Double(message.timestamp!) )
                
                guard let text = message.text else {return}
                
                self.messages.append(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, text: text))
                
                self.lastIndex = lastIndex ?? Int(self.messages[0].date.timeIntervalSince1970)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard collectionView.isDragging else {return}
        guard let lastIndex = self.lastIndex else {return}
        guard let endIndex = self.endIndex else {return}
        guard let uid = User.uid, let toId = user?.uid else {return}
        guard indexPath.row == 0 else {return}
        guard endIndex > lastIndex else {return }
        
        
        let userMessagesRef = Request.ref.child("UserMessages").child(uid).child(toId).queryOrdered(byChild: "timestamp").queryEnding(atValue: endIndex - 1).queryLimited(toLast: reqLimit)
        
        Request.singleRequest(reference: userMessagesRef, type: .value) { (snapshot, error) in
            guard error == nil else {return}
            
            if let snapshots = snapshot?.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots.reversed() {
                    if let dictionary = snap.value as? [String : Any] {
                        
                        let message = Message(dictionary: dictionary)
                        
                        let date = Date(timeIntervalSince1970: Double(message.timestamp!) )
                        
                        guard let text = message.text else {return}
                        
                        self.messages.insert(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, text: text), at: 0)
                    }
                }
                DispatchQueue.main.async {
                    let oldOffsetReversed = self.collectionView!.collectionViewLayout.collectionViewContentSize.height - self.collectionView!.contentOffset.y
                    self.collectionView!.reloadData()
                    let offset =  self.collectionView!.collectionViewLayout.collectionViewContentSize.height - oldOffsetReversed
                    self.collectionView!.contentOffset = CGPoint(x: self.collectionView!.contentOffset.x, y: offset)
                }
            }
        }
        
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Request.ref.child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid!
        let fromId = User.uid!
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        Request.updateChildValue(reference: childRef, value: values) {
            
            let userMessagesRef = Request.ref.child("UserMessages").child(fromId).child(toId)
            
            let messageId = childRef.key
            Request.updateChildValue(reference: userMessagesRef, value: [messageId : values], complition: {})
            
            let recipientUserMessagesRef = Request.ref.child("UserMessages").child(toId).child(fromId)
            Request.updateChildValue(reference: recipientUserMessagesRef, value: [messageId : values], complition: {})
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard text != "" else {return}
        
        let properties = ["text": text, "senderName" : User.person?.name]
        sendMessageWithProperties(properties as [String : AnyObject])
       
        self.keyboardController.textView.text = ""
        collectionView.reloadData()
        
        //let indexPath = IndexPath(item: self.chatMessages.count - 1, section: 0)
        //self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        let date = self.messages[indexPath.item].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return NSAttributedString(string: dateFormatter.string(from: date!))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let date = self.messages[indexPath.item].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        
        return NSAttributedString(string: dateFormatter.string(from: date!))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return NSAttributedString(string: "Доставлено")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault
//    }

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
