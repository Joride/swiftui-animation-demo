//
//  LevelView.swift
//  SwiftUI-Animations
//

import SwiftUI

struct LevelView: View 
{
    let centerLevel: Double
    let levelsInView: Int
    
    private let levels: [Level]
    init(centerLevel: Double,
         levelsInView: Int = 20)
    {
        self.centerLevel = centerLevel
        self.levelsInView = levelsInView
        
        var levels = [Level]()
        let firstLevel = Int(centerLevel) - (levelsInView / 2)
        for index in 0 ..< levelsInView
        {
            let value = firstLevel + index
            let level = Level(id: value, index: index)
            levels.append(level)
        }
        self.levels = levels
    }
    
    struct Level: Identifiable
    {
        var id: Int
        var index: Int
    }
    
    var body: some View
    {
        GeometryReader { geometry in
            let widthPerLevel = geometry.size.width / CGFloat(levelsInView)
            let lineHeight = geometry.size.height / 4
            
            ForEach(levels) { aLevel in
                Text("\(aLevel.id)")
                    .font(.system(size: 8))
                    .position(x: CGFloat(aLevel.index) * widthPerLevel)
                    .offset(y: (geometry.size.height - lineHeight) / 2 - 8)
                
                Color.black
                    .frame(width: 1,
                           height: geometry.size.height / 4)
                    .offset(x: CGFloat(aLevel.index) * widthPerLevel)
                    .offset(y: (geometry.size.height - lineHeight) / 2)
            }
        }
    }
}

#Preview
{
    LevelView(centerLevel: 90)
}
