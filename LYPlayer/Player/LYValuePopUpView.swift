//
//  LYValuePopUpView.swift
//  LYPlayer
//
//  Created by ly on 2017/10/10.
//  Copyright © 2017年 ly. All rights reserved.
//

import UIKit

let SliderFillColorAnim = "fillColor"

//
protocol LYValuePopUpViewDelegate : NSObjectProtocol {
    func currentValueOffSet() -> CGFloat
    func colorDidUpdate(opaqueColor : UIColor)
}

class LYValuePopUpView: UIView {

    //MARK: - public
    
    var cornerRadius : CGFloat = 0//
    var arrowLength : CGFloat = 0//
    var widthPaddingFactor : CGFloat = 0//
    var heightPaddingFactor : CGFloat = 0//
    var delegate : LYValuePopUpViewDelegate?
    //
    var imageView : UIImageView!
    //
    var timeLabel : UILabel!
    
    //
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.anchorPoint = CGPoint.init(x: 0.5, y: 1)
        
        self.isUserInteractionEnabled = false
        self.pathLayer = CAShapeLayer.init(layer: self.layer)
        
        self.cornerRadius = 4.0
        self.arrowLength = 13.0
        self.widthPaddingFactor = 1.15
        self.heightPaddingFactor = 1.1
        
        self.colorAnimLayer = CAShapeLayer()
        self.layer.addSublayer(self.colorAnimLayer)
        
        self.timeLabel = UILabel()
        self.timeLabel.text = "10:00"
        self.timeLabel.font = UIFont.systemFont(ofSize: 10.0)
        self.timeLabel.textAlignment = .center
        self.timeLabel.textColor = UIColor.white
        self.addSubview(self.timeLabel)
        
        self.imageView = UIImageView(frame:CGRect.zero)
        self.addSubview(self.imageView)
        
        
        self.imageView.backgroundColor = UIColor.red
        self.timeLabel.backgroundColor = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    var color : UIColor?{
        set{
            if newValue != nil{
                self.pathLayer.fillColor = newValue!.cgColor
                self.colorAnimLayer.removeAnimation(forKey: SliderFillColorAnim)
            }
        }
        get{
            if self.pathLayer.fillColor != nil{
                return UIColor.init(cgColor: self.pathLayer.fillColor!)
            }else{
                return nil
            }
        }
    }
    //
    var opaqueColor : UIColor{
        get {
            return opaqueUIColorFromCGColor(self.colorAnimLayer.fillColor != nil ? self.colorAnimLayer.fillColor : self.pathLayer.fillColor)
        }
    }
    
    //
    func setAnimated(colors : Array<UIColor>, keyTimes : Array<NSNumber>) {
        var cgColors = Array<CGColor>()
        for color in colors{
            cgColors.append(color.cgColor)
        }
        let colorAnim = CAKeyframeAnimation.init(keyPath: SliderFillColorAnim)
        colorAnim.keyTimes = keyTimes
        colorAnim.values = cgColors
        colorAnim.fillMode = kCAFillModeBoth
        colorAnim.duration = 1.0
        colorAnim.delegate = self
        self.colorAnimLayer.add(colorAnim, forKey: SliderFillColorAnim)
    }
    
    //
    func setAnimated(offset : CGFloat, returnColor : ((UIColor) -> Void)) {
        if (self.colorAnimLayer.animation(forKey: SliderFillColorAnim) != nil){
            self.colorAnimLayer.timeOffset = CFTimeInterval(offset)
            self.pathLayer.fillColor = self.colorAnimLayer.fillColor
            returnColor(self.opaqueColor)
        }
    }
    
    //
    func set(frame : CGRect, arrowOffset : CGFloat) {
        if arrowOffset != self.arrowCenterOffset || !__CGSizeEqualToSize(frame.size, self.frame.size){
            self.pathLayer.path = self.pathForRect(rect: frame, arrowOffset: arrowOffset).cgPath
        }
        self.arrowCenterOffset = arrowOffset
        
        let anchorX = 0.5 + arrowOffset / frame.size.width
        self.layer.anchorPoint = CGPoint.init(x: anchorX, y: 1)
        self.layer.position = CGPoint.init(x: frame.minX + frame.width * anchorX, y: 0)
        self.layer.bounds = CGRect.init(origin: CGPoint.zero, size: frame.size)
    }
    
    
    //
    func animateBlock(block : ((CFTimeInterval) -> Void)) {
        self.shouldAnimate = true
        self.animDuration = 0.5
        let anim = self.layer.animation(forKey: "position")
        if anim != nil{
            let elapsedTime = CACurrentMediaTime() - anim!.beginTime > anim!.duration ? anim!.duration : CACurrentMediaTime() - anim!.beginTime
            self.animDuration = self.animDuration * elapsedTime / anim!.duration
        }
        block(self.animDuration)
        self.shouldAnimate = false
    }
    
