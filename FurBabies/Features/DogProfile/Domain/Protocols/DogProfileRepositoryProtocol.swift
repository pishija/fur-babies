import Foundation

protocol DogProfileRepositoryProtocol: AnyObject {
    @discardableResult
    func createDog(_ dog: DogProfile) async throws -> String
    func fetchDogs(forUserId userId: String) async throws -> [DogProfile]
    func hasDogs(forUserId userId: String) async throws -> Bool
    func updateDog(_ dog: DogProfile) async throws
    func deleteDog(id: String, userId: String) async throws
}
