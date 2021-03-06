//
//  DNTimeAndDay.swift
//  Pods
//
//  Created by Daniel Nomura on 9/7/16.
//
//
import Foundation

public enum DNTimeAndDayError: ErrorType {
    case invalidMinuteInterval(Int)
}
public enum DNTimeFormat: String {
    case format24Hour = "24-Hour"
    case format12Hour = "12-Hour"
}
public enum DNDayFormat: String {
    case full
    case abbr
}
public struct DNTimeAndDayFormat {
    public var time: DNTimeFormat
    public var day: DNDayFormat
    public init(time: DNTimeFormat, day: DNDayFormat) {
        self.time = time
        self.day = day
    }
}

public protocol DNTimeUnit {
    mutating func increase(by interval:Int)
    mutating func decrease(by interval:Int)
    func stringValue(forFormat format: DNTimeAndDayFormat) -> String
    init?(stringValue: String)
}
public enum DNDay: Int, DNTimeUnit {
    //Int/raw values match the Gregorian Calendar day of the week format
    case Sun = 1, Mon, Tues, Wed, Thurs, Fri, Sat
    public func stringValue(forFormat format: DNTimeAndDayFormat) -> String {
        switch self {
        case .Sun: return format.day == .full ? "Sunday" : "Sun"
        case .Mon: return format.day == .full ? "Monday" : "Mon"
        case .Tues: return format.day == .full ? "Tuesday" : "Tues"
        case .Wed: return format.day == .full ? "Wednesday" : "Wed"
        case .Thurs: return format.day == .full ? "Thursday" : "Thurs"
        case .Fri: return format.day == .full ? "Friday" : "Fri"
        case .Sat: return format.day == .full ? "Saturday" : "Sat"
        }
    }
    public init?(stringValue: String) {
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
    static let allValues: [DNDay] = [Sun, Mon, Tues, Wed, Thurs, Fri, Sat]
    enum DayError: ErrorType {
        case invalidString(String)
    }
    public mutating func increase(by days:Int) {
        var dayInt = self.rawValue
        dayInt += days % 7
        normalize(&dayInt)
        self = DNDay.init(rawValue: dayInt)!
    }
    public mutating func decrease(by days:Int) {
        var dayInt = self.rawValue
        dayInt -= days % 7
        normalize(&dayInt)
        self = DNDay.init(rawValue: dayInt)!
    }
    
    private func normalize(inout dayInt: Int) {
        if dayInt > 7 {
            dayInt = dayInt % 7
            if dayInt == 0 {
                dayInt = 7
            }
        } else if dayInt < 1 {
            dayInt = dayInt % 7 + 7
        }
    }
}


public struct DNTime: DNTimeUnit {
    enum DNAmPm: String{
        case am, pm, format24
    }
    public var hour: Int
    public var min: Int {
        didSet{
            if min > 59 || min < 0 {
                print("Minute cannot be > 59 or < 0, will set as oldValue \(oldValue). File: \(#file), function: \(#function), line: \(#line)")
                min = oldValue
            }
        }
    }
    
    public init?(hour: Int, min:Int) {
        if (hour >= 0 && hour < 24) && (min >= 0 && min < 60) {
            self.hour = hour
            self.min = min
        } else {
            print("Hour, \(hour), and min, \(min), are not valid, should be between 0-23 and 0-60 respectively")
            return nil
        }
    }
    
