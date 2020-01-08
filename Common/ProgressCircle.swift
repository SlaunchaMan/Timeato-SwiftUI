//
//  ProgressCircle.swift
//  Timeato
//
//  Created by Jeff Kelley on 1/4/20.
//  Copyright © 2020 Jeff Kelley. All rights reserved.
//

import SwiftUI

struct ProgressCircle: View {
    
    @Binding var progress: CGFloat?
    
    #if os(iOS)
    var circleBackgroundColor: Color = Color(.tertiarySystemFill)
    var circleStrokeColor: Color = Color(.secondarySystemFill)
    #else
    var circleBackgroundColor: Color = Color(.gray)
    var circleStrokeColor: Color = Color(.lightGray)
    #endif
    
    var lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle().fill(circleBackgroundColor)
            Circle()
                .stroke(circleStrokeColor, lineWidth: lineWidth)
                .padding(.all, lineWidth / 2)
            
            progress.map {
                Circle()
                    .trim(from: 0, to: $0)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .fill(Color.accentColor)
                    .padding(.all, lineWidth / 2)
            }
        }
    }
    
}

#if DEBUG
struct ProgressCircle_Previews: PreviewProvider {
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.percent
        return formatter
    }()
    
    static var previews: some View {
        #if os(iOS)
        return ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.25)), id: \.self) { progress in
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ProgressCircle(progress: Binding<CGFloat?>(get: { return CGFloat(progress) },
                                                           set: { _ in }),
                               lineWidth: 10)
                    .background(Color(.systemBackground))
                    .environment(\.colorScheme, colorScheme)
                    .previewLayout(.fixed(width: 250, height: 250))
                    .previewDisplayName("\(colorScheme) - \(formatter.string(from: NSNumber(value: progress))!)")
            }
        }
        #else
        return ForEach(Array(stride(from: 0.0, through: 1.0, by: 0.25)), id: \.self) { progress in
            ProgressCircle(progress: Binding<CGFloat?>(get: { return CGFloat(progress) },
                                                       set: { _ in }),
                           lineWidth: 5)
                .previewLayout(.fixed(width: 250, height: 250))
                .previewDisplayName(formatter.string(from: NSNumber(value: progress))!)
        }
        #endif
        
    }
    
}
#endif
