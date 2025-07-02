//
//  View+Extensions.swift
//  Base
//
//  Created by José Ramón Ortiz Castañeda on 01/07/25.
//

import SwiftUI

extension View{
    
    // Close all keyboards
    func closeKyeboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    // MARK: DISABLINGH WITH OPACITY
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 0.1)
    }
    
    func hAlign(_ aligment: Alignment) -> some View{
        self.frame(maxWidth: .infinity, alignment: aligment)
    }
    
    func vAlign(_ aligment: Alignment) -> some View{
        self.frame(maxHeight: .infinity, alignment: aligment)
    }
    
    // MARK: Custom Border View With Padding
    func border(_ width: CGFloat, _ color: Color) -> some View{
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    // MARK: Custom Fill View With Padding
    func fillView(_ color: Color) -> some View{
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background{
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
    
}
