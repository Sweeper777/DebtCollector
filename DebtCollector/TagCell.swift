import Eureka
import UIKit
import TagWriteView

class TagCell: Cell<String>, CellType, TagWriteViewDelegate {
    @IBOutlet var tagWriteView: TagWriteView!
}
