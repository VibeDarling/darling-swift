// CGPathFillRule and the CGPath boolean operations (declared, trapping) through the CoreGraphics overlay.
// Run with no argument for the checks; the program runs itself with `union`, `intersection` or `subtracting` as the
// argument, which calls that operation and must be killed by a signal with a message naming it on standard error.
import CoreGraphics
import Darwin

var failures = 0
func check(_ condition: Bool, _ label: String) {
    print(condition ? "ok:" : "FAIL:", label)
    if !condition { failures += 1 }
}

if CommandLine.arguments.count > 1 {
    let path = CGMutablePath()!
    CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: 4, height: 4))
    let other: CGPath = path
    switch CommandLine.arguments[1] {
    case "union": _ = path.union(other)
    case "intersection": _ = path.intersection(other, using: .evenOdd)
    case "subtracting": _ = path.subtracting(other)
    default: print("unknown operation")
    }
    print("the operation returned")
    exit(1)
}

// Runs this program with `operation` and returns its wait status and what it wrote to standard error.
func runChild(_ operation: String) -> (status: Int32, stderr: String)? {
    var fds: [Int32] = [0, 0]
    guard pipe(&fds) == 0 else { return nil }
    var actions: posix_spawn_file_actions_t? = nil
    posix_spawn_file_actions_init(&actions)
    posix_spawn_file_actions_adddup2(&actions, fds[1], 2)
    posix_spawn_file_actions_addclose(&actions, fds[0])
    posix_spawn_file_actions_addclose(&actions, fds[1])
    var pid: pid_t = 0
    let argv: [UnsafeMutablePointer<CChar>?] = [strdup(CommandLine.arguments[0]), strdup(operation), nil]
    // The child needs the same dynamic library search paths as this process.
    var envp: [UnsafeMutablePointer<CChar>?] = []
    for name in ["DYLD_LIBRARY_PATH", "DYLD_FRAMEWORK_PATH"] {
        if let value = getenv(name) { envp.append(strdup("\(name)=\(String(cString: value))")) }
    }
    envp.append(nil)
    let rc = posix_spawn(&pid, CommandLine.arguments[0], &actions, nil, argv, envp)
    argv.forEach { free($0) }
    envp.forEach { free($0) }
    posix_spawn_file_actions_destroy(&actions)
    close(fds[1])
    guard rc == 0 else { close(fds[0]); return nil }
    var output = [UInt8]()
    var buffer = [UInt8](repeating: 0, count: 4096)
    while true {
        let n = read(fds[0], &buffer, buffer.count)
        if n <= 0 { break }
        output += buffer[0..<n]
    }
    close(fds[0])
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return (status, String(decoding: output, as: UTF8.self))
}

// The raw type and values, observed on a real Mac (probe symbols_b_probe1.txt lines 15-16).
check(CGPathFillRule.winding.rawValue == 0 && CGPathFillRule.evenOdd.rawValue == 1, "raw values are 0 and 1")
check(CGPathFillRule.RawValue.self == Int.self, "the raw type is Int")
check(MemoryLayout<CGPathFillRule>.size == 1, "a two-case enum is one byte")
check(CGPathFillRule(rawValue: 1) == .evenOdd && CGPathFillRule(rawValue: 0) == .winding && CGPathFillRule(rawValue: 2) == nil,
      "RawRepresentable round trip")

for operation in ["union", "intersection", "subtracting"] {
    guard let result = runChild(operation) else { check(false, "\(operation): could not run the child"); continue }
    check(result.status & 0x7f != 0, "\(operation) is killed by a signal (status \(result.status))")
    check(result.stderr.contains("CGPath.\(operation)(_:using:): path boolean operations are not implemented"),
          "\(operation) trap message names the operation")
}

print(failures == 0 ? "ALL PASS" : "\(failures) FAILED")
exit(failures == 0 ? 0 : 1)
