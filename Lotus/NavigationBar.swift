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

    public var icon: Image
    public var activeIcon: Image?
    public var width: CGFloat
    
    private let foregroundColor = Color.green
    private let height: CGFloat = 40
    
    public init(from: Image, to: Image? = nil, width: CGFloat = 100) {
        self.icon = from
        self.activeIcon = to
        self.width = width
    }
    
    public var body: some View {
        HStack {
            (isActive ? activeIcon : icon)?
                .scaleEffect(1 + 0.12 * animation)
                .foregroundColor(foregroundColor)
        }.frame(width: width, height: height)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .onAppear { animation = isActive ? 1 : 0 }
            .onTapGesture { if bar.isChangeable { bar.selectionIndex = index } }
            .onChange(of: bar.selectionIndex) { _, _ in animateSelectionChange() }
            .onChange(of: animation) { _, _ in bar.isChangeable = false; resetChangeability() }
    }
    
    private var isActive: Bool { bar.selectionIndex == index }
    
    private func animateSelectionChange() {
        withAnimation(.navigationItemBounce) { animation = isActive ? 1 : 0 }
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
}


public struct CustomNavigationBar<Content: View>: View {
    @ObservedObject private var bar = NavigationBar.shared
    @ObservedObject private var screen = Screen.shared
    public let items: [NavigationItem]
    public let content: Content
    private let height: CGFloat = 80
    private let cornerRadius: CGFloat = 32
    private let borderRadiusExtension: CGFloat = 6
    private let backgroundColor = Color.blue

    public init(items: [NavigationItem], @ViewBuilder content: () -> Content) {
        self.content = content()
        self.items = items
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                navigationBarOverlay,
                alignment: .bottom
            )
    }

    private var navigationBarOverlay: some View {
        ZStack {
            let borderRadius: CGFloat = cornerRadius + borderRadiusExtension
            RoundedRectangle(cornerRadius: borderRadius)
                .frame(width: screen.width - Screen.padding, height: height + borderRadiusExtension * 2)
                .foregroundStyle(Color.red)
            
            HStack(spacing: 0) {
                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    item
                        .environment(\.index, index)
                        .environment(\.itemCount, items.count)
                        .scaleEffect(bar.selectionIndex == index ? 1.1 : 1)
                        .animation(.easeInOut(duration: 0.2), value: bar.selectionIndex)

                    if index < items.count - 1 {
                        Spacer()
                    }
                }
            }
            .frame(width: screen.width, height: height)
            .padding(.horizontal, -Screen.halfPadding - borderRadiusExtension)
            .background(backgroundColor) // Use appropriate color for background
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

extension Animation {
    public static let navigationItemBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 22).speed(1.25)
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
