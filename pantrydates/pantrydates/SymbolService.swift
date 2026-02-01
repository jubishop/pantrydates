// Copyright Justin Bishop, 2026

import Foundation
import FoundationModels

@Generable(description: "Food category based on primary ingredient")
enum FoodSymbol: String, CaseIterable {
  case beef_pork_lamb_steak_meat = "pawprint.fill"
  case beef_jerky_meat_sticks_bacon = "rectangle.fill"
  case chicken_turkey_poultry = "bird.fill"
  case fish_salmon_tuna_seafood = "fish.fill"
  case sausage_hot_dog = "link"

  case eggs = "oval.portrait.fill"
  case milk_cream_butter = "drop.fill"
  case cheese_yogurt = "circle.fill"

  case carrot_vegetables = "carrot.fill"
  case salad_lettuce_greens = "leaf.fill"
  case fruits_apples_oranges = "tree.fill"
  case herbs_basil_cilantro = "laurel.leading"
  case berries_grapes = "camera.macro"

  case coffee_tea_hot_drinks = "mug.fill"
  case wine_alcohol = "wineglass.fill"
  case water_juice_soda = "waterbottle.fill"

  case bread_toast_sandwich = "square.stack.fill"
  case rice_grains_cereal = "circle.grid.3x3.fill"
  case pasta_noodles = "fork.knife"

  case cake_pie_dessert = "birthday.cake.fill"
  case candy_chocolate_treats = "gift.fill"
  case chips_nachos_tortilla = "triangle.fill"
  case crackers_cookies = "diamond.fill"
  case popcorn_snacks = "popcorn.fill"

  case soup_canned_beans = "cylinder.fill"
  case frozen_ice_cream = "snowflake"
  case grilled_bbq = "flame.fill"

  case vitamins_supplements = "pills.fill"
  case condiments_sauce = "leaf.circle.fill"
  case spices_seasoning = "sparkles"

  case other_unknown = "questionmark.circle.fill"
}

@Generable
struct SymbolSuggestion {
  @Guide(description: "Match the food to its primary ingredient category")
  var symbol: FoodSymbol
}

actor SymbolService {
  static let shared = SymbolService()

  private let instructions = Instructions("""
    Categorize food by PRIMARY INGREDIENT:
    - Wagyu, beef, steak, meat sticks, jerky → beef_jerky_meat_sticks_bacon or beef_pork_lamb_steak_meat
    - Chicken, turkey → chicken_turkey_poultry
    - Fish, salmon, tuna → fish_salmon_tuna_seafood
    """)

  private init() {}

  func suggestSymbol(for foodName: String) async -> String? {
    do {
      let session = LanguageModelSession(instructions: instructions)
      let response = try await session.respond(
        to: "What is the primary ingredient category for: \(foodName)",
        generating: SymbolSuggestion.self
      )
      return response.content.symbol.rawValue
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }
}
