import Observation

@MainActor @Observable
final class Router {
    var path: [Route] = []

    func push(_ route: Route) {
        path.append(route)
    }
}
