// https://github.com/Quick/Quick


import Quick
import Nimble
@testable import DNTimeAndDay

class DNTimeAndDaySpec: QuickSpec {
    override func spec() {
        var timeAndDay: DNTimeAndDay!
        describe("String values") {
            beforeEach({ 
                timeAndDay = DNTimeAndDay.init(dayString: "W", timeString: "9p")
            })
            describe("Day", { 
                it("checks and increases a day", closure: { 
                    expect(timeAndDay.day.stringValue(forFormat: .abbr)).to(equal("Wed"))
                    expect(timeAndDay.day.stringValue(forFormat: .full)).to(equal("Wednesday"))
                    timeAndDay.increaseDay()
                    expect(timeAndDay.day.stringValue(forFormat: .abbr)).to(equal("Thurs"))
                    expect(timeAndDay.day.stringValue(forFormat: .full)).to(equal("Thursday"))
                })
            })
            describe("Time", {
                context("24-Hour time format", {
                    it("is at night", closure: {
                        expect(timeAndDay.time.stringValue(forFormat: .format24Hour)).to(equal("21:00"))
                        timeAndDay.increaseTime()
                        expect(timeAndDay.time.stringValue(forFormat: .format24Hour)).to(equal("21:30"))
                    })
                    it("is in the morning", closure: { 
                        timeAndDay = DNTimeAndDay.init(dayInt: 6, hourInt: 8, minInt: 30)
                        expect(timeAndDay.time.stringValue(forFormat: .format24Hour)).to(equal("08:30"))
                        timeAndDay.increaseTime()
                        expect(timeAndDay.time.stringValue(forFormat: .format24Hour)).to(equal("09:00"))
                    })
                })
                context("12-Hour time format", {
                    it("is at night", closure: {
                        expect(timeAndDay.time.stringValue(forFormat: .format12Hour)).to(equal("9:00pm"))
                        timeAndDay.increaseTime()
                        expect(timeAndDay.time.stringValue(forFormat: .format12Hour)).to(equal("9:30pm"))
                    })
                    it("is in the morning", closure: {
                        timeAndDay = DNTimeAndDay.init(dayInt: 6, hourInt: 8, minInt: 30)
                        expect(timeAndDay.time.stringValue(forFormat: .format12Hour)).to(equal("8:30am"))
                        timeAndDay.increaseTime()
                        expect(timeAndDay.time.stringValue(forFormat: .format12Hour)).to(equal("9:00am"))
                    })
                })
            })
        }
        describe("Change time and day") {
            fdescribe("Time", closure: {
                beforeEach({
                    //day = 2, hour = 18, min = 0
                    timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6p")
                })
                it("increases time default value, 30", closure: {
                    timeAndDay.increaseTime()
                    expect(timeAndDay.time.hour).to(equal(18))
                    expect(timeAndDay.time.min).to(equal(30))
                    timeAndDay.increaseTime()
                    expect(timeAndDay.time.hour).to(equal(19))
                    expect(timeAndDay.time.min).to(equal(0))
                })
                it("decreases time default value, 30", closure: {
                    timeAndDay.decreaseTime()
                    expect(timeAndDay.time.hour).to(equal(17))
                    expect(timeAndDay.time.min).to(equal(30))
                    timeAndDay.decreaseTime()
                    expect(timeAndDay.time.hour).to(equal(17))
                    expect(timeAndDay.time.min).to(equal(0))
                    timeAndDay.decreaseTime()
                    expect(timeAndDay.time.hour).to(equal(16))
                    expect(timeAndDay.time.min).to(equal(30))
                })
                describe("Changes day appropriately after increase/decrease", closure: {
                    describe("positive 1515 minutes", {
                        beforeEach({
                            //day = 2, hour = 18, min = 0
                            timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6.5p")
                            // 1515 minutes is 1 day, 1 hour, and 15 minutes
                            timeAndDay.minuteInterval = 1515
                        })

                        it("increases", closure: {
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(3))
                            expect(timeAndDay.time.hour).to(equal(19))
                            expect(timeAndDay.time.min).to(equal(45))
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(4))
                            expect(timeAndDay.time.hour).to(equal(21))
                            expect(timeAndDay.time.min).to(equal(0))
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(5))
                            expect(timeAndDay.time.hour).to(equal(22))
                            expect(timeAndDay.time.min).to(equal(15))
                        })
                        it("decreases", closure: {
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(1))
                            expect(timeAndDay.time.hour).to(equal(17))
                            expect(timeAndDay.time.min).to(equal(15))
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(7))
                            expect(timeAndDay.time.hour).to(equal(16))
                            expect(timeAndDay.time.min).to(equal(0))
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(6))
                            expect(timeAndDay.time.hour).to(equal(14))
                            expect(timeAndDay.time.min).to(equal(45))
                        })

                    })
                    describe("positive 2120 minutes", {
                        beforeEach({
                            //day = 2, hour = 18, min = 0
                            timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6.5p")
                            // 2120 minutes is 1 day, 11 hour, and 20 minutes
                            timeAndDay.minuteInterval = 2120
                        })

                        it("increases 2120 minutes", closure: {
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(4))
                            expect(timeAndDay.time.hour).to(equal(5))
                            expect(timeAndDay.time.min).to(equal(40))
                        })
                        it("decreases 2120 minutes", closure: {
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(1))
                            expect(timeAndDay.time.hour).to(equal(7))
                            expect(timeAndDay.time.min).to(equal(20))
                        })

                    })
                    describe("negative 1515 minutes", {
                        beforeEach({
                            //day = 2, hour = 18, min = 0
                            timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6.5p")
                            // 1515 minutes is 1 day, 1 hour, and 15 minutes
                            timeAndDay.minuteInterval = -1515
                        })
                        
                        it("increases", closure: {
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(1))
                            expect(timeAndDay.time.hour).to(equal(17))
                            expect(timeAndDay.time.min).to(equal(15))
                        })
                        it("decreases", closure: {
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(3))
                            expect(timeAndDay.time.hour).to(equal(19))
                            expect(timeAndDay.time.min).to(equal(45))
                        })
                        
                    })
                    describe("negative 2120 minutes", {
                        beforeEach({
                            //day = 2, hour = 18, min = 0
                            timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6.5p")
                            // 2120 minutes is 1 day, 11 hour, and 20 minutes
                            timeAndDay.minuteInterval = -2120
                        })
                        
                        it("increases 2120 minutes", closure: {
                            timeAndDay.increaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(1))
                            expect(timeAndDay.time.hour).to(equal(7))
                            expect(timeAndDay.time.min).to(equal(20))
                        })
                        it("decreases 2120 minutes", closure: {
                            timeAndDay.decreaseTime()
                            expect(timeAndDay.day.rawValue).to(equal(4))
                            expect(timeAndDay.time.hour).to(equal(5))
                            expect(timeAndDay.time.min).to(equal(40))

                        })
                        
                    })
                })
            })
            describe("Day", closure: {
                describe("Change day in the same week", {
                    beforeEach({
                        //day = 2
                        timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "6p")
                    })
                    it("increases 2 days", closure: {
                        timeAndDay.day.increase(by: 2)
                        expect(timeAndDay.day.rawValue).to(equal(4))
                    })
                    it("decreases 2 days", closure: {
                        timeAndDay.day.decrease(by: 2)
                        expect(timeAndDay.day.rawValue).to(equal(7))
                    })
                })
                describe("Change day more than a week", {
                    beforeEach({ 
                        timeAndDay = DNTimeAndDay.init(dayInt: 3, hourInt: 4, minInt: 5)
                        timeAndDay.dayInterval = 15
                    })
                    it("increases 15 days", closure: {
                        timeAndDay.increaseDay()
                        expect(timeAndDay.day.rawValue).to(equal(4))
                    })
                    it("decreases 15 days", closure: {
                        timeAndDay.decreaseDay()
                        expect(timeAndDay.day.rawValue).to(equal(2))
                    })
                })
            })
        }
        xdescribe("Time and day initializers") {
            describe("for date", closure: {
                var currentTimeAndDay: DNTimeAndDay!
                var intValues: (day:Int, hour:Int, min:Int)!
                beforeEach({
                    let date = NSDate()
                    currentTimeAndDay = DNTimeAndDay.currentTimeAndDay()
                    timeAndDay = DNTimeAndDay.timeAndDay(forDate: date)
                    let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)!
                    intValues = (calendar.component(.Weekday, fromDate: date), calendar.component(.Hour, fromDate: date), calendar.component(.Minute, fromDate: date))
                })
                describe("it's IntValues", closure: {
                    it("s hour", closure: {
                        expect(timeAndDay.time.hour).to(equal(intValues.hour))
                    })
                    it("s minute", closure: {
                        expect(timeAndDay.time.min).to(equal(intValues.min))
                    })
                    it("s day", closure: {
                        expect(timeAndDay.day.rawValue).to(equal(intValues.day))
                    })
                })
                describe("it's comparison to current date static func", closure: {
                    it("s day", closure: {
                        expect(timeAndDay.day).to(equal(currentTimeAndDay.day))
                    })
                    it("s hour", closure: {
                        expect(timeAndDay.time.hour).to(equal(currentTimeAndDay.time.hour))
                    })
                    it("s min", closure: {
                        expect(timeAndDay.time.min).to(equal(currentTimeAndDay.time.min))
                    })
                })
            })
            describe("String initializer", closure: {
                context("Time with no punctuation", {
//                    self.initialize(withDayString: "m", timeString: "6p", expectation: (day: 2, hour: 18, min: 0), amPm: true)
                    let timeAndDay = DNTimeAndDay.init(dayString: "m", timeString: "6p")
                    context("am/pm preset") {
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(2))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(18))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(0))
                        })
                    }
