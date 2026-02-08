//
//  Logger.swift
//  OBD2Swift
//
//  Created by Hellen Soloviy on 5/31/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation
import UIKit

//func print(_ string: String) {
//    Logger.shared.log(string)
////    NSLog(string)
//}

enum LoggerMessageType {
    
    case debug
    case error
    case info
    case verbose //default
    case warning
    
}


enum LoggerSourceType {
    
    case console
    case file //default
    
}

open class Logger {
    
    static var sourceType: LoggerSourceType = .console
    static let queue = OperationQueue()
    
    // Modern Foundation API: URL.documentsDirectory
    static var logFileURL: URL {
        return URL.documentsDirectory.appending(path: "OBD2Logger.txt")
    }
    
    public static func warning(_ message:String) {
        newLog(message, type: .warning)
    }
    
    public static func info(_ message:String) {
        newLog(message, type: .info)
    }
    
    public static func error(_ message:String) {
        newLog(message, type: .error)

    }
    
    public static func shareFile(on viewController: UIViewController) {
        
        let activityVC = UIActivityViewController(activityItems: fileToShare(), applicationActivities: nil)
        viewController.present(activityVC, animated: true, completion: nil)
        
    }
    
    public static func fileToShare() -> [Any] {
        
        let comment = "Logger file"
        return [comment, logFileURL] as [Any]
        
    }

    
    public static func cleanLoggerFile() {
        
        do {
            try " ".write(to: logFileURL, atomically: true, encoding: .utf8)
        } catch let error {
            print("Failed writing to log file: \(logFileURL), Error: " + error.localizedDescription)
        }
    }
    
    
    private static func newLog(_ message:String, type: LoggerMessageType = .verbose) {
        
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            
            let log = "[\(Date().description)] [\(type)] \(message)"

            var content = ""
            // Avoid force try
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                do {
                    content = try String(contentsOf: logFileURL, encoding: .utf8)
                } catch {
                    print("Failed to read log file: \(error.localizedDescription)")
                }
            }
            
            do {
                try "\(content)\n\(log)".write(to: logFileURL, atomically: true, encoding: .utf8)
                
            } catch let error {
                print("Failed writing to log file: \(logFileURL), Error: " + error.localizedDescription)
            }
            
        }

    }
    
    
}
