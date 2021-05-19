//
//  LoginViewController.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/05/03.
//

import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import Alamofire

let LOGIN_URL = "http://IP/api/login"
let SIGNUP_URL = "http://IP/api/signUp"
let PLATFORM_KAKAO = "kakao"

class LoginViewController: UIViewController {
    var userID = ""
    var appVersion = ""
    @IBOutlet var loginButton: UIButton!
    
    @IBAction func kakaoLoginButton(_ sender: Any) {
        checkInstalledKakaoTalk()
    }
    
    override func viewDidLoad() {
        appVersion = currentAppVersion() // 앱 버전 초기화
    }

    override func viewDidAppear(_ animated: Bool) {
//        autoLogin()
    }
    
    /// 앱 버전 가져오기
    func currentAppVersion() -> String {
      if let info: [String: Any] = Bundle.main.infoDictionary,
          let currentVersion: String
            = info["CFBundleShortVersionString"] as? String {
            return currentVersion
      }
      return "nil"
    }
    
    /// 카카오톡이 설치되어 있는지 확인 후 카카오톡 로그인 API요청 (함수명이 명확하지 않은것 같음 수정하자.)
    @objc private func checkInstalledKakaoTalk() {
        if (KakaoSDKUser.UserApi.isKakaoTalkLoginAvailable()) {
            KakaoSDKUser.UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    self.requestUserInfo()
                }
            }
        }
    }
    
    /// 카카오톡 로그인 후 유저 정보를 요청하는 API
    private func requestUserInfo() {
        // 사용자 액세스 토큰 정보 조회
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("requestUserInfo() success.")

                let email = user?.kakaoAccount?.email ?? "NONE"
                self.userID = email
                
                print("email: \(email)")
                
                self.requestLogin(LOGIN_URL, email, PLATFORM_KAKAO)
            }
        }

    }
}

extension LoginViewController {
    /// 로그인  REST API 호출
    private func requestLogin(_ urlStr: String, _ id: String, _ sns: String) {
        // Rest API 호출 작업
        print(" ## requestLogin 호출 ## ")
        let url = URL(string: urlStr)!
        let params = ["id": id, "sns": sns]
        let req = AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil)
        
        // response에 따른 action
        req.validate(statusCode: 200..<500)
            .responseJSON { response in
                switch response.result{
                
                case .success(let value):
                    // 요청 성공
                    self.parseLoginJson(value)
                    break
                    
                case .failure(let e):
                    // 요청 실패
                    print("## requestLogin Fail ## \n\(e)")
                    break
                }
            }
    }
    
    /// 로그인 REST API 의 Response 데이터를 파싱
    private func parseLoginJson(_ value: Any) {
        do{
            print(" ## parseLoginJson 호출 ## ")
            let body = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            let loginRequestBody = try JSONDecoder().decode(LoginRequestBody.self, from: body)
            
            let resultCode = loginRequestBody.resultCode
            let resultMessage = loginRequestBody.resultMessage
//            let user  = loginRequestBody.user
            
            if (resultCode == "0000") {
                // SUCCESS
                print("\(self.userID) 로그인 성공")
                saveLoginData(userID: userID, sns: "kakao")
                goToMain()
                
            } else if (resultCode == "1000") {
                // FAIL: 비회원
                print("\(resultMessage)")
                
                // SignUp 진행
                requestSignUp(SIGNUP_URL, userID, PLATFORM_KAKAO)
            } else {
                // ERROR
                
            }
            
        } catch {
            print(error)
        }
    }
    
    /// SignUp  REST API 호출
    private func requestSignUp(_ urlStr: String, _ id: String, _ sns: String) {
        print(" ## requestSignUp 호출 ## ")
        let url = URL(string: urlStr)!
        let params = ["id": id, "sns": sns]
        
        let req = AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil)
        
        // response에 따른 action
        req.validate(statusCode: 200..<500)
            .responseJSON { response in
                switch response.result{
                
                case .success(let value):
                    // 요청 성공
                    self.parseSignUpJson(value)
                    break
                    
                case .failure(let e):
                    // 요청 실패
                    print(e)
                    break
                }
            }
    }
    
    /// SignUp REST API 의 Response 데이터를 파싱
    private func parseSignUpJson(_ value: Any) {
        do{
            print(" ## parseSignUpJson 호출 ## ")
            let body = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
            let signUpRequestBody = try JSONDecoder().decode(SignUpRequestBody.self, from: body)
            
            let resultCode = signUpRequestBody.resultCode
            let resultMessage = signUpRequestBody.resultMessage
            
            if (resultCode == "0000") {
                // SUCCESS
                print("\(resultMessage) sign up 성공")
                saveLoginData(userID: userID, sns: "kakao")
                goToMain()
                
            } else if (resultCode == "1000") {
                print("\(resultMessage)")
            } else {
                // ERROR
                
            }
            
        } catch {
            print(error)
        }
    }
    
    /// UserDefault에 로그인 데이터 저장
    private func saveLoginData(userID: String, sns: String) {
        UserDefaults.standard.set(userID, forKey: "id")
        UserDefaults.standard.set(sns, forKey: "sns")
    }
    
    /// 로그인 성공시 mainViewController로 이동
    private func goToMain() {
        print("## goToMain 호출 ##")
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "mainViewController") else { return }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func autoLogin() {
        guard let userID = UserDefaults.standard.string(forKey: "id"), let sns = UserDefaults.standard.string(forKey: "sns") else { return }
        
        print("id: \(userID) // sns: \(sns)")
        
        // 기존 로그인 데이터가 있으면 자동 로그인
        goToMain()
    }
}
