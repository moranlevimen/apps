
import Foundation
import UIKit

class Restarent{
    
    private var title, adress, id: String?
    private var hours : [String]?
    private var isOpen: Bool?
    private var loc : [Double]?;
    //
    public func set(title : String) ->Restarent{
        self.title = title;
        return self;
    }
    //
    public func set(id: String) ->Restarent{
        self.id = id
        return self;
    }
    //
    public func set(isOpen : Bool) ->Restarent{
        self.isOpen = isOpen;
        return self;
    }
    //
    public func set(hours : [String]) ->Restarent{
        self.hours = hours;
        return self;
    }
    //
    public func set(adress : String) ->Restarent{
        self.adress = adress;
        return self;
    }
    //
    public func set(location:[Double]) ->Restarent{
        let lat = location[0];
        let lng = location[1];
        self.loc = [lat,lng];
        return self;
    }
    //
    public func getLoc()->[Double]?{
        return self.loc;
    }
    //
    public func getTitle() -> String?{
        return self.title;
    }
    //
    public func getAdress() -> String?{
        return self.adress;
    }
    //
    public func getIsOpen() -> Bool?{
        return self.isOpen;
    }
    //
    public func getHours() -> [String]?{
        return self.hours;
    }
    //
    public func getId() -> String?{
        return self.id ;
    }
    //
}



