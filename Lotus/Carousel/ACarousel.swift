/**
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
 */

import SwiftUI


@available(iOS 13.0, OSX 10.15, *)
public struct ACarousel<Data, ID, Content, ReturnView> : View where Data : RandomAccessCollection, ID : Hashable, Content : View, ReturnView : View {
    
    @ObservedObject
    private var viewModel: ACarouselViewModel<Data, ID>
    private let content: (Data.Element) -> Content
    private let returnView: ReturnView
    
    public var body: some View {
        GeometryReader { proxy -> AnyView in
            viewModel.viewSize = proxy.size
            return AnyView(generateContent(proxy: proxy))
        }.clipped()
    }
    
    private func generateContent(proxy: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(zip(0..<viewModel.data.count, viewModel.data)), id: \.0) { index, data in
                let scale: CGFloat = viewModel.itemScaling(data)
                content(data)
                    .frame(width: viewModel.itemWidth)
                    .scaleEffect(x: scale, y: scale, anchor: .top)
                    .offset(x: generateOffset(for: data, with: index))
                    .animation(.snappy, value: viewModel.activeIndex)
            }
            Button {
                viewModel.activeIndex = 0
            } label: {
                returnView
            }
        }
        .frame(width: proxy.size.width, alignment: .leading)
        .offset(x: viewModel.offset)
        .gesture(viewModel.dragGesture)
        .animation(viewModel.offsetAnimation, value: viewModel.offset)
        .onReceive(timer: viewModel.timer, perform: viewModel.receiveTimer)
        .onReceiveAppLifeCycle(perform: viewModel.setTimerActive)
    }
    
    private func generateOffset(for data: Data.Element, with index: Int) -> CGFloat {
        let spacing: CGFloat = -(viewModel.itemWidth - viewModel.itemWidth * viewModel.sidesScaling) / 2
        let isPast: CGFloat = viewModel.activeIndex > index ? -1 : 1
        switch generateAdjacency(for: index) {
        case .active:
            return 0
        case .adjacent:
            return spacing * isPast
        case .nonadjacent:
            return (spacing - spacing * 2 * CGFloat(viewModel.activeIndex - (index - 1))) * isPast
        }
    }
    
    private func generateAdjacency(for index: Int) -> Adjacency {
        if (viewModel.activeIndex == index) { return .active }
        else if ([viewModel.activeIndex - 1, viewModel.activeIndex + 1].contains(where: { $0 == index })) { return .adjacent }
        else { return .nonadjacent }
    }
    
    private enum Adjacency {
        case active, adjacent, nonadjacent
    }
}


// MARK: - Initializers

@available(iOS 13.0, OSX 10.15, *)
extension ACarousel {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// - Parameters:
    ///   - data: The data that the ``ACarousel`` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - index: The index of currently active.
    ///   - spacing: The distance between adjacent subviews, default is 10.
    ///   - headspace: The width of the exposed side subviews, default is 10
    ///   - sidesScaling: The scale of the subviews on both sides, limits 0...1,
    ///     default is 0.8.
    ///   - isWrap: Define views to scroll through in a loop, default is false.
    ///   - autoScroll: A enum that define view to scroll automatically. See
    ///     ``ACarouselAutoScroll``. default is `inactive`.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, index: Binding<Int> = .constant(0), itemWidth: CGFloat = 80, spacing: CGFloat = 10, headspace: CGFloat = 10, sidesScaling: CGFloat = 0.7, isWrap: Bool = false, autoScroll: ACarouselAutoScroll = .defaultActive, canMove: Bool = true, @ViewBuilder content: @escaping (Data.Element) -> Content, @ViewBuilder returnView: @escaping () -> ReturnView) {
        
        self.viewModel = ACarouselViewModel(data, id: id, index: index, itemWidth: itemWidth, spacing: spacing, headspace: headspace, sidesScaling: sidesScaling, isWrap: isWrap, autoScroll: autoScroll, canMove: canMove)
        self.content = content
        self.returnView = returnView()
    }
    
}

@available(iOS 13.0, OSX 10.15, *)
extension ACarousel where ID == Data.Element.ID, Data.Element : Identifiable {
    
    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ACarousel`` instance uses to
    ///     create views dynamically.
    ///   - index: The index of currently active.
    ///   - spacing: The distance between adjacent subviews, default is 10.
    ///   - headspace: The width of the exposed side subviews, default is 10
    ///   - sidesScaling: The scale of the subviews on both sides, limits 0...1,
    ///      default is 0.8.
    ///   - isWrap: Define views to scroll through in a loop, default is false.
    ///   - autoScroll: A enum that define view to scroll automatically. See
    ///     ``ACarouselAutoScroll``. default is `inactive`.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, index: Binding<Int> = .constant(0), itemWidth: CGFloat = 80, spacing: CGFloat = 10, headspace: CGFloat = 10, sidesScaling: CGFloat = 0.7, isWrap: Bool = false, autoScroll: ACarouselAutoScroll = .defaultActive, canMove: Bool = true, @ViewBuilder content: @escaping (Data.Element) -> Content, @ViewBuilder returnView: @escaping () -> ReturnView) {
        
        self.viewModel = ACarouselViewModel(data, index: index, itemWidth: itemWidth, spacing: spacing, headspace: headspace, sidesScaling: sidesScaling, isWrap: isWrap, autoScroll: autoScroll, canMove: canMove)
        self.content = content
        self.returnView = returnView()
    }
    
}
