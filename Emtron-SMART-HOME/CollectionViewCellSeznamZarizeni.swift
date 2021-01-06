
//

import UIKit

class CollectionViewCellSeznamZarizeni: UICollectionViewCell {
    
    @IBOutlet weak var nazevZarizeni1: UILabel!
    @IBOutlet weak var nazevZarizeni2: UILabel!
    @IBOutlet weak var umisteniZarizeni1: UILabel!
    @IBOutlet weak var umisteniZarizeni2: UILabel!
    //@IBOutlet weak var IPadressa: UILabel!
    @IBOutlet weak var UIViewOutlet: UIView!
    @IBOutlet weak var UIImageOutletZarizeni1: UIImageView!
    @IBOutlet weak var UIImageOutletZarizeni2: UIImageView!
    
   // @IBOutlet weak var casZarizeni: UILabel!
    
    
    //MARK:- Events
    
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("Touch began tady")
        UIView.animate(withDuration: 0.15, animations:  {
                        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
        //animate(isHighlighted: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("Touch cancel tady")
        UIView.animate(withDuration: 0.3, animations:  {
            self.transform = .identity
        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touch end tady")
        UIView.animate(withDuration: 0.3, animations:  {
            self.transform = .identity
        })
    }

   /*

    //MARK:- Private functions
    private func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        let animationOptions: UIView.AnimationOptions = [.curveEaseInOut]
        if isHighlighted {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .init(scaleX: 0.9, y: 0.9)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }*/
}
