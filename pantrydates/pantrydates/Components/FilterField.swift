// Copyright Justin Bishop, 2026

import SwiftUI

struct FilterField: View {
  @Binding var text: String

  var body: some View {
    TextField("Filter", text: $text)
      .textFieldStyle(.roundedBorder)
      .padding(.horizontal)
      .padding(.vertical, 8)
  }
}
