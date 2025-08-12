import SwiftUI

struct ExerciseGuideSheet: View {
    let images: [String]
    let startIndex: Int
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(images: [String], startIndex: Int = 0) {
        self.images = images
        self.startIndex = min(max(0, startIndex), max(0, images.count - 1))
        _currentIndex = State(initialValue: self.startIndex)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if images.isEmpty{
                    Text("No guide available")
                        .foregroundColor(.secondary)
                }
                else {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Exercise Guide")
                            .font(.title3).bold()
                            .foregroundColor(.accentColor)

                        Image(images[currentIndex])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .onTapGesture {
                                currentIndex = (currentIndex + 1) % images.count
                            }

                        Text("Step \(currentIndex + 1) of \(images.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}