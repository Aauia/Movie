import UIKit

final class TrendingCell: UICollectionViewCell {
    static let reuseID = "TrendingCell"
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingLabel = UILabel()
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        yearLabel.text = nil
        ratingLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.cardBackground.withAlphaComponent(0.9)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16
        layer.masksToBounds = false
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.cardBorder.cgColor
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .cardBackground
        posterImageView.layer.cornerRadius = 16
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .movieTitleText
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.layer.shadowRadius = 3
        
        yearLabel.font = .systemFont(ofSize: 14, weight: .medium)
        yearLabel.textColor = .movieYearText
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.layer.shadowColor = UIColor.black.cgColor
        yearLabel.layer.shadowOpacity = 0.7
        yearLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        yearLabel.layer.shadowRadius = 2
        
        ratingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingLabel.textColor = .systemYellow
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubviews(posterImageView, gradientView, titleLabel, yearLabel, ratingLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            ratingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: yearLabel.topAnchor, constant: -6),
            
            yearLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            yearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(_ movie: Movie) {
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        
        ratingLabel.isHidden = true
        
        ImageLoader.shared.loadMoviePoster(for: movie, into: posterImageView)
    }
}
