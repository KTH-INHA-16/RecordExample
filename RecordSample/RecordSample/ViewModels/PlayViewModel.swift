//
//  PlayViewModel.swift
//  RecordSample
//
//  Created by κΉνν on 2022/04/05.
//

import Foundation
import Combine

final class PlayViewModel: ObservableObject {
    @Published var fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
    }
}
