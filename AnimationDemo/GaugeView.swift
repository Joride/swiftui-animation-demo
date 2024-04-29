//
//  GaugeView.swift
//  SwiftUI-Animations
//

import SwiftUI

struct GaugeView: View
{
    @Binding
    var level: Double
    
    @State
    var currentLevel: Double = 0
    
    @State
    var previousLevel: Double = 0
    
    @State
    var isAnimatingToNewLevel = false
    
    private let levelsInView = 20
    
    var body: some View
    {
        GeometryReader { geometry in
            let LevelHeight: CGFloat = 80
            
            // layout during animations
            let newOffset = -(currentLevel - previousLevel) / CGFloat(levelsInView) * geometry.size.width
            
            Rectangle()
                .foregroundColor(.purple)
//            LevelView(centerLevel: isAnimatingToNewLevel ? previousLevel : currentLevel,
//                      levelsInView: levelsInView)
            .frame(width: geometry.size.width)
            .frame(height: LevelHeight)
            .background(Color.red)
            .offset(y: (geometry.size.height - LevelHeight) / 2)
            .offset(x: isAnimatingToNewLevel ? newOffset : 0)
        }
        .background(Color.gray)
        .onChange(of: level) { (oldValue, newValue) in
            isAnimatingToNewLevel = true
            withAnimation(mergingEaseInAnimation())
            {
                previousLevel = currentLevel
                currentLevel = newValue
            } completion:
            {
                /// `previousLevel` needs to be updated, so that when a new
                /// animation starts, the view starts from the position
                /// given during `isAnimatingToNewLevel = false`
                previousLevel = currentLevel
                isAnimatingToNewLevel = false
                
            }
        }
    }
    
    private func mergingEaseInAnimation() -> Animation
    {
        Animation.mergingEaseIn(merge: true,
                                duration: 6,
                                progressHandler: animationProgressed(relativeDuration:totalDuration:))
    }
    
    private func animationProgressed(relativeDuration: CGFloat?, 
                                     totalDuration: CGFloat) -> Void
    {
        
    }
}

#Preview 
{
    GaugeView(level: .constant(0))
}



extension Animation
{
    static func mergingEaseIn(merge: Bool,
                              duration: Double = 2.0,
                              progressHandler: @escaping (CGFloat?, CGFloat) -> Void) -> Animation
    {
        Animation(MergingEaseInAnimation(merge: merge,
                                         duration: duration,
                                         progressHandler: progressHandler))
    }
}

struct MergingEaseInState<Value: VectorArithmetic>: AnimationStateKey
{
    var from: Value? = nil
    var interruption: TimeInterval? = nil
    
    static var defaultValue: Self { MergingEaseInState() }
}

extension AnimationContext
{
    var mergingEaseInState: MergingEaseInState<Value>
    {
        get { state[MergingEaseInState<Value>.self] }
        set { state[MergingEaseInState<Value>.self] = newValue }
    }
}

struct MergingEaseInAnimation: CustomAnimation
{
    static func == (lhs: MergingEaseInAnimation,
                    rhs: MergingEaseInAnimation) -> Bool
    {
        lhs.uuid == rhs.uuid
    }
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(uuid)
    }
    
    private let uuid = UUID()
    let merge: Bool
    let duration: TimeInterval
    let progressHandler: (CGFloat?, CGFloat) -> Void
    
    private static var count = 0
    func animate<V>(value: V,
                    time: TimeInterval,
                    context: inout AnimationContext<V>) -> V? where V : VectorArithmetic
    {
        guard time < duration + (context.mergingEaseInState.interruption ?? 0) else
        {
            progressHandler(nil, duration)
            return nil
        }
        let relativeProgress = CGFloat(time / duration)
        
        print("\(MergingEaseInAnimation.count) - \(relativeProgress)")
        MergingEaseInAnimation.count += 1
        
        
        defer  { progressHandler(relativeProgress, duration) }
        
        if let v = context.mergingEaseInState.from,
           let interruptionTime = context.mergingEaseInState.interruption
        {
            return v.interpolated(towards: value,
                                  amount: (time - interruptionTime)/duration)
        }
        else
        {
            return value.scaled(by: relativeProgress)
        }
        
    }
    
    func shouldMerge<V>(previous: Animation,
                        value: V,
                        time: TimeInterval,
                        context: inout AnimationContext<V>) -> Bool where V : VectorArithmetic
    {
        guard merge else { return false }
        
        context.mergingEaseInState.from = previous.base.animate(value: value,
                                                                time: time,
                                                                context: &context)
        context.mergingEaseInState.interruption = time
        
        return true
    }
}
