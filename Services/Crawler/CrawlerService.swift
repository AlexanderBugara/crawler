import Foundation
import SwiftSoup

protocol CrawlerDelegate: AnyObject {

  /// Called before the crawler visits a webpage.
  ///
  /// A skipped webpage is not considered among the visited pages.
  func crawler(_ crawler: CrawlerService, shouldVisitUrl url: URL) -> Bool

  /// Called whenever the crawler is about to visit a new webpage.
  func crawler(_ crawler: CrawlerService, willVisitUrl url: URL)

  /// Called whenever the crawler finds the searched word in a webpage.
  ///
  /// - Note: This call is fired only (up to) one time per webpage, regardless
  ///   of how many times the word is found in that webpage.
    func crawler(_ crawler: CrawlerService, didFindWordAt url: URL, count: UInt)

  /// Called once the crawler ends its execution.
  func crawlerDidFinish(_ crawler: CrawlerService)
}


protocol CrawlerServiceProtocol {
    func start()
    func update(crawlerItem: CrawlItem)
}

final class CrawlerService: CrawlerServiceProtocol {

    /// The starting page URL.
    var startURL: URL?

    /// The maximum number of pages that the instance will visit.
    ///
    /// - Note: If not enough links are found, the crawler will stop its execution
    ///   prematurely.
    var maximumPagesToVisit: UInt?

    /// The word the crawler is looking for.
    var wordToSearch: String?

    /// The urls of pages the instance has visited already.
    var visitedPages: Set<URL> = []

    /// The urls of pages found during crawling, but yet to visit.
    var pagesToVisit: Set<URL>?

    /// The object that acts as the delegate of the crawler.
    weak var delegate: CrawlerDelegate?

    /// The current `URLSessionDataTask`, if any.
    var currentTask: URLSessionDataTask?

    var counter: UInt = 0

    // MARK: init

    init(crawlerItem: CrawlItem) {
        update(crawlerItem: crawlerItem)
    }

    func update(crawlerItem: CrawlItem) {
        self.startURL = crawlerItem.URL
        self.maximumPagesToVisit = crawlerItem.maximumPages
        self.wordToSearch = crawlerItem.searchText
        self.pagesToVisit = [crawlerItem.URL]
    }

    // MARK: Actions

    func start() {
        counter = 0
        crawl()
    }

    /// Immediately ends the crawling process.
    public func cancel() {
        currentTask?.cancel()
        delegate?.crawlerDidFinish(self)
    }

    /// Starts a new crawling cycle.
    private func crawl() {
        guard
            let maximumPagesToVisit = maximumPagesToVisit,
            visitedPages.count < maximumPagesToVisit,
            let pageToVisit = pagesToVisit?.popFirst() else {
            
            delegate?.crawlerDidFinish(self)
            return
        }

        if visitedPages.contains(pageToVisit) {
            crawl()
        } else {
            if delegate?.crawler(self, shouldVisitUrl: pageToVisit) == true {
                visit(page: pageToVisit)
            } else {
                crawl()
            }
        }
    }

    /// Tells the crawler to visit the given `url` page.
    ///
    /// - Parameter url: The page we want to visit.
    func visit(page url: URL) {

        print(">>> url: \(url.absoluteString)")
        visitedPages.insert(url)

        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            defer {
                self?.crawl()
            }
            guard
                let data = data,
                let webpage = String(data: data, encoding: .utf8) else { return }
            self?.parse(webpage, url: url)
        }

        delegate?.crawler(self, willVisitUrl: url)
        currentTask?.resume()
    }

    /// Parses the given document.
    ///
    /// - Parameters:
    ///   - webpage: The content to parse.
    ///   - url: The url associated with the document.
    func parse(_ webpage: String, url: URL) {
        let document: Document? = try? SwiftSoup.parse(webpage, url.absoluteString)

        // Find word in webpage.
        if
            let wordToSearch = wordToSearch,
            let webpageText: String = try? document?.text() {

            let count = webpageText.count(occurrencesOf: wordToSearch, options: .caseInsensitive)
            if count > 0 {
                counter += UInt(count)
                delegate?.crawler(self, didFindWordAt: url, count: UInt(counter))
            }
        }

        // Collect links.
        let anchors: [Element] = (try? document?.select("a").array()) ?? []
        let links: [URL] = anchors.compactMap({ try? $0.absUrl("href") }).compactMap(URL.init(string:))
        pagesToVisit?.formUnion(links)
    }
}
