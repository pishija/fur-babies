#!/usr/bin/env swift
// Generates FurBabies/Shared/Theme/Generated/GeneratedTokens.swift
// from the token JSON files in design-tokens/tokens/.
//
// Run from the project root:
//   swift design-tokens/GenerateTheme.swift

import Foundation

let fm = FileManager.default
let root = fm.currentDirectoryPath
let tokensDir = "\(root)/design-tokens/tokens"
let outputDir = "\(root)/FurBabies/Shared/Theme/Generated"
let outputPath = "\(outputDir)/GeneratedTokens.swift"

func readJSON(_ path: String) -> [String: Any]? {
    guard let data = fm.contents(atPath: path),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    return json
}

// Returns all leaf tokens (dicts containing "value") with their key-path.
func leaves(from dict: [String: Any], path: [String] = []) -> [(path: [String], value: Any)] {
    dict.sorted { $0.key < $1.key }.flatMap { key, val -> [(path: [String], value: Any)] in
        guard let nested = val as? [String: Any] else { return [] }
        if let value = nested["value"] { return [(path: path + [key], value: value)] }
        return leaves(from: nested, path: path + [key])
    }
}

func camel(_ parts: [String]) -> String {
    guard !parts.isEmpty else { return "" }
    return parts[0] + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
}

func swiftUIColor(hex: String) -> String {
    let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
    guard h.count == 6, let v = UInt32(h, radix: 16) else {
        return "Color.clear // invalid hex: \(hex)"
    }
    let r = Double((v >> 16) & 0xFF) / 255
    let g = Double((v >> 8)  & 0xFF) / 255
    let b = Double( v        & 0xFF) / 255
    return String(format: "SwiftUI.Color(.sRGB, red: %.3f, green: %.3f, blue: %.3f, opacity: 1)", r, g, b)
}

func numericString(_ value: Any) -> String {
    guard let n = value as? NSNumber else { return String(describing: value) }
    let d = n.doubleValue
    return d.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(d)) : String(d)
}

func colorLines(from json: [String: Any]) -> [String] {
    guard let dict = json["color"] as? [String: Any] else { return [] }
    return leaves(from: dict).map { leaf in
        "        static let \(camel(leaf.path)) = \(swiftUIColor(hex: leaf.value as? String ?? ""))"
    }
}

func cgFloatLines(from json: [String: Any], key: String) -> [String] {
    guard let dict = json[key] as? [String: Any] else { return [] }
    return leaves(from: dict).map { leaf in
        "        static let \(camel(leaf.path)): CGFloat = \(numericString(leaf.value))"
    }
}

guard let colorJSON   = readJSON("\(tokensDir)/color.json"),
      let typoJSON    = readJSON("\(tokensDir)/typography.json"),
      let spacingJSON = readJSON("\(tokensDir)/spacing.json"),
      let radiusJSON  = readJSON("\(tokensDir)/radius.json")
else {
    print("❌  Could not read token files in \(tokensDir)")
    print("    Make sure you're running from the project root.")
    exit(1)
}

var lines: [String] = [
    "// AUTO-GENERATED — do not edit directly.",
    "// Regenerate by running: swift design-tokens/GenerateTheme.swift",
    "// Source of truth: design-tokens/tokens/*.json",
    "import SwiftUI",
    "",
    "enum GeneratedTokens {",
    "    enum Color {",
]
lines += colorLines(from: colorJSON)
lines += ["    }", "    enum Spacing {"]
lines += cgFloatLines(from: spacingJSON, key: "spacing")
lines += ["    }", "    enum FontSize {"]
lines += cgFloatLines(from: typoJSON, key: "fontSize")
lines += ["    }", "    enum FontWeight {"]
lines += cgFloatLines(from: typoJSON, key: "fontWeight")
lines += ["    }", "    enum Radius {"]
lines += cgFloatLines(from: radiusJSON, key: "radius")
lines += ["    }", "}", ""]

try? fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

do {
    try lines.joined(separator: "\n").write(toFile: outputPath, atomically: true, encoding: .utf8)
    print("✓  GeneratedTokens.swift → \(outputPath)")
} catch {
    print("❌  Failed to write output: \(error)")
    exit(1)
}
