# RicRibbonTag

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Library for adding tags shaped as ribbons to existing views

<img width="271" alt="captura de pantalla 2016-09-02 a las 16 55 16" src="https://cloud.githubusercontent.com/assets/7848066/18208717/d62dfde2-7130-11e6-82ca-461594ef2045.png"> ![captura de pantalla 2016-09-06 a las 8 30 43](https://cloud.githubusercontent.com/assets/7848066/18264340/f784c606-740f-11e6-8c7f-0451e137fc94.png)
 <img width="262" alt="captura de pantalla 2016-09-02 a las 17 04 40" src="https://cloud.githubusercontent.com/assets/7848066/18208716/d61c1136-7130-11e6-95cb-04b189a1eea8.png"> 

## Installation

#### Using Carthage

Copy this line into your Cartfile

```
github "ricardrm88/RicRibbonTag"
```

After that run the following command on your Cartfile directory

```
carthage update RicRibbonTag
```

#### Using CocoaPods

Add to your Podfile

```
platform :ios, "8.1"
use_frameworks!

target 'Test' do
pod 'RicRibbonTag'

end
```

Then run the following line on your project folder:

```
pod install
```

After that just include RicRibbonTag in your file to use it

```swift
import RicRibbonTag
```

#### Manually

Just copy RicRibbonLabel.swift and RicRibbonTag.swift to your project

## Quick example:

```swift
let ribbon = RicRibbon()

ribbon.type = .topLeftCorner
ribbon.label.text = "20% Discount"
ribbon.originDistance = 40
ribbon.ribbonWidth = 40
ribbon.label.textColor = .white

ribbon.wrap(containerView)
```

<img width="271" alt="captura de pantalla 2016-09-02 a las 16 55 16" src="https://cloud.githubusercontent.com/assets/7848066/18208717/d62dfde2-7130-11e6-82ca-461594ef2045.png">

## Properties

#### label
Label rendered inside the label, it can be used to modify it's text and font. It's frame, origin and transform are modified internally and shouldn't be edited

#### decorationSize
Size of the decoration at the outer edges of the ribbon, clipstobounds should be disabled in the parent view for them to be visible

#### ribbonWidth
Width of the ribbon, it's ignored if autoresizes is enabled

#### ribbonColor
Color that the ribbon will be displayed with

#### marginColor
Color of the margin of the ribbon

#### marginWidth
Width of the margin of the ribbon

#### originDistance
Distance from the reference point of the container view to the closest point of the ribbon

#### ribbonLength
Length of the ribbon, will only work with .Left .Right and .Top types

#### keepInBounds
If enabled originDistance and ribbon width may be modified to keep the ribbon in the container bounds

#### movesHorizontally
If enabled, it will move the ribbon horizontally when needed to keep the whole ribbon inside of the container bounds

#### usesShadow
If enabled the ribbon will cast a shadow

#### displayDecorators
If enabled it will display decorators at the outer edges of the ribbon, clipstobounds should be disabled in the parent view for them to be visible

#### type
It determines the position of the ribbon in the container, it allows the following values:
```swift
enum RibbonType {
    case TopLeftCorner
    case TopRightCorner
    case BottomLeftCorner
    case BottomRightCorner
    case Left
    case Right
    case Top
}
```

####autoresizePadding
Padding added between the ribbon and it's label when autoresizes is enabled

####autoresizes
When enabled the ribbon width will equal it's label height

## Methods

#### wrap(view: UIView)
Used to wrap a view with the current ribbon

#### setDashPattern(lineWidth: CGFloat, spaceWidth: CGFloat)
Sets a dash pattern as the margin of the ribbon where lineWidth will be the stripe length and spaceWidth will be the length of the space between stripes 


## License
```
MIT License

Copyright (c) 2016 Ricard Romeo Murgó (https://github.com/ricardrm88)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
