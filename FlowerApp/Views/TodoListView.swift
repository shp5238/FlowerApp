import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var showingNewTask = false
    @State private var editingTask: TodoItem?
    @State private var showingUndoDelete = false
    @State private var lastDeleted: TodoItem?
    @State private var draggedItem: TodoItem?
    @State private var dropTarget: TodoItem?
    @State private var showSortSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PageHeader(title: "Tasks")
            
            // Filters and Sorts
            HStack {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)
                
                Button(action: { showSortSheet.toggle() }) {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showSortSheet) {
                    VStack(spacing: 24) {
                        Text("Sort By")
                            .font(.headline)
                            .padding(.top)
                        ForEach(TaskSort.allCases) { sort in
                            Button(action: {
                                viewModel.sort = sort
                                showSortSheet = false
                            }) {
                                HStack {
                                    Text(sort.rawValue)
                                    if viewModel.sort == sort {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
                Text("\(viewModel.filteredAndSortedItems.count) tasks, \(viewModel.filteredAndSortedItems.filter { $0.isCompleted }.count) completed")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            mainContent
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingNewTask) {
            NewTaskView()
        }
        .sheet(item: $editingTask) { task in
            NewTaskView(editingTask: task)
        }
        .overlay(alignment: .bottom) {
            if showingUndoDelete, let task = lastDeleted {
                undoDeleteButton(task)
            }
        }
    }
    
    private var mainContent: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.filteredAndSortedItems.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No tasks found")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tap + to create a new task")
                .foregroundColor(.gray)
        }
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredAndSortedItems) { task in
                    taskRow(for: task)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func taskRow(for task: TodoItem) -> some View {
        TaskRow(
            task: task,
            isDropTarget: dropTarget?.id == task.id,
            isDragging: draggedItem?.id == task.id,
            onToggle: { viewModel.toggleComplete(task) },
            onEdit: { editingTask = task },
            onDelete: { handleDelete(task) }
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onDrag {
            draggedItem = task
            return NSItemProvider(object: task.id as NSString)
        }
        .onDrop(of: [.text], delegate: TaskDropDelegate(
            task: task,
            draggedItem: $draggedItem,
            dropTarget: $dropTarget,
            viewModel: viewModel
        ))
    }
    
    private func undoDeleteButton(_ task: TodoItem) -> some View {
        VStack {
            Button(action: {
                viewModel.restoreTask(task)
                showingUndoDelete = false
            }) {
                Text("Undo Delete")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom))
    }
    
    private func handleDelete(_ task: TodoItem) {
        lastDeleted = task
        viewModel.deleteTask(task)
        withAnimation {
            showingUndoDelete = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingUndoDelete = false
            }
        }
    }
}

struct TaskRow: View {
    let task: TodoItem
    let isDropTarget: Bool
    let isDragging: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.system(size: 22))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let dueDate = task.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(dueDate, style: .date)
                            .font(.caption)
                        if Calendar.current.isDateInToday(dueDate) {
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if task.isStarred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isDropTarget ? Color.blue.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isDropTarget ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct TaskDropDelegate: DropDelegate {
    let task: TodoItem
    @Binding var draggedItem: TodoItem?
    @Binding var dropTarget: TodoItem?
    let viewModel: TodoListViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = draggedItem else { return false }
        
        // Don't allow dropping a task onto itself
        if draggedItem.id == task.id {
            return false
        }
        
        if let fromIndex = viewModel.items.firstIndex(where: { $0.id == draggedItem.id }),
           let toIndex = viewModel.items.firstIndex(where: { $0.id == task.id }) {
            let indexSet = IndexSet(integer: fromIndex)
            viewModel.moveTask(from: indexSet, to: toIndex)
        }
        
        self.draggedItem = nil
        self.dropTarget = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        dropTarget = task
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        dropTarget = nil
    }
}

#Preview {
    NavigationView {
        TodoListView()
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

private let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeStyle = .short
    return df
}()

struct TaskCell: View {
    let item: TodoItem
    let highlight: Bool
    let toggle: () -> Void
    let edit: () -> Void
    let delete: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: toggle) {
                Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .strikethrough(item.isCompleted, color: .gray)
                    Button(action: { item.toggleStar?() }) {
                        Image(systemName: item.isStarred ? "star.fill" : "star")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(item.isStarred ? .yellow : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if let desc = item.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .strikethrough(item.isCompleted, color: .gray)
                }
                
                if let due = item.dueDate {
                    HStack {
                        Text("Due: \(due, formatter: dateFormatter)")
                        if due.timeIntervalSince1970.truncatingRemainder(dividingBy: 86400) != 0 {
                            Text("at \(due, formatter: timeFormatter)")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: edit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: delete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
        .background(highlight ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(10)
    }
} 
