import UIKit

struct SearchBuilder: BuildingService {
    var root: SetupRootProtocol?
    var resultViewModel: ResultViewModelProtocol?

    func build() -> UIViewController? {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        let viewModel = SearchViewModel()
        let searchViewController = SearchViewController(viewModel: viewModel)
        viewModel.storageService = StorageService()
        viewModel.delegate = searchViewController

        let navigationController = UINavigationController(rootViewController: searchViewController)
        navigationController.modalTransitionStyle = .flipHorizontal
        navigationController.modalPresentationStyle = .fullScreen

        viewModel.router = SearchScreenRouterService(root: navigationController)

        return navigationController
    }
}
