//
//  NoFlyZoneViewController.swift
//  NoFlyZoneMap
//
//  Created by Mark Zhong on 2/13/23.
//  Copyright © 2023 Kirway LLC. All rights reserved.


import UIKit
import Mapbox

class NoFlyZoneViewController: UIViewController, MGLMapViewDelegate {

    var mapView = MGLMapView()
    var mapVM: MapViewModel?
    
    required init(mapVM: MapViewModel) {
        self.mapVM = mapVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("No Fly Zone Map", comment: "title of nfz map")

        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.streetsStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.zoomLevel = 7.0
        mapView.minimumZoomLevel = 4
        mapView.isPitchEnabled = false
        mapView.showsUserLocation = false
        

        let center = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        mapView.centerCoordinate = center
        self.view.addSubview(mapView)
        
        addMapLegend()
    }
    
    func addMapLegend() {
        let legendView = MapLegendView()

        self.mapView.addSubview(legendView)
        legendView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            legendView.widthAnchor.constraint(equalToConstant: 160),
            legendView.heightAnchor.constraint(equalToConstant: 220),
            legendView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            legendView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5)
        ])
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        // add all airports layer
        loadAirportsWorldJson()
        
        //add national park layer
        loadNationalParkGeoJson()
        
        //add uas flight restriction
        loadUASFlightRestriction()
    }

    func createLayer(identifier:String, source: MGLShapeSource, type: String,
                     color: UIColor, distance: Double, alpha: Double) ->MGLCircleStyleLayer {
        let layer = MGLCircleStyleLayer(identifier: identifier, source: source)
        layer.predicate = NSPredicate(format: "type == %@", type)
        layer.circleRadius = NSExpression(forConstantValue: distance)

        let centerLatitude = mapView.centerCoordinate.latitude
        let radiusPoints = distance / mapView.metersPerPoint(atLatitude: centerLatitude)
        layer.circleRadius = NSExpression(forConstantValue: radiusPoints)
        layer.circleColor = NSExpression(forConstantValue: color)
        layer.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
        layer.circleStrokeWidth = NSExpression(forConstantValue: 1.0)
        layer.circleOpacity = NSExpression(forConstantValue: alpha)
        layer.minimumZoomLevel = 4
        layer.maximumZoomLevel = 20
        
        return layer
    }
    
    func loadAirportsWorldJson() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "airports", ofType: "geojson")!)
        let source = MGLShapeSource(identifier: "allPins",
                                    url: url,
                                    options: nil)
        guard let style = self.mapView.style else { return }
        style.addSource(source)

        DispatchQueue.global().async {
            
            guard let circleArr = self.mapVM?.airportCircleArray else { return }
            for item in circleArr {
                if (self.mapVM?.visibleCircleType.contains(item.type.rawValue) ?? false) {
                    let circleLayer = self.createLayer(identifier: item.type.rawValue, source: source,
                                                       type: item.type.rawValue , color: item.color, distance: item.distance, alpha: item.alpha)
                    DispatchQueue.main.async {
                        style.addLayer(circleLayer)
                    }
                }

            }
        }
    }
    
    func loadNationalParkGeoJson() {
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "us_uk_canada_parks", ofType: "geojson")!)
        
        // Create a shape source and register it with the map style.
        let source = MGLShapeSource(identifier: "usnational_park", url: url, options: nil)
        guard let style = self.mapView.style else { return }
        
        let sourceIds = style.sources.map{ $0.identifier }
        if sourceIds.contains("usnational_park") {
            //print("already has source")
        } else {
            style.addSource(source)
        }
     
        let layerIds = style.layers.map{ $0.identifier }
        if layerIds.contains("usnational_park") {
            //print("already has layer with same id")
            self.mapView.style?.layer(withIdentifier: "usnational_park")?.isVisible = true
        } else {
            let polygonLayer = MGLFillStyleLayer(identifier: "usnational_park", source: source)
            polygonLayer.sourceLayerIdentifier = "usnational_park"
            polygonLayer.fillColor = NSExpression(forConstantValue: UIColor.systemPink)
            polygonLayer.fillOpacity = NSExpression(forConstantValue: 0.6)
            
            DispatchQueue.main.async {
                self.mapView.style?.addLayer(polygonLayer)
            }
        }
        
    }
    

    func loadUASFlightRestriction() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "uas_reduced", ofType: "geojson")!)
        
        // Create a shape source and register it with the map style.
        let source = MGLShapeSource(identifier: "uas_restriction", url: url, options: nil)
        guard let style = self.mapView.style else { return }
        
        
        let sourceIds = style.sources.map{ $0.identifier }
        if sourceIds.contains("uas_restriction") {
            //print("already has source")
        } else {
            style.addSource(source)
        }
        let fillPatternImage = UIImage(named: "pattern")!
        style.setImage(fillPatternImage, forName: "stripe-pattern")
        
        let layerIds = style.layers.map{ $0.identifier }
        if layerIds.contains("tfr") {
            //print("already has layer with same id")
            self.mapView.style?.layer(withIdentifier: "tfr")?.isVisible = true
        } else {
            let polygonLayer = MGLFillStyleLayer(identifier: "tfr", source: source)
            polygonLayer.fillPattern = NSExpression(forConstantValue: "stripe-pattern")
            polygonLayer.fillOpacity = NSExpression(forConstantValue: 0.8)
            polygonLayer.fillOutlineColor = NSExpression(forConstantValue: UIColor.white)
            
            DispatchQueue.main.async {
                self.mapView.style?.addLayer(polygonLayer)
            }
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, regionIsChangingWith reason: MGLCameraChangeReason) {
        updateCircleRadius()
    }
    
    func updateCircleRadius() {
        guard let nfzArr = self.mapVM?.airportCircleArray else { return }
        for item in nfzArr {
            if let layer = mapView.style?.layer(withIdentifier: item.type.rawValue) as? MGLCircleStyleLayer {
                let centerLatitude = self.mapView.centerCoordinate.latitude
                let radiusPoints = item.distance / self.mapView.metersPerPoint(atLatitude: centerLatitude)
                layer.circleRadius = NSExpression(forConstantValue: radiusPoints)
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        mapView.removeAnnotations([annotation])
    }
}
