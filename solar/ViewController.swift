//
//  ViewController.swift
//  solar
//
//  Created by Nadia Barbosa on 7/16/17.
//  Copyright © 2017 nb. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {
    var timer: Timer?
    var utcSecTime = 61979
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 39.23225, longitude: -97.91015), zoomLevel: 5, animated: false)
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        let source = MGLVectorSource(identifier: "eclipse-umbra", configurationURL: URL(string: "mapbox://nbb12805.a9ot0w9k")!)
        style.addSource(source)
        
        let layer = MGLFillStyleLayer(identifier: "eclipse-umbra-style", source: source)
        layer.sourceLayerIdentifier = "sixtysec"
        
        style.addLayer(layer)
        animateUmbraSelection()
    }
            
    @objc func tick() {
        
        utcSecTime += 60
        print(utcSecTime)
        
        let categoricalStops = [
            utcSecTime: MGLStyleValue<UIColor>(rawValue: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
        ]
        
        if let layer = mapView.style?.layer(withIdentifier: "eclipse-umbra-style") as? MGLFillStyleLayer {
            layer.fillColor = MGLStyleValue(interpolationMode: .categorical, sourceStops: categoricalStops, attributeName: "UTCSec", options: [.defaultValue: MGLStyleValue<UIColor>(rawValue: #colorLiteral(red: 1, green: 0.3883662726, blue: 0.278445029, alpha: 0.8107074058))])
            
        }
        
        timeLabel.text = "\(timeFormatted(utcSec: utcSecTime))"
    }
    
    func timeFormatted(utcSec: Int) -> String {
        let userCalendar = NSCalendar.current
        var dateComponent = DateComponents()
        
        dateComponent.year = 2017
        dateComponent.month = 09
        dateComponent.day = 21
        dateComponent.hour = Int(utcSec / 3600)
        dateComponent.minute = Int((utcSec / 60) % 60)
        dateComponent.second = Int(utcSec % 60)
        dateComponent.timeZone = TimeZone(abbreviation: "EST")
        
        let dateTime = userCalendar.date(from: dateComponent)! as Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: dateTime as Date)
        
        return "\(convertedDate)"
    }
    
    func animateUmbraSelection() {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
}

