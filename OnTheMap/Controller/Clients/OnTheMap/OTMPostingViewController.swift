//
//  OTMPostingViewController.swift
//  OnTheMap
//
//  Created by macos on 05/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import CoreLocation

class OTMPostingViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var debugLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upperTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Properties
    var geoCoder = CLGeocoder()
    var placeMark : CLPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        //configureUI()
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
    }
    
    // Remove Observers
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Add Observers
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Find Location Methods
    @IBAction func findLocationButtonPressed(_ sender: Any) {
        userDidTapView(self)
        if upperTextField.text!.isEmpty || (bottomTextField.text?.isEmpty)! {
            debugTextLabel.text = "Please fill all the fields"
        } else {
            setUIEnabled(false)
            activityIndicator.isHidden = false
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            geoCoder.geocodeAddressString(upperTextField.text!) { (result, error) in
                guard (error == nil) else {
                    self.setDebugLabel(errorString: (error?.localizedDescription)!)
                    return
                }
                if let result = result {
                    self.setDebugLabel(errorString: "")
                    let placeMark = result.first
                    self.placeMark = placeMark
                    self.performSegue(withIdentifier: "segueToPostingMap", sender: sender)
                }
            }
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToPostingMap"{
            let destination = segue.destination as? OTMPostingMapViewController
            destination?.placeMark = self.placeMark
            destination?.mediaURL = bottomTextField.text
            destination?.mapString = upperTextField.text
        }
    }
    
    // Dismiss View
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Text Field Delegate Methods
extension OTMPostingViewController {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if upperTextField.isFirstResponder{
            upperTextField.text = textField.text
        }
        if bottomTextField.isFirstResponder {
            bottomTextField.text = textField.text
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(upperTextField)
        resignIfFirstResponder(bottomTextField)
    }
    
    // MARK: - Observer Methods
    
    // Keyboard Observer Method
    @objc func keyboardWillShow(_ notification: Notification){
        if UIDevice.current.orientation == .portrait{
            guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardSize = keyboardRect.cgRectValue
            let frameOriginY = keyboardSize.height - (debugLabelHeight.constant + findLocationButton.frame.height)
            view.frame.origin.y = -frameOriginY
            debugTextLabel.isHidden = true
            
        } else {
            guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardSize = keyboardRect.cgRectValue
            let frameOriginY = keyboardSize.height - (debugLabelHeight.constant + findLocationButton.frame.height)
            view.frame.origin.y = -frameOriginY
            showUI(true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
            showUI(false)
        }
    }
}

//MARK: - UI Config Methods
private extension OTMPostingViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        upperTextField.isEnabled = enabled
        bottomTextField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
        // adjust login button alpha
        findLocationButton.alpha = enabled ? 1.0 : 0.5
    }
    
    func setDebugLabel(errorString: String){
        DispatchQueue.main.async {
            self.debugTextLabel.text = errorString
            self.setUIEnabled(true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func showUI(_ enable: Bool) {
        imageView.isHidden = enable
        titleLabel.isHidden = false
        findLocationButton.isHidden = false
        debugTextLabel.isHidden = enable
    }
    
    func configureUI() {
        setUIEnabled(true)
        activityIndicator.isHidden = true
        debugTextLabel.backgroundColor = UIColor.white
        debugTextLabel.textColor = UIColor.black
        upperTextField.placeholder = "Location"
        bottomTextField.placeholder = "Link"
        findLocationButton.layer.cornerRadius = 5
        configureTextField(upperTextField)
        configureTextField(bottomTextField)
        debugLabelHeight.constant = self.view.frame.height/6

    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.delegate = self
    }
}



