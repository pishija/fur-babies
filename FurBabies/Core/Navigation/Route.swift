import Foundation

protocol Route: Hashable, Sendable {
    static var path: String { get }
    init?(url: URL)
}
