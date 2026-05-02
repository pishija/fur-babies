import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AnyRoute] = []
    @Published var modal: AnyRoute?

    let registry: any RouteRegistry
    let requirementsEvaluator: any RouteRequirementsEvaluator
    let results = RouteResultCenter()

    init(registry: any RouteRegistry, requirementsEvaluator: any RouteRequirementsEvaluator) {
        self.registry = registry
        self.requirementsEvaluator = requirementsEvaluator
    }

    func push<R: Route>(_ route: R) {
        let anyRoute = AnyRoute(route)
        var request = RouteRequest(push: anyRoute)
        request.requirements = registry.metadata(for: anyRoute) ?? []
        executeOrQueue(request)
    }

    func present<R: Route>(_ route: R) {
        let anyRoute = AnyRoute(route)
        var request = RouteRequest(presentModal: anyRoute)
        request.requirements = registry.metadata(for: anyRoute) ?? []
        executeOrQueue(request)
    }

    func presentForResult<R: Route & RequestIdentifiable, T: Sendable>(_ route: R, expecting type: T.Type) async -> T {
        present(route)
        return await results.awaitResult(for: route.requestID, as: type)
    }

    func complete<T: Sendable>(_ id: RouteRequestID, with value: T) {
        results.resume(id, with: value)
    }

    func dismissModal() {
        modal = nil
    }

    func open(_ url: URL) {
        guard let request = registry.parse(url) else { return }
        executeOrQueue(request)
    }

    func destination(for route: AnyRoute) -> AnyView? {
        registry.destination(for: route)
    }

    private func executeOrQueue(_ request: RouteRequest) {
        let missing = requirementsEvaluator.missingRequirementsFor(request.requirements)
        guard missing.isEmpty else { return }
        execute(request)
    }

    private func execute(_ request: RouteRequest) {
        if let route = request.push { path.append(route) }
        if let route = request.presentModal { modal = route }
    }
}