//                    self.initialize(withDayString: , timeString: "", expectation: (day: 3, hour: 6, min:0), amPm: false)
                    context("am/pm not present") {
                        let timeAndDay = DNTimeAndDay.init(dayString: "tues", timeString: "6")
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(3))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(6))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(0))
                        })
                    }

                })
                context("Time with period", {
//                    self.initialize(withDayString: "we", timeString: "6.4a", expectation: (day: 4, hour: 6, min: Int(40 * 0.6)), amPm: true)
                    context("am/pm present") {
                        let timeAndDay = DNTimeAndDay.init(dayString: "we", timeString: "6.4a")
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(4))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(6))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(Int(40 * 0.6)))
                        })
                    }
//                    self.initialize(withDayString: "th", timeString: "15.29", expectation: (day: 5, hour: 15, min: Int(29 * 0.6)), amPm: false)
                    context("am/pm not present") {
                        let timeAndDay = DNTimeAndDay.init(dayString: "th", timeString: "15.29")
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(5))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(15))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(Int(29 * 0.6)))
                        })
                    }
                    
                })
                context("Time with colon", {
//                    self.initialize(withDayString: "su", timeString: "12:49pm", expectation: (day: 1, hour: 12, min: 49), amPm: true)
                    context("am/pm present") {
                        let timeAndDay = DNTimeAndDay.init(dayString: "su", timeString: "12:49pm")
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(1))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(12))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(49))
                        })
                    }