    // Refactor
    public init?(stringValue userInput:String) {
        let lowerCaseStringValue = userInput.lowercaseString
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
    public func stringValue(forFormat format:DNTimeAndDayFormat) -> String {
        let minString: String
        let hourString: String
        var hour = self.hour
        var amPM = ""
        if format.time == .format12Hour {
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
    mutating public func increase(by minuteInterval:Int) {
        changeTime(byMinuteInterval: minuteInterval, increase: true)
    }
    mutating public func decrease(by minuteInterval:Int) {
        changeTime(byMinuteInterval: minuteInterval, increase: false)
    }
    mutating private func changeTime(byMinuteInterval minuteInterval:Int, increase: Bool) {
        guard minuteInterval != 0 else { return }
        guard minuteInterval > 0 else {
            changeTime(byMinuteInterval: -minuteInterval, increase: !increase)
            return
        }
        var timeToChange: DNTime = self
        let hourChange = Int(minuteInterval / 60)
        if hourChange != 0 {
            timeToChange.hour += increase ? hourChange : -hourChange
        }
        var remainingMinuteInterval = minuteInterval % 60
        if remainingMinuteInterval != 0 {
            if 60 % remainingMinuteInterval != 0 {
                print("Invalid minute interval: \(minuteInterval), 60 % (interval % 60) != 0. Will use default 30 min interval")
                remainingMinuteInterval = 30
            }
            let numberOfIntervals: Int = (60 / remainingMinuteInterval) - 1
            // the remainingMinuteInterval * numberOfIntervals is the greatest interval that is less than 60 (ie if the minute interval is 10 then the greatest interval is 50, if minute interval is 15 then the greatest minute interval is 45). If the timeToIncrease minutes is greater than the greatest interval then min = 0 and hour++. Otherwise increase/decrease the minutes to the correct interval
            let shouldChangeHour = increase ? timeToChange.min >= remainingMinuteInterval * numberOfIntervals : timeToChange.min == 0
            if shouldChangeHour {
                timeToChange.min = increase ? 0 : remainingMinuteInterval * numberOfIntervals
                timeToChange.hour += increase ? 1 : -1
            } else {
                for i in 1...numberOfIntervals + 1 {
                    let changeToMin = increase ? remainingMinuteInterval * i : remainingMinuteInterval * (numberOfIntervals - i + 1)
                    let shouldChangeToMin = increase ? timeToChange.min < changeToMin : timeToChange.min > changeToMin
                    if shouldChangeToMin {
                        timeToChange.min = changeToMin
                        break
                    }
                }
            }
        } else {
            timeToChange.min = 0
        }
        self.hour = timeToChange.hour
        self.min = timeToChange.min
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
public struct DNTimeAndDay {
    public var day: DNDay
    public var time: DNTime
    public var minuteInterval: Int = 30
    public var dayInterval = 1
    
    public mutating func increaseDay() {
        day.increase(by: dayInterval)
    }
    public mutating func decreaseDay() {
        day.decrease(by: dayInterval)
    }
    public mutating func increaseTime() {
        changeTime(increase: true)
    }
    public mutating func decreaseTime() {
        changeTime(increase: false)
    }
    private mutating func changeTime(increase increaseDecrease:Bool) {
        guard minuteInterval != 0 else { return }
        var absoluteMinInterval = minuteInterval
        var increase = increaseDecrease
        if absoluteMinInterval < 0 {
            absoluteMinInterval *= -1
            increase = !increase
        }
        increase ? time.increase(by: absoluteMinInterval) : time.decrease(by: absoluteMinInterval)
        if time.hour > 23 {
            let dayCounter = Int(time.hour / 24)
            time.hour = time.hour % 24
            day.increase(by: dayCounter)
        } else if time.hour < 0 {
            let dayCounter = Int(abs(time.hour / 24)) + 1
            time.hour = time.hour % 24 + 24
            if time.hour == 24 {
                time.hour = 0
            }
            day.decrease(by: dayCounter)
        }
    }
}
public extension DNTimeAndDay {
    public init(day: DNDay, time: DNTime) {
        self.init(day: day, time: time, minuteInterval: 30, dayInterval: 1)
    }
    public init(day:DNDay, time:DNTime, minuteInterval: Int) {
        self.init(day: day, time: time, minuteInterval: minuteInterval, dayInterval: 1)
    }
    public init?(dayString:String, timeString:String, minuteInterval:Int, dayInterval: Int) {
        guard let initDay = DNDay.init(stringValue: dayString) else {
            print("Unable to make day out of string: \(dayString)")
            return nil
        }
        guard let initTime = DNTime.init(stringValue: timeString) else {
            print("Unable to make time out of string: \(timeString)")
            return nil
        }
        self.init(day:initDay, time: initTime, minuteInterval: minuteInterval, dayInterval: dayInterval)
    }
    public init?(dayString:String, timeString:String, minuteInterval:Int) {
        self.init(dayString:dayString, timeString:timeString, minuteInterval:minuteInterval, dayInterval: 1)
    }
    public init?(dayString:String, timeString:String) {
        self.init(dayString:dayString, timeString:timeString, minuteInterval:30, dayInterval: 1)
    }
    
    public init?(dayInt:Int, hourInt:Int, minInt:Int, minuteInterval:Int, dayInterval:Int) {
        guard let initDay = DNDay.init(rawValue: dayInt) else {
            print("Unable to make day out of int: \(dayInt)")
            return nil
        }
        guard let initTime = DNTime.init(hour: hourInt, min: minInt) else {
            print("Unable to make time out of hour: \(hourInt), and min: \(minInt)")
            return nil
        }
        self.init(day:initDay, time: initTime, minuteInterval: minuteInterval, dayInterval: dayInterval)
    }
    public init?(dayInt:Int, hourInt:Int, minInt:Int, minuteInterval:Int) {
        self.init(dayInt: dayInt, hourInt: hourInt, minInt: minInt, minuteInterval: minuteInterval, dayInterval: 1)
    }
    public init?(dayInt:Int, hourInt:Int, minInt:Int) {
        self.init(dayInt: dayInt, hourInt: hourInt, minInt: minInt, minuteInterval: 30, dayInterval: 1)
    }
    
    public static func timeAndDay(forDate date:NSDate) -> DNTimeAndDay {
        if let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) {
            let hour = calendar.component(.Hour, fromDate: date)
            let minute = calendar.component(.Minute, fromDate: date)
            let day = calendar.component(.Weekday, fromDate: date)
            return DNTimeAndDay.init(dayInt: day, hourInt: hour, minInt: minute)!
        } else {
            print("Unable initialize Gregorian calendar to get current day, hour, and/or minutes, will return Mon, 12:00pm")
            return DNTimeAndDay.init(dayInt: 2, hourInt: 12, minInt: 0)!
        }
    }
    public static func currentTimeAndDay() -> DNTimeAndDay {
        let date = NSDate()
        return DNTimeAndDay.timeAndDay(forDate: date)
    }
}
