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
var currentTimeAndDay = DNTimeAndDay.currentTimeAndDay()  
// can also init with string and int values
// day string parameter is case insensitive and can recognize common day abbreviations, time string can have a period or colon and the option of am/pm (ie "11:30p", "11.5p", "11:00pm", "23.5", "23:30" are all the same) 
// default minuteInterval = 30, dayInterval = 1
var otherTimeAndDay = DNTimeAndDay.init(dayString: "m", timeString:"9p", minuteInterval: 90, dayInterval = 2)

otherTimeAndDay.increaseTime()  
otherTimeAndDay.time.stringValue(forFormat:.format12Hour)  // "10:30pm"
// if the time is in between intervals, then the minute will increase to match the interval. 
// ie time = 12:00pm, not 12;15pm

currentTimeAndDay.increaseDay() 
currentTimeAndDay.day.stringValue(forFormat:.abbr) // "Wed"
```

## Requirements
- iOS 9.3+
- Xcode 7.3.1+


## Author

dnomnom, dknomura@gmail.com

## License

DNTimeAndDay is available under the MIT license. See the LICENSE file for more info.
