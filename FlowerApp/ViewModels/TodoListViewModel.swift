//
//  TodoListViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    
    init() {
        // TODO: Load items from Firestore
        // For now, add some sample items
        items = [
            TodoItem(id: "1", title: "Sample Todo 1", isCompleted: false),
            TodoItem(id: "2", title: "Sample Todo 2", isCompleted: true)
        ]
    }
}

struct TodoItem: Identifiable {
    let id: String
    let title: String
    var isCompleted: Bool
}
