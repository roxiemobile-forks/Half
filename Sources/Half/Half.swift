//
//  Half.swift
//  Half
//
//  Copyright © 2020 SomeRandomiOSDev. All rights reserved.
//

#if SWIFT_PACKAGE
import CHalf
#endif
import Foundation

#if canImport(CoreGraphics)
import CoreGraphics.CGBase
#endif // #if canImport(CoreGraphics)

// MARK: - Half Definition

@frozen public struct Half {

    // MARK: Public Properties

    public var _value: half_t

    // MARK: Initialization

    @_transparent
    public init() {
        self._value = _half_zero()
    }

    @_transparent
    public init(_ _value: half_t) {
        self._value = _value
    }
}

// MARK: - Half Extension

extension Half {

    @inlinable
    public var bitPattern: UInt16 {
        return _half_to_raw(_value)
    }

    @inlinable
    public init(bitPattern: UInt16) {
        self._value = _half_from_raw(bitPattern)
    }

    @inlinable
    public init(nan payload: UInt16, signaling: Bool) {
        precondition(payload < (Half.quietNaNMask &>> 1), "NaN payload is not encodable.")

        var significand = payload
        significand |= Half.quietNaNMask &>> (signaling ? 1 : 0)

        self.init(sign: .plus, exponentBitPattern: Half.infinityExponent, significandBitPattern: significand)
    }
}

// MARK: - CustomStringConvertible Protocol Conformance

extension Half: CustomStringConvertible {

    public var description: String {
        if isNaN {
            return "nan"
        }

        return _half_to_float(_value).description
    }
}

// MARK: - CustomStringConvertible Protocol Conformance

extension Half: CustomDebugStringConvertible {

    public var debugDescription: String {
        return _half_to_float(_value).description
    }
}

// MARK: - TextOutputStreamable Protocol Conformance

extension Half: TextOutputStreamable {

    public func write<Target>(to target: inout Target) where Target: TextOutputStream {
        _half_to_float(_value).write(to: &target)
    }
}

// MARK: - Internal Constants

extension Half {

    @inlinable @inline(__always)
    internal static var significandMask: UInt16 {
        1 &<< UInt16(significandBitCount) - 1
    }

    @inlinable @inline(__always)
    internal static var infinityExponent: UInt {
        1 &<< UInt(exponentBitCount) - 1
    }

    @inlinable @inline(__always)
    internal static var exponentBias: UInt {
        infinityExponent &>> 1
    }

    @inlinable @inline(__always)
    internal static var quietNaNMask: UInt16 {
        1 &<< UInt16(significandBitCount - 1)
    }
}

// MARK: - BinaryFloatingPoint Protocol Conformance

extension Half: BinaryFloatingPoint {

    @inlinable
    public static var exponentBitCount: Int {
        return 5
    }

    @inlinable
    public static var significandBitCount: Int {
        return 10
    }

    @inlinable
    public var exponentBitPattern: UInt {
        return UInt(bitPattern &>> UInt16(Half.significandBitCount)) & Half.infinityExponent
    }

    @inlinable
    public var significandBitPattern: UInt16 {
        return bitPattern & Half.significandMask
    }

    //

    @inlinable
    public init(sign: FloatingPointSign, exponentBitPattern: UInt, significandBitPattern: UInt16) {
        let signBits: UInt16 = (sign == .minus ? 1 : 0) &<< (Half.exponentBitCount + Half.significandBitCount)
        let exponentBits = UInt16((exponentBitPattern & Half.infinityExponent) &<< Half.significandBitCount)
        let significandBits = significandBitPattern & Half.significandMask

        self.init(bitPattern: signBits | exponentBits | significandBits)
    }

    @inlinable @inline(__always)
    public init(_ other: Float) {
        if other.isInfinite {
            let infinity = Half.infinity
            self = Half(sign: other.sign, exponentBitPattern: infinity.exponentBitPattern, significandBitPattern: infinity.significandBitPattern)
        } else if other.isNaN {
            if other.isSignalingNaN {
                self = .signalingNaN
            } else {
                self = .nan
            }
        } else {
            _value = _half_from(other)
        }
    }

