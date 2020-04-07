//
//  ImageStorage.swift
//  Moments
//
//  Created by zhangchenglong01 on 2020/4/1.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation

struct TimeConstants {
    static let secondsInOneMinute = 60
    static let minutesInOneHour = 60
    static let hoursInOneDay = 24
    static let secondsInOneDay = 86_400
}

/// Represents the expiration strategy used in storage.
public enum StorageExpiration {
    case never
    case seconds(TimeInterval)
    case days(Int)
    case date(Date)
    case expired

    func estimatedExpirationSince(_ date: Date) -> Date {
        switch self {
        case .never: return .distantFuture
        case .seconds(let seconds):
            return date.addingTimeInterval(seconds)
        case .days(let days):
            let duration = TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
            return date.addingTimeInterval(duration)
        case .date(let ref):
            return ref
        case .expired:
            return .distantPast
        }
    }
    
    var estimatedExpirationSinceNow: Date {
        return estimatedExpirationSince(Date())
    }
    
    var isExpired: Bool {
        return timeInterval <= 0
    }

    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let seconds): return seconds
        case .days(let days): return TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
        case .date(let ref): return ref.timeIntervalSinceNow
        case .expired: return -(.infinity)
        }
    }
}

/// Represents the expiration extending strategy used in storage to after access.
public enum ExpirationExtending {
    case none
    case cacheTime
    case expirationTime(_ expiration: StorageExpiration)
}

/// Represents types which cost in memory can be calculated.
public protocol CacheCostCalculable {
    var cacheCost: Int { get }
}

public protocol Storageable {
    
}

/// Represents types which can be converted to and from data.
public protocol DataTransformable {
    func toData() throws -> Data
    static func fromData(_ data: Data) throws -> Self
    static var empty: Self { get }
}
