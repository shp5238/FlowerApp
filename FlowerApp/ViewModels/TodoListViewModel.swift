//
//  TodoListViewModel.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All Tasks"
    case pending = "Pending"
    case completed = "Completed"
    case overdue = "Overdue"
    var id: String { rawValue }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case createdAsc = "Created (Oldest First)"
    case createdDesc = "Created (Newest First)"
    case dueDateAsc = "Due Date (Earliest First)"
    case dueDateDesc = "Due Date (Latest First)"
    case none = "None"
    var id: String { rawValue }
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var filter: TaskFilter = .all
    @Published var sort: TaskSort = .createdAsc
    @Published var isLoading = true
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var filteredAndSortedItems: [TodoItem] {
        let now = Date()
        var filtered: [TodoItem]
        switch filter {
        case .all:
            filtered = items.filter { $0.parentId == nil }
        case .pending:
            filtered = items.filter { !$0.isCompleted && ($0.dueDate ?? now) >= now && $0.parentId == nil }
        case .completed:
            filtered = items.filter { $0.isCompleted && $0.parentId == nil }
        case .overdue:
            filtered = items.filter { !$0.isCompleted && ($0.dueDate ?? now) < now && $0.parentId == nil }
        }
        
        // Sort by order if no sort is selected
        if sort == .none {
            return filtered.sorted { $0.order < $1.order }
        }
        
        switch sort {
        case .createdAsc:
            return filtered.sorted { $0.created < $1.created }
        case .createdDesc:
            return filtered.sorted { $0.created > $1.created }
        case .dueDateAsc:
            return filtered.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .dueDateDesc:
            return filtered.sorted { ($0.dueDate ?? .distantFuture) > ($1.dueDate ?? .distantFuture) }
        case .none:
            return filtered
        }
    }
    
    init() {
        loadTasks()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func loadTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        listener = db.collection("users").document(userId).collection("tasks")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                    self?.isLoading = false
                    return
                }
                
                self?.items = documents.compactMap { document -> TodoItem? in
                    let data = document.data()
                    guard let title = data["title"] as? String,
                          let created = (data["created"] as? Timestamp)?.dateValue() else {
                        return nil
                    }
                    
                    var task = TodoItem(
                        id: document.documentID,
                        title: title,
                        description: data["description"] as? String,
                        dueDate: (data["dueDate"] as? Timestamp)?.dateValue(),
                        isCompleted: data["isCompleted"] as? Bool ?? false,
                        created: created,
                        isStarred: data["isStarred"] as? Bool ?? false,
                        toggleStar: nil,
                        parentId: data["parentId"] as? String,
                        order: data["order"] as? Int ?? 0,
                        subtasks: []
                    )
                    task.toggleStar = { [weak self] in self?.toggleStar(task) }
                    return task
                }
                
                // Organize subtasks
                self?.organizeSubtasks()
                self?.isLoading = false
            }
    }
    
    private func organizeSubtasks() {
        // First, collect all subtasks
        let subtasks = items.filter { $0.parentId != nil }
        
        // Remove subtasks from main list
        items.removeAll { $0.parentId != nil }
        
        // Add subtasks to their parent's subtasks array
        for subtask in subtasks {
            if let parentId = subtask.parentId,
               let parentIndex = items.firstIndex(where: { $0.id == parentId }) {
                var updatedParent = items[parentIndex]
                updatedParent.subtasks.append(subtask)
                items[parentIndex] = updatedParent
            }
        }
    }
    
    func addTask(title: String, description: String?, dueDate: Date?, isStarred: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let taskData: [String: Any] = [
            "title": title,
            "description": description as Any,
            "dueDate": dueDate as Any,
            "isCompleted": false,
            "created": Timestamp(date: Date()),
            "isStarred": isStarred
        ]
        
        db.collection("users").document(userId).collection("tasks").addDocument(data: taskData)
    }
    
    func updateTask(_ task: TodoItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let taskData: [String: Any] = [
            "title": task.title,
            "description": task.description as Any,
            "dueDate": task.dueDate as Any,
            "isCompleted": task.isCompleted,
            "created": Timestamp(date: task.created),
            "isStarred": task.isStarred
        ]
        
        db.collection("users").document(userId).collection("tasks").document(task.id).setData(taskData)
    }
    
    func toggleComplete(_ item: TodoItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("tasks").document(item.id)
            .updateData(["isCompleted": !item.isCompleted])
    }
    
    func toggleStar(_ item: TodoItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("tasks").document(item.id)
            .updateData(["isStarred": !item.isStarred])
    }
    
    func deleteTask(_ item: TodoItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("tasks").document(item.id).delete()
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    func restoreTask(_ task: TodoItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let taskData: [String: Any] = [
            "title": task.title,
            "description": task.description as Any,
            "dueDate": task.dueDate as Any,
            "isCompleted": task.isCompleted,
            "created": Timestamp(date: task.created),
            "isStarred": task.isStarred
        ]
        
        db.collection("users").document(userId).collection("tasks").document(task.id).setData(taskData)
        
        if !items.contains(where: { $0.id == task.id }) {
            items.append(task)
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first,
              sourceIndex != destination,
              sourceIndex >= 0 && sourceIndex < items.count,
              destination >= 0 && destination < items.count else {
            return
        }
        
        let task = items.remove(at: sourceIndex)
        items.insert(task, at: destination)
        
        // Update order property for all tasks
        for (index, var task) in items.enumerated() {
            task.order = index
            if let taskIndex = items.firstIndex(where: { $0.id == task.id }) {
                items[taskIndex] = task
            }
        }
        
        // Save to Firestore
        saveToFirestore()
    }
    
    func makeSubtask(parent: TodoItem, child: TodoItem) {
        guard let parentIndex = items.firstIndex(where: { $0.id == parent.id }),
              let childIndex = items.firstIndex(where: { $0.id == child.id }) else {
            return
        }
        
        var updatedChild = child
        updatedChild.parentId = parent.id
        
        // Remove child from its current position
        items.remove(at: childIndex)
        
        // Add child to parent's subtasks
        var updatedParent = parent
        updatedParent.subtasks.append(updatedChild)
        items[parentIndex] = updatedParent
        
        // Save to Firestore
        saveToFirestore()
    }
    
    func removeSubtask(_ task: TodoItem) {
        guard let parentId = task.parentId,
              let parentIndex = items.firstIndex(where: { $0.id == parentId }) else {
            return
        }
        
        var updatedParent = items[parentIndex]
        updatedParent.subtasks.removeAll { $0.id == task.id }
        items[parentIndex] = updatedParent
        
        // Add task back to main list
        var updatedTask = task
        updatedTask.parentId = nil
        items.append(updatedTask)
        
        // Save to Firestore
        saveToFirestore()
    }
    
    func getTasksForDate(_ date: Date) -> [TodoItem] {
        let calendar = Calendar.current
        return items.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }
    
    private func saveToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        // Save main tasks
        for (index, item) in items.enumerated() {
            let taskRef = db.collection("users").document(userId).collection("tasks").document(item.id)
            let taskData: [String: Any] = [
                "title": item.title,
                "description": item.description as Any,
                "dueDate": item.dueDate as Any,
                "isCompleted": item.isCompleted,
                "created": Timestamp(date: item.created),
                "isStarred": item.isStarred,
                "order": index
            ]
            batch.setData(taskData, forDocument: taskRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error saving tasks to Firestore: \(error.localizedDescription)")
            } else {
                print("Tasks saved successfully")
            }
        }
    }
}

struct TodoItem: Identifiable {
    let id: String
    var title: String
    var description: String?
    var dueDate: Date?
    var isCompleted: Bool
    let created: Date
    var isStarred: Bool
    var toggleStar: (() -> Void)?
    var parentId: String?
    var order: Int
    var subtasks: [TodoItem]
}