    @inlinable @inline(__always)
    public init(_ other: Double) {
        if other.isInfinite {
            let infinity = Half.infinity
            self = Half(sign: other.sign, exponentBitPattern: infinity.exponentBitPattern, significandBitPattern: infinity.significandBitPattern)
        } else if other.isNaN {
            if other.isSignalingNaN {
                self = .signalingNaN
            } else {
                self = .nan
            }
        } else {
            _value = _half_from(other)
        }
    }

#if !(os(Windows) || os(Android)) && (arch(i386) || arch(x86_64))
    @inlinable @inline(__always)
    public init(_ other: Float80) {
        if other.isInfinite {
            let infinity = Half.infinity
            self = Half(sign: other.sign, exponentBitPattern: infinity.exponentBitPattern, significandBitPattern: infinity.significandBitPattern)
        } else if other.isNaN {
            if other.isSignalingNaN {
                self = .signalingNaN
            } else {
                self = .nan
            }
        } else {
            _value = _half_from(Double(other))
        }
    }
#endif

#if canImport(CoreGraphics)
    // Not part of the protocol
    @inlinable @inline(__always)
    public init(_ other: CGFloat) {
        self.init(other.native)
    }
#endif // #if canImport(CoreGraphics)

    @inlinable @inline(__always)
    public init<Source>(_ value: Source) where Source: BinaryFloatingPoint {
        self.init(Float(value))
    }

    @inlinable
    public init?<Source>(exactly value: Source) where Source: BinaryFloatingPoint {
        self.init(value)

        if isInfinite || value.isInfinite {
            if value.isInfinite && (!isInfinite || sign != value.sign) {
                // If source is infinite but this isn't or this is but with a different sign
                return nil
            } else if isInfinite && !value.isInfinite {
                // If source isn't infinite but this is
                return nil
            }
        } else if isNaN || value.isNaN {
            if value.isNaN && (!isNaN || isSignalingNaN != value.isSignalingNaN) {
                // If source is NaN but this isn't or this is but one is signaling while the other isn't
                return nil
            } else if isNaN && !value.isNaN {
                // If source isn't NaN but this is
                return nil
            }
        } else if Source(self) != value {
            // If casting half back to source isn't equal to original source
            return nil
        }
    }

    //

    @inlinable
    public var binade: Half {
        guard isFinite else { return .nan }

        #if !arch(arm)
        if isSubnormal {
            let bitPattern = (self * 0x1p10).bitPattern & (-Half.infinity).bitPattern
            return Half(bitPattern: bitPattern) * .ulpOfOne
        }
        #endif

        return Half(bitPattern: bitPattern & (-Half.infinity).bitPattern)
    }

    @inlinable
    public var significandWidth: Int {
        let trailingZeroBits = significandBitPattern.trailingZeroBitCount
        if isNormal {
            guard significandBitPattern != 0 else { return 0 }
            return Half.significandBitCount &- trailingZeroBits
        }
        if isSubnormal {
            let leadingZeroBits = significandBitPattern.leadingZeroBitCount
            return UInt16.bitWidth &- (trailingZeroBits &+ leadingZeroBits &+ 1)
        }
        return -1
    }
}

// MARK: - ExpressibleByFloatLiteral Protocol Conformance

extension Half: ExpressibleByFloatLiteral {

    @_transparent
    public init(floatLiteral value: Float) {
        self.init(value)
    }
}

// MARK: - FloatingPoint Protocol Conformance

extension Half: FloatingPoint {

    @inlinable
    public init(sign: FloatingPointSign, exponent: Int, significand: Half) {
        var result = significand
        if sign == .minus { result = -result }

        if significand.isFinite && !significand.isZero {
            var clamped = exponent
            let leastNormalExponent = 1 - Int(Half.exponentBias)
            let greatestFiniteExponent = Int(Half.exponentBias)

            if clamped < leastNormalExponent {
                clamped = max(clamped, 3 * leastNormalExponent)

                while clamped < leastNormalExponent {
                    result *= Half.leastNormalMagnitude
                    clamped -= leastNormalExponent
                }
            } else if clamped > greatestFiniteExponent {
                let step = Half(sign: .plus, exponentBitPattern: Half.infinityExponent - 1, significandBitPattern: 0)
                clamped = min(clamped, 3 * greatestFiniteExponent)

                while clamped > greatestFiniteExponent {
                    result *= step
                    clamped -= greatestFiniteExponent
                }
            }

            let scale = Half(sign: .plus, exponentBitPattern: UInt(Int(Half.exponentBias) + clamped), significandBitPattern: 0)
            result *= scale
        }

        self = result
    }

    @_transparent
    public init(_ value: Int) {
        _value = _half_from(value)
    }

