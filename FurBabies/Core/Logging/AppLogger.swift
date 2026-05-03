import os

enum AppLogger {
    static let auth     = Logger(subsystem: "com.mihailstevchev.fur-babies", category: "Auth")
    static let app      = Logger(subsystem: "com.mihailstevchev.fur-babies", category: "App")
    static let dog      = Logger(subsystem: "com.mihailstevchev.fur-babies", category: "DogProfile")
}
