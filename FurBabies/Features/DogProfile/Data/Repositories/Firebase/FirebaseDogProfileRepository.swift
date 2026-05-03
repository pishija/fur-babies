import Foundation
import FirebaseFirestore
import os

final class FirebaseDogProfileRepository: DogProfileRepositoryProtocol {
    private let db = Firestore.firestore()

    private func collection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("dogs")
    }

    func createDog(_ dog: DogProfile) async throws -> String {
        let ref = collection(userId: dog.userId).document()
        try await ref.setData(firestoreData(from: dog, id: ref.documentID))
        AppLogger.dog.info("createDog — id=\(ref.documentID) userId=\(dog.userId)")
        return ref.documentID
    }

    func fetchDogs(forUserId userId: String) async throws -> [DogProfile] {
        let snapshot = try await collection(userId: userId).getDocuments()
        let dogs = snapshot.documents.compactMap { doc -> DogProfile? in
            guard let profile = dogProfile(from: doc.data(), id: doc.documentID) else {
                AppLogger.dog.warning("fetchDogs — failed to parse doc id=\(doc.documentID)")
                return nil
            }
            return profile
        }
        AppLogger.dog.info("fetchDogs — userId=\(userId) count=\(dogs.count)")
        return dogs
    }

    func hasDogs(forUserId userId: String) async throws -> Bool {
        let snapshot = try await collection(userId: userId).limit(to: 1).getDocuments()
        return !snapshot.documents.isEmpty
    }

    func updateDog(_ dog: DogProfile) async throws {
        var data = firestoreData(from: dog, id: dog.id)
        data["updatedAt"] = Timestamp(date: .now)
        try await collection(userId: dog.userId).document(dog.id).setData(data, merge: true)
        AppLogger.dog.info("updateDog — id=\(dog.id)")
    }

    func deleteDog(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
        AppLogger.dog.info("deleteDog — id=\(id) userId=\(userId)")
    }

    // MARK: - Mapping

    private func firestoreData(from dog: DogProfile, id: String) -> [String: Any] {
        var data: [String: Any] = [
            "userId": dog.userId,
            "name": dog.name,
            "breed": dog.breed,
            "sex": dog.sex.rawValue,
            "birthday": Timestamp(date: dog.birthday),
            "weightKg": dog.weightKg,
            "sizeClass": dog.sizeClass.rawValue,
            "coatColour": dog.coatColour,
            "microchip": dog.microchip,
            "isNeutered": dog.isNeutered,
            "isPublic": dog.isPublic,
            "temperamentTags": dog.temperamentTags.map { $0.rawValue },
            "createdAt": Timestamp(date: dog.createdAt),
            "updatedAt": Timestamp(date: dog.updatedAt)
        ]
        if let url = dog.primaryPhotoUrl {
            data["primaryPhotoUrl"] = url
        }
        return data
    }

    private func dogProfile(from data: [String: Any], id: String) -> DogProfile? {
        guard
            let userId    = data["userId"]    as? String,
            let name      = data["name"]      as? String,
            let breed     = data["breed"]     as? String,
            let sexRaw    = data["sex"]        as? String,
            let sex       = DogSex(rawValue: sexRaw),
            let birthdayTs = data["birthday"] as? Timestamp,
            let weightKg  = data["weightKg"]  as? Double,
            let sizeRaw   = data["sizeClass"] as? String,
            let sizeClass = DogSizeClass(rawValue: sizeRaw),
            let isNeutered = data["isNeutered"] as? Bool,
            let isPublic   = data["isPublic"]   as? Bool,
            let createdTs  = data["createdAt"] as? Timestamp,
            let updatedTs  = data["updatedAt"] as? Timestamp
        else { return nil }

        let tags = (data["temperamentTags"] as? [String] ?? []).compactMap { TemperamentTag(rawValue: $0) }

        return DogProfile(
            id: id,
            userId: userId,
            name: name,
            breed: breed,
            sex: sex,
            birthday: birthdayTs.dateValue(),
            weightKg: weightKg,
            sizeClass: sizeClass,
            coatColour: data["coatColour"] as? String ?? "",
            microchip: data["microchip"] as? String ?? "",
            isNeutered: isNeutered,
            isPublic: isPublic,
            temperamentTags: tags,
            primaryPhotoUrl: data["primaryPhotoUrl"] as? String,
            createdAt: createdTs.dateValue(),
            updatedAt: updatedTs.dateValue()
        )
    }
}
