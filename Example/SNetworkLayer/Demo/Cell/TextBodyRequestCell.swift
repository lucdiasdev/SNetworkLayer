//
//  TextBodyRequestCell.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 13/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

final class TextBodyRequestCell: UITableViewCell {
    
    lazy var textBodyRequestLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var viewBodyRequest: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        buildConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func buildConstraints() {
        contentView.addSubview(viewBodyRequest)
        viewBodyRequest.addSubview(textBodyRequestLabel)
        
        NSLayoutConstraint.activate([
            viewBodyRequest.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            viewBodyRequest.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewBodyRequest.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            viewBodyRequest.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -64),
            
            textBodyRequestLabel.topAnchor.constraint(equalTo: viewBodyRequest.topAnchor, constant: 8),
            textBodyRequestLabel.leadingAnchor.constraint(equalTo: viewBodyRequest.leadingAnchor, constant: 8),
            textBodyRequestLabel.trailingAnchor.constraint(equalTo: viewBodyRequest.trailingAnchor, constant: -8),
            textBodyRequestLabel.bottomAnchor.constraint(equalTo: viewBodyRequest.bottomAnchor, constant: -8)
        ])
    }
    
}
