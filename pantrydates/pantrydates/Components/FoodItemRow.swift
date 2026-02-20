// Copyright Justin Bishop, 2026

import SwiftUI

struct FoodItemRow: View {
  let symbolName: String
  let flagged: Bool
  let name: String
  let notes: String
  let date: Date
  let dateColor: Color
  let dateBold: Bool

  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()

  var body: some View {
    HStack {
      FoodIconView(name: symbolName, size: 24)
        .foregroundStyle(flagged ? .orange : .secondary)
      VStack(alignment: .leading, spacing: 2) {
        Text(name)
        if !notes.isEmpty {
          Text(notes)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Spacer()
      HStack(spacing: 4) {
        Image(systemName: "calendar")
          .font(.caption2)
        Text(dateFormatter.string(from: date))
          .fontWeight(dateBold ? .bold : .regular)
      }
      .foregroundStyle(dateColor)
    }
  }
}
