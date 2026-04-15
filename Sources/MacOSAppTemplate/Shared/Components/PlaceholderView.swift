import SwiftUI

struct PlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: "square.dashed",
            description: Text(message)
        )
    }
}
