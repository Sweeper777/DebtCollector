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
    
    func tagWriteView(view: TagWriteView!, didRemoveTag tag: String!) {
        row.value = view.tags.joined(separator: ",")
        row.updateCell()
    }
    
    func tagWriteView(view: TagWriteView!, didChangeText text: String!) {
        row.value = view.tags.joined(separator: ",")
        row.updateCell()
    }
    
    override func update() {
        tagWriteView.clear()
        tagWriteView.addTags(row.value?.split(separator: ",").map(String.init) ?? [])
    }
}
