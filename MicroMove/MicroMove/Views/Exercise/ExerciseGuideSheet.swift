import SwiftUI

struct ExerciseGuideSheet: View {
    let images: [String]
    let startIndex: Int
    let embedded: Bool
    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(images: [String], startIndex: Int = 0, embedded: Bool = false) {
        self.images = images
        self.startIndex = min(max(0, startIndex), max(0, images.count - 1))
        self.embedded = embedded
        _currentIndex = State(initialValue: self.startIndex)
    }

    var body: some View {
        Group {
            if embedded {
                content
            } else {
                NavigationStack { content.toolbar { closeToolbar } }
            }
        }
    }

    private var content: some View {
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

                    guideImageView(images[currentIndex])
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
    }

    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { dismiss() }
        }
    }

    @ViewBuilder
    private func guideImageView(_ nameOrPath: String) -> some View {
        let base = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/"
        if let url = urlForImagePath(nameOrPath, base: base) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure(_):
                    placeholderImage
                case .empty:
                    Color(.systemGray5)
                @unknown default:
                    Color(.systemGray5)
                }
            }
            .cornerRadius(16)
            .shadow(radius: 8)
        } else {
            Image(nameOrPath)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(16)
                .shadow(radius: 8)
        }
    }

    private func urlForImagePath(_ path: String, base: String) -> URL? {
        if path.lowercased().hasPrefix("http://") || path.lowercased().hasPrefix("https://") {
            return URL(string: path)
        }
        guard path.contains("/") else { return nil }
        let encoded = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        return URL(string: base + encoded)
    }

    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.secondary)
            .frame(height: 200)
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(16)
    }
}
