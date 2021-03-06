//
//  RecordSampleApp.swift
//  RecordSample
//
//  Created by κΉνν on 2022/03/24.
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
