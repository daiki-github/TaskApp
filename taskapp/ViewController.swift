//
//  ViewController.swift
//  taskapp
//
//  Created by 古林大輝 on 2018/11/17.
//  Copyright © 2018 daiki-github. All rights reserved.
//

import UIKit
import RealmSwift //レルム
import UserNotifications //ユーザー通知



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する。Realmを使うために import RealmSwiftを追加します。そしてlet realm = try! Realm()を追加してRealmのインスタンスを取得します。realmの中のデータをviewcontrollerで使えるようにする
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    //個別の読み書きではなく、データの一覧を取得するにはRealmクラスのobjects(_:)メソッドでクラスを指定しての一覧を取得します。そしてsorted(byKeyPath:ascending:)メソッドでソート（並べ替え）して配列を取り出します。
    //taskArrayはデータベースに追加や削除される度に自動で更新されるのでこのあとはソートを意識する必要はありません。
    
    //taskarrayには配列が入ってくる。Realm()の中のobjectを一旦取ってきて.sortedは並び替えるの意味で日付順に並び替える、そしてascendingは小さい順に並べるがfalseなので大きい順に並べるということになっている
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    //overrideは元の機能に上書きをする。ここでいう、UIViewControllerなど、初めに指定していれば指定は必要なし！
    //viewDidLoaアプリの起動などのライフサイクルの読み込みのタイミングに呼び出されるメソッド
    override func viewDidLoad() {
        //UIViewControllerの機能を使うという宣言！
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //下2行はデリゲート(渡す)の指定。Outletで接続したtableViewのdelegateとdataSourceにselfを指定しています。ここでselfとはViewControllerのこと。tableViewは自分で解決せずに、ViewControllerをデリゲートとして指定して実装を任せた。classにUITableViewDataSource, UITableViewDelegate を追加しこの二つから継承させる。そして、その二つにはプロトコルが存在し、プロトコル（約束）の中には何が記述されているのかについて触れておきますと、実装して欲しいメソッド名が記述されている。プロトコルで指定されたメソッドのことを デリゲートメソッド といい二箇所メソッドを追加する。cellの追加
        
        //selfはViewControllerに置き換えることができ、delegate、dataSource機能を使えるようにしている
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //ライフサイクルメソッドのひとつ、放置でもOK！
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // segueで画面遷移するに呼ばれる。画面遷移自体は先に実装していたperformSegue(withIdentifier:sender:)メソッドによってcellSegueのsegueが実行されて画面遷移します。今回、+ボタンとセルをタップした時の2つのケースで遷移することがあるのでこのメソッドの中で場合分けして処理を記述します。
    //cellはtableviewの行で、cellsegueはcellを判別する、segue始点と終点の間を行き来する
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        //目的地の設定、次の遷移先の指定
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //セルをタップした時は先ほど設定したIdentifierがcellSegueであるsegueが発行されます。IdentifierがcellSegueのときはすでに作成済みのタスクを編集するときなので配列taskArrayから該当するTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定します。
        
        //segue.identifierこの書き方は覚える
        if segue.identifier == "cellSegue" {
            //セルをタップした時は先ほど設定したIdentifierがcellSegueであるsegueが発行されます。IdentifierがcellSegueのときはすでに作成済みのタスクを編集するときなので配列taskArrayから該当するTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定します。
            
            //indexPathは、なんばんめのsectionで何番目のrowかを指定する、tableviewのカテゴリーがsectionでrowはカテゴリーの何番目かを指している
            let indexPath = self.tableView.indexPathForSelectedRow
            //taskArrayは全てのデータが入っている。その中のrowを取り出す。
            //レルムの中のtaskをinputViewControllerでtaskとして変数にしていてここで使っている、そしてここでrowを取り出している
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            //新規作成
            //+ボタンをタップした時はTaskクラスのインスタンスを生成して、初期値として現在時間と、プライマリキーであるIDに値を設定します。taskArray.max(ofProperty: "id")ですでに存在しているタスクのidのうち最大のものを取得し、1を足すことで他のIDと重ならない値を指定します。
            
            //taskのインスタンス作成、taskの入れ物を定義
            //右辺のTask()はTask.swiftをviewcontroller内で扱えるようにしている
            let task = Task()
            // Date()、Task()はレイムの決まりである
            task.date = Date()
            //task型の情報を一旦とってきてalltaskに格納している
            let allTasks = realm.objects(Task.self)
            //allTasksの個数を数えている、!は否定、
            if allTasks.count != 0 {
                //taskにはidが設定されていて、allTasksの一番大きいidをとってきている、ひとつ大きいidから１足して新たに作成
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            //inputViewControllerで他のことも編集できるようにする
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる。viewWillAppear:メソッドを追加し、UITableViewクラスのreloadDataメソッドを呼ぶことでタスク作成/編集画面で新規作成/編集したタスクの情報をTableViewに反映させます。
    //inputViewControllerから戻ってきて開かれた時に起動される時の処理をviewWillAppear
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //funcとは自分が作るものなのでoverrideどと違い上書きではなく、処理を少し変えるイメージ
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド。tableView(_:numberOfRowsInSection:)メソッドはデータの数を返すメソッドなのでデータの配列であるtaskArrayの要素数を返すようにします。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       //tableViewのcellの数を定義
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド。tableView(_:cellForRowAtIndexPath:)メソッドは各セルの内容を返すメソッドです。データの配列であるtaskArrayから該当するデータを取り出してセルに設定します。ここで登場するDateFormatterクラスは日付を表すDateクラスを任意の形の文字列に変換する機能を持ちます。
    
    //cellの内容の定義
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る。覚える。withIdentifierでカスタマイズ可能。これからcellを使うよ。場所
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.cellの中身の定義
        let task = taskArray[indexPath.row]
        //タイトルの変更
        cell.textLabel?.text = task.title
        //日ずけのフォーマットを指定、作成
        let formatter = DateFormatter()
        //"yyyy-MM-dd HH:mm"=年、月、日、24時間表記分
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        //dateFormatを使って、実行する
        let dateString:String = formatter.string(from: task.date)
        //フォーマットを文字列で表示
        cell.detailTextLabel?.text = dateString
        //出力
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド。ViewControllerのセルをタップした時に呼ばれるtableView(_:didSelectRowAt:)メソッドに、segueのIDを指定して遷移させるperformSegue(withIdentifier:sender)メソッドの呼び出しを追加します。これでタスク一覧画面で+ボタンをタップしたときと、セルをタップしたときにタスク作成/編集画面に遷移させることができるようになりました。
    //cellがったっぷされる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移の実行
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    //cellを左にスワイプさせ、削除を表示させる
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        //出力
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド。tableView(_:commit:forRowAt)メソッドはセルの削除を行う時に呼び出されます。ここではデータベースから該当するデータを削除する必要があります。Realmクラスのdeleteメソッドに削除したいオブジェクト（今回はTaskクラスのインスタンス）を与えることで削除することができます。また、UITableViewクラスのdeleteRows(at:with:)メソッドでセルをアニメーションさせながら削除します。
    
    //左にスワイプして削除の処理の具体的なことが記載されている
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除されたタスクを取得する
            //何行目がスワイプされたか記載されて選択されている
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            //レルム独自の書き方、147のtask
            try! realm.write {
                self.realm.delete(task)
                //taskの削除
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    //()ないはなんでもイイ
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
         }
    
       
    
    }

}
