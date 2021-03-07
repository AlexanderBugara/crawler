import UIKit

final class ResultTableViewCell: UITableViewCell, ReusableView {

    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var searchWordLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func update(item: Item) {
        if let url = item.url {
            urlLabel.text = "URL: \(url)"
        }

        if let date = item.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateInFormat = dateFormatter.string(from: date)
            dateLabel.text = "Date: \(dateInFormat)"
        }

        if let numberOccurrences = item.numberOccurrences {
            counterLabel.text = "Number of occurrences: \(numberOccurrences)"
        }

        if let searchWord = item.searchWord {
            searchWordLabel.text = "Search word: \(searchWord)"
        }
    }
}
