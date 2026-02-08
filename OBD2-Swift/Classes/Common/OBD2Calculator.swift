//
//  OBD2Calculator.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 27/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public struct OBD2Calculator {

    // MARK: - Constants

    private static let imperialTempFactor: Float = 9.0 / 5.0
    private static let imperialTempOffset: Float = 32.0
    private static let pressureKpaToInHg: Float = 3.38600
    private static let pressurePaToInHg: Float = 3386.0
    private static let kmhToMphFactor: Float = 0.621371
    private static let gramsToLbsFactor: Float = 0.132 // 132/1000
    private static let kmToMilesFactor: Float = 0.6213

    // MARK: - Calculation Functions

    public static func calcInt(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        return Float(data[0])
    }

    public static func calcTime(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Int16(data[0])
        let dataB = Int16(data[1])
        let result = (dataA * 256) + dataB
        return Float(result)
    }

    public static func calcTimingAdvance(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        let dataA = Float(data[0])
        return (dataA / 2) - 64
    }

    public static func calcDistance(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Int16(data[0])
        let dataB = Int16(data[1])
        let result = (dataA * 256) + dataB
        return Float(result)
    }

    public static func calcPercentage(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        return (Float(data[0]) * 100) / 255
    }

    public static func calcAbsoluteLoadValue(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) * 100) / 255
    }

    public static func calcTemp(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        let temp = Float(data[0])
        return temp - 40
    }

    public static func calcCatalystTemp(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) / 10) - 40
    }

    public static func calcFuelTrimPercentage(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        let value = Float(data[0])
        return (0.7812 * (value - 128))
    }

    public static func calcFuelTrimPercentage2(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let value = Float(data[1])
        return (0.7812 * (value - 128))
    }

    public static func calcEngineRPM(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) / 4)
    }

    public static func calcOxygenSensorVoltage(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        let dataA = Float(data[0])
        return (dataA * 0.005)
    }

    public static func calcControlModuleVoltage(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) / 1000)
    }

    public static func calcMassAirFlow(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) / 100)
    }

    public static func calcPressure(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) * 0.079)
    }

    public static func calcPressureDiesel(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) * 10)
    }

    public static func calcVaporPressure(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return ((((dataA * 256) + dataB) / 4) - 8192)
    }

    public static func calcEquivalenceRatio(data: Data) -> Float {
        guard data.count >= 2 else { return 0 }
        let dataA = Float(data[0])
        let dataB = Float(data[1])
        return (((dataA * 256) + dataB) * 0.0000305)
    }

    public static func calcEquivalenceVoltage(data: Data) -> Float {
        guard data.count >= 4 else { return 0 }
        let dataC = Float(data[2])
        let dataD = Float(data[3])
        return (((dataC * 256) + dataD) * 0.000122)
    }

    public static func calcEquivalenceCurrent(data: Data) -> Float {
        guard data.count >= 4 else { return 0 }
        let dataC = Float(data[2])
        let dataD = Float(data[3])
        return (((dataC * 256) + dataD) * 0.00390625) - 128
    }

    public static func calcEGRError(data: Data) -> Float {
        guard !data.isEmpty else { return 0 }
        let dataA = Float(data[0])
        return ((dataA * 0.78125) - 100)
    }

    public static func calcInstantMPG(vss: Double, maf: Double) -> Double {
        var _vss = vss
        var _maf = maf

        if _vss > 255 { _vss = 255 }
        if _vss < 0 { _vss = 0 }
        if _maf <= 0 { _maf = 0.1 }

        let mph = _vss * Double(kmhToMphFactor)
        return ((14.7 * 6.17 * 454 * mph) / (3600 * _maf))
    }

    public static func calcMILActive(data: [UInt8]) -> Bool {
        guard !data.isEmpty else { return false }
        let dataA = data[0]
        return (dataA & 0x80) != 0
    }

    // MARK: - Conversion Functions

    public static func convertTemp(value: Float) -> Float {
        return (value * imperialTempFactor) + imperialTempOffset
    }

    public static func convertPressure(value: Float) -> Float {
        return value / pressureKpaToInHg
    }

    public static func convertPressure2(value: Float) -> Float {
        return value / pressurePaToInHg
    }

    public static func convertSpeed(value: Float) -> Float {
        return value * kmhToMphFactor
    }

    public static func convertAir(value: Float) -> Float {
        return value * gramsToLbsFactor
    }

    public static func convertDistance(value: Float) -> Float {
        return value * kmToMilesFactor
    }
}
