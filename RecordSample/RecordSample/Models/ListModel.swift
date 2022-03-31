//
//  ListModel.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/30.
//

import Foundation

struct ListModel: Identifiable {
    var id: String
    var title: String
    var duration: String
    
    init(title: String, duration: String) {
        id = title
        self.title = title
        self.duration = duration
    }
}
