
import UIKit

final class TextFieldInsets: UITextField {

    private let textInset: UIEdgeInsets

    init(inset: UIEdgeInsets) {
        self.textInset = inset
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInset)
    }
}
