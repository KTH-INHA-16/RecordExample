//
//  RecordViewModel.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import Foundation

final class RecordViewModel: ObservableObject {
    @Published private(set) var date = Date()
    @Published var text = "00 : 00 : 00"
    
    func set(date: Date) {
        self.date = date
    }
    
    func set(from date: Date) {
        let interval = Int(date.timeIntervalSince(self.date))
        let seconds = String(interval % 60).count == 1 ? "0\(String(interval % 60))" : "\(String(interval % 60))"
        let minutes = String(interval / 60).count == 1 ? "0\(String(interval / 60))" : "\(String(interval / 60))"
        let hours = String(interval / 3600).count == 1 ? "0\(String(interval / 3600))" : "\(String(interval / 3600))"
        
        text = hours + " : " + minutes + " : " + seconds
    }
}
