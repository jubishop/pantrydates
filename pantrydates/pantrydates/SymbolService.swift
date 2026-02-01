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

  private let instructions = Instructions(
    """
    Classify a food name into ONE primary-ingredient category.
    Prefer preparation cues like jerky/biltong/sausage when present.
    Ignore packaging/brand words and shape words.
    If uncertain, choose other_unknown.
    """
  )

  private let promptExamples = """
    Examples:
    - Wagyu Beef Sticks -> beef_jerky_meat_sticks_bacon
    - Biltong -> beef_jerky_meat_sticks_bacon
    - Cheddar Cheese -> cheese_yogurt
    - Chicken breast -> chicken_turkey_poultry
    """

  private let generationOptions: GenerationOptions = {
    var options = GenerationOptions()
    options.temperature = 0
    options.sampling = .greedy
    return options
  }()

  private struct KeywordRule {
    let keywords: [String]
    let symbol: FoodSymbol
  }

  private let keywordRules: [KeywordRule] = [
    KeywordRule(
      keywords: [
        "jerky", "biltong", "meat sticks", "meat stick", "beef sticks", "beef stick", "bacon",
      ],
      symbol: .beef_jerky_meat_sticks_bacon
    ),
    KeywordRule(
      keywords: ["sausage", "hot dog", "bratwurst", "brat", "kielbasa", "chorizo"],
      symbol: .sausage_hot_dog
    ),
    KeywordRule(
      keywords: ["beef", "pork", "lamb", "steak", "roast", "ribs", "burger", "hamburger"],
      symbol: .beef_pork_lamb_steak_meat
    ),
    KeywordRule(
      keywords: ["chicken", "turkey", "poultry"],
      symbol: .chicken_turkey_poultry
    ),
    KeywordRule(
      keywords: [
        "fish", "salmon", "tuna", "shrimp", "crab", "lobster", "seafood", "sardine", "anchovy",
      ],
      symbol: .fish_salmon_tuna_seafood
    ),
    KeywordRule(
      keywords: ["egg", "eggs"],
      symbol: .eggs
    ),
    KeywordRule(
      keywords: ["milk", "cream", "butter", "ghee", "half and half"],
      symbol: .milk_cream_butter
    ),
    KeywordRule(
      keywords: ["cheese", "yogurt", "yoghurt"],
      symbol: .cheese_yogurt
    ),
    KeywordRule(
      keywords: ["salad", "lettuce", "greens", "spinach", "kale"],
      symbol: .salad_lettuce_greens
    ),
    KeywordRule(
      keywords: ["carrot", "vegetable", "veggie", "vegetables", "veggies"],
      symbol: .carrot_vegetables
    ),
    KeywordRule(
      keywords: ["fruit", "apple", "orange", "banana", "pear"],
      symbol: .fruits_apples_oranges
    ),
    KeywordRule(
      keywords: ["herb", "herbs", "basil", "cilantro", "parsley", "mint", "dill"],
      symbol: .herbs_basil_cilantro
    ),
    KeywordRule(
      keywords: ["berry", "berries", "grape", "grapes", "strawberry", "blueberry", "raspberry"],
      symbol: .berries_grapes
    ),
    KeywordRule(
      keywords: ["coffee", "tea", "hot cocoa", "cocoa"],
      symbol: .coffee_tea_hot_drinks
    ),
    KeywordRule(
      keywords: [
        "wine", "beer", "vodka", "whiskey", "whisky", "gin", "rum", "tequila", "bourbon", "brandy",
        "alcohol",
      ],
      symbol: .wine_alcohol
    ),
    KeywordRule(
      keywords: ["water", "juice", "soda", "cola", "sparkling water"],
      symbol: .water_juice_soda
    ),
    KeywordRule(
      keywords: ["bread", "toast", "sandwich", "bagel", "bun"],
      symbol: .bread_toast_sandwich
    ),
    KeywordRule(
      keywords: ["rice", "grain", "grains", "cereal", "oat", "oats", "granola", "quinoa"],
      symbol: .rice_grains_cereal
    ),
    KeywordRule(
      keywords: ["pasta", "noodle", "noodles", "spaghetti", "macaroni", "ramen", "udon", "penne"],
      symbol: .pasta_noodles
    ),
    KeywordRule(
      keywords: ["cake", "pie", "dessert", "brownie", "cupcake"],
      symbol: .cake_pie_dessert
    ),
    KeywordRule(
      keywords: ["candy", "chocolate", "treat", "caramel"],
      symbol: .candy_chocolate_treats
    ),
    KeywordRule(
      keywords: ["chips", "nacho", "nachos", "tortilla", "tostada", "corn chips"],
      symbol: .chips_nachos_tortilla
    ),
    KeywordRule(
      keywords: ["cracker", "crackers", "cookie", "cookies", "biscuit"],
      symbol: .crackers_cookies
    ),
    KeywordRule(
      keywords: ["popcorn"],
      symbol: .popcorn_snacks
    ),
    KeywordRule(
      keywords: ["soup", "stew", "broth", "canned beans", "canned bean"],
      symbol: .soup_canned_beans
    ),
    KeywordRule(
      keywords: ["frozen", "ice cream", "icecream", "gelato", "sorbet"],
      symbol: .frozen_ice_cream
    ),
    KeywordRule(
      keywords: ["grilled", "bbq", "barbecue", "barbeque"],
      symbol: .grilled_bbq
    ),
    KeywordRule(
      keywords: [
        "vitamin", "vitamins", "supplement", "supplements", "multivitamin", "omega-3", "fish oil",
      ],
      symbol: .vitamins_supplements
    ),
    KeywordRule(
      keywords: [
        "sauce", "condiment", "condiments", "ketchup", "mustard", "mayo", "mayonnaise", "relish",
        "salsa", "dressing", "soy sauce", "hot sauce",
      ],
      symbol: .condiments_sauce
    ),
    KeywordRule(
      keywords: ["spice", "spices", "seasoning", "salt", "pepper", "paprika", "cumin", "curry"],
      symbol: .spices_seasoning
    ),
  ]

  private init() {}

  func suggestSymbol(for foodName: String) async -> String? {
    do {
      print("Suggesting symbol for: \(foodName)")
      if let ruleSymbol = matchKeywordRule(for: foodName) {
        print("Keyword match for \(foodName): \(ruleSymbol.rawValue)")
        return ruleSymbol.rawValue
      }
      let session = LanguageModelSession(instructions: instructions)
      let response = try await session.respond(
        to: """
          \(promptExamples)
          Food: \(foodName)
          Answer with the category only.
          """,
        generating: SymbolSuggestion.self,
        options: generationOptions
      )
      print("Suggested symbol for \(foodName): \(response.content.symbol.rawValue)")
      return response.content.symbol.rawValue
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }

  private func matchKeywordRule(for foodName: String) -> FoodSymbol? {
    let lowercased = foodName.lowercased()
    let tokens = Set(
      lowercased
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .filter { !$0.isEmpty }
    )

    for rule in keywordRules {
      for keyword in rule.keywords {
        if keyword.contains(" ") {
          if lowercased.contains(keyword) {
            return rule.symbol
          }
        } else if tokens.contains(keyword) {
          return rule.symbol
        }
      }
    }

    return nil
  }
}
