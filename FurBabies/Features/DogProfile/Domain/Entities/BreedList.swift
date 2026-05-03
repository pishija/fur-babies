import Foundation

enum BreedList {
    static let all: [String] = [
        "Affenpinscher", "Afghan Hound", "Airedale Terrier", "Akita",
        "Alaskan Malamute", "Australian Cattle Dog", "Australian Shepherd",
        "Basenji", "Basset Hound", "Beagle", "Bearded Collie",
        "Belgian Malinois", "Bernese Mountain Dog", "Bichon Frise",
        "Border Collie", "Border Terrier", "Boxer", "Bulldog",
        "Bull Terrier", "Cairn Terrier", "Cavalier King Charles Spaniel",
        "Chihuahua", "Chinese Shar-Pei", "Chow Chow", "Cocker Spaniel",
        "Corgi", "Dachshund", "Dalmatian", "Doberman Pinscher",
        "English Setter", "English Springer Spaniel", "French Bulldog",
        "German Shepherd", "German Shorthaired Pointer", "Golden Retriever",
        "Great Dane", "Greyhound", "Havanese", "Husky",
        "Irish Setter", "Irish Wolfhound", "Jack Russell Terrier",
        "Labrador Retriever", "Lhasa Apso", "Maltese", "Miniature Schnauzer",
        "Mixed Breed", "Newfoundland", "Norfolk Terrier", "Norwegian Elkhound",
        "Old English Sheepdog", "Papillon", "Pekingese", "Pointer",
        "Pomeranian", "Poodle", "Pug", "Rottweiler",
        "Saint Bernard", "Samoyed", "Scottish Terrier", "Shetland Sheepdog",
        "Shih Tzu", "Staffordshire Bull Terrier", "Standard Schnauzer",
        "Vizsla", "Weimaraner", "Welsh Terrier", "West Highland White Terrier",
        "Whippet", "Yorkshire Terrier"
    ]

    static func suggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return Array(all.prefix(20)) }
        let lower = query.lowercased()
        return all.filter { $0.lowercased().contains(lower) }
    }
}
