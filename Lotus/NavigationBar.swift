//
//  NavigationBar.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/26/24.
//

#if os(iOS)
import SwiftUI
import SteadmanUI

import SwiftUI

public struct NavigationItem: View {
    @Environment(\.index) private var index
    @Environment(\.itemCount) private var itemCount
    @ObservedObject private var bar = NavigationBar.shared
    
    @State private var animation: CGFloat = 0

    public let name: String
    public let icon: Image
    public let activeIcon: Image?
    public let width: CGFloat
    
    private let textSize: CGSize
    private let foregroundColor = Color.foreground
    
    public init(name: String, from: Image, to: Image? = nil, width: CGFloat = 100) {
        self.name = name
        self.icon = from
        self.activeIcon = to
        self.width = width
        self.textSize = CGSize(width: name.widthOfString(usingFont: Font.uiSerifBody),
                               height: name.heightOfString(usingFont: Font.uiSerifBody))
    }
    
    public var body: some View {
        let paddedWidth: CGFloat = textSize.width + Screen.padding * 2
        let paddedHeight: CGFloat = textSize.height + Screen.padding
        ZStack {
            VStack {
                Text(name)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .opacity(isActive ? 0 : 1)
                    .animation(.snappy.delay(isActive ? 0 : 0.25), value: bar.selectionIndex)
                    .font(.serifNavigation)
                    .foregroundStyle(Color.primaryText)
            }.frame(width: paddedHeight * (animation) + paddedWidth * (1 - animation),
                    height: paddedHeight)
                .background(isActive ? Color.foreground : Color.background)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .animation(.snappy, value: bar.selectionIndex == index)
        }.padding(1)
            .background(isActive ? Color.background : Color.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .animation(.snappy, value: bar.selectionIndex == index)
            .onAppear { self.animation = bar.selectionIndex == index ? 1 : 0 }
            .onChange(of: bar.selectionIndex) { _, _ in animateSelectionChange() }
            .onChange(of: animation) { _, _ in bar.isChangeable = false; resetChangeability() }
            .onTapGesture {
                if bar.isChangeable {
                    Screen.impact(enabled: true, style: .soft)
                    bar.selectionIndex = index
                }
                
            }
//        VStack {
//            HStack {
//                (isActive ? activeIcon : icon)?
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: NavigationBar.iconHeight)
//                    .foregroundColor(foregroundColor)
//            }.frame(width: width, height: NavigationBar.iconHeight)
//                
//                .onChange(of: bar.selectionIndex) { _, _ in animateSelectionChange() }
//                .onChange(of: animation) { _, _ in bar.isChangeable = false; resetChangeability() }
//        }.scaleEffect(1 - 0.1 * animation)
    }
    
    private var isActive: Bool { bar.selectionIndex == index }
    
    private func animateSelectionChange() {
        withAnimation(.snappy) {
            animation = isActive ? 1 : 0
        }
    }
    
    private func resetChangeability() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            bar.isChangeable = true
        }
    }
}


public class NavigationBar: ObservableObject {
    public static let shared = NavigationBar()
    @Published var isShowing = false
    @Published var isChangeable = true
    @Published var selectionIndex = 0
    
    private init() {} // Ensures NavigationBar is a true singleton
    
    public static let iconHeight: CGFloat = 24
}


public struct CustomNavigationBar<Content: View>: View {
    @ObservedObject private var bar = NavigationBar.shared
    @ObservedObject private var screen = Screen.shared
    
    @State private var animation: CGFloat = 0
    
    public let items: [NavigationItem]
    public let content: Content
    
    private let cornerRadius: CGFloat = 24
    private let borderRadius: CGFloat = 3
    private let backgroundColor = Color.background
    private let borderColor = Color.foreground
    private let bottomPadding: CGFloat = 4

    public init(items: [NavigationItem], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.items = items
    }

    public var body: some View {
        Extract(content) { views in
        // ^ from https://github.com/GeorgeElsham/ViewExtractor
            VStack {
                ForEach(Array(zip(views.indices, views)), id: \.0) { index, view in
                    if bar.selectionIndex == index {
                        view
                            
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    navigationBarOverlay
                        .padding(.bottom, screen.safeAreaInsets.bottom),
                    alignment: .bottom
                ).safeAreaInset(edge: .top) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: screen.safeAreaInsets.top)
                        .foregroundStyle(Color.background)
                }.ignoresSafeArea()
        }
    }

    private var navigationBarOverlay: some View {
        let height = NavigationBar.iconHeight + Screen.padding * 3 // 2 + 1 to account for the name of each nav item
        return ZStack(alignment: .bottom) {
            let shadowHeight = items[bar.selectionIndex].name.heightOfString(usingFont: Font.uiSerifBody) + Screen.padding * 2
            
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: shadowHeight + bottomPadding) // 4 for padding
                        .foregroundStyle(LinearGradient(colors: [.background.opacity(0.00001), .background],
                                                   startPoint: .top,
                                                   endPoint: .bottom))
                    
                    HStack {
                        ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                            item
                                .environment(\.index, index)
                                .environment(\.itemCount, items.count)
                            
                            if index < items.count - 1 {
                                Spacer()
                            }
                        }
                    }.padding(.horizontal, Screen.halfPadding)
                        .padding(.bottom, bottomPadding)
                }
                ZStack {
                    ExpandingText(items[bar.selectionIndex].name.uppercased())
                        .environmentObject(screen)
                        .padding(.horizontal, Screen.halfPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: 300 * animation)
                }.background(Color.background)
            }.offset(y: height / 2 - Screen.padding * 1.5)
                .onChange(of: bar.selectionIndex) { _, _ in animateSelectionChange() }
                .onChange(of: animation) { _, _ in bar.isChangeable = false; resetChangeability() }
        }
    }
    
    private func animateSelectionChange() {
        animation = 1
        withAnimation(.snappy) {
            animation = 0
        }
    }
    
    private func resetChangeability() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            bar.isChangeable = true
        }
    }
}

extension Animation {
    public static let navigationItemBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 16).speed(2.5)
}

extension EnvironmentValues {
  public var index: Int {
    get { self[IndexKey.self] }
    set { self[IndexKey.self] = newValue }
  }
    public var itemCount: Int {
        get { self[ItemCountKey.self] }
        set { self[ItemCountKey.self] = newValue }
      }
}

private struct IndexKey: EnvironmentKey {
  public static let defaultValue = 0
}

private struct ItemCountKey: EnvironmentKey {
  public static let defaultValue = 0
}
#endif
