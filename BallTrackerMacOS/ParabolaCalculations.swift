//
// TennisBallTracker (BallTrackerMacOS)
// File created by Adrian Baumgart on 05.01.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://github.com/leabmgrt/TennisBallTracker
//

import Foundation

func calculate_parabola_vertex(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double) -> Parabola_Vertex {
    let denom = (x1-x2) * (x1-x3) * (x2 - x3)
    let a = (x3 * (y2-y1) + x2 * (y1-y3) + x1 * (y3-y2)) / denom
    let b = (x3*x3 * (y1-y2) + x2*x2 * (y3-y1) + x1*x1 * (y2-y3)) / denom
    let c = (x2 * x3 * (x2-x3) * y1+x3 * x1 * (x3-x1) * y2+x1 * x2 * (x1-x2) * y3) / denom
    
    return .init(a: a, b: b, c: c)
}

func calculate_parabola_function(a: Double, b: Double, c: Double) -> Parabola_Function {
    let function_a = a
    let function_d = -(b / (2 * a))
    let funciton_e = c - a * (function_d * function_d)
    
    return .init(a: function_a, d: function_d, e: funciton_e)
}

func calculate_parabola_zero_crossings(vertex: Parabola_Vertex) -> [Double] {
    let root = ((vertex.b * vertex.b) - (4 * vertex.a * vertex.c)).squareRoot()
    print(root)
    let x1 = ((vertex.b * (-1)) + root) / ( 2 * vertex.a)
    let x2 = ((vertex.b * (-1)) - root) / (2 * vertex.a)
    
    var arrayToReturn = [Double]()
    
    if root.isNaN {
        return arrayToReturn
    }
    
    else {
        if !x1.isNaN {
            arrayToReturn.append(x1)
        }
        if !x2.isNaN {
            arrayToReturn.append(x2)
        }
        return arrayToReturn
    }
}

struct Parabola_Vertex {
    // ax^2 + bx + c
    var a: Double
    var b: Double
    var c: Double
}

struct Parabola_Function {
    // a(x-d)^2 + e
    var a: Double
    var d: Double
    var e: Double
}
