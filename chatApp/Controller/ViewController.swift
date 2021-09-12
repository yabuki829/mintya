//
//  ViewController.swift
//  chatApp
//
//  Created by Yabuki Shodai on 2021/06/29.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

import IQKeyboardManagerSwift
class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var sendButton: UIButton!
    let database = Firestore.firestore()
    var groupID = String()
    var userName = String()
    var userImage = String()
    let userDefaults = UserDefaults.standard
    var messageArray = [chatData]()
    override func viewDidLoad() {
        
        print("遷移後です")
        textField.text = groupID
        loadFirebase()
        loadChatMessage()
        super.viewDidLoad()
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
 
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      //もしもメンバーが二人になったらグループを 解散する　groupID
        database.collection("GroupID").document(Auth.auth().currentUser!.uid).updateData(["groupID":"0"])
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.cgRectValue.minY
        textField.transform = CGAffineTransform(translationX: 0, y: min(0, -keyboardHeight + view.safeAreaInsets.bottom - textField.frame.height))
        sendButton.transform = CGAffineTransform(translationX: 0, y: min(0, -keyboardHeight + view.safeAreaInsets.bottom - sendButton.frame.height))
    }
 
    @IBAction func send(_ sender: Any) {
        //user名　画像 メッセージ内容　どこに送ったか
        if textField.text?.isEmpty == true{
            return
        }
        
       if let message = textField.text{
        self.database.collection("Groups").document(groupID).collection("Messages").document().setData(
            ["username":self.userName,"userImage":self.userImage,"message":message,"groupID":Auth.auth().currentUser?.uid,"date":Date().timeIntervalSince1970,"userID":Auth.auth().currentUser?.uid])
        }
        self.textField.text = ""
        textField.resignFirstResponder()
    }
    
    
}



extension ViewController:  UITableViewDelegate,UITableViewDataSource ,UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //messageの数を返す
        print(messageArray.count)
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //メッセージ　user名　自分以外のuserアイコン
        
        print("------------------------------------")
        print(messageArray[indexPath.row].userID)
        print(Auth.auth().currentUser?.uid)
        print("------------------------------------")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let yourUserImage = cell.contentView.viewWithTag(1) as! UIImageView
        
        let userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let messageLabel = cell.contentView.viewWithTag(3) as! UILabel
        let myImage = cell.contentView.viewWithTag(4) as! UIImageView
        let mymessageLabel =  cell.contentView.viewWithTag(5) as! UILabel
       
        //もしも自分のメッセージじゃなければ、画像と名前を表示しない。
        //メッセージと名前はコードで追加する
        if Auth.auth().currentUser?.uid == messageArray[indexPath.row].userID{
            
            //自分のメッセージ
            yourUserImage.isHidden = true
            myImage.isHidden = false
            myImage.image = UIImage(named: messageArray[indexPath.row].userImage)
            myImage.layer.cornerRadius = myImage.frame.size.height / 2
            userNameLabel.textAlignment = NSTextAlignment.right
            if messageArray[indexPath.row].message.count > 18 {
                mymessageLabel.textAlignment = NSTextAlignment.left
                mymessageLabel.text = messageArray[indexPath.row].message
            }else{
                mymessageLabel.textAlignment = NSTextAlignment.right
                mymessageLabel.text = messageArray[indexPath.row].message
            }
            
            
        }
        else{
//            相手のメッセージ
            myImage.isHidden = true
            yourUserImage.isHidden = false
            yourUserImage.image = UIImage(named: messageArray[indexPath.row].userImage)
            
            yourUserImage.layer.cornerRadius = 35
            
            if messageArray[indexPath.row].message.count >= 18 {
                messageLabel.textAlignment = NSTextAlignment.right
                
                messageLabel.text = messageArray[indexPath.row].message
            }
            else{
                messageLabel.textAlignment = NSTextAlignment.left
                
                messageLabel.text = messageArray[indexPath.row].message
            }
           
            
        }
        userNameLabel.text = messageArray[indexPath.row].userName
        return cell
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        
        print(textField.frame.origin.y)
      }
    
}


extension ViewController{
    //やること1
   
    func loadFirebase(){
        database.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapShot, error) in
            if let error = error {
                print(error)
                return
            }
            let data = snapShot?.data()
            self.userImage = data!["userImage"] as! String
            self.userName = data!["username"] as! String
          
        }
    }
    
    
    func loadChatMessage(){
        database.collection("Groups").document(groupID).collection("Messages").order(by:"date", descending: false).addSnapshotListener { [self] (snapShot, error) in
            if let error = error {
                print("エラーです")
            }
            else{
             
                if let snapShotDoc = snapShot?.documents {
                    messageArray = []
                    for doc in snapShotDoc
                    {
                        let data = doc.data()
                        if let userName = data["username"] as? String,
                           let userImage = data["userImage"]as? String,
                           let userID = data["userID"]as? String,
                           let message = data["message"]as? String {
                            
                            let Data = chatData(userName: userName, userImage: userImage,message: message, userID:userID)
                            messageArray.append(Data)
                        }
                    }
                }
                tableView.reloadData()
            }
        }
    }

}
