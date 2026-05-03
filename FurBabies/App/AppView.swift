import SwiftUI

struct AppView: View {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var router: AppRouter

    init() {
        let registry = AppRouteRegistry(registries: [])
        let evaluator = AppRequirementsEvaluator()
        _router = StateObject(wrappedValue: AppRouter(registry: registry, requirementsEvaluator: evaluator))
    }

    var body: some View {
        Group {
            switch viewModel.applicationState {
            case .initializing:
                SplashView()
            case .unauthenticated:
                AuthFlowView(onAuthComplete: { viewModel.markAuthenticated() })
            case .authenticated:
                NavigationStack(path: $router.path) {
                    MainTabView()
                        .navigationDestination(for: AnyRoute.self) { route in
                            router.destination(for: route) ?? AnyView(EmptyView())
                        }
                }
                .sheet(item: $router.modal) { route in
                    router.destination(for: route) ?? AnyView(EmptyView())
                }
            }
        }
        .environmentObject(router)
    }
}

#Preview {
    AppView()
}
