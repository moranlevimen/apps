//
//  RegisterController.swift
//  RestAndEat
//
//  Created by moran levi on 19.3.2017.
//  Copyright © 2017 I. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class RegisterController: UIViewController {
    
    @IBOutlet var uEmail: UITextField!;
    @IBOutlet var uPass: UITextField!;
    @IBOutlet var uName: UITextField!;
    @IBOutlet var rePass: UITextField!;
    var firRef: FIRDatabaseReference!;
    
    //
    override func viewDidLoad() {
        firRef = FIRDatabase.database().reference();
    }
    //
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false;
    }
    //
    @IBAction func doneBtn(_ sender: UIButton) {
        if checkFields() {
            FIRAuth.auth()?.createUser(withEmail: uEmail.text!, password: uPass.text!) { (user, error) in
                if error == nil {           //if no errors
                    user?.sendEmailVerification(completion: nil);
                    print("**You have successfully signed up");
                    self.firRef.child("users").child(user!.uid).setValue(["username": self.uName.text!]);   //add user name to database
                    let nextScreen = self.storyboard!.instantiateViewController(withIdentifier: "main") as! ViewController;     //go to main
                    nextScreen.logIn(self.uEmail.text!, self.uPass.text!);  //login
                    self.show(nextScreen, sender: self);
                } else{
                    //print error
                    print("**\(error)");
                }
            }
        }else{
            print("**cant send");
        }
    }
    //
    // validation and fields colors
    private func checkFields()->Bool{
        let email = uEmail.text!;
        let pass = uPass.text!;
        let rPass = rePass.text!;
        let fields = [uName,uEmail,uPass,rePass];
        var good = true;
        
        for f in fields {
            if f!.text! == ""{      //if empty color red
                red(f!);
                good = false;
            }
        }
        if !isValidEmail(testStr: email) {
            red(uEmail);
            good = false;
        }
        if pass != rPass {
            red(rePass);
            good = false;
        }
        return good;
    }
    //
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx);
        return emailTest.evaluate(with: testStr);
    }
    //
    private func red(_ field: UITextField){
        field.backgroundColor = UIColor.red;
    }
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    //
    
    @IBAction func beginEditing(field:UITextField){
        field.backgroundColor = UIColor.clear;
    }
    //
    
    
}
