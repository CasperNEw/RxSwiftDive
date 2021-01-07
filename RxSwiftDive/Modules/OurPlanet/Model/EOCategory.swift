import Foundation

struct EOCategory: Decodable {
	let identifier: Int
	let name: String
	let description: String

	var events = [EOEvent]()
	var endpoint: String {
		return "\(EONET.categoriesEndpoint)/\(identifier)"
	}

	private enum CodingKeys: String, CodingKey {
		case identifier = "id", name = "title", description
	}
}

extension EOCategory: Equatable {
	static func == (lhs: EOCategory, rhs: EOCategory) -> Bool {
		return lhs.identifier == rhs.identifier
	}
}
