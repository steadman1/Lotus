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
    
    private let foregroundColor = Color.green
    private let height: CGFloat = 26
    
    public init(name: String, from: Image, to: Image? = nil, width: CGFloat = 100) {
        self.name = name
        self.icon = from
        self.activeIcon = to
        self.width = width
    }
    
    public var body: some View {
        VStack {
            HStack {
                (isActive ? activeIcon : icon)?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                    .foregroundColor(foregroundColor)
            }.frame(width: width, height: height)
                .onTapGesture { if bar.isChangeable { bar.selectionIndex = index } }
                .onChange(of: bar.selectionIndex) { _, _ in animateSelectionChange() }
                .onChange(of: animation) { _, _ in bar.isChangeable = false; resetChangeability() }
            Text(name)
                .fontWeight(.bold)
                .foregroundStyle(foregroundColor)
        }.scaleEffect(1 - 0.15 * animation)
    }
    
    private var isActive: Bool { bar.selectionIndex == index }
    
    private func animateSelectionChange() {
        withAnimation(.navigationItemBounce) {
            animation = isActive ? 1 : 0
        } completion: {
            Screen.impact(enabled: true)
            withAnimation(.navigationItemBounce) {
                animation = 0
            }
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
}


public struct CustomNavigationBar<Content: View>: View {
    @ObservedObject private var bar = NavigationBar.shared
    @ObservedObject private var screen = Screen.shared
    public let items: [NavigationItem]
    public let content: Content
    
    private let height: CGFloat = 90
    private let cornerRadius: CGFloat = 24
    private let borderRadius: CGFloat = 3
    private let backgroundColor = Color.white
    private let borderColor = Color.green

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
            Rectangle()
                .frame(height: cornerRadius)
                .frame(maxWidth: .infinity)
                .foregroundStyle(backgroundColor)
                .background(backgroundColor)
                .offset(y: height / 2 - cornerRadius / 2)

            let borderCornerRadius: CGFloat = cornerRadius + borderRadius
            RoundedRectangle(cornerRadius: borderCornerRadius)
                .frame(height: borderCornerRadius * 2)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -borderRadius)
                .foregroundStyle(borderColor)
                .offset(y: height / -2 + cornerRadius - borderRadius)

            HStack(spacing: 0) {
                Spacer()
                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    item
                        .environment(\.index, index)
                        .environment(\.itemCount, items.count)

                    Spacer()
                }
            }
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(backgroundColor) // Use appropriate color for background
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

extension Animation {
    public static let navigationItemBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 12).speed(1.8)
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