    @inlinable @inline(__always)
    public init<Source: BinaryInteger>(_ value: Source) {
        if value.bitWidth <= MemoryLayout<Int>.size * 8 {
            if Source.isSigned {
                let asInt = Int(truncatingIfNeeded: value)
                self.init(_half_from(asInt))
            } else {
                let asUInt = UInt(truncatingIfNeeded: value)
                self.init(_half_from(asUInt))
            }
        } else {
            self.init(Float(value))
        }
    }

    //

    @inlinable
    public var exponent: Int {
        if !isFinite { return .max }
        if isZero { return .min }

        let provisional = Int(exponentBitPattern) - Int(Half.exponentBias)
        if isNormal { return provisional }

        let shift = Half.significandBitCount - significandBitPattern._binaryLogarithm()
        return provisional + 1 - shift
    }

    @inlinable
    public var isCanonical: Bool {
        #if arch(arm)
        if exponentBitPattern == 0 && significandBitPattern != 0 {
            return false
        }
        #endif

        return true
    }

    @inlinable @inline(__always)
    public var isFinite: Bool {
        exponentBitPattern < Half.infinityExponent
    }

    @inlinable @inline(__always)
    public var isInfinite: Bool {
        !isFinite && significandBitPattern == 0
    }

    @inlinable @inline(__always)
    public var isNaN: Bool {
        !isFinite && significandBitPattern != 0
    }

    @inlinable @inline(__always)
    public var isNormal: Bool {
        exponentBitPattern > 0 && isFinite
    }

    @inlinable @inline(__always)
    public var isSignalingNaN: Bool {
        isNaN && (significandBitPattern & Half.quietNaNMask) == 0
    }

    @inlinable @inline(__always)
    public var isSubnormal: Bool {
        exponentBitPattern == 0 && significandBitPattern != 0
    }

    @inlinable @inline(__always)
    public var isZero: Bool {
        exponentBitPattern == 0 && significandBitPattern == 0
    }

    @inlinable
    public var nextUp: Half {
        let next = self + 0

        #if arch(arm)
        // On arm, treat subnormal values as zero.
        if next == 0 { return .leastNonzeroMagnitude }
        if next == -.leastNonzeroMagnitude { return -0.0 }
        #endif

        if next < .infinity {
            let increment = Int16(bitPattern: next.bitPattern) &>> 15 | 1
            let bitPattern = next.bitPattern &+ UInt16(bitPattern: increment)
            return Half(bitPattern: bitPattern)
        }

        return next
    }

    @inlinable
    public var sign: FloatingPointSign {
        let shift = Half.significandBitCount + Half.exponentBitCount
        //swiftlint:disable force_unwrapping
        return FloatingPointSign(rawValue: Int(bitPattern &>> UInt16(shift)))!
        //swiftlint:enable force_unwrapping
    }

    @inlinable
    public var significand: Half {
        if isNaN { return self }
        if isNormal {
            return Half(sign: .plus, exponentBitPattern: Half.exponentBias, significandBitPattern: significandBitPattern)
        }

        if isSubnormal {
            let shift = Half.significandBitCount - significandBitPattern._binaryLogarithm()
            return Half(sign: .plus, exponentBitPattern: Half.exponentBias, significandBitPattern: significandBitPattern &<< shift)
        }

        return Half(sign: .plus, exponentBitPattern: exponentBitPattern, significandBitPattern: 0)
    }

    @inlinable
    public var ulp: Half {
        guard isFinite else { return .nan }
        if isNormal {
            let bitPattern = self.bitPattern & Half.infinity.bitPattern
            return Half(bitPattern: bitPattern) * .ulpOfOne
        }

        return .leastNormalMagnitude * .ulpOfOne
    }

    //

    @inlinable
    public static var greatestFiniteMagnitude: Half {
        return Half(bitPattern: 0x7BFF)
    }

    @inlinable
    public static var infinity: Half {
        return Half(bitPattern: 0x7C00)
    }

    @inlinable
    public static var leastNonzeroMagnitude: Half {
        #if arch(arm)
        return leastNormalMagnitude
        #else
        return Half(sign: .plus, exponentBitPattern: 0, significandBitPattern: 1)
        #endif
    }

    @inlinable
    public static var leastNormalMagnitude: Half {
        return Half(sign: .plus, exponentBitPattern: 1, significandBitPattern: 0)
    }

    @inlinable
    public static var nan: Half {
        return Half(_half_nan())
    }

