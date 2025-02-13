//
//  TextFieldsCell.swift
//  SNetworkLayer_Example
//
//  Created by Lucas Rodrigues Dias on 10/02/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

enum TextFieldType {
    case baseURL
    case endpointURL
    case httpMethod
}

protocol TextFieldsCellDelegate: AnyObject {
    func didUpdateTextField(value: String, type: TextFieldType)
}

class TextFieldsCell: UITableViewCell {
    
    private lazy var textFieldInputBaseURL: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Input base URL API"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.text = "https://pokeapi.co/api/v2/"
        return textField
    }()
    
    private lazy var textFieldInputEndpointURL: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Input endpoint API URL"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.text = "pokemon/ditto"
        return textField
    }()
    
    private lazy var textFieldInputHttpMethod: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Input HTTP Method"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private let httpTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Use available methods 'GET' or 'POST'"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var delegate: TextFieldsCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        buildConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case textFieldInputBaseURL:
            delegate?.didUpdateTextField(value: textField.text ?? "", type: .baseURL)
        case textFieldInputEndpointURL:
            delegate?.didUpdateTextField(value: textField.text ?? "", type: .endpointURL)
        case textFieldInputHttpMethod:
            delegate?.didUpdateTextField(value: textField.text ?? "", type: .httpMethod)
        default:
            break
        }
    }
    
    private func buildConstraints() {
        contentView.addSubview(textFieldInputBaseURL)
        contentView.addSubview(textFieldInputEndpointURL)
        contentView.addSubview(textFieldInputHttpMethod)
        contentView.addSubview(httpTitleLabel)
        
        NSLayoutConstraint.activate([
            textFieldInputBaseURL.heightAnchor.constraint(equalToConstant: 48),
            textFieldInputBaseURL.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            textFieldInputBaseURL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldInputBaseURL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldInputBaseURL.bottomAnchor.constraint(equalTo: textFieldInputEndpointURL.topAnchor, constant: -16),
            
            textFieldInputEndpointURL.heightAnchor.constraint(equalToConstant: 48),
            textFieldInputEndpointURL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldInputEndpointURL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldInputEndpointURL.bottomAnchor.constraint(equalTo: textFieldInputHttpMethod.topAnchor, constant: -16),
            
            textFieldInputHttpMethod.heightAnchor.constraint(equalToConstant: 48),
            textFieldInputHttpMethod.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldInputHttpMethod.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldInputHttpMethod.bottomAnchor.constraint(equalTo: httpTitleLabel.topAnchor, constant: -2),
            
            httpTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            httpTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            httpTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
}
