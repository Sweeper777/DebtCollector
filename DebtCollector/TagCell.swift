import Eureka
import UIKit
import TagWriteView

class TagCell: Cell<String>, CellType, TagWriteViewDelegate {
    @IBOutlet var tagWriteView: TagWriteView!
    
    override func setup() {
        super.setup()
        
        tagWriteView.delegate = self
        tagWriteView.placeHolderForInput = NSAttributedString(string: "Tags...")
        tagWriteView.minimumWidthOfTag = 100
    }
}
