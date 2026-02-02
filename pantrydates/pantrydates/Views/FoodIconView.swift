// Copyright Justin Bishop, 2026

import SwiftUI

/// A view that displays a food icon from the FoodIcons asset catalog
struct FoodIconView: View {
  let name: String
  let size: CGFloat

  var body: some View {
    Image("FoodIcons/\(name)")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: size, height: size)
  }
}
