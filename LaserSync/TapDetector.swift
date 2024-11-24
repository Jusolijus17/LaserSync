//
//  TapDetector.swift
//  LaserSync
//
//  Created by Justin Lefrançois on 2024-09-25.
//

import SwiftUI
import UIKit

class MyTapGesture : UITapGestureRecognizer {

    var didBeginTouch: (()->Void)?
    var didEndTouch: (()->Void)?

    init(target: Any?, action: Selector?, didBeginTouch: (()->Void)? = nil, didEndTouch: (()->Void)? = nil) {
        super.init(target: target, action: action)
        self.didBeginTouch = didBeginTouch
        self.didEndTouch = didEndTouch
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.didBeginTouch?()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.didEndTouch?()
    }
}

struct TouchesHandler: UIViewRepresentable {
    var didBeginTouch: (()->Void)?
    var didEndTouch: (()->Void)?

    func makeUIView(context: UIViewRepresentableContext<TouchesHandler>) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(context.coordinator.makeGesture(didBegin: didBeginTouch, didEnd: didEndTouch))
        return view;
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TouchesHandler>) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator {
        @objc
        func action(_ sender: Any?) {
            print("Tapped!")
        }

        func makeGesture(didBegin: (()->Void)?, didEnd: (()->Void)?) -> MyTapGesture {
            MyTapGesture(target: self, action: #selector(self.action(_:)), didBeginTouch: didBegin, didEndTouch: didEnd)
        }
    }
    typealias UIViewType = UIView
}

struct TestCustomTapGesture: View {
    var body: some View {
        Text("Hello, World!")
            .padding()
            .background(Color.yellow)
            .overlay(TouchesHandler(didBeginTouch: {
                print(">> did begin")
            }, didEndTouch: {
                print("<< did end")
            }))
    }
}

struct TestCustomTapGesture_Previews: PreviewProvider {
    static var previews: some View {
        TestCustomTapGesture()
    }
}
