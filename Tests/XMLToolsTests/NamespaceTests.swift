//
//  NamespaceTests.swift
//  XMLToolsTests
//  
//  Created on 24.06.18
//

import XCTest
@testable import XMLTools


class NamespaceTests: XCTestCase {

    func testNamespaces001() {
        let parser = XMLTools.Parser()
        
        guard let doc = try? parser.parse(contentsOf: "https://dev.w3.org/cvsweb/2001/XML-Test-Suite/xmlconf/eduni/namespaces/1.0/001.xml?rev=1.1.1.1;content-type=text%2Fplain") else {
            XCTFail("Error: cant parse")
            return
        }
        
        
        XCTAssertEqual("http://example.org/namespace", doc.select().name().namespaceURI);
    }
    
    func testNamespaces008() {
        let parser = XMLTools.Parser()
        
        guard let xml = try? parser.parse(contentsOf: "https://dev.w3.org/cvsweb/2001/XML-Test-Suite/xmlconf/eduni/namespaces/1.0/008.xml?rev=1.1.1.1;content-type=text%2Fplain") else {
            XCTFail("Error: cant parse")
            return
        }
        
        typealias QN = XMLTools.QName
        
        XCTAssertEqual(QN("bar"), xml["foo"]["bar"].name())
        
        XCTAssertEqual(xml["foo"]["bar"].attr(QN("attr", uri:"http://example.org/~wilbur")).text, "1")
        XCTAssertEqual(xml["foo"]["bar"].attr(QN("attr", uri:"http://example.org/%7ewilbur")).text, "2")
        XCTAssertEqual(xml["foo"]["bar"].attr(QN("attr", uri:"http://example.org/%7Ewilbur")).text, "3")
    }

    let namespaceXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <level1 xmlns:nsA="urn:dummy_A">
      <level1_1>
        <nsA:level1_1_1>Test1_1_1</nsA:level1_1_1>
        <nsA:level1_1_2>Test1_1_2</nsA:level1_1_2>
      </level1_1>
      <level1_2 xmlns:nsB="urn:dummy_B">
        <nsB:level1_2_1 attr1="attr1_value">Test1_2_1</nsB:level1_2_1>
        <nsB:level1_2_2 nsB:attr2="attr2_value">Test1_2_2</nsB:level1_2_2>
      </level1_2>
    </level1>
    """
    
    func testSelectWithNamespaces() {
        let parser = XMLTools.Parser()
        
        let xml: XMLTools.Selection
        do {
            xml = try parser.parse(string: namespaceXML, using: .utf8)
        } catch  {
            XCTFail("Error: cant parse \(error)")
            return
        }
        
        typealias QN = XMLTools.QName
        
        XCTAssertEqual("Test1_1_1", xml[QN("level1")][QN("level1_1")][QN("level1_1_1", uri: "urn:dummy_A")].text)
        
        XCTAssertEqual("Test1_1_1Test1_1_2", xml["level1", "level1_1"].text)
        XCTAssertEqual("Test1_2_1Test1_2_2", xml["level1", "level1_2"].text)
        
        xml.namespaceContext.prefix("custom_A", uri: "urn:dummy_A")
        xml.namespaceContext.prefix("custom_A_2", uri: "urn:dummy_A")
        XCTAssertEqual("Test1_1_1", xml["level1", "level1_1", "custom_A:level1_1_1"].text)
        XCTAssertEqual("Test1_1_1", xml["level1", "level1_1", "custom_A_2:level1_1_1"].text)
        
        xml.namespaceContext.prefix("custom_B", uri: "urn:dummy_B")
        XCTAssertEqual("Test1_2_1", xml["level1", "level1_2", "custom_B:level1_2_1"].text)
    }

}