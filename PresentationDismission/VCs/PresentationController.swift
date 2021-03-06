//  SheetModalPresentationController.swift
//
//
//  Created by Balazs Vincze on 2020. 01. 14..
//  Copyright © 2020. Balazs Vincze. All rights reserved.
//
import UIKit

final class SheetModalPresentationController: UIPresentationController {
            
    // MARK: Private Properties
    
    private let height: CGFloat
    private let interactor = UIPercentDrivenInteractiveTransition()
    private let dimmingView = UIView()
    private var propertyAnimator: UIViewPropertyAnimator!
    private var isInteractive = false
    
    // MARK: Initializers
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat) {
        self.height = min(height, presentedViewController.view.frame.height)
            
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: Function Overrides
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }

        // Calculate the frame for the presented view controller using the passed in height.
        var frame = containerBounds
        frame.size.height = height
        frame.origin.y = containerBounds.height - height + 0.5// - height
        
        return frame
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
                
        guard let containerBounds = containerView?.bounds, let presentedView = presentedView else { return }

        // Add a pan gesture recognizer for pull to dismiss.
        presentedView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        // Round the the presented view controller's corners.
        //presentedView?.layer.cornerRadius = 40
        
        // Add a dimming view below the presented view controller, and a tap gesture recognizer to it for dismissal.
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        dimmingView.backgroundColor = .black
        dimmingView.frame = containerBounds
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.5
        })
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }
    override func dismissalTransitionDidEnd(_ completed: Bool) {
    //        // Not setting this to nil causes a retain cycle for some reason.
            propertyAnimator = nil
    }
    
    // MARK: Private Functions
    
    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view,
            gesture.translation(in: gestureView).y >= 0 else { return } // Make sure we only recognize downward gestures.
                
        let percent = gesture.translation(in: gestureView).y / gestureView.bounds.height
        
        switch gesture.state {
        case .began:
            isInteractive = true
            presentedViewController.dismiss(animated: true, completion: nil)
        case .changed:
            interactor.update(percent)
        case .cancelled:
            interactor.cancel()
            isInteractive = false
        case .ended:
            let velocity = gesture.velocity(in: gestureView).y
            // Finish the animation if the user flicked the modal quickly (i.e. high velocity), or dragged it more than 50% down.
            if percent > 0.5 || velocity > 1600 {
                // Multiply the animation duration by the velocity, to make sure the modal dismisses as fast as the user swiped.
                // If the user pulled down slowly though, we want to use the default duration, hence the max().
                interactor.completionSpeed = max(1, velocity / (gestureView.frame.height * (1 / interactor.duration)))
                interactor.finish()
            } else {
                interactor.cancel()
            }
            isInteractive = false
        default:
            break
        }
    }

}

// MARK: UIViewControllerAnimatedTransitioning
extension SheetModalPresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                                  timingParameters: UICubicTimingParameters())
        propertyAnimator.addAnimations {
            // Move the view down.
            transitionContext.view(forKey: .from)?.frame.origin.y = transitionContext.containerView.frame.maxY
        }
        propertyAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        return propertyAnimator
    }
    
}

// MARK: UIViewControllerTransitioningDelegate
extension SheetModalPresentationController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isInteractive ? interactor : nil
    }

}

// MARK: UIViewController Extension
extension UIViewController {
    
    func presentAsSheet(_ vc: UIViewController, height: CGFloat) {
        let presentationController = SheetModalPresentationController(presentedViewController: vc,
                                                                      presenting: self,
                                                                      height: height)
        vc.transitioningDelegate = presentationController
        vc.modalPresentationStyle = .custom
        present(vc, animated: true)
    }
    
}

// Example usage:
final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentPressed)))
    }
    
    @objc private func presentPressed() {
        presentAsSheet(ModalViewController(), height: 600)
    }

}


final class ModalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
    }
    
}
