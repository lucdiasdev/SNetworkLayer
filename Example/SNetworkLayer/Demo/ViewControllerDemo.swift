//
//  ViewControllerDemo.swift
//  SNetworkLayer
//
//  Created by lucdiasdev on 02/10/2025.
//  Copyright (c) 2025 lucdiasdev. All rights reserved.
//

import UIKit
import SNetworkLayer

final class ViewControllerDemo: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonRequest: UIButton = {
        let button = UIButton()
        button.setTitle("Call Request", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.buttonRequestAction), for: .touchUpInside)
        return button
    }()
    
    private var viewModel: ViewModelDemo
    
    init(viewModel: ViewModelDemo) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swift Network Layer"
        configureView()
        resgisterCells()
    }
    
    func configureView() {
        view.addSubview(tableView)
        view.addSubview(buttonRequest)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            buttonRequest.heightAnchor.constraint(equalToConstant: 48),
            buttonRequest.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonRequest.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonRequest.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }
    
    func resgisterCells() {
        tableView.register(TextFieldsCell.self, forCellReuseIdentifier: String(describing: TextFieldsCell.self))
    }
    
    @objc private func buttonRequestAction() {
        viewModel.request()
    }
    
}

extension ViewControllerDemo: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.cells[indexPath.row] {
        case .textFieldInput:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextFieldsCell.self),
                                                           for: indexPath) as? TextFieldsCell else {
                return .init()
            }
            
            cell.delegate = self
            return cell
        }
    }
}

extension ViewControllerDemo: TextFieldsCellDelegate {
    func didUpdateTextField(value: String, type: TextFieldType) {
        switch type {
        case .baseURL:
            viewModel.baseURLString = value
        case .endpointURL:
            viewModel.endPointString = value
        case .httpMethod:
            viewModel.httpMethodString = .get
        }
    }
}
