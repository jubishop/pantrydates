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
  case bottleWine = "bottle-wine"
  case bowl
  case cake
  case cakeSlice = "cake-slice"
  case candy
  case carrot
  case chefHat = "chef-hat"
  case cherry
  case chocolate
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
  case energyBar = "energy-bar"
  case fish
  case glassWater = "glass-water"
  case grape
  case ham
  case hamburger
  case handPlatter = "hand-platter"
  case iceCreamBowl = "ice-cream-bowl"
  case iceCreamCone = "ice-cream-cone"
  case jar
  case leafyGreen = "leafy-green"
  case lollipop
  case martini
  case microwave
  case milk
  case nut
  case pineapple
  case pizza
  case popcorn
  case popsicle
  case refrigerator
  case salad
  case sandwich
  case shell
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
struct IconSuggestion {
  @Guide(description: "Best single icon for the food.")
  var icon: FoodIcon
}

actor SymbolService {
  static let shared = SymbolService()

  private let instructions = Instructions(
    """
    You are a food icon classifier. Pick the single best icon for the food.
    Focus on the food itself, not packaging or brand.
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
      let prompt = iconPrompt(for: foodName)
      let response = try await session.respond(
        to: prompt,
        generating: IconSuggestion.self,
        options: generationOptions
      )
      let icon = response.content.icon.rawValue
      print("Suggested icon for \(foodName): \(icon)")
      return icon
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }

  private func iconPrompt(for foodName: String) -> String {
    """
    Pick the best icon for the food item.
    Food: \(foodName)

    Glossary:
    - amphora = cheese, yogurt, fermented dairy
    - bowl = cereal, oatmeal, granola, grain bowls
    - chocolate = chocolate bars, cocoa, chocolate items
    - energy-bar = protein bars, energy bars, snack bars
    - jar = honey, jam, nut butter, preserves
    - pineapple = pineapple, tropical fruits
    - torus = bagels, donuts, ring-shaped foods
    - hand-platter = condiments, sauces, dips
    - barrel = spices, seasonings, dry powders
    - utensils = unknown or generic food
    - utensils-crossed = shared meal, general cooking
    - chef-hat = prepared dish, chef-made meal
    - cooking-pot = stew, soup, cooked dish
    - microwave = frozen or microwave meal
    - refrigerator = refrigerated or chilled item
    - cup-soda = soda, juice, soft drink
    - glass-water = water or plain beverage
    - drumstick = poultry
    - leafy-green = leafy vegetables
    - shell = shellfish

    Examples:
    Food: Greek yogurt -> icon: amphora
    Food: Everything bagel -> icon: torus
    Food: BBQ sauce -> icon: hand-platter
    Food: Taco seasoning -> icon: barrel
    Food: Cheerios -> icon: bowl
    Food: Dark chocolate -> icon: chocolate
    Food: Clif Bar -> icon: energy-bar
    Food: Strawberry jam -> icon: jar
    Food: Canned pineapple -> icon: pineapple
    """
  }
}
