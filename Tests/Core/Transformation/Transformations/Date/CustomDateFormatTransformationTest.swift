//
//  CustomDateFormatTransformationTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 31.12.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class CustomDateFormatTransformationTest: QuickSpec {
    
    override func spec() {
        describe("CustomDateFormatTransformation") {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyyMMdd"
            
            let transformation = CustomDateFormatTransformation(formatString: "yyyyMMdd")
            let value = formatter.date(from: "20161231")
            let type: SupportedType = .string("20161231")
            let incorrectType: SupportedType = .double(1)
            
            describe("transform(from)") {
                it("transforms correct SupportedType to value") {
                    expect(transformation.transform(from: type)) == value
                }
                it("transforms incorrect SupportedType to nil") {
                    expect(transformation.transform(from: incorrectType)).to(beNil())
                }
            }
            describe("transform(object)") {
                it("transforms value to SupportedType") {
                    expect(transformation.transform(object: value)) == type
                }
                it("transforms nil to SupportedType.null") {
                    expect(transformation.transform(object: nil)) == SupportedType.null
                }
            }
        }
    }
}
