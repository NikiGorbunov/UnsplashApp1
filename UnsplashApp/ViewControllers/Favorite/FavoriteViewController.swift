//
//  FavoriteViewController.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 05.09.2022.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    private var models: [PhotoCell] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isUserInteractionEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        models = Favourite.shared.favourites
        tableView.reloadData()
    }
}

extension FavoriteViewController {
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.register(FavoriteCellViewController.self, forCellReuseIdentifier: FavoriteCellViewController.identifier)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavoriteCellViewController.identifier,
            for: indexPath) as? FavoriteCellViewController else { return UITableViewCell() }
        cell.configure(with: models[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let infoVC = PhotoInfoViewController(photo: models[indexPath.row])
        let nc = UINavigationController(rootViewController: infoVC)
        nc.modalPresentationStyle = .automatic
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(nc, animated: true)
    }
}
