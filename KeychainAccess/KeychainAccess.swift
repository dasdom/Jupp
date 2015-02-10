//
//  KeychainAccess.swift
//  Jupp
//
//  Created by dasdom on 16.08.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import Foundation

public class KeychainAccess {
    
    private class func secClassGenericPassword() -> String {
//        return kSecClassGenericPassword.takeRetainedValue() as String
        return NSString(format: kSecClassGenericPassword) as! String
    }
    
    private class func secClass() -> String {
//        return kSecClass.takeRetainedValue() as String
        return NSString(format: kSecClass) as! String
    }
    
    private class func secAttrService() -> String {
//        return kSecAttrService.takeRetainedValue() as String
        return NSString(format: kSecAttrService) as! String
    }
    
    private class func secAttrAccount() -> String {
//        return kSecAttrAccount.takeRetainedValue() as String
        return NSString(format: kSecAttrAccount) as! String
    }
    
    private class func secValueData() -> String {
//        return kSecValueData.takeRetainedValue() as String
        return NSString(format: kSecValueData) as! String
    }
    
    private class func secReturnData() -> String {
//        return kSecReturnData.takeRetainedValue() as String
        return NSString(format: kSecReturnData) as! String
    }
    
    public class func setPassword(password: String, account: String, service: String = "kDDHDefaultService") {
        var secret: NSData = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let objects: Array = [secClassGenericPassword(), service, account, secret]
        
        let keys: Array = [secClass(), secAttrService(), secAttrAccount(), secValueData()]
        
        let query = NSDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status = SecItemAdd(query as CFDictionaryRef, nil)
    }
    
    public class func deletePasswortForAccount(account: String, service: String = "kDDHDefaultService") {
        let objects: Array = [secClassGenericPassword(), service, account]
        
        let keys: Array = [secClass(), secAttrService(), secAttrAccount()]
        
        let query = NSDictionary(objects: objects, forKeys: keys)
        
        SecItemDelete(query as CFDictionaryRef)
        
        let status = SecItemDelete(query as CFDictionaryRef)

    }
    
    public class func passwordForAccount(account: String, service: String = "kDDHDefaultService") -> String? {
        
        let queryAttributes = NSDictionary(objects: [secClassGenericPassword(), service, account, true], forKeys: [secClass(), secAttrService(), secAttrAccount(), secReturnData()])
        
        var dataTypeRef : Unmanaged<AnyObject>?
        let status = SecItemCopyMatching(queryAttributes, &dataTypeRef);
        if status == errSecItemNotFound {
            return nil
        }
//        if let dataTypeRef = dataTypeRef {
            let retrievedData : NSData = dataTypeRef!.takeRetainedValue() as! CFDataRef as NSData
        
//        if let retrievedData = retrievedData {
            let password = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
            
            return password as? String

//        }
//        return nil
    }
    
}
