//
//  LYValueTrackingSlider.swift
//  LYPlayer
//
//  Created by ly on 2017/10/11.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

//delegate
protocol LYValueTrackingSliderDelegate : NSObjectProtocol {
    func sliderWillDisplayPopUpView(slider : LYValueTrackingSlider)
    
    func sliderWillHidePopUpView(slider : LYValueTrackingSlider)
    func sliderDidHidePopUpView(slider : LYValueTrackingSlider)
}

class LYValueTrackingSlider: UISlider {
    //MARK: - override
    override var maximumValue : Float{
        didSet{
            self.valueRange = self.maximumValue - self.minimumValue
        }
    }
    override var minimumValue: Float{
        didSet{
            self.valueRange = self.maximumValue - self.minimumValue
        }
    }
    override var value: Float{
        didSet{
            self.popUpView.setAnimated(offset: self.currentValueOffSet()) { (opaqueReturnColor) in
                super.minimumTrackTintColor = opaqueReturnColor
            }
        }
    }
    override var minimumTrackTintColor: UIColor?{
        didSet{
            self.autoAdjustTrackColor = false
        }
    }
    
    //MARK: - public
    // setting the value of 'popUpViewColor' overrides 'popUpViewAnimatedColors' and vice versa
    // the return value of 'popUpViewColor' is the currently displayed value
    // this will vary if 'popUpViewAnimatedColors' is set (see below)
    var popUpViewColor : UIColor{
        get{
            return self.popUpView.color != nil ? self.popUpView.color! : self.popUpViewColor2
        }
        set{
//            popUpViewColor = newValue
            self.popUpViewAnimatedColors.removeAll()
            self.popUpView.color = newValue
            if self.autoAdjustTrackColor{
                super.minimumTrackTintColor = self.popUpView.opaqueColor
            }
        }
    }
    
    // pass an array of 2 or more UIColors to animate the color change as the slider moves
    var popUpViewAnimatedColors = Array<UIColor>()
    
    var popUpView : LYValuePopUpView!
    var popUpViewAlwaysOn = false
    
    // cornerRadius of the popUpView, default is 4.0
    var popUpViewCornerRadius : CGFloat{
        get{
            return self.popUpView.cornerRadius
        }
        set{
            self.popUpView.cornerRadius = newValue
        }
    }
    
    // arrow height of the popUpView, default is 13.0
    var popUpViewArrowLength : CGFloat{
        get{
            return self.popUpView.arrowLength
        }
        set{
            self.popUpView.arrowLength = newValue
        }
    }

    // width padding factor of the popUpView, default is 1.15
    var popUpViewWidthPaddingFactor : CGFloat{
        get{
            return self.popUpView.widthPaddingFactor
        }
    }
    
    // height padding factor of the popUpView, default is 1.1
    var popUpViewHeightPaddingFactor : CGFloat{
        get{
            return self.popUpView.heightPaddingFactor
        }
    }
    
    // changes the left handside of the UISlider track to match current popUpView color
    // the track color alpha is always set to 1.0, even if popUpView color is less than 1.0
    var autoAdjustTrackColor = true
    
    // delegate is only needed when used with a TableView or CollectionView - see below
    var delegate : LYValueTrackingSliderDelegate?
    
    //MARK: - private
    var numberFormatter : NumberFormatter!
    var popUpViewColor2 : UIColor!
    var keyTimes : Array<NSNumber>!
    var valueRange : Float!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.autoAdjustTrackColor = true
        self.valueRange = self.maximumValue - self.minimumValue
        self.popUpViewAlwaysOn = false
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumIntegerDigits = 2
        formatter.minimumIntegerDigits = 2
        self.numberFormatter = formatter
        
