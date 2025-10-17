//
//  Fingers.swift
//  RealityKitApp
//
//  Created by Marcos Bezerra on 30/09/25.
//
import Foundation

enum Fingers: String {
    
    case pinky
    case ring
    case middle
    case index
    case thumb
    
    static var root: String {
        Joints.root.rawValue
    }
    
    func jointName(_ joint: Fingers.Joints) -> String {
        if joint == .middle && self == .thumb {
            fatalError("Thumb Finger has no middle joint.")
        }

        return joint == .root
        ? joint.rawValue
        : joint.rawValue.replacing("finger", with: self.rawValue)
    }
    
    enum Joints: String {
        case root = "wrist"
        case metacarpal = "wrist/finger_metacarpal"
        case proximal = "wrist/finger_metacarpal/finger_proximal"
        case middle = "wrist/finger_metacarpal/finger_proximal/finger_middle"
        case distal = "wrist/finger_metacarpal/finger_proximal/finger_middle/finger_distal"
    }
}



