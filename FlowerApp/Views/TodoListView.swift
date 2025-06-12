import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var newTaskTitle = ""
    @State private var showDescription = false
    @State private var newTaskDescription = ""
    @State private var newTaskDueDate: Date? = nil
    @State private var isStarred = false
    @State private var showSortSheet = false
    @State private var showUndo = false
    @State private var lastDeleted: TodoItem? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                PageHeader(title: "Todo List")
                // Add Task Card
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Task Title")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        TextField("Add a new task...", text: $newTaskTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: { isStarred.toggle() }) {
                            Image(systemName: isStarred ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(isStarred ? .yellow : .gray)
                                .padding(.leading, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    // Description
                    Toggle(isOn: $showDescription) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    if showDescription {
                        VStack(alignment: .leading, spacing: 4) {
                            TextEditor(text: $newTaskDescription)
                                .frame(minHeight: 60, maxHeight: 120)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4)))
                        }
                    }
                    // Due Date (label and picker on same line)
                    HStack {
                        Text("Due Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        DatePicker("", selection: Binding(get: {
                            newTaskDueDate ?? Date()
                        }, set: { newValue in
                            newTaskDueDate = newValue
                        }), displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "en_US"))
                        Button(action: { newTaskDueDate = nil }) {
                            if newTaskDueDate != nil {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    Button(action: {
                        guard !newTaskTitle.isEmpty else { return }
                        viewModel.addTask(title: newTaskTitle, description: showDescription ? newTaskDescription : nil, dueDate: newTaskDueDate, isStarred: isStarred)
                        newTaskTitle = ""
                        newTaskDescription = ""
                        showDescription = false
                        newTaskDueDate = nil
                        isStarred = false
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Task")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
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
                
                // Upcoming Tasks Section
                let now = Date()
                let upcomingTasks = viewModel.filteredAndSortedItems.filter { ($0.dueDate ?? .distantFuture) > now }
                let upcomingIDs = Set(upcomingTasks.map { $0.id })
                if !upcomingTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Tasks")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.leading)
                        ForEach(upcomingTasks) { item in
                            TaskCell(item: item, highlight: true, toggle: { viewModel.toggleComplete(item) }, edit: { /* TODO: Edit logic */ }, delete: { handleDelete(item) })
                                .padding(.horizontal)
                        }
                    }
                }
                // Task List (excluding upcoming)
                let mainTasks = viewModel.filteredAndSortedItems.filter { !upcomingIDs.contains($0.id) }
                if mainTasks.isEmpty {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .overlay(
                            Text("No tasks found. Create your first task above!")
                                .foregroundColor(.gray)
                        )
                        .padding(.horizontal)
                    Spacer()
                } else {
                    List {
                        ForEach(mainTasks) { item in
                            TaskCell(item: item, highlight: false, toggle: { viewModel.toggleComplete(item) }, edit: { /* TODO: Edit logic */ }, delete: { handleDelete(item) })
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet { handleDelete(mainTasks[index]) }
                        })
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(.systemBackground))
            if showUndo, let lastDeleted = lastDeleted {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.items.append(lastDeleted)
                        self.lastDeleted = nil
                        withAnimation { showUndo = false }
                    }) {
                        HStack {
                            Image(systemName: "arrow.uturn.left")
                            Text("Undo Delete")
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding(.bottom, 24)
                .padding(.trailing, 24)
                .transition(.move(edge: .trailing))
            }
        }
    }
    private func handleDelete(_ item: TodoItem) {
        lastDeleted = item
        viewModel.deleteTask(item)
        withAnimation { showUndo = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation { showUndo = false }
            self.lastDeleted = nil
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
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
                    Text("Due: \(due, formatter: dateFormatter)")
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
                Button(action: delete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(8)
        .background(highlight ? Color.blue.opacity(0.08) : Color.clear)
        .cornerRadius(10)
    }
}

#Preview {
    TodoListView()
} 