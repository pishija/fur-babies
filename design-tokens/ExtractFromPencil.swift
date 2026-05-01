#!/usr/bin/env swift
// Extracts design variables from a Pencil .pen file and updates
// the token JSON files in design-tokens/tokens/.
//
// Run from the project root:
//   swift design-tokens/ExtractFromPencil.swift path/to/FurBabies.pen
//
// Then regenerate the Swift theme file:
//   swift design-tokens/GenerateTheme.swift
//
// Pencil variable naming convention (set these names in Pencil):
//   --color-brand-primary        → color.json  brand.primary
//   --color-background-surface   → color.json  background.surface
//   --color-text-secondary       → color.json  text.secondary
//   --color-border-default       → color.json  border.default
//   --color-status-error         → color.json  status.error
//   --spacing-md                 → spacing.json
//   --font-size-body             → typography.json fontSize
//   --font-weight-semibold       → typography.json fontWeight
//   --radius-lg                  → radius.json

import Foundation

let args = CommandLine.arguments
guard args.count >= 2 else {
    print("Usage: swift design-tokens/ExtractFromPencil.swift <path-to-design.pen>")
    exit(1)
}

let fm = FileManager.default
let root = fm.currentDirectoryPath
let tokensDir = "\(root)/design-tokens/tokens"
let penPath = args[1]

guard let penData = fm.contents(atPath: penPath),
      let penJSON = try? JSONSerialization.jsonObject(with: penData) as? [String: Any]
else {
    print("❌  Could not read or parse: \(penPath)")
    exit(1)
}

// .pen variables are stored as a dictionary: { "--var-name": { "type": "color"|"number"|"string", "value": ... } }
guard let variables = penJSON["variables"] as? [String: Any], !variables.isEmpty else {
    print("❌  No 'variables' dictionary found in .pen file.")
    exit(1)
}

func kebabToCamel(_ s: String) -> String {
    let parts = s.components(separatedBy: "-")
    guard !parts.isEmpty else { return s }
    return parts[0] + parts.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
}

func numericValue(_ entry: [String: Any]) -> Double {
    if let n = entry["value"] as? NSNumber { return n.doubleValue }
    if let s = entry["value"] as? String   { return Double(s.replacingOccurrences(of: "px", with: "")) ?? 0 }
    return 0
}

var colorGroups: [String: [String: [String: Any]]] = [:]
var spacing:     [String: [String: Any]] = [:]
var fontSizes:   [String: [String: Any]] = [:]
var fontWeights: [String: [String: Any]] = [:]
var radii:       [String: [String: Any]] = [:]

for (rawName, rawEntry) in variables {
    guard let entry = rawEntry as? [String: Any] else { continue }
    let name = rawName.hasPrefix("--") ? String(rawName.dropFirst(2)) : rawName

    if name.hasPrefix("color-") {
        let rest  = String(name.dropFirst("color-".count))
        let parts = rest.components(separatedBy: "-")
        guard !parts.isEmpty else { continue }
        let group = parts[0]
        let item  = parts.count > 1 ? kebabToCamel(parts.dropFirst().joined(separator: "-")) : "default"
        let hex   = entry["value"] as? String ?? "#000000"
        if colorGroups[group] == nil { colorGroups[group] = [:] }
        colorGroups[group]![item] = ["value": hex, "type": "color"]

    } else if name.hasPrefix("spacing-") {
        let item = kebabToCamel(String(name.dropFirst("spacing-".count)))
        spacing[item] = ["value": numericValue(entry), "type": "dimension"]

    } else if name.hasPrefix("font-size-") {
        let item = kebabToCamel(String(name.dropFirst("font-size-".count)))
        fontSizes[item] = ["value": numericValue(entry), "type": "dimension"]

    } else if name.hasPrefix("font-weight-") {
        let item = kebabToCamel(String(name.dropFirst("font-weight-".count)))
        fontWeights[item] = ["value": numericValue(entry), "type": "number"]

    } else if name.hasPrefix("radius-") {
        let item = kebabToCamel(String(name.dropFirst("radius-".count)))
        radii[item] = ["value": numericValue(entry), "type": "dimension"]
    }
}

func writeJSON(path: String, object: [String: Any]) {
    guard let data = try? JSONSerialization.data(
        withJSONObject: object,
        options: [.prettyPrinted, .sortedKeys]
    ) else {
        print("❌  Could not serialize JSON for \(path)")
        return
    }
    do {
        try data.write(to: URL(fileURLWithPath: path))
        print("✓  \((path as NSString).lastPathComponent) updated")
    } catch {
        print("❌  Could not write \(path): \(error)")
    }
}

writeJSON(path: "\(tokensDir)/color.json",    object: ["color": colorGroups])
writeJSON(path: "\(tokensDir)/spacing.json",  object: ["spacing": spacing])
writeJSON(path: "\(tokensDir)/radius.json",   object: ["radius": radii])

var typography: [String: Any] = [:]
if !fontSizes.isEmpty   { typography["fontSize"]   = fontSizes }
if !fontWeights.isEmpty { typography["fontWeight"] = fontWeights }
if !typography.isEmpty  { writeJSON(path: "\(tokensDir)/typography.json", object: typography) }

print("\nDone. Run: swift design-tokens/GenerateTheme.swift")
