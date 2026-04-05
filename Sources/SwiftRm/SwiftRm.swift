// The Swift Programming Language
// https://docs.swift.org/swift-book


// The main interface — a simple struct holding closures
public struct SwiftRm {
    public var fetchSomething: (String) async throws -> RmItem// [Item]
    public var deleteSomething: (String) async throws -> Void
    
    public init(
        fetchSomething: @escaping (String) async throws -> RmItem,//[Item],
        deleteSomething: @escaping (String) async throws -> Void
    ) {
        self.fetchSomething = fetchSomething
        self.deleteSomething = deleteSomething
    }
}
