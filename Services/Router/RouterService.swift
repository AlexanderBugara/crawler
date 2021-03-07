import UIKit

protocol RoutingService {
    func execute()
}

protocol SetupRootProtocol: AnyObject {
    func show(_ vc: UIViewController, sender: Any?)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
    var viewControllers: [UIViewController] { get set }
}

final class RouterService: RoutingService {
    
    let builder: BuildingService?
    let root: SetupRootProtocol?

    // MARK: Init

    init(builder: BuildingService?, root: SetupRootProtocol?) {
        self.builder = builder
        self.root = root
    }

    func execute() {
        guard let viewController = builder?.build() else { return }
        root?.viewControllers = [viewController]
    }
}
