# RicRibbonTag

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Library for adding tags shaped as ribbons to existing views

<img width="271" alt="captura de pantalla 2016-09-02 a las 16 55 16" src="https://cloud.githubusercontent.com/assets/7848066/18208717/d62dfde2-7130-11e6-82ca-461594ef2045.png"> <img width="253" alt="captura de pantalla 2016-09-02 a las 17 14 43" src="https://cloud.githubusercontent.com/assets/7848066/18208715/d6007dcc-7130-11e6-889e-313de2e9a646.png"> <img width="262" alt="captura de pantalla 2016-09-02 a las 17 04 40" src="https://cloud.githubusercontent.com/assets/7848066/18208716/d61c1136-7130-11e6-95cb-04b189a1eea8.png"> 

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

#### Manually

Just copy RicRibbonLabel.swift and RicRibbonTag.swift to your project

## Quick example:

```swift

let ribbon = RicRibbonTag()

ribbon.type = .TopLeftCorner
ribbon.label.text = "20% Discount"
ribbon.originDistance = 40
ribbon.ribbonWidth = 40
ribbon.label.textColor = UIColor.whiteColor()

ribbon.wrap(containerView)
```

<img width="271" alt="captura de pantalla 2016-09-02 a las 16 55 16" src="https://cloud.githubusercontent.com/assets/7848066/18208717/d62dfde2-7130-11e6-82ca-461594ef2045.png">
