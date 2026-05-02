import Foundation

protocol RouteRequirement: Hashable {}

struct AnyRouteRequirement: Hashable, Sendable {
    private let base: AnyHashable

    init<R: RouteRequirement>(_ value: R) {
        base = AnyHashable(value)
    }

    func unwrap<R: RouteRequirement>(_ type: R.Type) -> R? {
        base.base as? R
    }

    static func == (lhs: AnyRouteRequirement, rhs: AnyRouteRequirement) -> Bool {
        lhs.base == rhs.base
    }

    func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

typealias RouteRequirements = Set<AnyRouteRequirement>

struct RequiresAuth: RouteRequirement {}
struct RequiresOnboarding: RouteRequirement {}
