import Foundation

protocol SearchViewModelProtocol {
    var router: RoutingService? { get set }
    var storageService: StorageServiceProtocol? { get set }
    func startCrawl(crawlerItem: CrawlItem)
    func back()
}

struct CrawlItem {
    var URL: URL
    var searchText: String
    var maximumPages: UInt
}

protocol SearchViewModelDelegate: AnyObject {
    var countText: String? { get set }
    var startURLText: String? { get set }
    var currentURLText: String? { get set }
    var searchingWordText: String? { get set }
    var loadingIndicator: Bool { get set }
    func showAlert(title: String, message: String)
}

enum State {
    case started
    case finished
    case count(UInt)
    case startURL(String)
    case currentURL(String)
    case searchWord(String)
}

// MARK: SearchViewModelProtocol

final class SearchViewModel: SearchViewModelProtocol {
    var router: RoutingService?
    var crawlerService: CrawlerService?
    var storageService: StorageServiceProtocol?
    var title = Consts.searchScreenTitle
    var state: State? {
        didSet {
            switch state {
            case .count(let count): delegate?.countText = "Match count: \(count)"
            case .currentURL(let stringURL): delegate?.currentURLText = "Current URL: \(stringURL)"
            case .startURL(let startURL): delegate?.startURLText = "Start URL: \(startURL)"
            case .started: delegate?.loadingIndicator = true
            case .finished: delegate?.loadingIndicator = false
            case .searchWord(let word): delegate?.searchingWordText = "Searching: \(word)"
            case .none: break
            }
        }
    }

    weak var delegate: SearchViewModelDelegate?

    func startCrawl(crawlerItem: CrawlItem) {
        state = .started
        state = .count(0)
        state = .searchWord(crawlerItem.searchText)
        state = .currentURL(crawlerItem.URL.absoluteString)
        state = .startURL(crawlerItem.URL.absoluteString)
        crawlerService = CrawlerService(crawlerItem: crawlerItem)
        crawlerService?.delegate = self
        crawlerService?.start()
    }

    func back() {
        router?.execute()
    }
}

// MARK: CrawlerDelegate

extension SearchViewModel: CrawlerDelegate {
    func crawler(_ crawler: CrawlerService, shouldVisitUrl url: URL) -> Bool {
        true
    }

    func crawler(_ crawler: CrawlerService, willVisitUrl url: URL) {

    }

    func crawler(_ crawler: CrawlerService, didFindWordAt url: URL, count: UInt) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .count(count)
            self?.state = .currentURL(url.absoluteString)
        }
    }

    func crawlerDidFinish(_ crawler: CrawlerService) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .finished
            guard let startURL = crawler.startURL, let search = crawler.wordToSearch else {
                self?.delegate?.showAlert(title: "Error", message: "ERROR: crawler finished with empty start URL or search word")
                return
            }
            self?.storageService?.save(url: startURL, search: search, occurrences: crawler.counter)
            self?.back()
        }
    }



    func validate(httpTextField: String?, searchTextField: String?, maximumPageToVisit: String?) -> CrawlItem? {
        guard let urlString = httpTextField, let url = URL(string: urlString) else {
            delegate?.showAlert(title: "Error", message: "ERROR: Cant't constract URL")
            return nil
        }
        guard let searchText = searchTextField else {
            delegate?.showAlert(title: "Error", message: "ERROR: Search text is empty")
            return nil
        }
        guard let maximumPage = maximumPageToVisit else {
            delegate?.showAlert(title: "Error", message: "ERROR: Maximum page is empty")
            return nil
        }
        guard let maximumPageUInt = UInt(maximumPage) else {
            delegate?.showAlert(title: "Error", message: "ERROR: Cant accept maximum page")
            return nil
        }
        return CrawlItem(URL: url, searchText: searchText, maximumPages: maximumPageUInt)
    }
}
