import Foundation

class FrameInfoPersistance: FileKeeperService {
    
    func readFrame() -> FrameInfo? {
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        
        return try? JSONDecoder().decode(FrameInfo.self,
                                        from: data)
    }
    
    static func data(frame: FrameInfo) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(frame)
    }
}
