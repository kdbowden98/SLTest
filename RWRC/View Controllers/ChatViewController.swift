import UIKit
import Photos
import Firebase
import MessageKit
import FirebaseFirestore

final class ChatViewController: MessagesViewController {
  
  private let db = Firestore.firestore()
  private var reference: CollectionReference?
  private let storage = Storage.storage().reference()

  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  
  private let user: User
  private var userTo: String
  private let channel: Channel
  
  deinit {
    messageListener?.remove()
  }
  
  init(user: User, channel: Channel, userTo: String) {
    self.user = user
    self.userTo = userTo
    self.channel = channel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }
    
    if channel.name == UserDefaults.standard.string(forKey: "fullName"){
      title = channel.from
    } else{
      title = channel.name
    }

    findRecipientEmail(channel)
    reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
    
    if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
      layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
      layout.textMessageSizeCalculator.incomingAvatarSize = .zero
    }
    
    messageListener = reference?.order(by: "created").addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      print("document update")
      
      snapshot.documentChanges.forEach { change in
        print("to handle document change")
        self.handleDocumentChange(change)
      }
    }
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .primary
    messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    messageInputBar.leftStackView.alignment = .center
    messageInputBar.setLeftStackViewWidthConstant(to: 10, animated: false)// 3
  }
  
  // MARK: - Actions
  
   func handleSend(_ message: Message){
    
    reference?.addDocument(data: message.representation) { error in
      if let e = error {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  func findRecipientEmail(_ channel: Channel){
      let channelRef = db.collection("user-info")
      let userChannels = channelRef.whereField("name", isEqualTo: channel.name)
      userChannels.getDocuments(){(QuerySnapshot, err) in
          if let err = err{
            print("error retrieving documents: \(err)")
          }else{
            //get recipient email
            for document in QuerySnapshot!.documents{
              print(document.documentID)
              self.userTo = document.documentID
            }
          }
        }
    }
  
  // MARK: - Helpers
  
  private func insertNewMessage(_ message: Message) {
    guard !messages.contains(message) else {
      print("messages contains message")
      return
    }
    print("messages to append")
    
    messages.append(message)
    print("message appended \(message)")
    messages.sort()
    
    print("first \(messages.first)")
    let isLatestMessage = messages.index(of: message) == (messages.count - 1)
    let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
    
    messagesCollectionView.reloadData()
    
    if shouldScrollToBottom {
      DispatchQueue.main.async {
        self.messagesCollectionView.scrollToBottom(animated: true)
      }
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard let message = Message(document: change.document) else {
      print("message != change")
      return
    }
    print("handle change")
    
    switch change.type {
    case .added:
        insertNewMessage(message)
    default:
      break
    }
  }
  
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
    return false
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
  
  func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return .zero
  }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
    return CGSize(width: 0, height: 8)
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    
    return 0
  }
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func currentSender() -> Sender {
    return Sender(id: user.uid, displayName: AppSettings.displayName)
  }
  
  func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
  
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    let message = Message(user: user, content: text, toId: userTo)

    handleSend(message)
    inputBar.inputTextView.text = ""
  }
}



