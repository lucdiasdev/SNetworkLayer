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
    
    private var selectedMethod: HTTPMethod?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var textFieldInputBaseURL: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "base URL API"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var textFieldInputEndpointURL: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "endpoint API"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var stackViewTaskConfig: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var pickerMethodTask: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
       return picker
    }()
    
    private lazy var pickerMethodTaskTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Task Method"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var stackViewHeaderParam: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var textFieldParamKey: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "header param"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var textFieldParamValue: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "key param"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var addButtonHeaderParam: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .systemBlue
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var stackViewMethodConfig: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var pickerMethodHttp: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
       return picker
    }()
    
    private lazy var pickerMethodHttpTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "HTTP Method"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var textFieldInputBodyInMethodPostSelected: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "send body request POST Method"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.isHidden = true
        return textField
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
    
    private lazy var stackViewStatusCode: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 2
        stackView.isLayoutMarginsRelativeArrangement = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleStatusCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.text = "Status Code:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
       return label
    }()
    
    private lazy var resultStatusCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.text = "Empty"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
       return label
    }()
    
    private lazy var stackViewResponse: UIStackView = {
        let stackView = UIStackView()
        stackView.layer.cornerRadius = 8
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .lightGray
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var viewResponse: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var labelResponse: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        viewModel.delegate = self
        view.backgroundColor = .white
        configureView()
        configureHttpMethodPicker()
        configureTaskMethodPicker()
        tapOutsidePicker()
    }
    
    private func addingHeaderParams() {
        viewModel.addingHeaderParams()
    }
    
    private func configureHttpMethodPicker() {
        pickerMethodHttpTextField.inputView = pickerMethodHttp
        pickerMethodHttpTextField.text = HTTPMethod.allCases.first?.rawValue
        selectedMethod = HTTPMethod.allCases.first
    }
    
    private func configureTaskMethodPicker() {
        pickerMethodTaskTextField.inputView = pickerMethodTask
        pickerMethodTaskTextField.text = viewModel.taskPickerItems.first?.label
    }
    
    private func tapOutsidePicker() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsidePicker))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textFieldInputBaseURL)
        contentView.addSubview(textFieldInputEndpointURL)
        contentView.addSubview(stackViewTaskConfig)
//        stackViewHeaderParam.addArrangedSubview(textFieldParamKey)
//        stackViewHeaderParam.addArrangedSubview(textFieldParamValue)
        stackViewTaskConfig.addArrangedSubview(pickerMethodTaskTextField)
//        stackViewTaskConfig.addArrangedSubview(stackViewHeaderParam)
//        contentView.addSubview(addButtonHeaderParam)
        contentView.addSubview(stackViewMethodConfig)
        stackViewMethodConfig.addArrangedSubview(pickerMethodHttpTextField)
        stackViewMethodConfig.addArrangedSubview(textFieldInputBodyInMethodPostSelected)
        contentView.addSubview(buttonRequest)
        contentView.addSubview(stackViewStatusCode)
        contentView.addSubview(stackViewResponse)
        stackViewStatusCode.addArrangedSubview(titleStatusCodeLabel)
        stackViewStatusCode.addArrangedSubview(resultStatusCodeLabel)
        viewResponse.addSubview(labelResponse)
        stackViewResponse.addArrangedSubview(viewResponse)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 48),
            
            textFieldInputBaseURL.topAnchor.constraint(equalTo: contentView.topAnchor),
            textFieldInputBaseURL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldInputBaseURL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldInputBaseURL.heightAnchor.constraint(equalToConstant: 48),
            
            textFieldInputEndpointURL.topAnchor.constraint(equalTo: textFieldInputBaseURL.bottomAnchor, constant: 8),
            textFieldInputEndpointURL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldInputEndpointURL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldInputEndpointURL.heightAnchor.constraint(equalToConstant: 48),
            
//            textFieldParamKey.heightAnchor.constraint(equalToConstant: 48),
//            textFieldParamValue.heightAnchor.constraint(equalToConstant: 48),
            
            stackViewTaskConfig.topAnchor.constraint(equalTo: textFieldInputEndpointURL.bottomAnchor, constant: 8),
            stackViewTaskConfig.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewTaskConfig.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pickerMethodTaskTextField.heightAnchor.constraint(equalToConstant: 48),
            
