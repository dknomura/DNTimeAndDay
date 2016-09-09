//
//  DNTimeAndDay.swift
//  Pods
//
//  Created by Daniel Nomura on 9/7/16.
//
//

//: Playground - noun: a place where people can play
//
//
//  DNTimeAndDay.swift
//  Pods
//
//  Created by Daniel Nomura on 9/7/16.



import Foundation

public enum DNTimeAndDayError: ErrorType {
    case invalidMinuteInterval(Int?)
}
public enum DNTimeFormat : Int {
    case format24Hour = 0
    case format12Hour
}

public struct DNTimeAndDay {
    public var day: DNDay
    public var time: DNTime
    public var minuteInterval: Int?
    
    public enum DNDay: Int {
        case Sun = 1, Mon, Tues, Wed, Thurs, Fri, Sat
        public var stringValue: String {
            switch self {
            case .Sun: return "Sun"
            case .Mon: return "Mon"
            case .Tues: return "Tues"
            case .Wed: return "Wed"
            case .Thurs: return "Thurs"
            case .Fri: return "Fri"
            case .Sat: return "Sat"
            }
        }
        static let allValues: [DNDay] = [Sun, Mon, Tues, Wed, Thurs, Fri, Sat]
        enum DayError: ErrorType {
            case invalidString(String)
        }
        public mutating func increaseDay() {
            var dayInt = self.rawValue
            if dayInt == 7 {
                dayInt = 1
            } else {
                dayInt += 1
            }
            self = DNDay.init(rawValue: dayInt)!
        }
        public mutating func decreaseDay() {
            var dayInt = self.rawValue
            if dayInt == 1 {
                dayInt = 7
            } else {
                dayInt -= 1
            }
            self = DNDay.init(rawValue: dayInt)!
        }
        public init?(stringValue:String) {
            let lowerCase = stringValue.lowercaseString
            let rawValue: Int
            switch lowerCase {
            case "su", "sun", "sund", "sunda", "sunday", "7":
                rawValue = 1
            case "m", "mo", "mon", "mond", "monda", "monday", "1":
                rawValue = 2
            case "t", "tu", "tue", "tues", "tuesday", "2":
                rawValue = 3
            case "w", "we", "wed", "wedn", "wedne",  "wednes", "wednesday", "3":
                rawValue = 4
            case "th", "thu", "thur", "thurs", "thursday", "4":
                rawValue = 5
            case "f", "fr", "fri", "frid", "friday", "5":
                rawValue = 6
            case "s", "sa", "sat", "satu", "satur", "saturday", "6":
                rawValue = 7
            default:
                return nil
            }
            self.init(rawValue: rawValue)
        }
    }
    public struct DNTime {
        enum DNAmPm: String{
            case am, pm, format24
            
        }
        var hour: Int
        var min: Int
        
