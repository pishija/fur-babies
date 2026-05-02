import Foundation

struct AnyRoute: Hashable, Sendable, Identifiable {
    var id: Int { hashValue }

    private let base: AnyHashable

    init<R: Route>(_ route: R) {
        base = AnyHashable(route)
    }

    func unwrap<R: Route>(_ type: R.Type) -> R? {
        base.base as? R
    }

    static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs.base == rhs.base
    }

    func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}
