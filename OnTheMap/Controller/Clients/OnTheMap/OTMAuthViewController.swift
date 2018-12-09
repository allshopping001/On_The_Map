//
//  OTMAuthViewController.swift
//  OnTheMap
//
//  Created by macos on 28/09/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
// MARK: - OTMAuthViewController: UIViewController

class OTMAuthViewController: UIViewController {
    
    // Properties
    var client = OTMClient()
    var signUpURLRequest : URLRequest? = nil
  
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var debugLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
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
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    // Add Observers
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK: - Login Methods
    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        if usernameTextField.text!.isEmpty || (passwordTextField.text?.isEmpty)! {
            debugTextLabel.text = "Login or Username Empty"
        } else {
            setUIEnabled(false)
            activityIndicator.isHidden = false
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            client.taskForLoginUser(username: usernameTextField.text!, password: passwordTextField.text!) { (data, response, error) in
                guard (error == nil) else {
                    self.setDebugLabel(errorString: (error?.localizedDescription)!)
                    return
                }
                guard let statusCode = response, statusCode >= 200 && statusCode <= 299 else {
                    self.setDebugLabel(errorString: "Invalid username or password. Try again.")
                    return
                }
                self.completeLogin()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
        
    func completeLogin(){
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            self.performSegue(withIdentifier: "segueToMap", sender: self)
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        signUpURLRequest = URLRequest(url:URL(string: OTMClient.Constants.SignUpURL)!)
        performSegue(withIdentifier: "segueToWebView", sender: sender)
    }

    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToWebView"{
            guard let NVC = segue.destination as? UINavigationController, let webVC = NVC.viewControllers.first as? OTMWebViewController else {
                return
            }
            webVC.navigationTitle = "Sign Up"
            webVC.urlRequest = self.signUpURLRequest
        }
    }
}

//MARK: - Text Field Delegate Methods
extension OTMAuthViewController : UITextFieldDelegate {
    
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
        resignIfFirstResponder(textField)
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // MARK: - Observer Methods
    
    // Keyboard Observer Method
    @objc func keyboardWillShow(_ notification: Notification){
        
        if notification.name == UIResponder.keyboardWillShowNotification  {
            
            if UIDevice.current.orientation == .portrait{
                guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardSize = keyboardRect.cgRectValue
                let frameOriginY = keyboardSize.height - (debugLabelHeight.constant + loginButton.frame.height)
                view.frame.origin.y = -frameOriginY
                debugTextLabel.isHidden = true
                
            } else {
                guard let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardSize = keyboardRect.cgRectValue
                let frameOriginY = keyboardSize.height - (debugLabelHeight.constant + loginButton.frame.height)
                view.frame.origin.y = -frameOriginY
                showUI(true)
            }
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
private extension OTMAuthViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1.0 : 0.5
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
        loginButton.isHidden = false
        signUpButton.isHidden = enable
        debugTextLabel.isHidden = enable
    }
    
    func configureUI() {
        setUIEnabled(true)
        activityIndicator.isHidden = true
        debugTextLabel.backgroundColor = UIColor.white
        debugTextLabel.isHidden = false
        loginButton.layer.cornerRadius = 5
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
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

