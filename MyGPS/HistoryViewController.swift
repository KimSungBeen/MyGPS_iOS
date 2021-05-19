//
//  HistoryViewController.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/04/28.
//

import UIKit
import Alamofire

protocol HistoryDataDelegate {
    func didHistoryDataReceive(locationData: LocationData)
}

class HistoryViewController: UITableViewController {
    let REQUEST_LOCATION_DATA_URL = "http:/IP/api/getLocationData"
    var items: [String] = [] // 테이블 cell 아이템 (날짜)
    var locationDatas: [LocationData] = [] // 테이블 cell 아이템 데이터
    var historyDataDelegate: HistoryDataDelegate?
    
    // 리프레쉬 컨트롤러
    let refresh = UIRefreshControl()
    
    @IBOutlet var historyTableView: UITableView!
    
    override func viewDidLoad() {
        // 히스토리 요청 메소드 호출
        requestHistory(REQUEST_LOCATION_DATA_URL, "devsbeen@gmail.com")
        // 새로고침 효과 적용
        initRefresh()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        
        cell!.textLabel?.text = items[(indexPath as NSIndexPath).row]
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgShowDetail" {
            let cell = sender as! UITableViewCell
            
            guard let indexPath = self.historyTableView.indexPath(for: cell) else { return }
            let row = (indexPath as NSIndexPath).row
            
            let historyDetailsViewController = segue.destination as! HistoryDetailsViewController
            historyDataDelegate = historyDetailsViewController // Delegate 연결
            historyDataDelegate?.didHistoryDataReceive(locationData: locationDatas[row])
        }
    }
}
    


extension HistoryViewController {
    
    /// 히스토리 REST API 호출
    private func requestHistory(_ urlStr: String, _ id: String) {
        // Rest API 호출 작업
        let url = URL(string: urlStr)!
        let params = ["id": id]
        
        let req = AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil)
        
        // response에 따른 action
        req.validate(statusCode: 200..<500)
            .responseJSON { response in
                switch response.result{
                
                case .success(let value):
                    // 요청 성공
                    self.parseJson(value)
                    break
                    
                case .failure(let e):
                    // 요청 실패
                    print(e)
                    break
                }
            }
    }
    
    /// REST API의 Response 데이터를 파싱
    private func parseJson(_ value: Any) {
        do{
            let body = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            let locationDataRequestBody = try JSONDecoder().decode(LocationDataRequestBody.self, from: body)
            
            locationDatas = locationDataRequestBody.locationData
            
            let resultCode = locationDataRequestBody.resultCode
            
            if (resultCode == "0000") {
                // SUCCESS
                items.removeAll()
                
                for locationData in locationDatas {
                    items.append(locationData.date)
                    print("\(locationData.date)")
                }
                
                items.reverse() // 데이터가 최신 것 부터 나오도록 뒤집기
                
                print("\(items)")
                
                // 테이블 뷰 데이터 갱신
                historyTableView.reloadData()
                
                // 리프레쉬 모션 끝.
                refresh.endRefreshing()
            } else if (resultCode == "1000") {
                // FAIL
            } else {
                //ERROR
            }
            
        } catch {
            print(error)
        }
    }
    
    private func initRefresh() {
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString()
        
        if #available(iOS 10.0, *) {
            historyTableView.refreshControl = refresh // 테이블뷰에 리프레쉬콘트롤 프로퍼티가 존재함으로 설정
        } else {
            historyTableView.addSubview(refresh)
        }
    }
    
    @objc func updateUI(refresh: UIRefreshControl) {
        requestHistory(REQUEST_LOCATION_DATA_URL, "devsbeen@gmail.com")
    }
    
}
