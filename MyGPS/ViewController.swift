//
//  ViewController.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/04/21.
//

import UIKit
import CoreLocation
import Alamofire
import MapKit

class ViewController: UIViewController {
    let UPDATE_LOCATION_DATA_URL = "http:/IP/api/saveLocationData"
    let TIMER = 30.0 // 초(second)
    
    //LocationManager 선언
    var locationManager:CLLocationManager!
    
    //위도와 경도
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet var gpsMap: MKMapView!
    
    @IBAction func getGPS(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // 위치 가져오기 타이머
        Timer.scheduledTimer(timeInterval: TIMER, target: self, selector: #selector(reloadToLocation), userInfo: nil, repeats: true)
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    /// LocationManager 및 맵뷰 셋팅
    private func setLocation() {
        //locationManager 인스턴스 생성 및 델리게이트 생성
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 위치업데이트 시작
        locationManager.startUpdatingLocation()
        
        gpsMap.showsUserLocation = true
    }
    
    /// 위치 갱신 값 가져오기
    @objc private func reloadToLocation() {
        OperationQueue().addOperation { // 비동기 실행
            
            // 위도 경도 가져오기
            let coor = self.locationManager.location?.coordinate
            self.latitude = coor?.latitude
            self.longitude = coor?.longitude
            
            guard let latitude = self.latitude, let longitude = self.longitude else { return }
            
            //위치정보 갱신 Rest API 호출 작업
            self.updateLocationData(latitude: latitude, longitude: longitude)
            
            print("위도: \(String(describing: latitude)) \n경도: \(String(describing: longitude))")
        }
    }
    
    /// 위치정보 갱신 Rest API 호출 작업
    func updateLocationData(latitude: Double, longitude: Double) {
        let url = URL(string: UPDATE_LOCATION_DATA_URL)!
        let params: Parameters = [
            "id": "devsbeen@gmail.com",
            "latitude": latitude ,
            "longitude": longitude
        ]
        let req = AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
        
        // response에 따른 action
        req.responseJSON { response in
            self.locationDataCallback(response: response)
        }
    }
    
    /// updateLocationData의 콜백
    func locationDataCallback(response: AFDataResponse<Any>) {
        guard let body = response.value as? [String: Any] else { return }
        guard let resultMessage = body["resultMessage"] as? String else { return }
        guard let resultCode = body["resultCode"] as? String else { return }
        var resultAlertController: UIAlertController
        print("body: \(body)")
        
        if (resultCode == "0000") {
            // SUCCESS
            
        } else if (resultCode == "1000") {
            // FAIL
            resultAlertController = getSimpleAlert(title: "FAIL", message: resultMessage)
            self.present(resultAlertController, animated: true, completion: nil)
        } else {
            // ERROR
            resultAlertController = getSimpleAlert(title: "ERROR", message: "알 수 없는 오류가 발생하였습니다.")
            self.present(resultAlertController, animated: true, completion: nil)
        }
    }
    
    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span: Double) {
        let pLocations = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        let pRegion = MKCoordinateRegion(center: pLocations, span: spanValue)
        
        gpsMap.setRegion(pRegion, animated: true)
    }
    
    /// 위치가 업데이트 될때 호출되는 delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let pLocation = locations.last
        
        goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)
        
        CLGeocoder().reverseGeocodeLocation(pLocation!, completionHandler: { (placebarks, error) -> Void in
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
            
            print("현재위치: \(address)")
        })
        
        // 위치가 업데이트되는 것을 멈춤
        locationManager.stopUpdatingLocation()
    }
}
