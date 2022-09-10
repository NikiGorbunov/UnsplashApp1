//
//  SearchPhotoViewController.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 05.09.2022.
//

import UIKit

class SearchPhotoViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    private var networkService = NetworkManager()
    private let columnCount = 3
    private var isLoading = false
    private var query: String = ""
    private let caretaker = PhotoCaretaker()
    private let factory = PhotoFactory()
    private var models: [PhotoCell] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addNotifications()
        setupCollectionView()
        getRandomPhotos(completion: {})
    }
    
    deinit {
        removeNotifications()
    }
}

extension SearchPhotoViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: WaterfallLayout())
        guard let collectionView = collectionView else { return }
        
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isUserInteractionEnabled = true
        collectionView.register(SearchPhotoCell.self, forCellWithReuseIdentifier: SearchPhotoCell.reuseId)
        
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        searchBar.delegate = self
        
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallLayout {
            waterfallLayout.delegate = self
        }
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWasShown(notification: Notification) {
        addTapOnView()
    }
    
    @objc private func keyboardWillBeHidden(notification: Notification) {
        view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
    }
    
    private func addTapOnView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    private func getRandomPhotos(completion: @escaping () -> Void) {
        networkService.getRandomPhotos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                print("GET RANDOM PHOTOS ERROR")
            case .success(let models):
                self.factory.buildCellsModels(from: models) { models in
                    self.models.append(contentsOf: models)
                }
            }
        }
    }
    
    private func getSearchPhotos() {
        networkService.getSearchPhotos(query: self.query) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                print("GET SEARCH PHOTOS ERROR")
            case .success(let models):
                self.factory.buildCellsModels(from: models) { models in
                    self.models = models
                }
            }
        }
    }
    
}

extension SearchPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPhotoCell.reuseId,
                                                            for: indexPath) as? SearchPhotoCell
        else { return UICollectionViewCell() }
        let url = models[indexPath.item].smallImage
        cell.configure(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let infoVC = PhotoInfoViewController(photo: models[indexPath.item])
        let nc = UINavigationController(rootViewController: infoVC)
        nc.modalPresentationStyle = .automatic
        self.present(nc, animated: true)
    }
}

extension SearchPhotoViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let photo = models[indexPath.item]
        guard let width = photo.width, let height = photo.height else { return CGSize()}
        return CGSize(width: width, height: height)
    }
}
extension SearchPhotoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        query = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchPhotos()
    }
}

extension SearchPhotoViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.last?.item else { return }
        if maxIndex > models.count - 7,
           !isLoading {
            isLoading = true
            getRandomPhotos {
                self.isLoading = false
            }
        }
    }
}
