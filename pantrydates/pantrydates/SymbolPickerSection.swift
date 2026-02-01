// Copyright Justin Bishop, 2026

import FoundationModels
import SwiftUI

struct SymbolPickerSection: View {
  @Binding var symbolName: String
  @Binding var userDidSelectSymbol: Bool
  let itemName: String
  let isGeneratingSymbol: Bool
  let onSuggestSymbol: () -> Void

  @State private var isExpanded = false

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

  var body: some View {
    Section {
      HStack {
        if isGeneratingSymbol {
          ProgressView()
            .frame(width: 32, height: 32)
        } else {
          Image(systemName: symbolName)
            .font(.system(size: 32))
            .foregroundStyle(.secondary)
        }

        Spacer()

        Button {
          isExpanded.toggle()
        } label: {
          Label(
            isExpanded ? "Hide Symbols" : "Choose Symbol",
            systemImage: isExpanded ? "chevron.up" : "chevron.down"
          )
        }
        .buttonStyle(.bordered)
      }

      if isExpanded {
        Button {
          onSuggestSymbol()
        } label: {
          Label("Suggest Symbol", systemImage: "sparkles")
        }
        .disabled(
          isGeneratingSymbol || itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        LazyVGrid(columns: columns, spacing: 12) {
          ForEach(FoodSymbol.allCases, id: \.self) { foodSymbol in
            let sfSymbol = foodSymbol.rawValue
            Button {
              symbolName = sfSymbol
              userDidSelectSymbol = true
              isExpanded = false
            } label: {
              Image(systemName: sfSymbol)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(
                  symbolName == sfSymbol
                    ? Color.accentColor.opacity(0.2)
                    : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .foregroundStyle(symbolName == sfSymbol ? .primary : .secondary)
          }
        }
        .padding(.vertical, 8)
      }
    } header: {
      Label("Symbol", systemImage: "photo")
    }
  }
}
