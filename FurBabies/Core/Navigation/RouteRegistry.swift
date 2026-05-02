import SwiftUI

protocol RouteRegistry {
    func parse(_ url: URL) -> RouteRequest?
    func destination(for route: AnyRoute) -> AnyView?
    func metadata(for route: AnyRoute) -> RouteRequirements?
}

protocol RouteRequirementsEvaluator {
    func missingRequirementsFor(_ requirements: RouteRequirements) -> RouteRequirements
}
