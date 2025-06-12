//
//  TodoListViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All Tasks"
    case pending = "Pending"
    case completed = "Completed"
    case overdue = "Overdue"
    var id: String { rawValue }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case created = "Created"
    case dueDate = "Due Date"
    var id: String { rawValue }
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var filter: TaskFilter = .all
    @Published var sort: TaskSort = .created
    
    var filteredAndSortedItems: [TodoItem] {
        let now = Date()
        var filtered: [TodoItem]
        switch filter {
        case .all:
            filtered = items
        case .pending:
            filtered = items.filter { !$0.isCompleted && ($0.dueDate ?? now) >= now }
        case .completed:
            filtered = items.filter { $0.isCompleted }
        case .overdue:
            filtered = items.filter { !$0.isCompleted && ($0.dueDate ?? now) < now }
        }
        switch sort {
        case .created:
            return filtered.sorted { $0.created < $1.created }
        case .dueDate:
            return filtered.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        }
    }
    
    func addTask(title: String, description: String?, dueDate: Date?, isStarred: Bool) {
        var newTask = TodoItem(id: UUID().uuidString, title: title, description: description, dueDate: dueDate, isCompleted: false, created: Date(), isStarred: isStarred)
        newTask.toggleStar = { [weak self] in self?.toggleStar(newTask) }
        items.append(newTask)
    }
    
    func toggleComplete(_ item: TodoItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isCompleted.toggle()
        }
    }
    
    func toggleStar(_ item: TodoItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].isStarred.toggle()
        }
    }
    
    func deleteTask(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
    }
    
    init() {
        // TODO: Load items from Firestore
        // For now, add some sample items
        let now = Date()
        items = [
            TodoItem(id: "1", title: "Sample Todo 1", description: "This is a sample task.", dueDate: now, isCompleted: false, created: now, isStarred: false),
            TodoItem(id: "2", title: "Sample Todo 2", description: nil, dueDate: nil, isCompleted: true, created: now, isStarred: true)
        ]
    }
}

struct TodoItem: Identifiable {
    let id: String
    let title: String
    var description: String?
    var dueDate: Date?
    var isCompleted: Bool
    let created: Date
    var isStarred: Bool
    var toggleStar: (() -> Void)?
}
