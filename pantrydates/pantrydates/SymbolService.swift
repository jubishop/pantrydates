// Copyright Justin Bishop, 2026

import Foundation
import FoundationModels

/// Valid SF Symbols for food items - case names describe foods, raw values are SF Symbol names
@Generable(description: "A symbol representing a food category. Choose based on the primary ingredient or food type, not packaging or preparation method.")
enum FoodSymbol: String, CaseIterable {
  // Produce
  case carrotVegetable = "carrot.fill"
  case leafyGreensSpinachLettuceSalad = "leaf.fill"
  case treeNutsFruitsAppleOrange = "tree.fill"
  case herbsCilantroBasilMintParsley = "laurel.leading"
  case berriesGrapesSmallFruit = "camera.macro"

  // Protein
  case fishSeafoodSalmonTunaSushi = "fish.fill"
  case rabbitGameMeat = "hare.fill"
  case chickenPoultryTurkeyWings = "bird.fill"
  case beefPorkLambSteakMeatWagyu = "pawprint.fill"
  case tortoiseTurtle = "tortoise.fill"
  case insectsAntsProtein = "ant.fill"
  case jerkyBeefSticksDeliMeatBaconStrips = "rectangle.fill"
  case sausageHotDogLinks = "link"

  // Eggs & Dairy
  case eggsOval = "oval.portrait.fill"
  case milkCreamLiquidsOilButter = "drop.fill"
  case cheeseYogurtDairy = "circle.fill"

  // Beverages
  case coffeeHotChocolateTea = "mug.fill"
  case teaCoffeeEspresso = "cup.and.saucer.fill"
  case wineAlcohol = "wineglass.fill"
  case waterJuiceBottledDrink = "waterbottle.fill"
  case sodaFastFoodTakeout = "takeoutbag.and.cup.and.straw.fill"
  case beerAle = "mug"

  // Baked Goods & Desserts
  case cakeDessertPiePastry = "birthday.cake.fill"
  case candyTreatsGiftsChocolate = "gift.fill"

  // Grains & Bread
  case riceGrainsCerealOats = "circle.grid.3x3.fill"
  case breadSlicesToastSandwich = "square.stack.fill"

  // Meals & Dining
  case mealDinnerLunchPreparedFood = "fork.knife"
  case trayMealPrepLeftovers = "tray.fill"
  case popcornSnacks = "popcorn.fill"

  // Containers & Storage
  case groceriesShoppingCart = "cart.fill"
  case groceryBagShopping = "bag.fill"
  case produceBasketFarmersMarket = "basket.fill"
  case packagedFoodDelivery = "shippingbox.fill"
  case pantryStorageBulk = "archivebox.fill"
  case cannedFoodSoupBeans = "cylinder.fill"

  // Cooking & Kitchen
  case grilledBBQFlameCooked = "flame.fill"
  case bakedOvenRoasted = "oven.fill"
  case microwaveFrozenMeal = "microwave.fill"
  case refrigeratedColdStorage = "refrigerator.fill"
  case timedCooking = "timer"
  case friedPanCooked = "frying.pan.fill"

  // Temperature & State
  case frozenIceCreamPopsicle = "snowflake"
  case driedDehydratedSunDried = "sun.max.fill"
  case temperatureSensitive = "thermometer.medium"

  // Health & Supplements
  case healthyHeartSmart = "heart.fill"
  case medicalDietaryRestriction = "cross.fill"
  case vitaminsSupplementsPills = "pills.fill"
  case organicNatural = "staroflife.fill"

  // Snacks & Shapes
  case tortillaChipsNachosPizzaSlice = "triangle.fill"
  case tofuChocolateBrowniesFudge = "square.fill"
  case honeycombWaffles = "hexagon.fill"
  case crackersBiscuits = "diamond.fill"
  case roundChipsCookiesBagels = "seal.fill"

  // Condiments & Seasonings
  case spicesSeasoningHerbs = "leaf.circle.fill"
  case saltSugarSeasoning = "sparkles"

  // Misc
  case specialFavorite = "star.fill"
  case energyDrinksCaffeine = "bolt.fill"
  case fermentedProbioticsKombucha = "atom"
  case otherUnknown = "questionmark.circle.fill"
}

@Generable
struct SymbolSuggestion {
  @Guide(description: "Select based on the main ingredient. For meat products like beef sticks or jerky, use meat symbols. For vegetables, use vegetable symbols.")
  var symbol: FoodSymbol
}

actor SymbolService {
  static let shared = SymbolService()

  private let instructions = Instructions("""
    You are a food categorization assistant. Given a food item name, select the most appropriate \
    symbol based on its PRIMARY INGREDIENT or food category.

    Rules:
    - Beef, wagyu, steak, jerky, meat sticks → use beef/meat symbols (beefPorkLambSteakMeatWagyu or jerkyBeefSticksDeliMeatBaconStrips)
    - Chicken, turkey, poultry → use chickenPoultryTurkeyWings
    - Fish, salmon, tuna, seafood → use fishSeafoodSalmonTunaSushi
    - Vegetables → use appropriate vegetable symbol
    - Focus on WHAT the food IS, not how it's packaged or stored
    """)

  private init() {}

  /// Suggests an SF Symbol for the given food name using Apple Intelligence
  func suggestSymbol(for foodName: String) async -> String? {
    do {
      let session = LanguageModelSession(instructions: instructions)
      let prompt = "Categorize this food item: \(foodName)"
      let response = try await session.respond(to: prompt, generating: SymbolSuggestion.self)
      return response.content.symbol.rawValue
    } catch {
      print("Failed to generate symbol: \(error)")
      return nil
    }
  }
}
