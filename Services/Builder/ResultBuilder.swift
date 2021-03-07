import UIKit

protocol BuildingService {
    var root: SetupRootProtocol? { get set }
    func build() -> UIViewController?
}

struct ResultBuilder: BuildingService {
    var root: SetupRootProtocol?

    func build() -> UIViewController? {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))

        guard let root = root else { return nil }
        let router = ResultScreenRouterService(root: root)
        router.builder = SearchBuilder()

        let viewModel = ResultViewModel()
        viewModel.storageService = StorageService()
        viewModel.router = router
        let resultViewController = ResultViewController(viewModel: viewModel)
        return resultViewController
    }
}
