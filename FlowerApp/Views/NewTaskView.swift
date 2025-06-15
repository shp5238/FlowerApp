import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TodoListViewModel()
    
    private let editingTask: TodoItem?
    private let isEditing: Bool
    
    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var hasTime: Bool
    @State private var isStarred: Bool
    @State private var showDescription: Bool
    
    init(editingTask: TodoItem? = nil) {
        self.editingTask = editingTask
        self.isEditing = editingTask != nil
        
        _title = State(initialValue: editingTask?.title ?? "")
        _description = State(initialValue: editingTask?.description ?? "")
        _dueDate = State(initialValue: editingTask?.dueDate ?? Date())
        _hasDueDate = State(initialValue: editingTask?.dueDate != nil)
        _hasTime = State(initialValue: editingTask?.dueDate?.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400) != 0)
        _isStarred = State(initialValue: editingTask?.isStarred ?? false)
        _showDescription = State(initialValue: editingTask?.description != nil)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Task title", text: $title)
                }
                
                Section {
                    Toggle("Add description", isOn: $showDescription)
                    if showDescription {
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $dueDate,
                            displayedComponents: hasTime ? [.date, .hourAndMinute] : .date
                        )
                        Toggle("Set time", isOn: $hasTime)
                    }
                }
                
                Section {
                    Toggle("Star task", isOn: $isStarred)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func saveTask() {
        let finalDueDate = hasDueDate ? dueDate : nil
        let task = TodoItem(
            id: editingTask?.id ?? UUID().uuidString,
            title: title,
            description: showDescription ? description : nil,
            dueDate: finalDueDate,
            isCompleted: editingTask?.isCompleted ?? false,
            created: editingTask?.created ?? Date(),
            isStarred: isStarred,
            toggleStar: nil,
            parentId: editingTask?.parentId,
            order: editingTask?.order ?? viewModel.items.count,
            subtasks: editingTask?.subtasks ?? []
        )
        
        if isEditing {
            viewModel.updateTask(task)
        } else {
            viewModel.addTask(
                title: title,
                description: showDescription ? description : nil,
                dueDate: finalDueDate,
                isStarred: isStarred
            )
        }
    }
}

#Preview {
    NewTaskView()
} 