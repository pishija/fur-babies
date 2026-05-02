import Foundation

struct RouteRequest {
    var push: AnyRoute?
    var presentModal: AnyRoute?
    var requirements: RouteRequirements = []
}
