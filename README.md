# DNTimeAndDay

[![CI Status](http://img.shields.io/travis/dnomnom/DNTimeAndDay.svg?style=flat)](https://travis-ci.org/dnomnom/DNTimeAndDay)
[![Version](https://img.shields.io/cocoapods/v/DNTimeAndDay.svg?style=flat)](http://cocoapods.org/pods/DNTimeAndDay)
[![License](https://img.shields.io/cocoapods/l/DNTimeAndDay.svg?style=flat)](http://cocoapods.org/pods/DNTimeAndDay)
[![Platform](https://img.shields.io/cocoapods/p/DNTimeAndDay.svg?style=flat)](http://cocoapods.org/pods/DNTimeAndDay)

A simple model object to store and adjust time and day of the week. Increase/decrease the time in even intervals***. Output the time string value in 12/24-hour formats (4:00pm vs 16:00). Plans to include date (day, week, month, year).   

## Installation

DNTimeAndDay is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DNTimeAndDay"
```


## Example

To run the example project, clone the repo,

`git clone https://github.com/dknomura/DNTimeAndDay.git`

and run 

`pod install` 

from the Example directory.

## Usage
```swift
var currentTimeAndDay = DNTimeAndDay.currentTimeAndDay()  // stringValues: "Mon", "11:45am"
// can also init with string and int values
currentTimeAndDay.minuteInterval = 30  

do {
    currentTimeAndDay.increaseTimeInterval()  
    currentTimeAndDaytime.stringValue(withFormat:.format12Hour) 
    // if the time is in between intervals, then the minute will increase to match the interval. 
    // ie time = 12:00pm, not 12;15pm
} catch DNTimeAndError.invalidMinuteInterval {
    print("Minute interval is invalid, must be greater than 0 and 60 % (interval % 60) == 0 ***") 
}
currentTimeAndDay.day.increaseDay() 
currentTimeAndDay.day.stringValue // "Tues"
```

## Requirements
- iOS 9.3+
- Xcode 7.3.1+


## Author

dnomnom, dknomura@gmail.com

## License

DNTimeAndDay is available under the MIT license. See the LICENSE file for more info.
