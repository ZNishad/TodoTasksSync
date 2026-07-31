//
//  LoadingDotsView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 31.07.26.
//

import SwiftUI

struct LoadingDotsView: View {
    var color: Color = Asset.AppColor.appPrimaryText
    var dotSize: CGFloat = Asset.AppSpacing.sm

    @State private var animate = false

    var body: some View {
        HStack(spacing: dotSize * 0.6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animate ? -dotSize * 0.6 : 0)
                    .opacity(animate ? 0.4 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    LoadingDotsView()
        .padding()
}
