//
//  OnboardingView.swift
//  HabitTrackerApp
//
//  Created by Admin on 6/26/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var selectedItem: OnboardingItem = onboardingItems.first!
    @State private var items: [OnboardingItem] = onboardingItems
    @State private var activeIndex: Int = 0
    @State private var askUsername: Bool = false
    @AppStorage("username") private var username: String = ""
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button {
                updateItem(isForward: false)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.blue.gradient)
                    .contentShape(.rect)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(selectedItem.id != onboardingItems.first?.id ? 1 : 0)
            
            ZStack {
                ForEach(onboardingItems) { item in
                    AnimatedIconView(item)
                }
            }
            .frame(height: 250)
            .frame(maxHeight: .infinity)
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(onboardingItems) { item in
                        Capsule()
                            .fill((selectedItem.id == item.id ? .blue : Color.gray).gradient)
                            .frame(width: selectedItem.id == item.id ? 25 : 4, height: 4)
                    }
                }
                .padding(.bottom, 15)
                
                Text(selectedItem.title)
                    .font(.title.bold())
                    .contentTransition(.numericText())
                
                Text(selectedItem.description)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .contentTransition(.numericText())
                
                Button {
                    if selectedItem.id == onboardingItems.last?.id {
                        askUsername.toggle()
                    }
                    updateItem(isForward: true)
                } label: {
                    Text(selectedItem.id == onboardingItems.last?.id ? "Continue" : "Next")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .frame(width: 250)
                        .padding(.vertical, 12)
                        .background(.blue.gradient, in: .capsule)
                }
                .padding(.top, 25)
            }
            .multilineTextAlignment(.center)
            .frame(width: 300)
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .overlay {
            ZStack(alignment: .bottom) {
                Rectangle().fill(.black.opacity(askUsername ? 0.3 : 0))
                    .ignoresSafeArea()
                    .onTapGesture {
                        askUsername = false
                    }
                
                if askUsername {
                    UserNameView()
                        .transition(.move(edge: .bottom).combined(with: .offset(y: 100)))
                }
            }
        }
        .animation(.snappy, value: askUsername)
    }
    
    @ViewBuilder
    func UserNameView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Let's Start With Your Name")
                .font(.caption.bold())
                .foregroundStyle(.gray)
            
            TextField("Username", text: $username)
                .applyPaddedBackground(10, hPadding: 15, vPadding: 12)
                .opacityShadow(.black, opacity: 0.1, radius: 5)
            
            Button {
                isOnboardingCompleted.toggle()
            } label: {
                Text("Start Tracking Your Habits")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(.blue.gradient, in: .rect(cornerRadius: 10))
            }
            .padding(.top, 10)
        }
        .applyPaddedBackground(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func AnimatedIconView(_ item: OnboardingItem) -> some View {
        let isSelected = selectedItem.id == item.id
        
        Image(systemName: item.image)
            .font(.system(size: 80))
            .foregroundStyle(.white.shadow(.drop(radius: 10)))
            .blendMode(.overlay)
            .frame(width: 120, height: 120)
            .background(.blue.gradient, in: .rect(cornerRadius: 32))
            .background {
                RoundedRectangle(cornerRadius: 35)
                    .fill(.background)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: 1, y: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 1, x: -1, y: -1)
                    .padding(-3)
                    .opacity(selectedItem.id == item.id ? 1 : 0)
            }
            .rotationEffect(.init(degrees: -item.rotation))
            .scaleEffect(isSelected ? 1.1 : item.scale, anchor: item.anchor)
            .offset(x: item.offset)
            .rotationEffect(.init(degrees: item.rotation))
            .zIndex(isSelected ? 2 : item.zindex)
    }
    
    func updateItem(isForward: Bool) {
        guard isForward ? activeIndex != onboardingItems.count - 1 : activeIndex != 0 else {
            return
        }
        
        var fromIndex: Int
        var extraOffset: CGFloat
        
        if isForward {
            activeIndex += 1
        } else {
            activeIndex -= 1
        }
        
        if isForward {
            fromIndex = activeIndex - 1
            extraOffset = onboardingItems[activeIndex].extraOffset
        } else {
            fromIndex = activeIndex + 1
            extraOffset = onboardingItems[activeIndex].extraOffset
        }
        
        for index in onboardingItems.indices {
            onboardingItems[index].zindex = 0
        }
        
        Task {
            withAnimation(.bouncy(duration: 3)) {
                onboardingItems[fromIndex].scale = onboardingItems[activeIndex].scale
                onboardingItems[fromIndex].rotation = onboardingItems[activeIndex].rotation
                onboardingItems[fromIndex].anchor = onboardingItems[activeIndex].anchor
                onboardingItems[fromIndex].offset = onboardingItems[activeIndex].offset
                
                onboardingItems[activeIndex].offset = extraOffset
                onboardingItems[fromIndex].zindex = 1
            }
            
            try? await Task.sleep(for: .seconds(0.1))
            
            withAnimation(.bouncy(duration: 2.9)) {
                onboardingItems[activeIndex].scale = 1
                onboardingItems[activeIndex].rotation = .zero
                onboardingItems[activeIndex].anchor = .center
                onboardingItems[activeIndex].offset = .zero
                
                selectedItem = onboardingItems[activeIndex]
            }
            
        }
        
    }
    
}

#Preview {
    OnboardingView()
}
