import UIKit

final class NowPlayingViewController: UIViewController {
    private let vm = NowPlayingViewModel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupSortButton()
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
        title = NSLocalizedString("В кино сейчас", comment: "")
        view.backgroundColor = .darkBlue
        view.addGradientBackground()
        
        // Configure navigation bar
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.primaryText,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
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
        collectionView.register(NowPlayingCell.self, forCellWithReuseIdentifier: NowPlayingCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        refreshControl.tintColor = .primaryPurple
        
        view.addSubview(collectionView)
        collectionView.pinToSuperviewSafeArea()
    }
    
    private func setupSortButton() {
        let sortButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(showSortMenu)
        )
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // Create a more visually appealing grid layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.48), // Slightly less than 0.5 for better spacing
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Better group sizing with aspect ratio for movie posters (2:3 ratio)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(280) // Fixed height for consistency
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(12) // More space between items
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, 
            leading: 16, 
            bottom: 16, 
            trailing: 16
        )
        section.interGroupSpacing = 16 // More space between rows
        
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
                    self.showEmpty("Новинки не найдены")
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
    
    @objc private func showSortMenu() {
        let alert = UIAlertController(
            title: NSLocalizedString("Сортировать", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for option in SortOption.allCases {
            let title = option == vm.currentSortOption ? "✓ \(option.title)" : option.title
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.vm.sort(by: option)
            }
            
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: ""), style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension NowPlayingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.sortedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NowPlayingCell.reuseID, for: indexPath) as! NowPlayingCell
        
        // Защита от выхода за границы массива
        guard indexPath.item < vm.sortedItems.count else {
            print("⚠️ Index out of range: \(indexPath.item), array count: \(vm.sortedItems.count)")
            return cell
        }
        
        cell.configure(vm.sortedItems[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NowPlayingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Защита от выхода за границы массива
        guard indexPath.item < vm.sortedItems.count else {
            print("⚠️ Index out of range in didSelectItemAt: \(indexPath.item), array count: \(vm.sortedItems.count)")
            return
        }
        
        let movie = vm.sortedItems[indexPath.item]
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
