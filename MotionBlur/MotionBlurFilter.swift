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

    override func setValue(value: AnyObject?, forKey key: String) {
        if key == kMotionBlurSampleCountKey {
            if let number = value as? NSNumber {
                numberOfSample = number.integerValue
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }

    override func valueForKey(key: String) -> AnyObject? {
        if key == kMotionBlurSampleCountKey {
            return NSNumber(integer: numberOfSample)
        } else {
            return super.valueForKey(key)
        }
    }

    override func setDefaults() {
        super.setDefaults()
        setValue(NSNumber(float: 40), forKey: kCIInputRadiusKey)
        setValue(NSNumber(double: M_PI_2), forKey: kCIInputAngleKey)
    }

    override var outputImage: CIImage {
        let radius = self.valueForKey(kCIInputRadiusKey)!.floatValue
        let angle = self.valueForKey(kCIInputAngleKey)!.floatValue
        let inputImage = self.valueForKey(kCIInputImageKey) as CIImage

        let x = CGFloat(radius * cosf(angle))
        let y = CGFloat(radius * sin(angle))
        let dod = CGRectInset(inputImage.extent(), -abs(x), -abs(y))

        return kernel.applyWithExtent(dod, roiCallback: { (index, rect) -> CGRect in
                CGRectInset(rect, -abs(x), -abs(y))
            }, arguments: [inputImage, CIVector(x: x, y: y), numberOfSample])
    }

}
