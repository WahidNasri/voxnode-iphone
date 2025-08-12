//
//  SupportsLongPress.swift
//  LinphoneApp
//
//  Created by Mehrooz Khan on 10/08/2025.
//

import SwiftUI

// Conform to `PrimitiveButtonStyle` for custom interaction behaviour

struct SupportsLongPress: PrimitiveButtonStyle {
    
    let normalColor: Color
    let pressedColor: Color
    let longPressAction: () -> ()
    
    @State var isPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .background(
                (isPressed ? pressedColor : normalColor)
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            )
            .clipShape(.circle)
            .scaleEffect(self.isPressed ? 0.9 : 1.0)
            .onTapGesture {
                configuration.trigger()
            }
            .onLongPressGesture(
                perform: {
                    self.longPressAction()
                },
                onPressingChanged: { pressing in
                    self.isPressed = pressing
                }
            )
    }
    
}

/// A modifier that applies the `SupportsLongPress` style to buttons
struct SupportsLongPressModifier: ViewModifier {
    let normalColor: Color
    let pressedColor: Color
    let longPressAction: () -> ()
    func body(content: Content) -> some View {
        content.buttonStyle(SupportsLongPress(normalColor: normalColor,pressedColor: pressedColor,longPressAction: self.longPressAction))
    }
}

/// Extend the View protocol for a SwiftUI-like shorthand version
extension View {
    func supportsLongPress(normalColor: Color,pressedColor: Color,longPressAction: @escaping () -> ()) -> some View {
        modifier(SupportsLongPressModifier(normalColor: normalColor,pressedColor: pressedColor,longPressAction: longPressAction))
    }
}

// --- At the point of use:

struct MyCustomButtonRoom: View {
    
    var body: some View {
        
        Button(action: {
            print("You've tapped me!")
        }) {
            VStack(spacing: 4) {
                Text("5")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("ABC")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 80)
            //.background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            
        }
        .supportsLongPress(normalColor: Color.gray.opacity(0.1), pressedColor: Color.gray) {
            print("Button is Long Tapped.")
        }
        
    }
    
}

#Preview {
    MyCustomButtonRoom()
}
