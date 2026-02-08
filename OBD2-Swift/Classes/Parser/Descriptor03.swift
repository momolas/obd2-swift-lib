//
//  Descriptor03.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class Mode03Descriptor : DescriptorProtocol {
  public var response : Response
  
  public required init(describe response : Response) {
    self.response = response
    self.mode = response.mode
  }
  
  public var mode : Mode
  
  private var pid: UInt8 {
    return response.pid
  }
  
  public func getTroubleCodes() -> [String] {
    guard let data = response.data , data.count >= 2 else {
      // data length must be a multiple of 2
      // each DTC is encoded in 2 bytes of data
      print("data \(String(describing: response.data)) is NULL or dataLength is not a multiple of 2 \(response.data?.count ?? 0)")
      return []
    }
    
    let systemCode: [Character]	= [ "P", "C", "B", "U" ]
    
    var codes = [String]()
    
    // Modern Swift: stride instead of C-style loop where possible, but here logic is specific
    // Using simple loop with step 2
    for i in stride(from: 0, to: data.count - 1, by: 2) {
      let codeIndex = Int(data[i] >> 6)
      
      //Out of range
      guard codeIndex < systemCode.count else { break }
      
      let c1 = systemCode[codeIndex]
      let a2 = Int(data[i] & DTC_DIGIT_0_1_MASK)
      let a3 = Int(data[i+1] & DTC_DIGIT_2_3_MASK)
      
      // AGENTS.md: Never use C-style number formatting like String(format: "%02d", ...)
      // We manually pad with 0 if < 10 since the range is limited to 2 digits for DTC.

      let c2 = a2 < 10 ? "0\(a2)" : "\(a2)"
      let c3 = a3 < 10 ? "0\(a3)" : "\(a3)"
      
      let code = "\(c1)\(c2)\(c3)"
      
      codes.append(code)
    }
    
    return codes
  }
  
  public func isMILActive() -> Bool {
      return OBD2Calculator.calcMILActive(data: response.rawData)
  }
  
  public func troubleCodeCount() -> Int {
    //   43 06 01 00 02 00
    //     [..] - 06 is a dct count.
    //Second byte of DCT response is a DTC count. Like a pid in other modes.
    return Int(self.pid)
  }
}
