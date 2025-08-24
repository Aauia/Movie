import UIKit

protocol SimilarMoviesViewDelegate: AnyObject {
    func similarMoviesView(_ view: SimilarMoviesView, didSelectMovie movie: Movie)
}

final class SimilarMoviesView: UIView {
    weak var delegate: SimilarMoviesViewDelegate?
    
    private let titleLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let debugLabel = UILabel()
    
    private var movies: [Movie] = []
    var onRetry: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        titleLabel.text = NSLocalizedString("Похожие фильмы", comment: "")
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .systemRed.withAlphaComponent(0.3)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SimilarMovieCell.self, forCellWithReuseIdentifier: SimilarMovieCell.reuseID)
        print("🔧 Registered SimilarMovieCell with reuseID: \(SimilarMovieCell.reuseID)")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.layer.borderWidth = 3
        collectionView.layer.borderColor = UIColor.red.cgColor
        collectionView.layer.cornerRadius = 8
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        emptyLabel.text = NSLocalizedString("Похожие фильмы не найдены", comment: "")
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        errorLabel.text = NSLocalizedString("Ошибка загрузки похожих фильмов", comment: "")
        errorLabel.font = .systemFont(ofSize: 16)
        errorLabel.textColor = .secondaryLabel
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        retryButton.setTitle(NSLocalizedString("Попробовать снова", comment: ""), for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        retryButton.tintColor = .systemBlue
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        debugLabel.font = .systemFont(ofSize: 12)
        debugLabel.textColor = .systemRed
        debugLabel.textAlignment = .center
        debugLabel.numberOfLines = 0
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.text = "Debug: Initial state"
        
        addSubviews(titleLabel, collectionView, loadingIndicator, emptyLabel, errorLabel, retryButton, debugLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 250),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            errorLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            errorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            retryButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            debugLabel.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 16),
            debugLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            debugLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            debugLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        print("🔧 Created collection view layout - Item: \(itemSize), Group: \(groupSize), Spacing: 16, Insets: 20")
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func configure(with state: ViewState<[Movie]>) {
        print("🔧 SimilarMoviesView.configure(with state: \(state))")
        switch state {
        case .idle:
            debugLabel.text = "Debug: Idle state"
            break
        case .loading:
            print("⏳ Showing loading state")
            debugLabel.text = "Debug: Loading similar movies..."
            loadingIndicator.startAnimating()
            emptyLabel.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
            collectionView.isHidden = false
        case .content(let movies):
            print("✅ Showing content state with \(movies.count) movies")
            debugLabel.text = "Debug: Content state with \(movies.count) movies"
            self.movies = movies
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = movies.isEmpty ? false : true
            errorLabel.isHidden = true
            retryButton.isHidden = true
            collectionView.isHidden = movies.isEmpty ? true : false
            if movies.isEmpty {
                emptyLabel.text = NSLocalizedString("Похожие фильмы не найдены", comment: "")
            }
            collectionView.reloadData()
        case .empty:
            print("ℹ️ Showing empty state")
            debugLabel.text = "Debug: Empty state - no similar movies"
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = false
            errorLabel.isHidden = true
            retryButton.isHidden = true
            collectionView.isHidden = true
        case .error(let message):
            print("❌ Showing error state: \(message)")
            debugLabel.text = "Debug: Error state - \(message)"
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            errorLabel.isHidden = false
            retryButton.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    func configure(with movies: [Movie]) {
        print("🔧 SimilarMoviesView.configure(with movies: \(movies.count))")
        debugLabel.text = "Debug: Direct configure with \(movies.count) movies"
        self.movies = movies
        loadingIndicator.stopAnimating()
        emptyLabel.isHidden = movies.isEmpty ? false : true
        errorLabel.isHidden = true
        retryButton.isHidden = true
        collectionView.isHidden = movies.isEmpty ? true : false
        if movies.isEmpty {
            emptyLabel.text = NSLocalizedString("Похожие фильмы не найдены", comment: "")
        }
        collectionView.reloadData()
    }
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}

extension SimilarMoviesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("📊 Collection view asking for number of items: \(movies.count)")
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("🔧 Configuring cell at index \(indexPath.item) with movie: \(movies[indexPath.item].title)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimilarMovieCell.reuseID, for: indexPath) as! SimilarMovieCell
        cell.configure(movies[indexPath.item])
        return cell
    }
}

extension SimilarMoviesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("👆 Similar movie selected at index \(indexPath.item): \(movies[indexPath.item].title)")
        let movie = movies[indexPath.item]
        delegate?.similarMoviesView(self, didSelectMovie: movie)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("👁️ Will display cell at index \(indexPath.item)")
    }
}

final class SimilarMovieCell: UICollectionViewCell {
    static let reuseID = "SimilarMovieCell"
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    
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
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .systemGray5
        posterImageView.layer.cornerRadius = 8
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubviews(posterImageView, titleLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 160),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(_ movie: Movie) {
        print("🔧 Configuring SimilarMovieCell with movie: \(movie.title)")
        titleLabel.text = movie.title
        
        if let posterURL = movie.poster {
            print("🖼️ Loading poster from URL: \(posterURL)")
            ImageLoader.shared.load(posterURL, into: posterImageView)
        } else {
            print("⚠️ No poster URL for movie: \(movie.title)")
            posterImageView.image = nil
        }
        
  
        contentView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        print("✅ Cell configured for movie: \(movie.title)")
    }
}