    @inlinable
    public static var pi: Half {
        return Half(_half_pi())
    }

    @inlinable
    public static var signalingNaN: Half {
        return Half(nan: 0, signaling: true)
    }

    @inlinable
    public static var ulpOfOne: Half {
        return Half(_half_epsilon())
    }

    //

    @_transparent
    public mutating func addProduct(_ lhs: Half, _ rhs: Half) {
        _value = _half_fma(_value, lhs._value, rhs._value)
    }

    @inlinable @inline(__always)
    public mutating func formRemainder(dividingBy other: Half) {
        self = Half(Float(self).remainder(dividingBy: Float(other)))
    }

    @_transparent
    public mutating func formSquareRoot() {
        _value = _half_sqrt(_value)
    }

    @inlinable @inline(__always)
    public mutating func formTruncatingRemainder(dividingBy other: Half) {
        self = Half(Float(self).truncatingRemainder(dividingBy: Float(other)))
    }

    @_transparent
    public func isEqual(to other: Half) -> Bool {
        return Bool(_half_equal(self._value, other._value))
    }

    @_transparent
    public func isLess(than other: Half) -> Bool {
        return Bool(_half_lt(self._value, other._value))
    }

    @_transparent
    public func isLessThanOrEqualTo(_ other: Half) -> Bool {
        return Bool(_half_lte(self._value, other._value))
    }

    @_transparent
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        self = Half(Float(self).rounded(rule))
    }

    //

    @_transparent
    public static func / (lhs: Half, rhs: Half) -> Half {
        return Half(_half_div(lhs._value, rhs._value))
    }

    @_transparent
    public static func /= (lhs: inout Half, rhs: Half) {
        lhs._value = _half_div(lhs._value, rhs._value)
    }
}

// MARK: - Hashable Protocol Conformance

extension Half: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        var value = self
        if isZero {
            value = 0 // to reconcile -0.0 and +0.0
        }

        hasher.combine(value.bitPattern)
    }
}

// MARK: - Strideable Protocol Conformance

extension Half: Strideable {

    @_transparent
    public func distance(to other: Half) -> Half {
        return other - self
    }

    @_transparent
    public func advanced(by amount: Half) -> Half {
        return self + amount
    }
}

// MARK: - SignedNumeric Protocol Conformance

extension Half: SignedNumeric {

    @_transparent
    public mutating func negate() {
        _value = _half_neg(_value)
    }

    @_transparent
    public static prefix func - (value: Half) -> Half {
        return Half(_half_neg(value._value))
    }
}

// MARK: - Numeric Protocol Conformance

extension Half: Numeric {

    @inlinable @inline(__always)
    public var magnitude: Half {
        Half(_half_abs(_value))
    }

    @inlinable @inline(__always)
    public init?<Source>(exactly value: Source) where Source: BinaryInteger {
        self.init(value)

        if isInfinite || isNaN || Source(self) != value {
            return nil
        }
    }

    @_transparent
    public static func * (lhs: Half, rhs: Half) -> Half {
        return Half(_half_mul(lhs._value, rhs._value))
    }

    @_transparent
    public static func *= (lhs: inout Half, rhs: Half) {
        lhs._value = _half_mul(lhs._value, rhs._value)
    }
}

// MARK: - ExpressibleByIntegerLiteral Protocol Conformance

extension Half: ExpressibleByIntegerLiteral {

    @_transparent
    public init(integerLiteral value: Int64) {
        self = Half(value)
    }
}

// MARK: - AdditiveArithmetic Protocol Conformance

extension Half: AdditiveArithmetic {

    @_transparent
    public static func + (lhs: Half, rhs: Half) -> Half {
        return Half(_half_add(lhs._value, rhs._value))
    }

    @_transparent
    public static func += (lhs: inout Half, rhs: Half) {
        lhs._value = _half_add(lhs._value, rhs._value)
    }

    @_transparent
    public static func - (lhs: Half, rhs: Half) -> Half {
        return Half(_half_sub(lhs._value, rhs._value))
    }

    @_transparent
    public static func -= (lhs: inout Half, rhs: Half) {
        lhs._value = _half_sub(lhs._value, rhs._value)
    }
}

extension Half: CustomReflectable {

    @_transparent
    public var customMirror: Mirror {
        Mirror(reflecting: Float(self))
    }
}

extension Half: CustomPlaygroundDisplayConvertible {

    @_transparent
    public var playgroundDescription: Any {
        return Float(self)
    }
}
