//
//  JSONHelper.swift
//  NXT_Programming
//
//  Created by Erick Chong on 11/2/17.
//  Copyright © 2017 LA's BEST. All rights reserved.
//

import UIKit

// This function will only return the array of "commands" that is parsed from a json string
class JSONHelper: NSObject {
    // String must be in JSON format
    class func parseJSONWith(json: String) -> Array<Dictionary<String, Any>> {
        var result: Array<Dictionary<String, Any>> = []
        if let data = json.data(using: .utf8) {
            if let json = try? JSON(data: data) {
                // Iterate through each json index
                for (index, _) in json {
                    // If we are on "commands" array
                    if index == "commands" {
                        // Iterate through the "commands" array (which contains dictionaries)
                        for (_, object) in json["commands"] {
                            var dictionary: Dictionary<String, Any> = [:]
                            // Iterate through the dictionaries
                            for (key, value) in object {
                                if key == "condition" {
                                    var conditionDictionary: Dictionary<String, Any> = [:]
                                    for (condition, conditionValue) in value {
                                        // Array of commands from if/else
                                        var ifArray: Array<Dictionary<String, Any>> = []
                                        if condition == "if" || condition == "else" {
                                            // Iterate through the array in the if/else
                                            for (_, ifValue) in conditionValue {
                                                var ifDictionary: Dictionary<String, Any> = [:]
                                                // Iterate through each dictionary in the array
                                                for (ifArrayKey, ifArrayValue) in ifValue {
                                                    if self.stringIsInt(value: ifArrayValue.stringValue) {
                                                        ifDictionary[ifArrayKey] = ifArrayValue.intValue
                                                    } else if self.stringIsBool(value: ifArrayValue.stringValue) {
                                                        ifDictionary[ifArrayKey] = ifArrayValue.boolValue
                                                    } else {
                                                        ifDictionary[ifArrayKey] = ifArrayValue.stringValue
                                                    }
                                                }
                                                ifArray.append(ifDictionary)
                                            }
                                            conditionDictionary[condition] = ifArray
                                        } else {
                                            // Condition value will always be a Bool or an array
                                            conditionDictionary[condition] = conditionValue.boolValue
                                        }
                                        dictionary[key] = conditionDictionary
                                    }
                                // If value is an integer, store it as an integer. Otherwise, store as a string
                                } else if self.stringIsInt(value: value.stringValue) {
                                    dictionary[key] = value.intValue
                                    //print(type(of: value.intValue))
                                } else if self.stringIsBool(value: value.stringValue) {
                                    //print(value)
                                    dictionary[key] = value.boolValue
                                    //print(type(of: value.boolValue))
                                } else {
                                    dictionary[key] = value.stringValue
                                    //print(type(of: value.stringValue))
                                }
                            }
                            // Add the resulting dictionary to the array
                            result.append(dictionary)
                        }
                    }
                }
            }
        }
        return result
    }
    
    class func iterateArrayOfDictionariesWith(array: Array<Dictionary<String, Any>>) {
        var index = 0
        for dictionary in array {
            print("Index: \(index)")
            for (key, value) in dictionary {
                print("Key: \(key)")
                print("Value: \(value)")
            }
            print("\n")
            index += 1
        }
    }
    
    private class func stringIsInt(value: String) -> Bool {
        return Int(value) != nil
    }
    
    private class func stringIsBool(value: String) -> Bool {
        return Bool(value) != nil
    }
    
}
