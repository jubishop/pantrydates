// Copyright Justin Bishop, 2026

import Foundation
import FoundationModels

/// All available Lucide food icons from Assets.xcassets/FoodIcons
@Generable(description: "Icon that best represents a food item visually")
enum FoodIcon: String, CaseIterable {
  case amphora
  case apple
  case banana
  case barrel
  case bean
  case beef
  case beer
  case bottleWine = "bottle-wine"
  case cake
  case cakeSlice = "cake-slice"
  case candy
  case candyCane = "candy-cane"
  case carrot
  case chefHat = "chef-hat"
  case cherry
  case citrus
  case coffee
  case cookie
  case cookingPot = "cooking-pot"
  case croissant
  case cupSoda = "cup-soda"
  case dessert
  case donut
  case drumstick
  case egg
  case eggFried = "egg-fried"
  case fish
  case glassWater = "glass-water"
  case grape
  case ham
  case hamburger
  case handPlatter = "hand-platter"
  case hop
  case iceCreamBowl = "ice-cream-bowl"
  case iceCreamCone = "ice-cream-cone"
  case leafyGreen = "leafy-green"
  case lollipop
  case martini
  case microwave
  case milk
  case nut
  case pizza
  case popcorn
  case popsicle
  case refrigerator
  case salad
  case sandwich
  case shell
  case snail
  case soup
  case torus
  case utensils
  case utensilsCrossed = "utensils-crossed"
  case vegan
  case wheat
  case wine

  /// Asset catalog path for this icon
  var assetName: String {
    "FoodIcons/\(rawValue)"
  }

  /// Display name for the icon
  var displayName: String {
    rawValue
      .replacingOccurrences(of: "-", with: " ")
      .capitalized
  }
}

@Generable
struct SymbolSuggestion {
  @Guide(
    description: """
      Pick the icon that best represents this food visually.
      - beef/ham/drumstick/fish: meats and proteins
      - egg/eggFried: eggs
      - milk: dairy, cream, butter
      - amphora: cheese, yogurt, fermented dairy
      - carrot/leafyGreen/salad/vegan: vegetables
      - apple/banana/cherry/citrus/grape: fruits
      - bean/nut: legumes, nuts, seeds
      - sandwich/croissant: bread, bakery
      - wheat: grains, rice, pasta, cereal
      - coffee: coffee, tea, hot drinks
      - beer/wine/bottleWine/martini/hop: alcoholic drinks
      - cupSoda/glassWater: sodas, juice, water
      - cake/cakeSlice/dessert/donut/cookie: desserts, baked sweets
      - candy/candyCane/lollipop: candy, chocolate
      - iceCreamBowl/iceCreamCone/popsicle: frozen treats
      - pizza/hamburger: fast food
      - popcorn: snacks
      - soup/cookingPot: soups, stews, cooked dishes
      - shell/snail: shellfish, escargot
      - handPlatter: condiments, sauces
      - barrel: spices, seasonings
      - microwave/refrigerator: prepared/frozen meals
      - chefHat/utensils/utensilsCrossed: generic food, unknown
      - torus: bagels, donuts, ring-shaped foods
      """
  )
  var icon: FoodIcon
}

actor SymbolService {
  static let shared = SymbolService()

  private let instructions = Instructions(
    """
    You are a food icon classifier. Given a food name, pick the single best matching icon.
    Focus on the primary ingredient or food type, not packaging or brand names.
    When uncertain, prefer utensils as a safe default.
    """
  )

  private let generationOptions: GenerationOptions = {
    var options = GenerationOptions()
    options.temperature = 0
    options.sampling = .greedy
    return options
  }()

  private init() {}

  func suggestSymbol(for foodName: String) async -> String? {
    do {
      print("Suggesting symbol for: \(foodName)")
      let session = LanguageModelSession(instructions: instructions)
      let response = try await session.respond(
        to: "Food: \(foodName)",
        generating: SymbolSuggestion.self,
        options: generationOptions
      )
      print("Suggested icon for \(foodName): \(response.content.icon.rawValue)")
      return response.content.icon.rawValue
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }
}
