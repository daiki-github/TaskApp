//
//  InputViewController.swift
//  taskapp
//
//  Created by 古林大輝 on 2018/11/17.
//  Copyright © 2018 daiki-github. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    //前の画面から変数の受け渡し、の継続を宣言しているviewcontrollerの82行目
    var task:Task!
    //画面上でのキーボードの出し入れ
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tapGestureのクラスを作っていてこの画面がタップされた時に行う処理の記載、タップ時にdismissKeyboardが起動のルール設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //そして実行される
        self.view.addGestureRecognizer(tapGesture)
        //var task:Task!からのデータを引っ張ってきて画面に表示させている、前の画面のtaskうの詳細の変更
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //viewWillDisappear(_:)メソッドは遷移する際に、画面が非表示になるとき呼ばれるメソッドです。
    //inputviewcontrollerからviewcontrollerに移動するときに画面を消す処理、レルムを使う時に使用される場合が多い
    override func viewWillDisappear(_ animated: Bool) {
        //viewcontrollerに戻るときにデータの保存、書き換えの処理をやりたいという時に使用、
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        //通知、(task: task)は56行目につながっていてパラメーターのようなもの
        setNotification(task: task)
        //決まり文句、viewWillDisappear実行の合図
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        //UNMutableNotificationContentクラスのインスタンスを使って通知内容を設定
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        //UNNotificationRequestに、通知内容やトリガーを設定し、ローカル通知を作成
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録。UNUserNotificationCenterにローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    //dismissKeyboard()メソッドではendEditing(true)を呼び出してキーボードを閉じます。
    @objc func dismissKeyboard(){
        // キーボードを閉じる、今表示されているキーボードが下がるということ
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
