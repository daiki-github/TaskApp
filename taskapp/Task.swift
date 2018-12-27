//
//  Task.swift
//  
//
//  Created by 古林大輝 on 2018/11/18.
//
//レルムのモデルの定義をやっていて、これから登録していくデータの定義をしている。
import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