//            stackViewHeaderParam.topAnchor.constraint(equalTo: textFieldInputEndpointURL.bottomAnchor, constant: 8),
//            stackViewHeaderParam.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
//            addButtonHeaderParam.heightAnchor.constraint(equalToConstant: 32),
//            addButtonHeaderParam.widthAnchor.constraint(equalToConstant: 32),
//            addButtonHeaderParam.leadingAnchor.constraint(equalTo: stackViewTaskConfig.trailingAnchor, constant: 8),
//            addButtonHeaderParam.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            addButtonHeaderParam.centerYAnchor.constraint(equalTo: stackViewTaskConfig.centerYAnchor),
            
            stackViewMethodConfig.topAnchor.constraint(equalTo: stackViewTaskConfig.bottomAnchor, constant: 8),
            stackViewMethodConfig.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewMethodConfig.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            pickerMethodHttpTextField.heightAnchor.constraint(equalToConstant: 48),
            textFieldInputBodyInMethodPostSelected.heightAnchor.constraint(equalToConstant: 48),
            
            buttonRequest.topAnchor.constraint(equalTo: stackViewMethodConfig.bottomAnchor, constant: 16),
            buttonRequest.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonRequest.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonRequest.heightAnchor.constraint(equalToConstant: 48),
            
            stackViewStatusCode.topAnchor.constraint(equalTo: buttonRequest.bottomAnchor, constant: 16),
            stackViewStatusCode.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewStatusCode.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            stackViewResponse.topAnchor.constraint(equalTo: stackViewStatusCode.bottomAnchor, constant: 16),
            stackViewResponse.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackViewResponse.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackViewResponse.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            
            labelResponse.topAnchor.constraint(equalTo: viewResponse.topAnchor, constant: 4),
            labelResponse.leadingAnchor.constraint(equalTo: viewResponse.leadingAnchor, constant: 4),
            labelResponse.trailingAnchor.constraint(equalTo: viewResponse.trailingAnchor, constant: -4),
            labelResponse.bottomAnchor.constraint(equalTo: viewResponse.bottomAnchor, constant: -4)
        ])
    }
    
    @objc private func handleTapOutsidePicker(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func buttonRequestAction() {
        //TODO: apresentar um activity
        viewModel.fetchSNetworkLayer()
        //        stackViewResponse.isHidden = false
    }
    
}

extension ViewControllerDemo: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerMethodHttp {
            return HTTPMethod.allCases.count
        } else if pickerView == pickerMethodTask {
            return viewModel.taskPickerItems.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerMethodHttp {
            return HTTPMethod.allCases[row].rawValue
        } else if pickerView == pickerMethodTask {
            return viewModel.taskPickerItems[row].label
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerMethodHttp {
            selectedMethod = HTTPMethod.allCases[row]
            pickerMethodHttpTextField.text = selectedMethod?.rawValue
            pickerMethodHttpTextField.resignFirstResponder()
            if selectedMethod?.rawValue == "POST" {
                textFieldInputBodyInMethodPostSelected.isHidden = false
            } else {
                textFieldInputBodyInMethodPostSelected.isHidden = true
            }
        }
        
        if pickerView == pickerMethodTask {
//            selectedTask =
//            pickerMethodTaskTextField.text =
            pickerMethodTaskTextField.resignFirstResponder()
        }
    }
}

extension ViewControllerDemo: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension ViewControllerDemo: ViewModelDemoDelegate {
    func didRequestResponseSuccess(response: String, statusCode: Int) {
        DispatchQueue.main.async {
            self.stackViewResponse.isHidden = false
            self.resultStatusCodeLabel.text = "\(statusCode)"
            self.resultStatusCodeLabel.textColor = .green
            if response.isEmpty {
                self.labelResponse.text = "empty response body"
                return
            }
            self.labelResponse.text = response.replacingOccurrences(of: #"\"#, with: "")
        }
    }
    
    func didRequestResponseFailure(error: Error, statusCode: Int) {
        DispatchQueue.main.async {
            self.resultStatusCodeLabel.text = "\(statusCode)"
            self.resultStatusCodeLabel.textColor = .red
            self.labelResponse.text = error.localizedDescription
        }
    }
}
