import SwiftUI

struct TodoListView: View {
    @StateObject private var viewModel = TodoListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Todo List")
                    .font(.largeTitle)
                    .padding()
                
                List {
                    ForEach(viewModel.items) { item in
                        Text(item.title)
                    }
                }
            }
            .navigationTitle("Todo List")
        }
    }
}

#Preview {
    TodoListView()
} 