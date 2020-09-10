import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet var imageView: UIImageView!

    // MARK: - Properties
    var representedAssetIdentifier: String!
    static let identifier = String(describing: PhotoCollectionViewCell.self)

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Public functions
    func flash() {
        imageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5,
                       animations: { [weak self] in
            self?.imageView.alpha = 1
        })
    }

    // MARK: - Module functions
    private func setupImageView() {
        imageView.image = nil
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
}