    //
    func showAnimated(animate : Bool) {
        if !animate{
            self.layer.opacity = 1.0
            return
        }
        
        CATransaction.begin()
        let fromValue = self.layer.animation(forKey: "transform") != nil ? self.layer.value(forKey: "transform") : NSValue.init(caTransform3D: CATransform3DMakeScale(0.5, 0.5, 1))
        self.layer.animateKey(animateName: "transform", fromeValue: fromValue, toValue: NSValue.init(caTransform3D: CATransform3DIdentity)) { (animation) in
            animation.duration = 0.4
            animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.8, 2.5, 0.35, 0.5)
        }
        self.layer.animateKey(animateName: "opacity", fromeValue: nil, toValue: 1.0) { (animation) in
            animation.duration = 0.1
        }
        CATransaction.commit()
        
    }
    
    //
    func hideAnimated(animate : Bool, completionBlock : @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completionBlock()
            self.layer.transform = CATransform3DIdentity
        }
        if animate{
            self.layer.animateKey(animateName: "transform", fromeValue: nil, toValue: NSValue.init(caTransform3D: CATransform3DMakeScale(0.5, 0.5, 1)), customize: { (animation) in
                animation.duration = 0.55
                animation.timingFunction = CAMediaTimingFunction.init(controlPoints: 0.1, -2, 0.3, 3)
            })
            self.layer.animateKey(animateName: "opacity", fromeValue: nil, toValue: 0.0, customize: { (animation) in
                animation.duration = 0.75
            })
        }else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.layer.opacity = 0.0
            })
        }
        CATransaction.commit()
    }
    
    //
    
    //MARK: - private
    
    //
    fileprivate var shouldAnimate = false
    //
    fileprivate var animDuration : CFTimeInterval!
    //
    fileprivate var pathLayer : CAShapeLayer!
    
    //
    fileprivate var arrowCenterOffset : CGFloat = 0
    //
    fileprivate var colorAnimLayer : CAShapeLayer!

}

extension LYValuePopUpView : CAAnimationDelegate{
    
    //MARK: - CAAnimationDelegate
    func animationDidStart(_ anim: CAAnimation) {
        self.colorAnimLayer.speed = 0.0
        if self.delegate != nil{
            self.colorAnimLayer.timeOffset = CFTimeInterval(self.delegate!.currentValueOffSet())
        }
        self.pathLayer.fillColor = self.colorAnimLayer.fillColor
        if self.delegate != nil{
            self.delegate!.colorDidUpdate(opaqueColor: self.opaqueColor)
        }
    }
    
    func opaqueUIColorFromCGColor(_ col : CGColor?) -> UIColor {
        if col == nil {return UIColor()}
        if col!.components != nil{
            let components = col!.components!
            var color = UIColor()
            if col!.numberOfComponents == 2{
                color = UIColor.init(white: components[0], alpha: 1.0)
            }else{
                color = UIColor.init(red: components[0], green: components[1], blue: components[2], alpha: 1.0)
            }
            return color
        }
        return UIColor()
    }
    
    func pathForRect(rect : CGRect, arrowOffset : CGFloat) -> UIBezierPath {
        if rect.equalTo(CGRect.zero){return UIBezierPath.init()}
        
        let rect2 = CGRect.init(origin: CGPoint.zero, size: rect.size)
        var roundedRect = rect2
        roundedRect.size.height -= self.arrowLength
        let popUpPath = UIBezierPath.init(roundedRect: roundedRect, cornerRadius: self.cornerRadius)
        let arrowTipX = rect2.maxX + arrowOffset
        let tip = CGPoint.init(x: arrowTipX, y: rect2.maxY)
        
        let arrowLH = roundedRect.size.height / 2.0
        let x = arrowLH * tan(45.0 * CGFloat(Double.pi/180))
        
        let arrowPath = UIBezierPath()
        arrowPath.move(to: tip)
        arrowPath.addLine(to: CGPoint.init(x: (arrowTipX - x) > 0 ? arrowTipX - x : 0, y: roundedRect.maxY - arrowLH))
        arrowPath.addLine(to: CGPoint.init(x: arrowTipX + x > roundedRect.maxX ? roundedRect.maxX : arrowTipX + x, y: roundedRect.maxY - arrowLH))
        arrowPath.close()
        popUpPath.append(arrowPath)
        return popUpPath
    }
    
}


extension CALayer{
    func animateKey(animateName : String, fromeValue : Any?, toValue : Any, customize : ((CABasicAnimation) -> Void)?) {
        self.setValue(toValue, forKey: animateName)
        let anim = CABasicAnimation.init(keyPath: animateName)
        if self.presentation() != nil{
            anim.fromValue = fromeValue != nil ? fromeValue : self.presentation()!.value(forKey: animateName)
        }
        anim.toValue = toValue
        if customize != nil{
            customize!(anim)
        }
        self.add(anim, forKey: animateName)
    }
}
