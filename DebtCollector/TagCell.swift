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
    
    func tagWriteView(view: TagWriteView!, didMakeTag tag: String!) {
        row.value = view.tags.joined(separator: ",")
        row.updateCell()
    }
    
}
