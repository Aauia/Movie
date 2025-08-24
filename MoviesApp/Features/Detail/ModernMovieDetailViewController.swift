

import UIKit

final class ModernMovieDetailViewController: UIViewController {
    private let movieID: String
    private let vm = MovieDetailViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Hero section
    private let heroContainerView = UIView()
    private let backgroundImageView = UIImageView()
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    // Content section
    private let posterImageView = UIImageView()
    private let rightSideContainerView = UIView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingView = UIStackView()
    private let genresStackView = UIStackView()
    private let metaInfoStackView = UIStackView()
    private let runtimeLabel = UILabel()
    private let directorLabel = UILabel()
    
    // Action buttons
    private let actionsStackView = UIStackView()
    private let playTrailerButton = UIButton(type: .system)
    private let watchlistButton = UIButton(type: .system)
    
    // Description section
    private let overviewTitleLabel = UILabel()
    private let overviewLabel = UILabel()
    private let castTitleLabel = UILabel()
    private let castLabel = UILabel()
    
    // Similar movies
    private let similarMoviesView = SimilarMoviesView()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init(movieID: String) {
        self.movieID = movieID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        
        Task {
            await vm.loadDetail(id: movieID)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = .darkBlue
        navigationItem.largeTitleDisplayMode = .never
        
    
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        setupScrollView()
        setupHeroSection()
        setupContent()
        setupActionButtons()
        setupLoadingIndicator()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeroSection() {
        // Hero container
        heroContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heroContainerView)
        
        // Background image for movie backdrop
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        heroContainerView.addSubview(backgroundImageView)
        
        // Gradient overlay
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.darkBlue.withAlphaComponent(0.8).cgColor,
            UIColor.darkBlue.cgColor
        ]
        gradientLayer.locations = [0.0, 0.7, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        heroContainerView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            heroContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroContainerView.heightAnchor.constraint(equalToConstant: 400),
            
            backgroundImageView.topAnchor.constraint(equalTo: heroContainerView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: heroContainerView.bottomAnchor),
            
            gradientView.topAnchor.constraint(equalTo: heroContainerView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: heroContainerView.bottomAnchor)
        ])
    }
    
    private func setupContent() {
    // Title
    titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
    titleLabel.textColor = .white
    titleLabel.numberOfLines = 0
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.layer.shadowColor = UIColor.black.cgColor
    titleLabel.layer.shadowOpacity = 0.8
    titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    titleLabel.layer.shadowRadius = 4
    
    // Year
    yearLabel.font = .systemFont(ofSize: 18, weight: .medium)
    yearLabel.textColor = UIColor.white.withAlphaComponent(0.9)
    yearLabel.translatesAutoresizingMaskIntoConstraints = false
    
    // Rating
    ratingView.axis = .horizontal
    ratingView.spacing = 8
    ratingView.alignment = .center
    ratingView.translatesAutoresizingMaskIntoConstraints = false
    
    // Genres
    genresStackView.axis = .horizontal
    genresStackView.spacing = 8
    genresStackView.alignment = .center
    genresStackView.translatesAutoresizingMaskIntoConstraints = false
    
    // Meta info
    metaInfoStackView.axis = .vertical
    metaInfoStackView.spacing = 8
    metaInfoStackView.alignment = .leading
    metaInfoStackView.translatesAutoresizingMaskIntoConstraints = false
    runtimeLabel.font = .systemFont(ofSize: 16, weight: .medium)
    runtimeLabel.textColor = .secondaryText
    directorLabel.font = .systemFont(ofSize: 16, weight: .medium)
    directorLabel.textColor = .secondaryText
    directorLabel.numberOfLines = 0
    
    // Overview
    overviewTitleLabel.text = "Описание"
    overviewTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    overviewTitleLabel.textColor = .primaryText
    overviewTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    overviewLabel.font = .systemFont(ofSize: 16, weight: .regular)
    overviewLabel.textColor = .primaryText
    overviewLabel.numberOfLines = 0
    overviewLabel.lineBreakMode = .byWordWrapping
    overviewLabel.translatesAutoresizingMaskIntoConstraints = false
    

    castTitleLabel.text = "В ролях"
    castTitleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    castTitleLabel.textColor = .primaryText
    castTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    castLabel.font = .systemFont(ofSize: 16, weight: .regular)
    castLabel.textColor = .secondaryText
    castLabel.numberOfLines = 0
    castLabel.translatesAutoresizingMaskIntoConstraints = false
    

    similarMoviesView.delegate = self
    similarMoviesView.translatesAutoresizingMaskIntoConstraints = false
    

    contentView.addSubviews(
        titleLabel, yearLabel, ratingView, genresStackView,
        metaInfoStackView, overviewTitleLabel, overviewLabel,
        castTitleLabel, castLabel, similarMoviesView
    )
    
    metaInfoStackView.addArrangedSubview(runtimeLabel)
    metaInfoStackView.addArrangedSubview(directorLabel)
    
    NSLayoutConstraint.activate([

        titleLabel.topAnchor.constraint(equalTo: heroContainerView.bottomAnchor, constant: 20),
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        
        yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
        yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        
        ratingView.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 16),
        ratingView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        
        genresStackView.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 16),
        genresStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        genresStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        metaInfoStackView.topAnchor.constraint(equalTo: genresStackView.bottomAnchor, constant: 24),
        metaInfoStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        metaInfoStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        overviewTitleLabel.topAnchor.constraint(equalTo: metaInfoStackView.bottomAnchor, constant: 40),
        overviewTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        overviewTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 16),
        overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        castTitleLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 40),
        castTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        castTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        castLabel.topAnchor.constraint(equalTo: castTitleLabel.bottomAnchor, constant: 16),
        castLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
        castLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        
        similarMoviesView.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 40),
        similarMoviesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        similarMoviesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        similarMoviesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
}

    
    private func setupActionButtons() {
        // Actions stack
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 16
        actionsStackView.distribution = .fillEqually
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Play trailer button
        playTrailerButton.setTitle("▶ Смотреть трейлер", for: .normal)
        playTrailerButton.setTitleColor(.white, for: .normal)
        playTrailerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        playTrailerButton.backgroundColor = .primaryPurple
        playTrailerButton.layer.cornerRadius = 25
        playTrailerButton.layer.masksToBounds = true
        playTrailerButton.addTarget(self, action: #selector(playTrailerTapped), for: .touchUpInside)
        
      
        
        actionsStackView.addArrangedSubview(playTrailerButton)
        actionsStackView.addArrangedSubview(watchlistButton)
        
        heroContainerView.addSubview(actionsStackView)
        
        NSLayoutConstraint.activate([
            actionsStackView.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor, constant: 20),
            actionsStackView.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor, constant: -20),
            actionsStackView.bottomAnchor.constraint(equalTo: heroContainerView.bottomAnchor, constant: -80),
            actionsStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .primaryPurple
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func playTrailerTapped() {
        guard let movieDetail = vm.movieDetail,
              let youtubeURL = movieDetail.youtubeVideoURL else {
         
            showNoTrailerAlert()
            return
        }
        
        // Open YouTube trailer in system browser
        if UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL, options: [:], completionHandler: nil)
        } else {
            showNoTrailerAlert()
        }
    }
    
    private func showNoTrailerAlert() {
        let alert = UIAlertController(
            title: "Трейлер недоступен",
            message: "К сожалению, для этого фильма трейлер не найден",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    private func bind() {
        vm.onDetailStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    self.loadingIndicator.startAnimating()
                case .content(let detail):
                    self.loadingIndicator.stopAnimating()
                    self.configure(with: detail)
                case .empty:
                    self.loadingIndicator.stopAnimating()
                    // Handle empty state
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.showError(message)
                }
            }
        }
        
        vm.onSimilarStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch state {
                case .content(let movies):
                    self.similarMoviesView.configure(with: movies)
                case .error(let message):
                    print("Similar movies error: \(message)")
                default:
                    break
                }
            }
        }
    }
    
    private func configure(with detail: MovieDetail) {
        titleLabel.text = detail.title
        yearLabel.text = detail.year
        overviewLabel.text = detail.overview
        
        if let runtime = detail.runtime {
            runtimeLabel.text = "⏱ \(runtime)"
        }
        if let director = detail.director {
            directorLabel.text = "🎬 Режиссёр: \(director)"
        }
        
        // ✅ Show full cast
        if let cast = detail.cast, !cast.isEmpty {
            castLabel.text = cast.joined(separator: ", ")
        } else {
            castTitleLabel.isHidden = true
            castLabel.isHidden = true
        }
        
        setupRating(detail.rating)
        setupGenres(detail.genres)
        
        // ✅ Background only (poster removed)
        if let thumbnailURL = detail.youtubeThumbnailURL {
            ImageLoader.shared.load(thumbnailURL, into: backgroundImageView)
        }
        
        playTrailerButton.isHidden = !detail.hasYouTubeTrailer
        
        if !vm.similarMovies.isEmpty {
            similarMoviesView.configure(with: vm.similarMovies)
        }
    }

    
    private func loadImages(for detail: MovieDetail) {
        // Use YouTube thumbnail for background
        if let thumbnailURL = detail.youtubeThumbnailURL {
            ImageLoader.shared.load(thumbnailURL, into: backgroundImageView)
        }
        
        // Use poster for poster view with fallback to YouTube
        if let posterURL = detail.poster {
            ImageLoader.shared.load(posterURL, into: posterImageView)
        } else if let thumbnailURL = detail.youtubeThumbnailHQURL {
            ImageLoader.shared.load(thumbnailURL, into: posterImageView)
        } else {
            // Create movie placeholder
            posterImageView.image = ImageLoader.shared.createPlaceholderImage(for: nil)
        }
    }
    
    private func setupRating(_ rating: Double?) {
        // Clear existing views
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let rating = rating else { return }
        
        // Star icon
        let starLabel = UILabel()
        starLabel.text = "⭐"
        starLabel.font = .systemFont(ofSize: 20)
        
        // Rating text
        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", rating)
        ratingLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        ratingLabel.textColor = .accentText
        
        // Add some spacing between star and rating
        let spacingView = UIView()
        spacingView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        ratingView.addArrangedSubview(starLabel)
        ratingView.addArrangedSubview(spacingView)
        ratingView.addArrangedSubview(ratingLabel)
    }
    
    private func setupGenres(_ genres: [String]?) {
        // Clear existing views
        genresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let genres = genres, !genres.isEmpty else { return }
        
        for genre in genres.prefix(3) {
            let genreLabel = UILabel()
            genreLabel.text = genre
            genreLabel.font = .systemFont(ofSize: 14, weight: .medium)
            genreLabel.textColor = .white
            genreLabel.backgroundColor = UIColor.primaryPurple.withAlphaComponent(0.8)
            genreLabel.layer.cornerRadius = 12
            genreLabel.layer.masksToBounds = true
            genreLabel.textAlignment = .center
            
            // Add padding
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
            genresStackView.addArrangedSubview(genreLabel)
            
            NSLayoutConstraint.activate([
                genreLabel.heightAnchor.constraint(equalToConstant: 28),
                genreLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
            ])
        }
        
        // Add some bottom spacing to the genres stack
        let bottomSpacing = UIView()
        bottomSpacing.heightAnchor.constraint(equalToConstant: 8).isActive = true
        genresStackView.addArrangedSubview(bottomSpacing)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SimilarMoviesViewDelegate
extension ModernMovieDetailViewController: SimilarMoviesViewDelegate {
    func similarMoviesView(_ view: SimilarMoviesView, didSelectMovie movie: Movie) {
        let detailVC = ModernMovieDetailViewController(movieID: movie.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

