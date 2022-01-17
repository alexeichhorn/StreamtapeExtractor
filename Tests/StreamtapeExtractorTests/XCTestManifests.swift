//
//  XCTestManifests.swift
//  StreamtapeExtractor
//
//  Created by Alexander Eichhorn on 17.01.22.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(StreamtapeExtractorTests.allTests)
    ]
}
#endif
