//
//  Ripples.swift
//  Pods-Ripples_Example
//
//  Created by CatchZeng on 2018/8/1.
//

import Foundation
import UIKit

internal let rippleAnimationKey = "rippleAnimationKey"

open class Ripples: CAReplicatorLayer, CAAnimationDelegate {
    
    override open var backgroundColor: CGColor? {
        didSet {
            ripple.backgroundColor = backgroundColor
            guard let backgroundColor = backgroundColor else {return}
            let oldAlpha = alpha
            alpha = backgroundColor.alpha
            if alpha != oldAlpha {
                recreate()
            }
        }
    }
    
    open var rippleCount: Int = 1 {
        didSet {
            if rippleCount < 1 {
                rippleCount = 1
            }
            instanceCount = rippleCount
            updateInstanceDelay()
        }
    }
    
    open var radius: CGFloat = 60 {
        didSet {
            updateRipple()
        }
    }
    
    open var animationDuration: TimeInterval = 5 {
        didSet {
            updateInstanceDelay()
        }
    }
    
    override open var repeatCount: Float {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.repeatCount = repeatCount
            }
        }
    }
    
    open var scaleFromValue: Float = 0.0 {
        didSet {
            if scaleFromValue >= 1.0 {
                scaleFromValue = 0.0
            }
            recreate()
        }
    }
    
    open var keyTimeForHalfOpacity: Float = 0.3 {
        didSet {
            recreate()
        }
    }
    
    open var rippleInterval: TimeInterval = 0
    
    open var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault) {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.timingFunction = timingFunction
            }
        }
    }
    
    open var isAnimating: Bool {
        guard let keys = ripple.animationKeys() else {return false}
        return keys.count > 0
    }
    
    fileprivate let ripple = CALayer()
    fileprivate var animationGroup: CAAnimationGroup!
    fileprivate var alpha: CGFloat = 0.5
    fileprivate weak var prevSuperlayer: CALayer?
    fileprivate var prevLayerIndex: Int?
    
    // MARK: - Init
    
    override public init() {
        super.init()
        setupRipple()
        instanceDelay = 1
        repeatCount = MAXFLOAT
        backgroundColor = UIColor(red: 0, green: 0.455, blue: 0.756, alpha: alpha).cgColor
        setupNotifications()
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    open func start() {
        setupRipple()
        setupAnimationGroup()
        ripple.add(animationGroup, forKey: rippleAnimationKey)
    }
    
    open func stop() {
        ripple.removeAllAnimations()
        animationGroup = nil
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(save),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resume),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    fileprivate func setupRipple() {
        ripple.contentsScale = UIScreen.main.scale
        ripple.opacity = 0
        addSublayer(ripple)
        updateRipple()
    }
    
    fileprivate func setupAnimationGroup() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = scaleFromValue
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = animationDuration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.values = [alpha, alpha * 0.5, 0.0]
        opacityAnimation.keyTimes = [0.0, NSNumber(value: keyTimeForHalfOpacity), 1.0]
        
        animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        animationGroup.duration = animationDuration + rippleInterval
        animationGroup.repeatCount = repeatCount
        if let timingFunction = timingFunction {
            animationGroup.timingFunction = timingFunction
        }
        animationGroup.delegate = self
    }
    
    fileprivate func updateRipple() {
        let diameter: CGFloat = radius * 2
        ripple.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: diameter, height: diameter))
        ripple.cornerRadius = radius
        ripple.backgroundColor = backgroundColor
    }
    
    fileprivate func updateInstanceDelay() {
        guard rippleCount >= 1 else { fatalError() }
        instanceDelay = (animationDuration + rippleInterval) / Double(rippleCount)
    }
    
    fileprivate func recreate() {
        guard animationGroup != nil else { return }        // Not need to be recreated.
        stop()
        let when = DispatchTime.now() + Double(Int64(0.2 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: when) { () -> Void in
            self.start()
        }
    }
    
    // MARK: - Internal Methods
    
    @objc internal func save() {
        prevSuperlayer = superlayer
        prevLayerIndex = prevSuperlayer?.sublayers?.index(where: {$0 === self})
    }
    
    @objc internal func resume() {
        if let prevSuperlayer = prevSuperlayer, let prevLayerIndex = prevLayerIndex {
            prevSuperlayer.insertSublayer(self, at: UInt32(prevLayerIndex))
        }
        if ripple.superlayer == nil {
            addSublayer(ripple)
        }
        let isAnimating = ripple.animation(forKey: rippleAnimationKey) != nil
        
        if let animationGroup = animationGroup, !isAnimating {
            ripple.add(animationGroup, forKey: rippleAnimationKey)
        }
    }
    
    // MARK: - Delegate
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let keys = ripple.animationKeys(), keys.count > 0 {
            ripple.removeAllAnimations()
        }
        ripple.removeFromSuperlayer()
    }
}
