//
//  ViewController.swift
//  LoginEmail
//
//  Created by new on 7/2/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Log In"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let emailField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Email Address"
        emailField.layer.borderWidth = 1
        emailField.autocapitalizationType = .none
        emailField.layer.borderColor = UIColor.blue.cgColor
        emailField.backgroundColor = .white
        emailField.leftViewMode = .always
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return emailField
    }()
    
    private let passwordField: UITextField = {
        let pwField = UITextField()
        pwField.placeholder = "Password"
        pwField.layer.borderWidth = 1
        pwField.isSecureTextEntry = true
        pwField.layer.borderColor = UIColor.blue.cgColor
        pwField.backgroundColor = .white
        pwField.leftViewMode = .always
        pwField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return pwField
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemMint
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Continue", for: .normal)
        return button
    }()
    
    private let forgotpwbutton: UIButton = {
       let button = UIButton()
       button.backgroundColor = .systemMint
       button.setTitleColor(.white, for: .normal)
       button.setTitle("Forgot Password", for: .normal)
       return button
   }()
    
    private let SignOutbutton: UIButton = {
       let button = UIButton()
       button.backgroundColor = .systemTeal
       button.setTitleColor(.white, for: .normal)
       button.setTitle("Sign Out", for: .normal)
       return button
   }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(button)
        view.addSubview(forgotpwbutton)
        view.backgroundColor = .systemCyan
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        forgotpwbutton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            label.isHidden = true
            button.isHidden = true
            emailField.isHidden = true
            passwordField.isHidden = true
            forgotpwbutton.isHidden = true
            
            view.addSubview(SignOutbutton)
            SignOutbutton.frame = CGRect(x: 20, y: 150, width: view.frame.size.width-40, height: 52)
            SignOutbutton.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        }
    }
    
    @objc private func logOutTapped() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            label.isHidden = false
            button.isHidden = false
            emailField.isHidden = false
            passwordField.isHidden = false
            forgotpwbutton.isHidden = false
            SignOutbutton.removeFromSuperview()
        }
        catch {
            print("An error occured")
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: 80)
        emailField.frame = CGRect(x: 20,
                                  y: label.frame.origin.y+label.frame.size.height+10,
                                  width: view.frame.size.width-40,
                                  height: 50)
        passwordField.frame = CGRect(x: 20,
                                     y:emailField.frame.origin.y+emailField.frame.size.height+10,
                                     width: view.frame.size.width-40,
                                     height: 50)
        button.frame = CGRect(x: 20,
                              y:passwordField.frame.origin.y+passwordField.frame.size.height+30,
                              width: view.frame.size.width-40,
                              height: 52)
        forgotpwbutton.frame = CGRect(x: 20,
                              y:button.frame.origin.y+button.frame.size.height+30,
                              width: view.frame.size.width-40,
                              height: 52)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FirebaseAuth.Auth.auth().currentUser == nil {
        emailField.becomeFirstResponder()
    }
    }
    
    @objc private func didTapButton() {
        print("continue button tapped")
        guard let email = emailField.text, !email.isEmpty,
        let password = passwordField.text, !password.isEmpty else {
            print("Missing field data")
            return
        }
        
        //get auth instance
        //attemp sign in
        //if failure, present alert to create account
        //if user continues, create account
        
        //check sign in on app lauch
        //allow user to sign out with button
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                //show account creation
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            print("You have signed in")
            strongSelf.label.isHidden = true
            strongSelf.emailField.isHidden = true
            strongSelf.passwordField.isHidden = true
            strongSelf.button.isHidden = true
            strongSelf.forgotpwbutton.isHidden = true
            //dismiss keyboard
            strongSelf.emailField.resignFirstResponder()
            strongSelf.passwordField.resignFirstResponder()
        })
        
    }
    
    func showCreateAccount(email: String, password: String) {
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
                guard let strongSelf = self else {
                    return
                }
                guard error == nil else {
                    print("Account creation failed")
                    return
                }
                print("You have signed in")
                strongSelf.label.isHidden = true
                strongSelf.emailField.isHidden = true
                strongSelf.passwordField.isHidden = true
                strongSelf.button.isHidden = true
                strongSelf.forgotpwbutton.isHidden = true
                strongSelf.emailField.resignFirstResponder()
                strongSelf.passwordField.resignFirstResponder()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapResetButton() {
        print("Reset button tapped")
        guard let email = emailField.text, !email.isEmpty else {
            print("Missing email data")
            return
        }
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                print("Sent")
                self.showResetpw(email: email)
            }
            else {
                print("Failed\(String(describing: error?.localizedDescription))")
               
            }
        }
    }
    func showResetpw(email: String) {
        let alert = UIAlertController(title: "Reset link sent", message: "Please check your email.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
        }))
        present(alert, animated: true)
    }
}