        self.popUpView = LYValuePopUpView.init(frame: CGRect.zero)
//        self.popUpViewColor = UIColor.init(hue: 0.6, saturation: 0.5, brightness: 0.5, alpha: 0.8)
        self.popUpView.alpha = 0.0
        self.popUpView.delegate = self
        self.addSubview(self.popUpView)
    }
    
    func setAutoAdjustTrackColor(autoAdjust : Bool) {
        if self.autoAdjustTrackColor == autoAdjust {return}
        
        self.autoAdjustTrackColor = autoAdjust
        if autoAdjust{
            super.minimumTrackTintColor = self.popUpView.opaqueColor
        }else{
            self.minimumTrackTintColor = nil
        }
    }
    
    func setText(text : String) {
        self.popUpView.timeLabel.text = text
    }
    
    func setImage(image : UIImage) {
        self.popUpView.imageView.image = image
    }
    
    func setPopUpViewColor(color : UIColor) {
        self.popUpViewColor2 = color
        self.popUpViewAnimatedColors.removeAll()
        self.popUpView.color = color
        if self.autoAdjustTrackColor{
            super.minimumTrackTintColor = self.popUpView.opaqueColor
        }
    }
    
    func setPopUpViewAnimatedColors(colors : Array<UIColor>) {
        self.setPopUpViewAnimatedColors(colors: colors, withPositions: nil)
    }
    
    func setPopUpViewAnimatedColors(colors : Array<UIColor>, withPositions positions : Array<NSNumber>?) {
        if positions != nil{
            assert(colors.count == positions!.count, "popUpViewAnimatedColors and locations should contain the same number of items")
        }
        self.popUpViewAnimatedColors = colors
        self.keyTimes = self.keyTimesFromSliderPositions(positions: positions)
        
        if colors.count >= 2{
            self.popUpView.setAnimated(colors: colors, keyTimes: self.keyTimes)
        }else{
            self.setPopUpViewColor(color: colors.last != nil ? colors.last! : self.popUpViewColor2)
        }
    }
    
    func keyTimesFromSliderPositions(positions : Array<NSNumber>?) -> Array<NSNumber>? {
        if positions == nil{
            return nil
        }
        
        var array = Array<NSNumber>()
        for num in positions!.sorted(by: { (num1, num2) -> Bool in
            return num1.floatValue > num2.floatValue
        }){
            let value : NSNumber = NSNumber(value:(num.floatValue - self.minimumValue) / self.valueRange)
            array.append(value)
        }
        return array
    }
    
    func setPopUpViewCornerRadius(radius : CGFloat) {
        self.popUpView.cornerRadius = radius
    }
    
    func setPopUpViewArrowLength(length : CGFloat) {
        self.popUpView.arrowLength = length
    }
    
    func setPopUpViewWidthPaddingFactor(factor : CGFloat) {
        self.popUpView.widthPaddingFactor = factor
    }
    
    func setPopUpViewHeightPaddingFactor(factor : CGFloat) {
        self.popUpView.heightPaddingFactor = factor
    }

    func showPopUpViewAnimated(animate : Bool) {
        self.popUpViewAlwaysOn = true
        if self.delegate != nil{
            self.delegate?.sliderWillHidePopUpView(slider: self)
        }
        self.popUpView.showAnimated(animate: animate)
    }
    
    func hidePopUpViewAnimated(animate : Bool) {
        self.popUpViewAlwaysOn = false
        if self.delegate != nil{
            if self.delegate!.responds(to: Selector.init(("sliderWillHidePopUpView:"))){
                self.delegate?.sliderWillHidePopUpView(slider: self)
            }
        }
        self.popUpView.hideAnimated(animate: animate) {
            if self.delegate != nil{
                if self.delegate!.responds(to: Selector.init(("sliderDidHidePopUpView:"))){
                    self.delegate?.sliderDidHidePopUpView(slider: self)
                }
            }
        }
    }
    

    
}

extension LYValueTrackingSlider {
    
    @objc func didBecomeActiveNotification(noti : NSNotification) {
        if self.popUpViewAnimatedColors.count > 0{
            self.popUpView.setAnimated(colors: self.popUpViewAnimatedColors, keyTimes: self.keyTimes)
        }
    }
    
    func updatePopUpView() {
        let popUpViewSize = CGSize.init(width: 100, height: 56 + self.popUpViewArrowLength + 18)
        let thumbRect = self.thumbRect(forBounds: self.bounds, trackRect: self.trackRect(forBounds: self.bounds), value: self.value)
        let thumbW = thumbRect.size.width
        let thumbH = thumbRect.size.height
        var popUpRect = thumbRect.insetBy(dx: (thumbW - popUpViewSize.width) / 2, dy: (thumbH - popUpViewSize.height) / 2)
        popUpRect.origin.y = thumbRect.origin.y - popUpViewSize.height
        let minOffsetX = popUpRect.maxX
        let maxOffsetX = popUpRect.maxX - self.bounds.width
        
        let offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0)
        popUpRect.origin.x -= offset
        self.popUpView.set(frame: popUpRect, arrowOffset: offset)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updatePopUpView()
    }
    
    override func didMoveToWindow() {
        if self.window == nil{
            NotificationCenter.default.removeObserver(self)
        }else{
            if self.popUpViewAnimatedColors.count > 0{
                self.popUpView.setAnimated(colors: self.popUpViewAnimatedColors, keyTimes: self.keyTimes)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(LYValueTrackingSlider.didBecomeActiveNotification(noti:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
    }
    
    override func setValue(_ value: Float, animated: Bool) {
        if animated{
            self.popUpView.animateBlock(block: { (duration) in
                UIView.animate(withDuration: duration, animations: {
                    super.setValue(value, animated: animated)
                    self.popUpView.setAnimated(offset: self.currentValueOffSet(), returnColor: { (opaqueReturnColor) in
                        super.minimumTrackTintColor = opaqueReturnColor
                    })
                    self.layoutIfNeeded()
                })
            })
        }else{
            super.setValue(value, animated: animated)
        }
    }
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let begin = super.beginTracking(touch, with: event)
        if begin && !self.popUpViewAlwaysOn{
            if self.delegate != nil{
                self.delegate?.sliderWillHidePopUpView(slider: self)
            }
            self.popUpView.showAnimated(animate: false)
        }
        return begin
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let continueTrack = super.continueTracking(touch, with: event)
        if continueTrack{
            self.popUpView.setAnimated(offset: self.currentValueOffSet(), returnColor: { (opaqueReturnColor) in
                super.minimumTrackTintColor = opaqueReturnColor
            })
        }
        return continueTrack
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        if !self.popUpViewAlwaysOn{
            if self.delegate != nil{
                self.delegate?.sliderWillHidePopUpView(slider: self)
            }
            self.popUpView.showAnimated(animate: false)
        }
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if !self.popUpViewAlwaysOn{
            if self.delegate != nil{
                self.delegate?.sliderWillHidePopUpView(slider: self)
            }
            self.popUpView.showAnimated(animate: false)
        }
    }
    
}


extension LYValueTrackingSlider : LYValuePopUpViewDelegate{
    func colorDidUpdate(opaqueColor: UIColor) {
        self.minimumTrackTintColor = opaqueColor
    }
    
    func currentValueOffSet() -> CGFloat {
        return CGFloat((self.value - self.minimumValue) / self.valueRange)
    }
}

