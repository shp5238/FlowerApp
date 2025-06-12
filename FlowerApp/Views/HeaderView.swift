//
//  HeaderView.swift
//  FlowerApp
//
//  Created by Shreya Pasupuleti on 6/10/25.
//

import SwiftUI

struct HeaderView: View {
    @Environment(\.colorScheme) var cS
    
    var bgColor: Color {
        cS == .dark ? Color(red: 61/255, green: 61/255, blue: 61/255) : Color.white
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(bgColor)
                .frame(height: 400)
            VStack {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                Text("The Ultimate Productivity App")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

#Preview {
    HeaderView()
}

/*
 //figure out correct bg color based on theme
 @Environment(\.colorScheme) var cS
 
 var bgColor: Color{
     if cS == .dark{
         return Color(red: 61/255, green: 61/255, blue: 61/255)
     }else{
         return Color.white //light mode
     }
 }
 
 var textBgColor: Color{
     if cS == .dark{
         return Color.white
     }else{
         return Color.gray
     }
 }
 */
