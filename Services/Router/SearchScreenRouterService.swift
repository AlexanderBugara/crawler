import Foundation

final class SearchScreenRouterService: RoutingService {
    private weak var root: SetupRootProtocol?

    // MARK: Init

    init(root: SetupRootProtocol) {
        self.root = root
    }

    func execute() {
        root?.dismiss(animated: true, completion: nil)
    }
}
