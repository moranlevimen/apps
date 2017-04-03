import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet var uEmail: UITextField!
    @IBOutlet var uPass: UITextField!
    var pref = PrefMngr.getInstance();
    var fireRef: FIRDatabaseReference!
    
    //
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true;
        if let u = pref.getLogedUser(){         //if theres a loged user, go to search
            logIn(u[0], u[1]);
        }
    }
    //
    @IBAction func loginBtn(_ sender: UIButton) {
        if checkFields() {                          //preform validation
            self.logIn(uEmail.text!, uPass.text!);  //if all good, login
        }
    }
    //
    func logIn(_ email:String, _ pass:String){
        FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: {(user,error)in    //log in
            if error == nil{
                self.pref.setLogedUser(email, pass);    //save loged user to userdefaults
                let nextScreen = self.storyboard!.instantiateViewController(withIdentifier: "searchCtrl") as! SearchController;
                self.show(nextScreen, sender: self);    //if no error, go to searchscreen
            }else{
                print("**\(error)");
            }
        });
    }
    //
    private func checkFields()->Bool{
        let fields = [uEmail,uPass];
        var good = true;
        for f in fields {           //check if fields r empty
            if f!.text! == ""{
                red(f!);
                good = false;
            }
        }
        return good;
    }
    //
    private func red(_ field: UITextField){         //color fields red
        field.backgroundColor = UIColor.red;
    }
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //revoke first responder
        view.endEditing(true);
    }
    //
    @IBAction func beginEditing(field:UITextField){     //remove color when editing
        field.backgroundColor = UIColor.clear;
    }
    //
}

