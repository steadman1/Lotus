//
//  DismissBar.swift
//  ponder
//
//  Created by Spencer Steadman on 11/13/23.
//

import SwiftUI
import SteadmanUI

struct DismissBar: View {
    @Environment(\.dismiss) var envDismiss
    
    let title: String
    let presentationMode: PresentationMode
    let hasDismissal: Bool
    let dismiss: (() -> Void)?
    
    init(_ title: String, presentation: PresentationMode, dismiss: @escaping () -> Void) {
        self.title = title
        self.presentationMode = presentation
        self.hasDismissal = true
        self.dismiss = dismiss
    }
    
    init(_ title: String, presentation: PresentationMode) {
        self.title = title
        self.presentationMode = presentation
        self.hasDismissal = false
        self.dismiss = nil
    }
    
    var body: some View {
        HStack {
            if presentationMode == .page {
                Button {
                    if hasDismissal {
                        dismiss!()
                    } else {
                        envDismiss()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.foreground, lineWidth: 1)
                        Image(.chevronLeft)
                            .font(.icon48)
                            .foregroundStyle(Color.foreground)
                    }.frame(width: 48, height: 48)
                        .padding(.trailing, Screen.halfPadding)
                }
            } else {
                Spacer()
                    .frame(width: 48, height: 48)
            }
            Spacer()
            Text(title)
                .lineLimit(2)
                .font(.sansBody)
                .fontWeight(.bold)
                .frame(maxHeight: 48)
                .foregroundStyle(Color.primaryText)
                .multilineTextAlignment(.center)
                .animation(.snappy, value: title)
            
            Spacer()
            
            if presentationMode == .fullscreen || presentationMode == .sheet {
                Button {
                    if hasDismissal {
                        dismiss!()
                    } else {
                        envDismiss()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.foreground, lineWidth: 1)
                        Image(.chevronLeft)
                            .font(.icon48)
                            .foregroundStyle(Color.foreground)
                    }.frame(width: 48, height: 48)
                        .padding(.trailing, Screen.halfPadding)
                }
            } else {
                Spacer()
                    .frame(width: 48, height: 48)
            }
        }.padding(.horizontal, Screen.padding)
            .padding(.top, Screen.halfPadding)
    }
    
    enum PresentationMode {
        case sheet, fullscreen, page
    }
}

struct BlankDismissBar: View {
    @Environment(\.dismiss) var envDismiss
    let dismiss: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                ZStack {
                    Image(systemName: "xmark")
                        .font(.miniIcon.bold())
                        .foregroundStyle(.primaryText)
                }.shadow(color: .black.opacity(0.8), radius: 8)
            }
        }.padding([.horizontal, .top], Screen.padding)
    }
}
