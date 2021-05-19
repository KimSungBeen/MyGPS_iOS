//
//  HistoryDetailsViewController.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/04/29.
//

import UIKit
import MapKit
import CoreLocation

class HistoryDetailsViewController: UIViewController {
    var locationData: LocationData?
    var latitudeValue: CLLocationDegrees?
    
    //LocationManager 선언
    var locationManager:CLLocationManager!
    
    @IBOutlet var detailMapView: MKMapView!
    @IBOutlet var locationLabel: UILabel!
    
    override func viewDidLoad() {
        setData()
    }
    
    private func setData() {
        setLocation()
        goLocation()
    }
}

extension HistoryDetailsViewController: CLLocationManagerDelegate, HistoryDataDelegate {
    /// LocationManager 및 맵뷰 셋팅
    private func setLocation() {
        //locationManager 인스턴스 생성 및 델리게이트 생성
        locationManager = CLLocationManager()
        
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        detailMapView.showsUserLocation = true
    }
    
    /// 좌표를 받아 지도위치를 이동시킴
    private func goLocation() {
        // 좌표 설정
        guard let latitude = locationData?.latitude, let longitude = locationData?.longitude else { return }
        let latitudeValue = CLLocationDegrees.init(latitude)
        let longitudeValue = CLLocationDegrees.init(longitude)
        let pLocation = CLLocation.init(latitude: latitudeValue, longitude: longitudeValue)
        setAddress(pLocation: pLocation)
        
        let pLocations = CLLocationCoordinate2D(latitude: latitudeValue, longitude: longitudeValue)
        let spanValue = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let pRegion = MKCoordinateRegion(center: pLocations, span: spanValue)
        
        detailMapView.setRegion(pRegion, animated: true)
    }
    
    private func setAnnotation(title strTitle: String, subTitle strSubtitle: String) {
        let annotaion = MKPointAnnotation()
        
        guard let latitude = locationData?.latitude, let longitude = locationData?.longitude else { return }
        let latitudeValue = CLLocationDegrees.init(latitude)
        let longitudeValue = CLLocationDegrees.init(longitude)
        let pLocations = CLLocationCoordinate2D(latitude: latitudeValue, longitude: longitudeValue)
        
        annotaion.coordinate = pLocations
        
        annotaion.title = strTitle
        annotaion.subtitle = strSubtitle
        detailMapView.addAnnotation(annotaion)
    }
    
    private func setAddress(pLocation: CLLocation) {
        // 좌표로 부터 주소 불러오기
        CLGeocoder().reverseGeocodeLocation(pLocation, completionHandler: { (placebarks, error) -> Void in
            guard let pm = placebarks?.first else { return }
            let country = pm.country // 나라
            var address: String = country!
            
            // 지역 값이 존재하면 address 문자열에 추가
            guard let locality = pm.locality else { return }
            address += " "
            address += locality
            
            // 도로 값이 존재하면 address 문자열에 추가
            guard let thoroughfare = pm.thoroughfare else { return }
            address += " "
            address += thoroughfare
            self.locationLabel.text = address
            self.setAnnotation(title: address, subTitle: "")
            
            print("위치: \(address)")
        })
    }
    
    /// delegate
    func didHistoryDataReceive(locationData: LocationData) {
        self.locationData = locationData
    }
}
