import UIKit
import SafariServices

final class MovieDetailViewController: UIViewController {
    private let movieID: String
    private let vm = MovieDetailViewModel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingView = UIStackView()
    private let genresLabel = UILabel()
    private let runtimeLabel = UILabel()
    private let directorLabel = UILabel()
    private let castLabel = UILabel()
    private let overviewLabel = UILabel()
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        setupScrollView()
        setupContent()
        setupLoadingIndicator()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    
    private func setupContent() {
        // Poster
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.backgroundColor = .systemGray5
        posterImageView.layer.cornerRadius = 12
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Year
        yearLabel.font = .systemFont(ofSize: 16, weight: .medium)
        yearLabel.textColor = .secondaryLabel
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating
        ratingView.axis = .horizontal
        ratingView.spacing = 4
        ratingView.alignment = .center
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Genres
        genresLabel.font = .systemFont(ofSize: 14, weight: .medium)
        genresLabel.textColor = .systemBlue
        genresLabel.numberOfLines = 0
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Runtime
        runtimeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        runtimeLabel.textColor = .secondaryLabel
        runtimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Director
        directorLabel.font = .systemFont(ofSize: 14, weight: .medium)
        directorLabel.textColor = .secondaryLabel
        directorLabel.numberOfLines = 0
        directorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Cast
        castLabel.font = .systemFont(ofSize: 14, weight: .medium)
        castLabel.textColor = .secondaryLabel
        castLabel.numberOfLines = 0
        castLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Overview
        overviewLabel.font = .systemFont(ofSize: 16)
        overviewLabel.textColor = .label
        overviewLabel.numberOfLines = 0
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Similar movies
        similarMoviesView.delegate = self
        similarMoviesView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubviews(
            posterImageView, titleLabel, yearLabel, ratingView,
            genresLabel, runtimeLabel, directorLabel, castLabel,
            overviewLabel, similarMoviesView
        )
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            yearLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ratingView.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            
            genresLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            genresLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            runtimeLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            runtimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            runtimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            directorLabel.topAnchor.constraint(equalTo: runtimeLabel.bottomAnchor, constant: 8),
            directorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            directorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            castLabel.topAnchor.constraint(equalTo: directorLabel.bottomAnchor, constant: 8),
            castLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            castLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: castLabel.bottomAnchor, constant: 20),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            similarMoviesView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            similarMoviesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            similarMoviesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            similarMoviesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
                    self.hideErrorAndEmpty()
                case .content(let movieDetail):
                    self.loadingIndicator.stopAnimating()
                    self.hideErrorAndEmpty()
                    self.configure(with: movieDetail)
                case .empty:
                    self.loadingIndicator.stopAnimating()
                    self.showEmpty("Детали фильма не найдены")
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.showError(message) { [weak self] in
                        guard let self = self else { return }
                        Task {
                            await self.vm.loadDetail(id: self.movieID)
                        }
                    }
                }
            }
        }
        
        vm.onSimilarStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.similarMoviesView.configure(with: state)
            }
        }
    }
    
    private func configure(with movieDetail: MovieDetail) {
        title = movieDetail.title
        titleLabel.text = movieDetail.title
        yearLabel.text = movieDetail.year
        
        // Rating
        setupRating(movieDetail.rating)
        
        // Genres
        if let genres = movieDetail.genres, !genres.isEmpty {
            genresLabel.text = genres.joined(separator: " • ")
        } else {
            genresLabel.text = ""
        }
        
        // Runtime
        if let runtime = movieDetail.runtime {
            runtimeLabel.text = "⏱ \(runtime)"
        } else {
            runtimeLabel.text = ""
        }
        
        // Director
        if let director = movieDetail.director {
            directorLabel.text = "Режиссёр: \(director)"
        } else {
            directorLabel.text = ""
        }
        
        // Cast
        if let cast = movieDetail.cast, !cast.isEmpty {
            let castText = cast.prefix(3).joined(separator: ", ")
            castLabel.text = "В ролях: \(castText)"
        } else {
            castLabel.text = ""
        }
        
        // Overview
        overviewLabel.text = movieDetail.overview ?? NSLocalizedString("Описание отсутствует", comment: "")
        
        // Poster
        if let posterURL = movieDetail.poster {
            ImageLoader.shared.load(posterURL, into: posterImageView)
        }
    }
    
    private func setupRating(_ rating: Double?) {
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let rating = rating else { return }
        
        let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit
        
        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", rating)
        ratingLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        ratingLabel.textColor = .label
        
        ratingView.addArrangedSubview(starImageView)
        ratingView.addArrangedSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            starImageView.widthAnchor.constraint(equalToConstant: 20),
            starImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

// MARK: - SimilarMoviesViewDelegate
extension MovieDetailViewController: SimilarMoviesViewDelegate {
    func similarMoviesView(_ view: SimilarMoviesView, didSelectMovie movie: Movie) {
        let detailVC = MovieDetailViewController(movieID: movie.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
