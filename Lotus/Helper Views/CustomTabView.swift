//
//  CustomTabView.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import Foundation
import SwiftUI

struct CustomTabView: View {
    @State private var currentIndex = 2
    @State private var dragOffset: CGFloat = 0
    
    private let itemWidth: CGFloat = 80
    private let peekAmount: CGFloat = 0
    private let dragThreshold: CGFloat = 100
    private let items: [String] = [
        "Test",
        "test 2",
        "Testing 3",
        "Testing 3",
        "Testing 3",
        "Testing 3",
    ]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .top, spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.foreground)
                        .frame(width: itemWidth, height: 80)
                        .overlay (alignment: .bottomLeading) {
                            Text(items[index])
                                .foregroundColor(.black).font(.title).bold()
                                .offset(y: 40)
                        }.scaleEffect(self.scaleValueForItem(at: index, in: geometry))
                }
            }.offset(x: calculateOffset() + dragOffset)
                .gesture(
                    DragGesture(coordinateSpace: .global).onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            dragOffset = value.translation.width
                        }
                        
                    }.onEnded { value in
                        withAnimation(.interactiveSpring()) {
                            finalizePosition(dragValue: value)
                            dragOffset = 0
                        }
                    }
                )
        }
    }
    
    func calculateOffset() -> CGFloat {
        let totalItemWidth = itemWidth + peekAmount
        let baseOffset = -CGFloat(currentIndex) * totalItemWidth
        
        return baseOffset
    }
    
    func scaleValueForItem(at index: Int, in geometry: GeometryProxy) -> CGFloat {
        let currentItemOffset = calculateOffset() + dragOffset
        let itemPosition = CGFloat(index) * (itemWidth + peekAmount) + currentItemOffset
        let distanceFromCenter = abs(geometry.size.width / 2 - itemPosition - itemWidth / 2)
            
        let scale: CGFloat = 0.8 + (0.2 * (1 - min(1, distanceFromCenter / (itemWidth + peekAmount))))
            
        return scale
    }

    func finalizePosition(dragValue: DragGesture.Value) {
        if dragValue.predictedEndTranslation.width > dragThreshold && currentIndex > 0 {
            currentIndex -= 1
        } else if dragValue.predictedEndTranslation.width < -dragThreshold && currentIndex < items.count - 1 {
            currentIndex += 1 // Increment the current index
        }
    }
}
