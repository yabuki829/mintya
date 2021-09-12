//
//  RegisterViewController.swift
//  chatApp
//
//  Created by Yabuki Shodai on 2021/06/29.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate  {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var UIPicker: UIPickerView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    let userDefaults = UserDefaults.standard
    var hiddenImageArray = [(key: String, imagename: String)]()
    var userImageString = ""
    let database = Firestore.firestore()
    var usedImageName = ["女性1","女性2","女性3","女性4","女性5","女性6","女性7","女性8","女性9","女性10","女性11","男性1","男性2","男性3","男性4","男性5","男性6","男性7","男性8","男性9","男性10","男性11","男性12","赤ちゃん"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        userImage.image = UIImage(named: usedImageName[1])
        UIPicker.delegate = self
        UIPicker.dataSource = self
        userNameTextField.delegate = self
        
        //隠しコマンド的な
        let imagedata = imagesData()
        hiddenImageArray = imagedata.hiddenImage
        print(hiddenImageArray[0].key)
        
        buttonDesign()
    }
    

    @IBAction func register(_ sender: Any) {
        //画像と名前があれば
        if userNameTextField.text?.isEmpty  == true {
            return
        }
        let userName  = userNameTextField.text
        //匿名ログインを行う
        Auth.auth().signInAnonymously { (authResult, error) in
            if error != nil{
                print(error)
                return
            }
            let user = authResult?.user
            let sendDBModel = SendDBModel(userID: Auth.auth().currentUser!.uid, userName: userName!, userImage: self.userImageString)
            sendDBModel.register()
            self.userDefaults.set(userName, forKey: "userName")
            self.userDefaults.set(self.userImageString, forKey: "userImage")
            //画面遷移する
            self.database.collection("GroupID").document(Auth.auth().currentUser!.uid).setData(["groupID":"0"])
            self.performSegue(withIdentifier: "home", sender: nil)
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //filterかける　エラーが出てできなかった。
        checkComand()
        userNameTextField.resignFirstResponder()
        return true
    }
    
    
    
    //UIPicker---------------------------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return usedImageName.count
    }
    func pickerView(_ pickerView: UIPickerView,
                       titleForRow row: Int,
                       forComponent component: Int) -> String? {
           
           return usedImageName[row]
       }
    
       
       // UIPickerViewのRowが選択された時の挙動
       func pickerView(_ pickerView: UIPickerView,
                       didSelectRow row: Int,
                       inComponent component: Int) {
        userImage.image = UIImage(named: usedImageName[row])
        userImageString = usedImageName[row]
       }
    
    func checkComand(){
        //特定のユーザー名にすると特別な画像が使える
        let username = userNameTextField.text
        for i in 0..<hiddenImageArray.count{
            if username == hiddenImageArray[i].key {
                userImage.image = UIImage(named:hiddenImageArray[i].imagename)
                userImageString = hiddenImageArray[i].imagename
                userNameTextField.text = ""
                break
            }
        }
    }
    func buttonDesign(){
        button.layer.shadowOpacity = 0.7
               // 影のぼかしの大きさ
        button.layer.shadowRadius = 3
               // 影の色
        button.layer.shadowColor = UIColor.black.cgColor
               // 影の方向（width=右方向、height=下方向）
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
    }

}
