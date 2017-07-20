//
//  CEMKit+CGFloat.swift
//
//
//  Created by Cem Olcay on 12/08/15.
//
//

import UIKit

extension CGFloat {
    /// EZSE: Return the central value of CGFloat.
    public var center: CGFloat { return (self / 2) }

    /// EZSwiftExtensions
    public func toRadians() -> CGFloat {
        return (CGFloat (Double.pi) * self) / 180.0
    }

    /// EZSwiftExtensions
    public func degreesToRadians() -> CGFloat {
        return toRadians()
    }

    /// EZSwiftExtensions
    public mutating func toRadiansInPlace() {
        self = (CGFloat (Double.pi) * self) / 180.0
    }

    /// EZSE: Converts angle degrees to radians.
    public func degreesToRadians (_ angle: CGFloat) -> CGFloat {
        return (CGFloat (Double.pi) * angle) / 180.0
    }
}
