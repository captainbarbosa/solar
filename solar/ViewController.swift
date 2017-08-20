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
    var timerRunning = false
    var utcSecTime = 61920
    var vectorSource: MGLVectorSource!
    
    @IBOutlet weak var mapView: MGLMapView!
    
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dateView: UIView!

    @IBOutlet weak var timerButton: UIButton!
    @IBAction func timerButton(_ sender: Any) {
        animateUmbraSelection()
    }
    
    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 39.23225, longitude: -99.99470), zoomLevel: 2, animated: false)
        mapView.styleURL = NSURL(string: "mapbox://styles/nbb12805/cj6l0e7ny7nq82sqvesdhjqqf")! as URL
        mapView.delegate = self
        
        timeView.layer.cornerRadius = timeView.frame.size.height / 8
        timeView.layer.masksToBounds = true
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        vectorSource = MGLVectorSource(identifier: "eclipse-umbra", configurationURL: URL(string: "mapbox://nbb12805.7nlrnej6")!)
        style.addSource(vectorSource)
        
        let layer = MGLFillStyleLayer(identifier: "eclipse-umbra-style", source: vectorSource)
        layer.fillColor = MGLStyleValue<UIColor>(rawValue: #colorLiteral(red: 1, green: 0.3883662726, blue: 0.278445029, alpha: 0.5))
        layer.sourceLayerIdentifier = "60s_umbrageojson"
        
        style.addLayer(layer)
    }
    
    
    func animateUmbraSelection() {
        if timerRunning == false {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
            timerRunning = true
            timerButton.setImage(pauseImage, for: .normal)
        } else {
            timer?.invalidate()
            timerRunning = false
            timerButton.setImage(playImage, for: .normal)
        }
    }
    
    @objc func tick() {
        self.utcSecTime += 60
        
        let categoricalStops = [
            self.utcSecTime: MGLStyleValue<UIColor>(rawValue: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 0.6049604024))
        ]
        
        if let layer = self.mapView.style?.layer(withIdentifier: "eclipse-umbra-style") as? MGLFillStyleLayer {
            layer.fillColor = MGLStyleValue(interpolationMode: .categorical, sourceStops: categoricalStops, attributeName: "UTCSec", options: [.defaultValue: MGLStyleValue<UIColor>(rawValue: #colorLiteral(red: 1, green: 0.3883662726, blue: 0.278445029, alpha: 0.5))])
        }
        
        let predicate = NSPredicate(format: "UTCSec = %i", self.utcSecTime)
        
        let selectedFeature = self.vectorSource.features(sourceLayerIdentifiers: Set(["60s_umbrageojson"]), predicate: predicate)
        
        guard let latitude = selectedFeature.first?.attribute(forKey: "CenterLat") as? NSNumber else { return }
        
        let offsetLatitude = latitude.doubleValue - 0.46
        
        guard let longitude = selectedFeature.first?.attribute(forKey: "CenterLon") as? NSNumber else { return }
        
        let center = CLLocationCoordinate2DMake(offsetLatitude, longitude.doubleValue)
        
        self.mapView.setCenter(center, zoomLevel: 6.5, animated: true)
        
        self.timeLabel.text = "\(self.timeFormatted(utcSec: self.utcSecTime))"
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
        dateFormatter.dateStyle = DateFormatter.Style.none
        dateFormatter.timeStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: dateTime as Date)
        
        return "\(convertedDate)"
    }
}

