import SwiftUI

struct CustomPicker: View {
    @Binding var selectedType: ExerciseType?

    let allCases: [ExerciseType?] = [nil] + ExerciseType.allCases

    var body: some View {
        HStack(spacing: 8) {
            ForEach(allCases, id: \.self) { type in
                Button(action: {
                    selectedType = type
                }) {
                    Text(type?.rawValue ?? "Suggested")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(selectedType == type ? .white : .black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Group {
                                if selectedType == type {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.black)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
            }
        }
        .padding(6)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
