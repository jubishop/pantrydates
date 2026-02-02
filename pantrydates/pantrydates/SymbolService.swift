// Copyright Justin Bishop, 2026

import Foundation
import FoundationModels

/// All available Lucide food icons from Assets.xcassets/FoodIcons
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

@Generable(description: "Food category based on primary ingredient")
enum FoodCategory: String, CaseIterable {
  case beef_pork_lamb_steak_meat = "beef"
  case beef_jerky_meat_sticks_bacon = "ham"
  case chicken_turkey_poultry = "drumstick"
  case fish_salmon_tuna_seafood = "fish"
  case sausage_hot_dog = "hamburger"

  case eggs = "egg"
  case milk_cream_butter = "milk"
  case cheese_yogurt = "amphora"

  case carrot_vegetables = "carrot"
  case salad_lettuce_greens = "leafy-green"
  case fruits_apples_oranges = "apple"
  case herbs_basil_cilantro = "vegan"
  case berries_grapes = "grape"

  case coffee_tea_hot_drinks = "coffee"
  case wine_alcohol = "wine"
  case water_juice_soda = "cup-soda"

  case bread_toast_sandwich = "sandwich"
  case rice_grains_cereal = "wheat"
  case pasta_noodles = "utensils"

  case cake_pie_dessert = "cake"
  case candy_chocolate_treats = "candy"
  case chips_nachos_tortilla = "pizza"
  case crackers_cookies = "cookie"
  case popcorn_snacks = "popcorn"

  case soup_canned_beans = "soup"
  case frozen_ice_cream = "ice-cream-cone"
  case grilled_bbq = "cooking-pot"

  case vitamins_supplements = "nut"
  case condiments_sauce = "hand-platter"
  case spices_seasoning = "barrel"

  case other_unknown = "chef-hat"
}

@Generable
struct SymbolSuggestion {
  @Guide(description: "Match the food to its primary ingredient category")
  var category: FoodCategory
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
    let category: FoodCategory
  }

  private let keywordRules: [KeywordRule] = [
    KeywordRule(
      keywords: [
        "jerky", "biltong", "meat sticks", "meat stick", "beef sticks", "beef stick", "bacon",
      ],
      category: .beef_jerky_meat_sticks_bacon
    ),
    KeywordRule(
      keywords: ["sausage", "hot dog", "bratwurst", "brat", "kielbasa", "chorizo"],
      category: .sausage_hot_dog
    ),
    KeywordRule(
      keywords: ["beef", "pork", "lamb", "steak", "roast", "ribs", "burger", "hamburger"],
      category: .beef_pork_lamb_steak_meat
    ),
    KeywordRule(
      keywords: ["chicken", "turkey", "poultry"],
      category: .chicken_turkey_poultry
    ),
    KeywordRule(
      keywords: [
        "fish", "salmon", "tuna", "shrimp", "crab", "lobster", "seafood", "sardine", "anchovy",
      ],
      category: .fish_salmon_tuna_seafood
    ),
    KeywordRule(
      keywords: ["egg", "eggs"],
      category: .eggs
    ),
    KeywordRule(
      keywords: ["milk", "cream", "butter", "ghee", "half and half"],
      category: .milk_cream_butter
    ),
    KeywordRule(
      keywords: ["cheese", "yogurt", "yoghurt"],
      category: .cheese_yogurt
    ),
    KeywordRule(
      keywords: ["salad", "lettuce", "greens", "spinach", "kale"],
      category: .salad_lettuce_greens
    ),
    KeywordRule(
      keywords: ["carrot", "vegetable", "veggie", "vegetables", "veggies"],
      category: .carrot_vegetables
    ),
    KeywordRule(
      keywords: ["fruit", "apple", "orange", "banana", "pear"],
      category: .fruits_apples_oranges
    ),
    KeywordRule(
      keywords: ["herb", "herbs", "basil", "cilantro", "parsley", "mint", "dill"],
      category: .herbs_basil_cilantro
    ),
    KeywordRule(
      keywords: ["berry", "berries", "grape", "grapes", "strawberry", "blueberry", "raspberry"],
      category: .berries_grapes
    ),
    KeywordRule(
      keywords: ["coffee", "tea", "hot cocoa", "cocoa"],
      category: .coffee_tea_hot_drinks
    ),
    KeywordRule(
      keywords: [
        "wine", "beer", "vodka", "whiskey", "whisky", "gin", "rum", "tequila", "bourbon", "brandy",
        "alcohol",
      ],
      category: .wine_alcohol
    ),
    KeywordRule(
      keywords: ["water", "juice", "soda", "cola", "sparkling water"],
      category: .water_juice_soda
    ),
    KeywordRule(
      keywords: ["bread", "toast", "sandwich", "bagel", "bun"],
      category: .bread_toast_sandwich
    ),
    KeywordRule(
      keywords: ["rice", "grain", "grains", "cereal", "oat", "oats", "granola", "quinoa"],
      category: .rice_grains_cereal
    ),
    KeywordRule(
      keywords: ["pasta", "noodle", "noodles", "spaghetti", "macaroni", "ramen", "udon", "penne"],
      category: .pasta_noodles
    ),
    KeywordRule(
      keywords: ["cake", "pie", "dessert", "brownie", "cupcake"],
      category: .cake_pie_dessert
    ),
    KeywordRule(
      keywords: ["candy", "chocolate", "treat", "caramel"],
      category: .candy_chocolate_treats
    ),
    KeywordRule(
      keywords: ["chips", "nacho", "nachos", "tortilla", "tostada", "corn chips"],
      category: .chips_nachos_tortilla
    ),
    KeywordRule(
      keywords: ["cracker", "crackers", "cookie", "cookies", "biscuit"],
      category: .crackers_cookies
    ),
    KeywordRule(
      keywords: ["popcorn"],
      category: .popcorn_snacks
    ),
    KeywordRule(
      keywords: ["soup", "stew", "broth", "canned beans", "canned bean"],
      category: .soup_canned_beans
    ),
    KeywordRule(
      keywords: ["frozen", "ice cream", "icecream", "gelato", "sorbet"],
      category: .frozen_ice_cream
    ),
    KeywordRule(
      keywords: ["grilled", "bbq", "barbecue", "barbeque"],
      category: .grilled_bbq
    ),
    KeywordRule(
      keywords: [
        "vitamin", "vitamins", "supplement", "supplements", "multivitamin", "omega-3", "fish oil",
      ],
      category: .vitamins_supplements
    ),
    KeywordRule(
      keywords: [
        "sauce", "condiment", "condiments", "ketchup", "mustard", "mayo", "mayonnaise", "relish",
        "salsa", "dressing", "soy sauce", "hot sauce",
      ],
      category: .condiments_sauce
    ),
    KeywordRule(
      keywords: ["spice", "spices", "seasoning", "salt", "pepper", "paprika", "cumin", "curry"],
      category: .spices_seasoning
    ),
  ]

  private init() {}

  func suggestSymbol(for foodName: String) async -> String? {
    do {
      print("Suggesting symbol for: \(foodName)")
      if let ruleCategory = matchKeywordRule(for: foodName) {
        print("Keyword match for \(foodName): \(ruleCategory.rawValue)")
        return ruleCategory.rawValue
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
      print("Suggested icon for \(foodName): \(response.content.category.rawValue)")
      return response.content.category.rawValue
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }

  private func matchKeywordRule(for foodName: String) -> FoodCategory? {
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
            return rule.category
          }
        } else if tokens.contains(keyword) {
          return rule.category
        }
      }
    }

    return nil
  }
}
