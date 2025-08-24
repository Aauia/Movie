import UIKit

final class NowPlayingCell: UICollectionViewCell {
    static let reuseID = "NowPlayingCell"
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingLabel = UILabel()
    private let newBadge = UILabel()
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
        // Modern card styling with glass-morphism effect
        contentView.backgroundColor = UIColor.cardBackground.withAlphaComponent(0.9)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        // Enhanced shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16
        layer.masksToBounds = false
        
        // Add subtle border
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.cardBorder.cgColor
        
        // Poster with better styling
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .cardBackground
        posterImageView.layer.cornerRadius = 16
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Enhanced gradient overlay for better text readability
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 0.6, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        // New badge
        newBadge.text = "NEW"
        newBadge.font = .systemFont(ofSize: 10, weight: .bold)
        newBadge.textColor = .primaryText
        newBadge.backgroundColor = .primaryPurple
        newBadge.textAlignment = .center
        newBadge.layer.cornerRadius = 8
        newBadge.layer.masksToBounds = true
        newBadge.translatesAutoresizingMaskIntoConstraints = false
        
        // Title with better typography
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .movieTitleText
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.layer.shadowRadius = 3
        
        // Year with better styling
        yearLabel.font = .systemFont(ofSize: 14, weight: .medium)
        yearLabel.textColor = .movieYearText
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.layer.shadowColor = UIColor.black.cgColor
        yearLabel.layer.shadowOpacity = 0.7
        yearLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        yearLabel.layer.shadowRadius = 2
        
        // Rating
        ratingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        ratingLabel.textColor = .accentText
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubviews(posterImageView, gradientView, newBadge, titleLabel, yearLabel, ratingLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            newBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            newBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            newBadge.widthAnchor.constraint(equalToConstant: 40),
            newBadge.heightAnchor.constraint(equalToConstant: 16),
            
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
        
        // Hide rating
        ratingLabel.isHidden = true
        
        // Show NEW badge for recent movies (2023-2024)
        if let year = movie.year, let yearInt = Int(year), yearInt >= 2023 {
            newBadge.isHidden = false
        } else {
            newBadge.isHidden = true
        }
        
        // Load movie poster with YouTube thumbnail fallback (same as TrendingCell)
        ImageLoader.shared.loadMoviePoster(for: movie, into: posterImageView)
    }
}
