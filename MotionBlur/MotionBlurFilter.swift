//
//  MotionBlurFilter.swift
//  MotionBlur
//
//  Created by Guanshan Liu on 18/10/2014.
//  Copyright (c) 2014 guanshanliu. All rights reserved.
//

import UIKit
import CoreImage

let kernelSource =  "kernel vec4 motionBlur(sampler image, vec2 velocity, float numSamplesInput) { "    +
                        "int numSamples = int(floor(numSamplesInput)); "                                +
                        "vec4 sum = vec4(0.0), avg = vec4(0.0); "                                       +
                        "vec2 dc = destCoord(), offset = -velocity; "                                   +
                        "for (int i=0; i < (numSamples * 2 + 1); i++) { "                               +
                        "sum += sample (image, samplerTransform (image, dc + offset)); "            +
                        "offset += velocity / float(numSamples); "                                  +
                        "} "                                                                            +
                        "avg = sum / float((numSamples * 2 + 1)); "                                     +
                        "return avg; "                                                                  +
                    "}"

class MotionBlurFilter: CIFilter {

    let kernel = CIKernel(string: kernelSource)

    let kMotionBlurSampleCountKey = "kMotionBlurSampleCountKey"
    var numberOfSample: Int = 5

    var radius: Float = 40
    var angle: Float = Float(M_PI_2)
    var inputImage: CIImage?

    override func setValue(value: AnyObject?, forKey key: String) {
        if key == kMotionBlurSampleCountKey {
            if let number = value as? NSNumber {
                numberOfSample = number.integerValue
            }
        } else if key == kCIInputRadiusKey {
            if let number = value as? NSNumber {
                radius = number.floatValue
            }
        } else if key == kCIInputAngleKey {
            if let number = value as? NSNumber {
                angle == number.floatValue
            }
        } else if key == kCIInputImageKey {
            if let image = value as? CIImage {
                inputImage = image
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }

    override func valueForKey(key: String) -> AnyObject? {
        if key == kMotionBlurSampleCountKey {
            return NSNumber(integer: numberOfSample)
        } else if key == kCIInputRadiusKey {
            return NSNumber(float: radius)
        } else if key == kCIInputAngleKey {
            return NSNumber(float: angle)
        } else if key == kCIInputImageKey {
            return inputImage
        } else {
            return super.valueForKey(key)
        }
    }

    override var outputImage: CIImage {
        let x = CGFloat(radius * cosf(angle))
        let y = CGFloat(radius * sin(angle))
        let dod = CGRectInset(inputImage!.extent(), -abs(x), -abs(y))

        return kernel.applyWithExtent(dod, roiCallback: { (index, rect) -> CGRect in
                CGRectInset(rect, -abs(x), -abs(y))
            }, arguments: [inputImage!, CIVector(x: x, y: y), numberOfSample])
    }

}

func motionBlur(angle: Float) -> Filter {
    return { image in
        let parameters: Parameters = [
            kCIInputAngleKey: angle,
            kCIInputImageKey: image
        ]
        let filter = MotionBlurFilter()
        for (key, value) in parameters {
            filter.setValue(value, forKey: key)
        }
        return filter.outputImage
    }
}
