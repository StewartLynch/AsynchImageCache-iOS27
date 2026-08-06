import Foundation

enum DogBreed: String, CaseIterable, Identifiable {
  case airedale
  case beagle
  case cockapoo
  case bulldog
  case poodle
  
  var id: Self { self }
  
  var displayName: String {
    rawValue.capitalized
  }
  
  var imageListURL: URL {
    URL(string: "https://dog.ceo/api/breed/\(rawValue)/images")!
  }
}
