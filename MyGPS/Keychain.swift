//
//  Keychain.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/05/03.
//

import UIKit
import Security

// Keychain 관련 쿼리 키 값들
let kSecClassValue                  = NSString(format: kSecClass)
let kSecAttrAccountValue            = NSString(format: kSecAttrAccount)
let kSecValueDataValue              = NSString(format: kSecValueData)
let kSecAttrGenericValue            = NSString(format: kSecAttrGeneric)
let kSecAttrServiceValue            = NSString(format: kSecAttrService)
let kSecAttrAccessValue             = NSString(format: kSecAttrAccessible)
let kSecMatchLimitValue             = NSString(format: kSecMatchLimit)
let kSecReturnDataValue             = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue          = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessGroupValue        = NSString(format: kSecAttrAccessGroup)
let kSecClassGenericPasswordValue   = NSString(format: kSecClassGenericPassword)

class Keychain: NSObject {
    /*
     * 외부로 제공되는 메소드
     * serviceIdentifier: 키체인에서 해당 앱을 식별하는 값으로 앱만의 고유한 값을 써야합니다. (데이터를 해당 앱에서만 사용하기 위해)
     * userAccount: 앱 내에서 데이터를 식별하기 위한 키에 해당하는 값입니다.
     */
         
    public class func saveData(serviceIdentifier:NSString, userAccount:NSString, data: String) {
        self.save(service: serviceIdentifier, userAccount: userAccount, data: data)
    }
     
    public class func loadData(serviceIdentifier:NSString, userAccount:NSString) -> String? {
        let data = self.load(service: serviceIdentifier, userAccount: userAccount)
         
        return data
    }
    
    /*
     * Keychain 에 실제 접근하는 내부 메소드
     */
         
    private class func save(service: NSString, userAccount:NSString, data: String) {
        let dataFromString: Data = data.data(using: String.Encoding.utf8)!
         
        // Instantiate a new default keychain query
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: userAccount,
                                    kSecValueData as String: dataFromString]
        
        // Delete any existing items
        SecItemDelete(query as CFDictionary)
         
        // Add the new keychain item
        SecItemAdd(query as CFDictionary, nil)
    }
     
    private class func load(service: NSString, userAccount:NSString) -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: userAccount,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne as String]
         
        var retrievedData: NSData?
        var dataTypeRef:AnyObject?
        var contentsOfKeychain: String?
         
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
         
        if (status == errSecSuccess) {
            retrievedData = dataTypeRef as? NSData
            contentsOfKeychain = String(data: retrievedData! as Data, encoding: String.Encoding.utf8)
        }
        else
        {
            print("Nothing was retrieved from the keychain. Status code \(status)")
            contentsOfKeychain = nil
        }
         
        return contentsOfKeychain
    }
}
