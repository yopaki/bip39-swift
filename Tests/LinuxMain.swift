//
//  LinuxMain.swift
//
//
//  Created by Carlos Chida on 07/07/24.
//

import XCTest

import Bip39Tests

var tests = [XCTestCaseEntry]()
tests += Bip39Tests.__allTests()

XCTMain(tests)
