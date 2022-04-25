//
//  ListViewModel.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/30.
//

import Foundation
import AVFoundation
import Combine

final class ListViewModel: ObservableObject {
    @Published private(set) var list: [ListModel] = []
    
    init() {
        fetch()
    }
    
    func fetch() {
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        list = DataManager.shared.fetch().map { value -> ListModel in
            var url = directoryURL
            let title = value.file ?? ""
            url.appendPathComponent(title)
            let player = try? AVAudioPlayer(contentsOf: url)
            let duration: Double = player?.duration ?? 0
            let seconds: String = "\(Int(duration) % 60)".count == 1 ? "0\(Int(duration) % 60)" : "\(Int(duration) % 60)"
            let minutes: String = "\(Int(duration) / 60)".count == 1 ? "0\(Int(duration) / 60)" : "\(Int(duration) / 60)"
            
            return ListModel(title: title, duration: minutes+" : "+seconds)
        }.reversed()
    }
    
    func delete(object: Record) {
        guard let file = object.file, var directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        directoryURL.appendPathComponent(file)
        
        do {
            DataManager.shared.remove(object: object, type: "Record")
            try FileManager.default.removeItem(at: directoryURL)
            
            for item in list.enumerated() {
                if item.element.id == file {
                    list.remove(at: item.offset)
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
