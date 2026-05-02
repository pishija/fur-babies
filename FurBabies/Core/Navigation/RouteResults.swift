import Foundation

struct RouteRequestID: Hashable, Sendable {
    let rawValue = UUID()
}

protocol RequestIdentifiable: Sendable {
    var requestID: RouteRequestID { get }
}

@MainActor
final class RouteResultCenter {
    private var continuations: [RouteRequestID: Any] = [:]

    func awaitResult<T: Sendable>(for id: RouteRequestID, as type: T.Type) async -> T {
        await withCheckedContinuation { continuation in
            continuations[id] = continuation
        }
    }

    func resume<T: Sendable>(_ id: RouteRequestID, with value: T) {
        guard let continuation = continuations.removeValue(forKey: id) as? CheckedContinuation<T, Never> else { return }
        continuation.resume(returning: value)
    }

    func cancel(_ id: RouteRequestID) {
        continuations.removeValue(forKey: id)
    }
}
