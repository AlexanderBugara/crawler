import Foundation

protocol ResultViewModelProtocol {
    var storageService: StorageServiceProtocol? { get set }
    var router: RoutingService? { get set }
    var title: String { get set }
    func showInput()
    func update()
    var count: Int { get }
    func item(at index: Int) -> Item?
}

final class ResultViewModel {
    var router: RoutingService?
    var storageService: StorageServiceProtocol?
    private var pages: [Page]?
    var title = Consts.resultScreenTitle
}

// MARK: ResultViewModelProtocol

extension ResultViewModel: ResultViewModelProtocol {

    var count: Int { pages?.count ?? 0 }

    func item(at index: Int) -> Item? {
        guard let page = pages?[index] else { return nil }
        return Item(date: page.date, url: page.url, searchWord: page.searchtext, numberOccurrences: page.count)
    }
    
    func update() {
        pages = storageService?.pages
    }

    func showInput() {
        router?.execute()
    }
}

struct Item {
    var date: Date?
    var url: String?
    var searchWord: String?
    var numberOccurrences: Int64?
}
