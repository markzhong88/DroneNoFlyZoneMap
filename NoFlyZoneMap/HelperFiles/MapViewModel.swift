//
//  MapViewModel.swift
//  HappyDrone
//
//  Created by Mark Zhong on 6/12/21.
//  Copyright © 2021 Kirway LLC. All rights reserved.
//

import Foundation
import Mapbox

//the string equal to the geojson's airport type
enum NFZType: String {
    case largeAirport = "large_airport"
    case mediumAirport = "medium_airport"
    case smallAirport = "small_airport"
    case heliAirport = "heliport"
    case seaplaneAirport = "seaplane_base"
    case usNationalPark = "usnational_park"
    case tfr = "tfr"
    case amaClub = "ama_club"
}

enum SouceType:String {
    case airports
    case nationalpark
    case ama_club
    case tfr
}

class MapCircleColor {
    var tfr_color = UIColor.systemPink
    var large_color = UIColor.blue
    var medium_color = UIColor.purple
    var small_color = UIColor.orange
    var sea_color = UIColor.cyan
    var heli_color = UIColor.yellow
    var nationalpark_color = UIColor.red // use stripe fill
    var ama_color = UIColor.green
}

class MapCircle {
    var color = UIColor.red
    var distance = 8064.0
    var type: NFZType
    var id: String
    var alpha: Double
    
    init(color:UIColor, distance: Double, type: NFZType, id: String, alpha: Double) {
        self.color = color
        self.distance = distance
        self.type = type
        self.id = id
        self.alpha = alpha
    }
}


class MapViewModel {
        
    var mapColor = MapCircleColor()
    var circleRadiusData = CircleRadius()
    var airportCircleArray = [MapCircle]()
    var nationalParkSourceIds = [String]()
    
    var visibleCircleType = [String]()
    
    init() {
        syncUserPreference()
    }
    
    func getUserSetting() -> [String: Bool]? {
        if let nfzSetting = UserDefaults.standard.dictionary(forKey: "Show_NFZ") as? [String: Bool] {
            print("get nfzsetting dic:",nfzSetting)
            return nfzSetting
        }
        
        return nil
    }
    
    func setUserSetting(dictionary: [String: Bool]) {
        if dictionary.count > 0 {
            UserDefaults.standard.setValue(dictionary, forKey: "Show_NFZ")
        } else {
            return
        }
    }
    
    func syncUserPreference() {
        
        let userDefault = UserDefaults.standard
        if userDefault.dictionary(forKey: "Show_NFZ") != nil {
            //do nothing

        } else {
            let newSetting = ["large_airport": true,
                               "medium_airport" : true,
                               "small_airport": true,
                               "heliport": true,
                               "seaplane_base": true,
                               "usnational_park": true,
                               "tfr": true,
                               "ama_club": true,
                               "flying_sites_260": true]
            userDefault.setValue(newSetting, forKey: "Show_NFZ")
            print("init new setting:", newSetting)
        }
        
        if let nfzSetting = UserDefaults.standard.dictionary(forKey: "Show_NFZ") as? [String: Bool] {
            for (key,val) in nfzSetting {
                if val == true {
                    visibleCircleType.append(key)
                }
            }
        }
        
        circleRadiusData.syncSetting()
        addAirportsLayer(circleRadius: circleRadiusData)
    }
    
    func addAirportsLayer(circleRadius: CircleRadius) {

        let nfz1 = MapCircle(color: UIColor.blue, distance: circleRadius.largeAirport, type: .largeAirport, id: NFZType.largeAirport.rawValue, alpha: 0.4)
        airportCircleArray.append(nfz1)
        
        let nfz2 = MapCircle(color: UIColor.purple, distance: circleRadius.mediumAirport, type: .mediumAirport, id: NFZType.mediumAirport.rawValue, alpha: 0.4)
        airportCircleArray.append(nfz2)
        
        let nfz3 = MapCircle(color: UIColor.orange, distance: circleRadius.smallAirport, type: .smallAirport, id: NFZType.smallAirport.rawValue, alpha: 0.4)
        airportCircleArray.append(nfz3)
        
        let nfz4 = MapCircle(color: UIColor.yellow, distance: circleRadius.heliAirport, type: .heliAirport, id: NFZType.heliAirport.rawValue, alpha: 0.3)
        airportCircleArray.append(nfz4)
        
        let nfz5 = MapCircle(color: UIColor.cyan, distance: circleRadius.seaplane, type: .seaplaneAirport, id: NFZType.seaplaneAirport.rawValue, alpha: 0.4)
        airportCircleArray.append(nfz5)

    }
    
    func getMapSource(sourceType:SouceType) -> MGLShapeSource? {
        switch sourceType {
        case .airports:
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "airports", ofType: "geojson")!)
            let source = MGLShapeSource(identifier: "allPins",
                                        url: url,
                                        options: nil)
            return source
        case .ama_club:
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "ama_club", ofType: "geojson")!)
            let source = MGLShapeSource(identifier: "ama_club",
                                        url: url,
                                        options: nil)
            return source
        case .tfr:
            //TODO
            return nil
        case .nationalpark:
            //todo
            return nil
        }
        
    }
    
    func getNationalParkLayer() {
        //TODO
    }
    
    func updateCircleDistance()  {
        //TODO
    }
}



class CircleRadius {
    var largeAirport = 16093.4
    var mediumAirport = 8064.0
    var smallAirport = 3210.0
    var heliAirport = 2414.0
    var amaClub = 800.0
    var seaplane = 2414.0
    
    func syncSetting() {
        if let large = UserDefaults.standard.value(forKey: "LargeCircleRadius") as? Double {
            self.largeAirport = large
        } else {
            UserDefaults.standard.setValue(self.largeAirport, forKey: "LargeCircleRadius")
        }
    
        if let medium = UserDefaults.standard.value(forKey: "MediumCircleRadius") as? Double {
            self.mediumAirport = medium
        } else {
            UserDefaults.standard.setValue(self.mediumAirport, forKey: "MediumCircleRadius")
        }
        
        if let small = UserDefaults.standard.value(forKey: "SmallCircleRadius") as? Double {
            self.smallAirport = small
        } else {
            UserDefaults.standard.setValue(self.smallAirport, forKey: "SmallCircleRadius")
        }
        
        if let heli = UserDefaults.standard.value(forKey: "HeliCircleRadius") as? Double {
            self.heliAirport = heli
        } else {
            UserDefaults.standard.setValue(self.heliAirport, forKey: "HeliCircleRadius")
        }
        
        if let seaPlane = UserDefaults.standard.value(forKey: "SeaplaneCircleRadius") as? Double {
            self.seaplane = seaPlane
        } else {
            UserDefaults.standard.setValue(self.seaplane, forKey: "SeaplaneCircleRadius")
        }
        
        if let ama = UserDefaults.standard.value(forKey: "AMACircleRadius") as? Double {
            self.amaClub = ama
        } else {
            UserDefaults.standard.setValue(self.amaClub, forKey: "AMACircleRadius")
        }
    }
}
