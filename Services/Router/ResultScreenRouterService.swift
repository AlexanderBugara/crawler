import UIKit

final class ResultScreenRouterService: RoutingService {
    private weak var root: SetupRootProtocol?
    var builder: BuildingService?

    // MARK: Init

    init(root: SetupRootProtocol) {
        self.root = root
    }

    func execute() {
        guard let viewController = builder?.build() else { return }
        root?.present(viewController, animated: true, completion: nil)
    }
}
