//
//  Task.swift
//  FireBaseApp
//
//  Created by Kate on 12/11/2023.
//

import Foundation
import Firebase

struct Task {
    
    let title: String
    let userId: String
    var completed: Bool = false
    let ref: DatabaseReference! // Reference к конкретной записи в DB
    
    /// для создания объекта локально
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    /// для создания объекта из FB
    init?(snapshot: DataSnapshot) { // DataSnapshot - снимок иерархии DB
        guard let snapshotValue = snapshot.value as? [String: Any],
              let title = snapshotValue[Constants.titleKey] as? String,
              let userId = snapshotValue[Constants.userIdKey] as? String,
              let completed = snapshotValue[Constants.completedKey] as? Bool else { return nil }
        self.title = title
        self.userId = userId
        self.completed = completed
        self.ref = snapshot.ref
    }
    
    func convertToDictionary() -> [String: Any] {
        [Constants.titleKey: title, Constants.userIdKey: userId, Constants.completedKey: completed]
    }
    
    private enum Constants {
        static let titleKey = "title"
        static let userIdKey = "userId"
        static let completedKey = "completed"
    }
    
}
