import UIKit

final class TrendingViewController: UIViewController {
    private let vm = TrendingViewModel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupSearchController()
        bind()
        
        Task {
            await vm.load(reset: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    private func setupUI() {
        title = NSLocalizedString("В тренде", comment: "")
        view.backgroundColor = .darkBlue
        view.addGradientBackground()
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.primaryText,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .primaryPurple
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(TrendingCell.self, forCellWithReuseIdentifier: TrendingCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        refreshControl.tintColor = .primaryPurple
        
        view.addSubview(collectionView)
        collectionView.pinToSuperviewSafeArea()
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Поиск фильмов...", comment: "")
        searchController.searchBar.tintColor = .primaryPurple
        searchController.searchBar.searchTextField.backgroundColor = .cardBackground
        searchController.searchBar.searchTextField.textColor = .primaryText
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Поиск фильмов...", comment: ""),
            attributes: [.foregroundColor: UIColor.secondaryText]
        )
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.48),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(280)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, 
            leading: 16, 
            bottom: 16, 
            trailing: 16
        )
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func bind() {
        vm.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    if self.vm.items.isEmpty {
                        self.loadingIndicator.startAnimating()
                        self.hideErrorAndEmpty()
                    }
                case .content:
                    self.loadingIndicator.stopAnimating()
                    self.hideErrorAndEmpty()
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                case .empty:
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showEmpty("Фильмы не найдены")
                case .error(let message):
                    self.loadingIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showError(message) { [weak self] in
                        Task {
                            await self?.vm.load(reset: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func onRefresh() {
        Task {
            await vm.load(reset: true)
        }
    }
}

extension TrendingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseID, for: indexPath) as! TrendingCell
        
        guard indexPath.item < vm.filteredItems.count else {
            print("⚠️ Index out of range: \(indexPath.item), array count: \(vm.filteredItems.count)")
            return cell
        }
        
        cell.configure(vm.filteredItems[indexPath.item])
        return cell
    }
}

extension TrendingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < vm.filteredItems.count else {
            print("⚠️ Index out of range in didSelectItemAt: \(indexPath.item), array count: \(vm.filteredItems.count)")
            return
        }
        
        let movie = vm.filteredItems[indexPath.item]
        let detailVC = ModernMovieDetailViewController(movieID: movie.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if vm.shouldLoadMore(for: indexPath.item) {
            Task {
                await vm.load(reset: false)
            }
        }
    }
}

extension TrendingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        vm.search(query: query)
    }
}
