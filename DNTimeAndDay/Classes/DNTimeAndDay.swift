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


enum SPTimeAndDayError: ErrorType {
    case invalidMinuteInterval(Int)
}
struct SPTimeAndDay {
    var dayOfWeek: SPDay
    var time: SPTime
    
    enum SPTimeFormat : Int {
        case format24Hour = 0
        case format12Hour
    }
    enum SPDay: Int{
        case Sun = 1, Mon, Tues, Wed, Thurs, Fri, Sat
        var stringValue: String {
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
        static let allValues: [SPDay] = [Sun, Mon, Tues, Wed, Thurs, Fri, Sat]
        enum DayError: ErrorType {
            case invalidString(String)
        }
        mutating func increaseDay() {
            var dayInt = self.rawValue
            if dayInt == 7 {
                dayInt = 1
            } else {
                dayInt += 1
            }
            self = SPDay.init(rawValue: dayInt)!
        }
        mutating func decreaseDay() {
            var dayInt = self.rawValue
            if dayInt == 1 {
                dayInt = 7
            } else {
                dayInt -= 1
            }
            self = SPDay.init(rawValue: dayInt)!
        }
        init?(stringValue:String) {
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
    struct SPTime {
        enum SPAmPm: String{
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
        
        func stringValue(format:SPTimeFormat) -> String {
            let minString: String
            let hourString: String
            var hour = self.hour
            var amPM = ""
            if format == SPTimeFormat.format12Hour {
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
        
        mutating func increaseTimeInterval(minuteInterval:Int) throws {
            guard minuteInterval > 0 else { throw SPTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            var setTime: SPTime = self
            setTime.hour += Int(minuteInterval / 60)
            let remainingMinutes = minuteInterval % 60
            guard 60 % remainingMinutes == 0 else { throw SPTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            if remainingMinutes > 0 {
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
            }
            
            self.hour = setTime.hour
            self.min = setTime.min
        }
        mutating func decreaseTimeInterval(minuteInterval:Int) throws {
            guard minuteInterval > 0 else { throw SPTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            var setTime: SPTime = self
            setTime.hour += Int(minuteInterval / 60)
            let remainingMinutes = minuteInterval % 60
            guard 60 % remainingMinutes == 0 else { throw SPTimeAndDayError.invalidMinuteInterval(minuteInterval) }
            if remainingMinutes > 0 {
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
        
        init?(userInputValue timeString:String) {
            let lowerCaseStringValue = timeString.lowercaseString
            let periodRange = lowerCaseStringValue.rangeOfString(".")
            let colonRange = lowerCaseStringValue.rangeOfString(":")
            let pRange = lowerCaseStringValue.rangeOfString("p")
            let aRange = lowerCaseStringValue.rangeOfString("a")
            var amOrPM: SPAmPm?
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
            SPTime.adjustHourInput(&hour, amOrPM: amOrPM)
            guard min != nil && hour != nil else {
                print("No hour and/or min in \(lowerCaseStringValue). hour: \(hour) min: \(min)")
                return nil
            }
            self.init(hour:hour!, min: min!)
        }
        static private func adjustHourInput(inout hour:Int?, amOrPM:SPAmPm?) {
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
    
    mutating func increaseTimeInterval(minutes:Int) throws {
        do {
            try time.increaseTimeInterval(minutes)
            if time.hour > 24 {
                let dayChanger = Int(time.hour / 24)
                time.hour = time.hour % 24
                for _ in 0..<dayChanger { dayOfWeek.increaseDay() }
                
            }
        } catch let error as NSError {
            print("Error increasing interval by \(minutes). " + error.localizedDescription)
        }
    }
    //    mutating private func changeTimeInterval(minutes:Int, change:(time:(Int) throws -> Void, day: () -> Void)) {
    //        try change.time(minutes)
    //        if time.hour > 24 {
    //            let dayChanger = Int(time.hour / 24)
    //            time.hour = time.hour % 24
    //            for _ in 0..<dayChanger { change.day() }
    //        }
    //
    //        do{
    //        } catch SPTimeAndDayError.invalidMinuteInterval(let minute) {
    //            print("Invalid minute interval: \(minute). Must be greater than 0 and evenly divide into 60")
    //        } catch let error as NSError{
    //            print("Error while changing time, interval: \(minutes). \(error.localizedDescription)")
    //        }
    //    }
    mutating func decreaseTimeInterval(minutes: Int) {
        do {
            try time.increaseTimeInterval(minutes)
            if time.hour > 24 {
                let dayChanger = Int(time.hour / 24)
                time.hour = time.hour % 24
                for _ in 0..<dayChanger { dayOfWeek.increaseDay() }
            }
            
        } catch let error as NSError {
            print("Error decreasing interval by \(minutes). " + error.localizedDescription)
        }
    }
    func nextStreetCleaning() -> SPTimeAndDay {
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
            returnTimeAndDay.dayOfWeek.increaseDay()
        }
        if returnTimeAndDay.dayOfWeek.rawValue == 1 {
            returnTimeAndDay.dayOfWeek.increaseDay()
        }
        return SPTimeAndDay.init(dayOfWeek: returnTimeAndDay.dayOfWeek, time: returnTimeAndDay.time)
    }
    
    func previousValidTimeAndDay() -> SPTimeAndDay {
        var returnTimeAndDay = self
        if returnTimeAndDay.time.hour > 19 && (returnTimeAndDay.dayOfWeek.rawValue != 1 || returnTimeAndDay.dayOfWeek.rawValue != 7) {
            returnTimeAndDay.time.hour = 19
            returnTimeAndDay.time.min = 0
        } else if returnTimeAndDay.time.hour > 14 || (returnTimeAndDay.time.hour == 14 && returnTimeAndDay.time.min == 30) {
            returnTimeAndDay.time.hour = 14
            returnTimeAndDay.time.min = 0
        } else if returnTimeAndDay.time.hour < 3 {
            returnTimeAndDay.dayOfWeek.decreaseDay()
            if returnTimeAndDay.dayOfWeek.rawValue == 7 {
                returnTimeAndDay.time.hour = 13
                returnTimeAndDay.time.min = 0
            } else {
                returnTimeAndDay.time.hour = 19
                returnTimeAndDay.time.min = 0
            }
        }
        if returnTimeAndDay.dayOfWeek.rawValue == 1 {
            returnTimeAndDay.dayOfWeek.decreaseDay()
            returnTimeAndDay.time.hour = 13
            returnTimeAndDay.time.min = 0
        }
        return SPTimeAndDay.init(dayOfWeek: returnTimeAndDay.dayOfWeek, time: returnTimeAndDay.time)
    }
}
extension SPTimeAndDay {
    init?(dayString:String, timeString:String) {
        guard let initDay = SPDay.init(stringValue: dayString) else {
            print("Unable to make day out of string: \(dayString)")
            return nil
        }
        guard let initTime = SPTime.init(userInputValue: timeString) else {
            print("Unable to make time out of string: \(timeString)")
            return nil
            
        }
        self.init(dayOfWeek:initDay, time: initTime)
    }
    init?(dayInt:Int, hourInt:Int, minInt:Int) {
        guard let initDay = SPDay.init(rawValue: dayInt) else {
            print("Unable to make day out of int: \(dayInt)")
            return nil
        }
        guard let initTime = SPTime.init(hour: hourInt, min: minInt) else {
            print("Unable to make time out of hour: \(hourInt), and min: \(minInt)")
            return nil
        }
        self.init(dayOfWeek:initDay, time: initTime)
    }
    init?(currentTimeAndDayWithFormat format: SPTimeFormat) {
        let date = NSDate()
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let hour = calendar.component(.Hour, fromDate: date)
            let minute = calendar.component(.Minute, fromDate: date)
            let day = calendar.component(.Weekday, fromDate: date)
            self.init(dayInt: day, hourInt: hour, minInt: minute)
        } else {
            print("Unable to get current day, hour, and/or minutes, will return (2, 12, 0) respectively")
            self.init(dayInt: 2, hourInt: 12, minInt: 0)
        }
    }
}