        init?(hour: Int, min:Int) {
            if (hour >= 0 && hour < 24) && (min >= 0 && min < 60) {
                self.hour = hour
                self.min = min
            } else {
                print("Hour, \(hour), and min, \(min), are not valid, should be between 0-23 and 0-60 respectively")
                return nil
            }
        }
        public init?(userInputValue timeString:String) {
            let lowerCaseStringValue = timeString.lowercaseString
            let periodRange = lowerCaseStringValue.rangeOfString(".")
            let colonRange = lowerCaseStringValue.rangeOfString(":")
            let pRange = lowerCaseStringValue.rangeOfString("p")
            let aRange = lowerCaseStringValue.rangeOfString("a")
            var amOrPM: DNAmPm?
            var hour, min:Int?
            // If minute value exists, then there is either '.' or ':'. The minute value will be multipled by the minute scale and if '.' the minute will need to be multiplied by 0.6
            var minuteScale: Double = 1.0
            // If there is no delimiter ('.' or ':') then we will only have an hour value, which will be to the endIndex of the string
            var delimiterStartIndex = lowerCaseStringValue.endIndex
            var delimiterEndIndex = lowerCaseStringValue.endIndex
            // Similarly, if there is no 'a' or 'p', then the minute value will be to the endIndex of the string
            var apIndex = lowerCaseStringValue.endIndex
            if aRange != nil {
                apIndex = aRange!.startIndex
                amOrPM = .am
            } else if pRange != nil {
                apIndex = pRange!.startIndex
                amOrPM = .pm
            }
            if periodRange != nil {
                if colonRange != nil {
                    print("Colon and period both present in \(lowerCaseStringValue)")
                    return nil
                }
                delimiterStartIndex = periodRange!.startIndex
                delimiterEndIndex = periodRange!.endIndex
                if delimiterEndIndex.distanceTo(apIndex) == 2 {
                    minuteScale = 0.6
                } else if delimiterEndIndex.distanceTo(apIndex) == 1 {
                    minuteScale = 6
                }
                
            } else if colonRange != nil {
                delimiterStartIndex = colonRange!.startIndex
                delimiterEndIndex = colonRange!.endIndex
            } else {
                if amOrPM != nil {
                    delimiterStartIndex = apIndex
                    delimiterEndIndex = apIndex
                }
            }
            hour = Int(lowerCaseStringValue.substringWithRange(lowerCaseStringValue.startIndex..<delimiterStartIndex))
            if delimiterEndIndex < apIndex {
                let tempMinString = lowerCaseStringValue.substringWithRange(delimiterEndIndex..<apIndex)
                if let tempMin = Double(tempMinString) {
                    min = Int(tempMin * minuteScale)
                } else {
                    print("Substring \(tempMinString) from \(delimiterStartIndex) to \(apIndex) in String: \(lowerCaseStringValue), is not a number")
                    return nil
                }
            } else {
                min = 0
            }
            DNTime.adjustHourInput(&hour, amOrPM: amOrPM)
            guard min != nil && hour != nil else {
                print("No hour and/or min in \(lowerCaseStringValue). hour: \(hour) min: \(min)")
                return nil
            }
            self.init(hour:hour!, min: min!)
        }
        public func stringValue(forFormat format:DNTimeFormat) -> String {
            let minString: String
            let hourString: String
            var hour = self.hour
            var amPM = ""
            if format == DNTimeFormat.format12Hour {
                if hour == 0 {
                    hour = 12
                    amPM = "am"
                } else if hour < 12 {
                    amPM = "am"
                } else if hour == 12 {
                    amPM = "pm"
                }else if hour > 12 && hour < 24 {
                    hour -= 12
                    amPM = "pm"
                }
                hourString = String(hour)
            } else {
                if hour < 10 {
                    hourString = "0" + String(hour)
                } else {
                    hourString = String(hour)
                }
            }
            if self.min < 10 {
                minString = "0" + String(self.min)
            } else {
                minString = String(self.min)
            }
            return hourString + ":" + minString + amPM
        }
        mutating func increase(byMinuteInterval minuteInterval:Int) throws {
            guard minuteInterval > 0 else { throw DNTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            var setTime: DNTime = self
            setTime.hour += Int(minuteInterval / 60)
            let remainingMinutes = minuteInterval % 60
            if remainingMinutes > 0 {
                guard 60 % remainingMinutes == 0 else { throw DNTimeAndDayError.invalidMinuteInterval(minuteInterval) }
                let loops: Int = (60 / remainingMinutes) - 1
                if setTime.min >= (remainingMinutes * loops) {
                    setTime.min = 0
                    setTime.hour += 1
                } else {
                    for i in 1...loops {
                        if setTime.min < remainingMinutes * i {
                            setTime.min = remainingMinutes * i
                            break
                        }
                    }
                }
            } else if remainingMinutes == 0 {
                setTime.min = 0
            }
            
            self.hour = setTime.hour
            self.min = setTime.min
        }
        mutating func decrease(byMinuteInterval minuteInterval:Int) throws {
            guard minuteInterval > 0 else { throw DNTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            var setTime: DNTime = self
            setTime.hour += Int(minuteInterval / 60)
            let remainingMinutes = minuteInterval % 60
            if remainingMinutes > 0 {
                guard 60 % remainingMinutes == 0 else { throw DNTimeAndDayError.invalidMinuteInterval(minuteInterval) }
                let loops: Int = (60 / remainingMinutes) - 1
                if setTime.min == 0 {
                    setTime.min = remainingMinutes * loops
                    setTime.hour -= 1
                } else {
                    for i in loops.stride(through: 0, by: -1) {
                        if setTime.min > remainingMinutes * i {
                            setTime.min = remainingMinutes * i
                            break
                        }
                    }
                }
            }
            self.hour = setTime.hour
            self.min = setTime.min
        }
        static private func adjustHourInput(inout hour:Int?, amOrPM:DNAmPm?) {
            guard hour != nil else { return }
            var upperBound, lowerBound:Int
            if amOrPM != nil {
                upperBound = 12
                lowerBound = 1
            } else {
                upperBound = 23
                lowerBound = 0
            }
            if hour < lowerBound || hour > upperBound {
                print("Hour \(hour), is not valid, not in between \(lowerBound) and \(upperBound). AM/PM: \(amOrPM)")
                hour = nil
            }
            if amOrPM != nil {
                if amOrPM == .am {
                    if hour == 12 {
                        hour = 0
                    }
                } else if amOrPM == .pm {
                    if hour < 12 {
                        hour = 12 + hour!
                    }
                }
            }
        }
    }
    
    public mutating func increaseTimeInterval() throws {
        try changeTime(increase: true)
    }
    public mutating func decreaseTimeInterval() throws {
        try changeTime(increase: false)
    }
    private mutating func changeTime(increase increase:Bool) throws {
        guard minuteInterval != nil else {
            print("Unable to change time, property minute interval not set")
            throw DNTimeAndDayError.invalidMinuteInterval(minuteInterval)
        }
        increase ? try time.increase(byMinuteInterval: minuteInterval!) : try time.decrease(byMinuteInterval: minuteInterval!)
        if time.hour > 23 {
            let dayCounter = Int(time.hour / 24)
            time.hour = time.hour % 24
            for _ in 0..<dayCounter { increase ? day.increaseDay() : day.decreaseDay() }
        }
    }
    func nextStreetCleaningTimeAndDay() -> DNTimeAndDay {
        var returnTimeAndDay = self
        if returnTimeAndDay.time.hour < 15 && returnTimeAndDay.time.hour > 2 {
            if returnTimeAndDay.time.hour == 14 && returnTimeAndDay.time.min == 30 {
                returnTimeAndDay.time.hour = 19
                returnTimeAndDay.time.min = 0
            }
        } else if returnTimeAndDay.time.hour < 19 {
            returnTimeAndDay.time.hour = 19
            returnTimeAndDay.time.min = 0
        } else if returnTimeAndDay.time.hour == 19 && returnTimeAndDay.time.min == 0 {
        } else {
            returnTimeAndDay.time.hour = 3
            returnTimeAndDay.time.min = 0
            returnTimeAndDay.day.increaseDay()
        }
        if returnTimeAndDay.day.rawValue == 1 {
            returnTimeAndDay.day.increaseDay()
        }
        return DNTimeAndDay.init(day: returnTimeAndDay.day, time: returnTimeAndDay.time)
    }
    
    func previousStreetCleaningTimeAndDay() -> DNTimeAndDay {
        var returnTimeAndDay = self
        if returnTimeAndDay.time.hour > 19 && (returnTimeAndDay.day.rawValue != 1 || returnTimeAndDay.day.rawValue != 7) {
            returnTimeAndDay.time.hour = 19
            returnTimeAndDay.time.min = 0
        } else if returnTimeAndDay.time.hour > 14 || (returnTimeAndDay.time.hour == 14 && returnTimeAndDay.time.min == 30) {
            returnTimeAndDay.time.hour = 14
            returnTimeAndDay.time.min = 0
        } else if returnTimeAndDay.time.hour < 3 {
            returnTimeAndDay.day.decreaseDay()
            if returnTimeAndDay.day.rawValue == 7 {
                returnTimeAndDay.time.hour = 13
                returnTimeAndDay.time.min = 0
            } else {
                returnTimeAndDay.time.hour = 19
                returnTimeAndDay.time.min = 0
            }
        }
        if returnTimeAndDay.day.rawValue == 1 {
            returnTimeAndDay.day.decreaseDay()
            returnTimeAndDay.time.hour = 13
            returnTimeAndDay.time.min = 0
        }
        return DNTimeAndDay.init(day: returnTimeAndDay.day, time: returnTimeAndDay.time)
    }
}
public extension DNTimeAndDay {
    public init(day: DNDay, time: DNTime) {
        self.init(day: day, time: time, minuteInterval: nil)
    }
    public init?(dayString:String, timeString:String) {
        guard let initDay = DNDay.init(stringValue: dayString) else {
            print("Unable to make day out of string: \(dayString)")
            return nil
        }
        guard let initTime = DNTime.init(userInputValue: timeString) else {
            print("Unable to make time out of string: \(timeString)")
            return nil
        }
        self.init(day:initDay, time: initTime)
    }
    public init?(dayInt:Int, hourInt:Int, minInt:Int) {
        guard let initDay = DNDay.init(rawValue: dayInt) else {
            print("Unable to make day out of int: \(dayInt)")
            return nil
        }
        guard let initTime = DNTime.init(hour: hourInt, min: minInt) else {
            print("Unable to make time out of hour: \(hourInt), and min: \(minInt)")
            return nil
        }
        self.init(day:initDay, time: initTime)
    }
    public static func currentTimeAndDay() -> DNTimeAndDay {
        let date = NSDate()
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let hour = calendar.component(.Hour, fromDate: date)
            let minute = calendar.component(.Minute, fromDate: date)
            let day = calendar.component(.Weekday, fromDate: date)
            return DNTimeAndDay.init(dayInt: day, hourInt: hour, minInt: minute)!
        } else {
            print("Unable initialize Gregorian calendar to get current day, hour, and/or minutes")
            return DNTimeAndDay.init(dayInt: 2, hourInt: 12, minInt: 0)!
        }
    }
}