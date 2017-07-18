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
import ImageSlideshow

class ChatViewController: JSQMessagesViewController {
    
    var typingRef: FIRDatabaseReference?
    var messagesRef: FIRDatabaseReference?
    var userStatusRef: FIRDatabaseReference?
    
    let imagePicker = UIImagePickerController()
    
    let chatNavigationView = Bundle.main.loadNibNamed("ChatNavigationView", owner: self, options: nil)?.first as! ChatNavigationView
    
    var customMessages = [Message]()
    var messages = [JSQMessage]() {
        didSet {
            endIndex = Int(self.messages[0].date.timeIntervalSince1970)
        }
    }
    var lastIndex: Int? // Last pagination index
    var endIndex: Int? // Last batch index
    
    var checkTypingTimer: Timer?
    var isTyping = false
    var updateStatusCount = 1
    
    var user: User? {
        didSet {
            chatNavigationView.nameLabel.text = user?.person?.name
            chatNavigationView.lastSeen = user?.lastSeen
            chatNavigationView.status = user?.status
            observeMessagesTypingStatus()
            setProfileImageOnBarButton()
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == self.navigationController?.parent {
            let refArray = [typingRef, userStatusRef]
            Request.removeAllObservers(refArray)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Observe user status (It works only here O_o)
        guard let toId = user?.uid else {return}
        self.userStatusRef = Request.ref.child("Users").child(toId)
        
        Request.observeRequest(reference: self.userStatusRef!, type: .childChanged, completion: { (snapshot, error) in
            guard let status = snapshot?.value as? String, snapshot?.key == "status" else {return}
            let stringArray = status.components(separatedBy: "_")
            self.chatNavigationView.lastSeen = stringArray[1]
            self.chatNavigationView.status = UserStatus(rawValue: stringArray[0])
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = false
        self.senderId = User.uid
        self.senderDisplayName = User.person?.name
        self.navigationController?.delegate = self
        imagePicker.delegate = self        
        self.navigationItem.titleView = chatNavigationView
    }
    
    func setProfileImageOnBarButton() {
        let button = UIButton()
        getCachedImage(url: user?.icon) { (image) in
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action:#selector(showDetail), for: .touchUpInside)
        button.frame = CGRect(x: 0, y :0, width: 36, height: 36)
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.masksToBounds = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: Segue
    func showDetail() {
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DetailViewController {
            dvc.user = user
        }
    }
    
    // MARK: Requests
    func observeMessagesTypingStatus() {
        guard let uid = User.uid, let toId = user?.uid else {return}        
        
        // Last index
        Request.singleRequest(reference: Request.ref.child("UserMessages").child(uid).child(toId).queryLimited(toFirst: 1), type: .value) { (snapshot, error) in
            
            var lastIndex: Int?
            
            if let snap = snapshot?.value as? NSDictionary {
                let json = JSON(snap).first
                lastIndex = json?.1["timestamp"].intValue
            }
            
            // Observe typing
            self.typingRef = Request.ref.child("UserMessages").child(uid).child("Typing").child(toId)
            
            Request.observeRequest(reference: self.typingRef!, type: .childChanged) { (snapshot, error) in
                guard error == nil else {return}
                guard snapshot?.key == "typing" else {return}
                
                if let typing = snapshot?.value as? Bool {
                    DispatchQueue.main.async {
                        self.showTypingIndicator = typing
                        if !self.collectionView.isDragging {
                            self.scrollToBottom(animated: true)
                        }
                    }
                }
            }
            
            
            
            self.messagesRef = Request.ref.child("UserMessages").child(uid).child(toId)
            
            // Observe message status
            Request.observeRequest(reference: self.messagesRef!.queryLimited(toLast: 1), type: .childChanged) { (snapshot, error) in
                DispatchQueue.main.async {
                    self.customMessages.last?.status = .read
                    self.collectionView?.reloadData()
                }
            }
            
            // Observe messages
            Request.observeRequest(reference: self.messagesRef!.queryLimited(toLast: reqLimit), type: .childAdded) { (snapshot, error) in
                guard error == nil else {return}
                
                guard let dictionary = snapshot?.value as? [String: AnyObject] else {return}
                
                let message = Message(dictionary: dictionary)
                message.key = snapshot?.key
                
                let date = Date(timeIntervalSince1970: Double(message.timestamp!))
                
                if message.type == "text" {
                    
                    guard let text = message.text else {return}
                    self.messages.append(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, text: text))
                    
                } else {
                    
                    guard let imageUrl = message.imageUrl else {return}
                    let jsqImage = JSQPhotoMediaItem(image: nil)
                    
                    jsqImage?.appliesMediaViewMaskAsOutgoing = self.senderId == message.fromId
                    
                    getCachedImage(url: imageUrl, completion: { (image) in
                        jsqImage?.image = image
                        self.collectionView?.reloadData()
                    })
                    self.messages.append(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, media: jsqImage))
                    
                }
                self.customMessages.append(message)
                
                self.lastIndex = lastIndex ?? Int(self.messages[0].date.timeIntervalSince1970)
                
                self.updateStatusCount = 1
                
                DispatchQueue.main.async {
                    
                    // Update message status
                    if let lastMessage = self.customMessages.last {
                        if self.updateStatusCount == 1 {
                            self.updateStatusCount += 1
                            if self.senderId != lastMessage.fromId {
                                let messageKey = lastMessage.key!
                                Request.updateChildValue(reference: Request.ref.child("UserMessages").child(toId).child(uid).child(messageKey), value: ["status" : "read" as AnyObject], completion: {})
                            }
                        }
                    }
                    self.collectionView?.reloadData()
                    if !self.collectionView.isDragging {
                        self.scrollToBottom(animated: true)
                    }
                }
            }
        }
    }
    
    // Pagination
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard collectionView.isDragging else {return}
        guard let lastIndex = self.lastIndex else {return}
        guard let endIndex = self.endIndex else {return}
        guard let messagesRef = self.messagesRef else {return}
        guard indexPath.row == 0 else {return}
        guard endIndex > lastIndex else {return}
        
        let userMessagesRef = messagesRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: endIndex - 1).queryLimited(toLast: reqLimit)
        
        Request.singleRequest(reference: userMessagesRef, type: .value) { (snapshot, error) in
            guard error == nil else {return}
            
            if let snapshots = snapshot?.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots.reversed() {
                    if let dictionary = snap.value as? [String : Any] {
                        
                        let message = Message(dictionary: dictionary)
                        
                        let date = Date(timeIntervalSince1970: Double(message.timestamp!) )
                        
                        if message.type == "text" {
                            
                            guard let text = message.text else {return}
                            self.messages.insert(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, text: text), at: 0)
                            
                        } else {
                            
                            guard let imageUrl = message.imageUrl else {return}
                            let jsqImage = JSQPhotoMediaItem(image: nil)
                            
                            jsqImage?.appliesMediaViewMaskAsOutgoing = self.senderId == message.fromId
                            
                            getCachedImage(url: imageUrl, completion: { (image) in
                                DispatchQueue.main.async {
                                    jsqImage?.image = image
                                    self.collectionView?.reloadData()
                                }
                            })
                            self.messages.insert(JSQMessage(senderId: message.fromId, senderDisplayName: message.senderName, date: date, media: jsqImage), at: 0)
                        }
                        self.customMessages.insert(message, at: 0)
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
    
    // MARK: Buttons handle
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard text != "" else {return}
        
        let properties = ["type" : "text", "text": text]
        
        Request.updateChildValue(reference: Request.ref.child("UserMessages").child(user!.uid!).child("Typing").child(User.uid!), value: ["typing" : false], completion: {
            self.sendMessageWithProperties(properties as [String : AnyObject])
        })
        
        inputToolbar.contentView.textView.text.removeAll()
        inputToolbar.contentView.rightBarButtonItem.isEnabled = false
        
        collectionView.reloadData()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["type" : "image" as AnyObject, "imageUrl": imageUrl as AnyObject]
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Request.ref.child("Messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid!
        let fromId = User.uid!
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["senderName" : User.person?.name as AnyObject, "toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp": timestamp as AnyObject, "status" : "delivered" as AnyObject]
        
        properties.forEach({values[$0] = $1})
        
        Request.updateChildValue(reference: childRef, value: values) {
            
            let userMessagesRef = Request.ref.child("UserMessages").child(fromId).child(toId)
            
            let messageId = childRef.key
            Request.updateChildValue(reference: userMessagesRef, value: [messageId : values], completion: {})
            
            let recipientUserMessagesRef = Request.ref.child("UserMessages").child(toId).child(fromId)
            Request.updateChildValue(reference: recipientUserMessagesRef, value: [messageId : values], completion: {})
        }
    }
    
    // MARK: Typing
    override func textViewDidChange(_ textView: UITextView) {
        inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        startTypingRequest()
        checkTypingTimer?.invalidate()
        checkTypingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopTypingRequest), userInfo: nil, repeats: false)
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom(animated: true)
    }
    
    func startTypingRequest() {
        if !isTyping {
            Request.updateChildValue(reference: Request.ref.child("UserMessages").child(user!.uid!).child("Typing").child(User.uid!), value: ["typing" : true], completion: {})
        }
        isTyping = true
    }
    
    func stopTypingRequest() {
        Request.updateChildValue(reference: Request.ref.child("UserMessages").child(user!.uid!).child("Typing").child(User.uid!), value: ["typing" : false], completion: {})
        isTyping = false
    }
    
    // MARK: CollectionView Delegate
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
        cell.textView?.textColor = UIColor.white
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
        dateFormatter.dateFormat = "dd MMMM"
        
        return NSAttributedString(string: dateFormatter.string(from: date!))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let status = self.customMessages[indexPath.item].status?.localValue ?? ""
        return NSAttributedString(string: status)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item == messages.count - 1 && self.messages[indexPath.item].senderId == self.senderId {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        guard indexPath.item != 0 else {return 0}
        let currentMessageDate = messages[indexPath.item].date
        let previousMessageDate = messages[indexPath.item - 1].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        
        if dateFormatter.string(from: currentMessageDate!) != dateFormatter.string(from: previousMessageDate!) {
            return 35
        }
        return 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if let image = self.getImageFromBubble(indexPath: indexPath) {
            
            let fullscreen = FullScreenSlideshowViewController()
            let imageSource = ImageSource(image: image)
            fullscreen.slideshow.pageControl.currentPageIndicatorTintColor = UIColor.clear
            fullscreen.inputs = [imageSource]
            
            self.present(fullscreen, animated: true, completion: nil)
           
        }
    }
    
    func getImageFromBubble(indexPath: IndexPath) -> UIImage? {
        let message = self.messages[indexPath.row]
        if message.isMediaMessage == true {
            let mediaItem = message.media
            if mediaItem is JSQPhotoMediaItem {
                let photoItem = mediaItem as! JSQPhotoMediaItem
                if let image = photoItem.image {
                    let result = image
                    return result
                }
            }
        }
        return nil
    }    
}

// MARK: Send image
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageName = UUID().uuidString
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if let uploadPhoto = UIImageJPEGRepresentation(image, 0.6) {
            Request.storagePutData(reference: Request.storageRef.child(User.uid!).child("messagePhotos").child(imageName), data: uploadPhoto, completion: { (metadata, error) in
                guard error == nil else {print (error?.localizedDescription as Any); return}
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageURL, image: image)
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
    
}
