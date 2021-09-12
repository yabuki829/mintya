//
//  HomeViewController.swift
//  chatApp
//
//  Created by Yabuki Shodai on 2021/06/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
   
    @IBOutlet weak var button: UIButton!
    let database =  Firestore.firestore()
    var  userImageString = String()
    var  userNamelString = String()
    var  groupMenber = [String]()
    //
    var  groupID = String()
    var isLeader = false
    let userDefaults = UserDefaults.standard
    var i = 0
    //グループの最低人数
    var groupNumofPeople = 3
    var indicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        butttonDesign()
        loadFirebase()
        checkMatching()
    }
    override func viewWillAppear(_ animated: Bool) {
        database.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["group":"0","waitingFlg":"0"])
        groupMenber = []
        groupID = ""
        isLeader = false
        button.setTitle("みんなとお話する", for:.normal)
        
    }
    
    //マッチング
    @IBAction func lookforUser(_ sender: Any) {
        matchingUser ()
      
    }
    
    func matchingUser (){
        //addIndicatorを回す
        addIndicator()
        //自分をオンラインにする
        doOnLine()
        //オンラインの人を探す
        getOnLineUsers()
        
    }
    
    func checkMatching(){
        print("マッチングしてるか確認します")
        database.collection("GroupID").document(Auth.auth().currentUser!.uid).addSnapshotListener { [self] (snapShot, error) in
            
            if let error = error {
                print("エラー")
                return
            }
            if isLeader == true {
                return
            }
            let data = snapShot?.data()
            groupID = data!["groupID"] as! String
            if groupID != "0"{
                print("-----------------")
                print(i)
                print("-----------------")
                i = i + 1
                indicator.stopAnimating()
                self.database.collection("GroupID").document(Auth.auth().currentUser!.uid).setData(["groupID":"0"])
                self.performSegue(withIdentifier: "chat", sender: nil)
            }
        }
        
        
        
    }
    
   
    
    
    
    func getOnLineUsers(){
        groupMenber = []
        database.collection("Users").whereField("waitingFlg", isEqualTo:"1").getDocuments{ [self] (QuerySnapshot, Error) in
                if let error = Error {
                    print(error)
                    return
                }
                else{
                    //読み込み中のやつ回す,広告出す

                    print("相手をさがしています")

                    for document in QuerySnapshot!.documents {
                        let data = document.data()
                        let userID = data["userID"] as? String
                        
                        if groupMenber.last != userID {
                            groupMenber.append(userID as! String)
                        }
//                        print("人数\(groupMenber)")
                    }
                    //グループidを作成し取得する
                    getGroupID()

                   
                }

            
            
        }
      

    }
    
    
    
    func  getGroupID(){
                if groupMenber.count == groupNumofPeople {
                    if Auth.auth().currentUser?.uid == groupMenber[1] {
                        print("あなたはリーダーです")
                        isLeader = true
                        createGroupID()
                       

                    }else{
                       
                    }
                }else {
                   print("見つかりませんでした")

                }
       
        
        
    }
    
    func createGroupID(){
        print("createGroupID")
        let docID = database.collection("Groups").document()
        print("docID.documentID:\(docID.documentID)")
        //グループの作成
        var  roomID = String()
        roomID = docID.documentID
        print("roomID:\(roomID)")
        groupID = roomID
        //探し中の状態を変更
        
        print(groupMenber)
        for i in 0..<groupMenber.count{
            
            self.database.collection("GroupID").document(groupMenber[i]).setData(["groupID":roomID])
            let flgData = ["waitingFlg":"0"]
            database.collection("Users").document(groupMenber[i]).updateData(flgData)
            print("\(i)回目")
            //メンバーのユーザー名を取得する
            database.collection("Users").document(groupMenber[i]).getDocument { [self] (snapShot, error) in
                let data = snapShot?.data()
                let username = data!["username"]
               
                database.collection("Groups").document(roomID).collection("Menber").document(groupMenber[i]).setData(["username": username! ,"userID":groupMenber[i]])
               
                }
           
        }
        
        print("遷移します")
        indicator.stopAnimating()
        self.performSegue(withIdentifier: "chat", sender: nil)
    }
    func addIndicator(){
       
        indicator.center = view.center
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    //userLabelがなぜか表示されないためfirebaseからuser名を読み込んでいる　できればuserDefaltsをつかいたい。
    func getuserInfo(){
        userNamelString = (UserDefaults.standard.string(forKey: "userName") as String?)!
        userImageString = (UserDefaults.standard.string(forKey: "userImage") as String?)!
        print(userImageString)
        print(userNamelString)
        self.userImage.image = UIImage(named: self.userImageString)
        self.userLabel.text = "こんにちは　\(self.userNamelString)　さん"
       
    }
    
    func doOnLine(){
        let flgData = ["waitingFlg":"1"]
        database.collection("Users").document(Auth.auth().currentUser!.uid).updateData(flgData)
        
    }
    func doOffLine(userid:String)  {
        let flgData = ["waitingFlg":"0"]
        database.collection("Users").document(userid).updateData(flgData)
    }
    
    //firebaseからuser情報を取得
    //userDefaultsを使うとなぜかuserlabelが表示されないため,原因を見つけて今後　UserDefaltsに変更する予定
    func loadFirebase(){
        database.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (snapShot, error) in
            if let error = error {
                print(error)
                return
            }
            let data = snapShot?.data()
            self.userImageString = data!["userImage"] as! String
            self.userNamelString = data!["username"] as! String
            self.userImage.image = UIImage(named: self.userImageString)
            self.userLabel.text = "こんにちは　\(self.userNamelString)　さん"
        }
    }
    func  butttonDesign(){
        button.layer.shadowOpacity = 0.7
               // 影のぼかしの大きさ
        button.layer.shadowRadius = 3
               // 影の色
        button.layer.shadowColor = UIColor.black.cgColor
               // 影の方向（width=右方向、height=下方向）
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let nextVC = segue.destination as!  ViewController
            nextVC.groupID = self.groupID
    }
    

}
