import UIKit

final class SearchViewController: UIViewController, ViewControllerModellable, SearchViewModelDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var httpTextField: UITextField!
    @IBOutlet weak var startURLLabel: UILabel!
    @IBOutlet weak var searchWordLabel: UILabel!
    @IBOutlet weak var currentURLLabel: UILabel!
    @IBOutlet weak var matchCounterLabel: UILabel!
    @IBOutlet weak var maximumPageToVisit: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var viewModel: SearchViewModel

    // MARK: SearchViewModelDelegate

    var countText: String? {
        didSet { matchCounterLabel.text = countText }
    }
    var startURLText: String? {
        didSet { startURLLabel.text = startURLText }
    }
    var currentURLText: String? {
        didSet { currentURLLabel.text = currentURLText }
    }
    var searchingWordText: String? {
        didSet { searchWordLabel.text = searchingWordText }
    }
    var loadingIndicator: Bool = false {
        didSet {
            if loadingIndicator {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }

    // MARK: Init

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life Circle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: Setup

    private func setupUI() {
        loadingIndicator = false
        let startButton = UIBarButtonItem(title: Consts.startTitleString, style: .plain, target: self, action: #selector(start(_:)))
        navigationItem.rightBarButtonItem = startButton

        let backButton = UIBarButtonItem(title: Consts.backButtonTitle, style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = viewModel.title
    }

    // MARK: Actions

    @IBAction func setupDefault(_ sender: Any) {
        httpTextField.text = Consts.defaultSearchURL
        searchTextField.text = Consts.defaultSearchWord
    }

    @objc
    func back(_ sender: Any) {
        viewModel.back()
    }

    @objc
    func start(_ sender: Any) {

        searchTextField.resignFirstResponder()
        httpTextField.resignFirstResponder()
        maximumPageToVisit.resignFirstResponder()

        guard let crawlerItem = viewModel.validate(httpTextField: httpTextField.text,
                                                   searchTextField: searchTextField.text,
                                                   maximumPageToVisit: maximumPageToVisit.text) else {
            return
        }
        viewModel.startCrawl(crawlerItem: crawlerItem)
    }

    // MARK: SearchViewModelDelegate Alert

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
