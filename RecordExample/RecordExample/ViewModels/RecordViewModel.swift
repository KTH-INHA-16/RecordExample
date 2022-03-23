//
//  RecordViewModel.swift
//  RecordExample
//
//  Created by 김태훈 on 2022/03/22.
//

import Foundation

final class RecordViewModel {
    private(set) var date = Date()
    
    func set(date: Date) {
        self.date = date
    }
}
