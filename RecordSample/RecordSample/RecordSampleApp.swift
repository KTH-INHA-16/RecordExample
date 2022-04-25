//
//  RecordSampleApp.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import SwiftUI

@main
struct RecordSampleApp: App {
    let manager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, manager.container.viewContext)
        }
    }
}
