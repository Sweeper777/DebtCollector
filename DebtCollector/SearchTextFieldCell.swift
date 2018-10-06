import UIKit
import SearchTextField
import Eureka

class _SearchTextFieldCell<T>: _FieldCell<T> where T: Equatable, T: InputTypeInitiable {
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textField.removeFromSuperview()
        
        let searchTextField = SearchTextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(searchTextField)
        self.textField = searchTextField
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SearchTextCell: _SearchTextFieldCell<String>, CellType {
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
    }
}

class _SearchTextRow: FieldRow<SearchTextCell> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

final class SearchTextRow: _SearchTextRow, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
