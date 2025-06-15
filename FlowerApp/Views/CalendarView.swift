//
//  CalendarView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @StateObject private var viewModel = TodoListViewModel()
    @State private var editingTask: TodoItem? = nil
    @State private var showingEditSheet = false
    @State private var showUndo = false
    @State private var lastDeleted: TodoItem? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PageHeader(title: "Calendar")
            VStack(spacing: 20) {
                DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Text("Tasks for \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else {
                    let tasksForDate = viewModel.getTasksForDate(selectedDate)
                    if tasksForDate.isEmpty {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .overlay(
                                Text("No tasks for this date")
                                    .foregroundColor(.gray)
                            )
                            .padding(.horizontal)
                    } else {
                        List {
                            ForEach(tasksForDate) { task in
                                TaskCell(
                                    item: task,
                                    highlight: false,
                                    toggle: { viewModel.toggleComplete(task) },
                                    edit: { handleEdit(task) },
                                    delete: { handleDelete(task) }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            Spacer()
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingEditSheet) {
            if let task = editingTask {
                NewTaskView(editingTask: task)
            }
        }
        .overlay(
            Group {
                if showUndo, let lastDeleted = lastDeleted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.restoreTask(lastDeleted)
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
                            .padding(.bottom, 24)
                            .padding(.trailing, 24)
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
            }
        )
    }
    
    private func handleEdit(_ task: TodoItem) {
        editingTask = task
        showingEditSheet = true
    }
    
    private func handleDelete(_ task: TodoItem) {
        lastDeleted = task
        viewModel.deleteTask(task)
        withAnimation { showUndo = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation { showUndo = false }
            self.lastDeleted = nil
        }
    }
}

#Preview {
    CalendarView()
}
