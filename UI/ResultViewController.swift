import UIKit

protocol ViewControllerModellable: UIViewController {
    associatedtype ViewModel
    var viewModel: ViewModel { get }
    init(viewModel: ViewModel)
}

final class ResultViewController: UIViewController, ViewControllerModellable {

    @IBOutlet weak var tableView: UITableView!

    private(set) var viewModel: ResultViewModelProtocol

    // MARK: Init

    init(viewModel: ResultViewModelProtocol) {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update()
        tableView.reloadData()
    }

    // MARK: Setup

    private func setupUI() {
        let showingInputButton = UIBarButtonItem(title: Consts.inputTitleString, style: .plain, target: self, action: #selector(showInput(_:)))
        navigationItem.rightBarButtonItem = showingInputButton

        let nib = UINib(nibName: ResultTableViewCell.reusableIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ResultTableViewCell.reusableIdentifier)

        navigationItem.title = viewModel.title
    }

    // MARK: Actions

    @objc
    func showInput(_ sender: Any) {
        viewModel.showInput()
    }
}

// MARK: UITableViewDataSource

extension ResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResultTableViewCell.reusableIdentifier, for: indexPath) as? ResultTableViewCell else { fatalError("Could not create new cell") }
        if let item = viewModel.item(at: indexPath.row) {
            cell.update(item: item)
        }
        return cell
    }
}

extension ResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
