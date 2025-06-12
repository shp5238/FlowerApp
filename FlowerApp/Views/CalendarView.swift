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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PageHeader(title: "Calendar")
            VStack(spacing: 20) {
                DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                Text("Events on \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal)
                Text("Upcoming Tasks")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                // Placeholder for events/tasks
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .overlay(
                        Text("No tasks for this date.")
                            .foregroundColor(.gray)
                    )
                    .padding(.horizontal)
            }
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    CalendarView()
}