//                    self.initialize(withDayString: "sa", timeString: "2:02", expectation: (day: 7, hour: 2, min: 2), amPm: false)
                    context("am/pm not present") {
                        let timeAndDay = DNTimeAndDay.init(dayString: "sa", timeString: "2:02")
                        it("s day", closure: {
                            expect(timeAndDay!.day.rawValue).to(equal(7))
                        })
                        it("s hour", closure: {
                            expect(timeAndDay!.time.hour).to(equal(2))
                        })
                        it("s minute", closure: {
                            expect(timeAndDay!.time.min).to(equal(2))
                        })
                    }
                    
                })
                context("Time with invalid punctuation/characters", {
                    it("returns nil", closure: {
                        var timeAndDay = DNTimeAndDay.init(dayString: "", timeString: "")
                        expect(timeAndDay).to(beNil())
                        timeAndDay = DNTimeAndDay.init(dayString: "j", timeString: "6p")
                        expect(timeAndDay).to(beNil())
                        timeAndDay = DNTimeAndDay.init(dayString: "mon", timeString: "p9:00")
                        expect(timeAndDay).to(beNil())
                        timeAndDay = DNTimeAndDay.init(dayString: "wed", timeString: "9'00pm")
                        expect(timeAndDay).to(beNil())
                    })
                    
                })
            })
            describe("Int initializer", { 
                beforeEach({ 
                    timeAndDay = DNTimeAndDay.init(dayInt: 2, hourInt: 3, minInt: 5)
                })
                it("Convenience initializer", closure: { 
                    expect(timeAndDay.day.rawValue).to(equal(2))
                    expect(timeAndDay.time.hour).to(equal(3))
                    expect(timeAndDay.time.min).to(equal(5))
                    expect(timeAndDay.minuteInterval).to(equal(30))
                    expect(timeAndDay.dayInterval).to(equal(1))
                })
                it("is nil", closure: { 
                    timeAndDay = DNTimeAndDay.init(dayInt: -1, hourInt: 8, minInt: 8)
                    expect(timeAndDay).to(beNil())
                    timeAndDay = DNTimeAndDay.init(dayInt: 3, hourInt: 55, minInt: 8)
                    expect(timeAndDay).to(beNil())
                    timeAndDay = DNTimeAndDay.init(dayInt: 5, hourInt: 8, minInt: 90)
                    expect(timeAndDay).to(beNil())
                })
            })
        }
        
    }
    
    private func initialize(withDayString dayString:String, timeString:String, expectation:(day:Int, hour:Int, min:Int), amPm:Bool) {
        let timeAndDay = DNTimeAndDay.init(dayString: dayString, timeString: timeString)
        context(amPm ? "am/pm preset" : "am/pm not present") {
            it("s day", closure: {
                expect(timeAndDay!.day.rawValue).to(equal(expectation.day))
            })
            it("s hour", closure: {
                expect(timeAndDay!.time.hour).to(equal(expectation.hour))
            })
            it("s minute", closure: {
                expect(timeAndDay!.time.min).to(equal(expectation.min))
            })
        }
    }
}

