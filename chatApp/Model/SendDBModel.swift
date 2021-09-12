//
//  SendDBModel.swift
//  chatApp
//
//  Created by Yabuki Shodai on 2021/06/30.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class SendDBModel {
    var database = Firestore.firestore()
    
    var userID = String()
    var groupID = String()
    var userName = String()
    var userImage = String()
    var message = String()
    
    
    init(userID: String,userName: String,userImage: String) {
        self.userID = userID
        self.userName = userName
        self.userImage = userImage
    }
    func register(){
        self.database.collection("Users").document(Auth.auth().currentUser!.uid).setData(
            ["userID":self.userID,"username":self.userName,"userImage":self.userImage,"waitingFlg":"0","group":"0"]
        )
        
        print("登録が呼ばれてます")
        print("登録完了しました。")
    }
    
    
    //-------------------Send a Message.---------------------------

    init(userName:String,userImage:String,message:String,userID:String,groupID:String) {
        self.userName = userName
        self.userImage = userImage
        self.message = message
        self.userID = userID
        self.groupID = groupID
        
    }
    func sendMessage(){
        self.database.collection("Groups").document(groupID).setData(
            ["userName": self.userName,"userImage":userImage,"message":message,"userID":userID]
        )
        
    }
    
}
