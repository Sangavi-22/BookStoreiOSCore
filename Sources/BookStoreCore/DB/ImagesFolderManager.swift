
import Foundation
import UIKit

class ImagesFolderManager{
    
    class func createFolder(withPathCompenent component: String) throws -> URL?{
        var newFolderURL: URL?
        
        let manager = FileManager.default
        if let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first{
            print(url.path) // Path for documents directory
            
            newFolderURL = url.appendingPathComponent(component)
            try manager.createDirectory(atPath: newFolderURL!.path, withIntermediateDirectories: true)
        }
        return newFolderURL
    }
    
    class func saveImage(atPath filePath: String?, contents: Data?) throws{
        guard let filePath else{
            throw ImageHandlingError.savingOfImageFailed
        }
        FileManager.default.createFile(atPath: filePath, contents: contents)
    }
     
    
    class func deleteImage(atPath filePath: String?) throws{
        guard let filePath else {
            throw ImageHandlingError.deletionOfImageFailed
        }
        try FileManager.default.removeItem(atPath: filePath)
    }
    
    class func getSavedImage(fromFilePath filePath: String?) throws -> UIImage?{
        guard let filePath else {
            throw ImageHandlingError.errorInFetchingImage
        }
        return UIImage(contentsOfFile: filePath)
    }
    
}
