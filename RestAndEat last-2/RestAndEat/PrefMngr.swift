
import Foundation
class PrefMngr {
    private let pref = UserDefaults.standard;
    private static var prefMngr : PrefMngr?;
    private init(){}
    
        //
    public static func getInstance()->PrefMngr{
        if PrefMngr.prefMngr == nil{   //if dosnt exist
            PrefMngr.prefMngr = PrefMngr();   //create and store statically
        }
        return PrefMngr.prefMngr!;     
    }
    //
    public func setLogedUser(_ email:String, _ pass:String){
        pref.set([email,pass], forKey: "logedUser");
    }
    //
    public func getLogedUser()->[String]?{
        return pref.array(forKey: "logedUser") as! [String]?;
    }
    //
    public func logUserOut(){
        pref.removeObject(forKey: "logedUser");
    }

}
