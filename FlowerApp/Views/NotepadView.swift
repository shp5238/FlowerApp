import SwiftUI

struct NotepadView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var noteText = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PageHeader(title: "Notepad")
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Notes")
                    .font(.headline)
                    .padding(.horizontal)
                TextEditor(text: $noteText)
                    .frame(minHeight: 200)
                    .padding(.horizontal)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    NotepadView()
        .environmentObject(MainViewModel())
} 
