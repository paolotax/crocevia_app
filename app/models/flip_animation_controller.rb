class FlipAnimationController

  attr_accessor :reverse

  def animateTransition(transitionContext)
    
    # 1. the usual stuff ...
    containerView = transitionContext.containerView
    fromVC = transitionContext.viewControllerForKey UITransitionContextFromViewControllerKey
    toVC = transitionContext.viewControllerForKey UITransitionContextToViewControllerKey 
    toView = toVC.view
    fromView = fromVC.view
    containerView.addSubview toVC.view
    
    # 2. Add a perspective transform
    transform = CATransform3DIdentity
    transform.m34 = -0.002
    containerView.layer.setSublayerTransform transform
    
    # 3. Give both VCs the same start frame
    initialFrame = transitionContext.initialFrameForViewController fromVC
    fromView.frame = initialFrame
    toView.frame = initialFrame
    
    # 4. reverse?
    factor = self.reverse ? 1.0 : -1.0
    
    # 5. flip the to VC halfway round - hiding it
    toView.layer.transform = self.yRotation factor * -(Math::PI / 2)
    
    # 6. Animate
    duration = self.transitionDuration transitionContext
    UIView.animateKeyframesWithDuration(duration,
                                   delay:0.0,
                                 options:0,
                              animations: lambda do 
                            UIView.addKeyframeWithRelativeStartTime(0.0,
                                                    relativeDuration:0.5,
                                                           animations: lambda do
                                                                # 7. rotate the from view
                                                                fromView.layer.transform = self.yRotation factor * (Math::PI  / 2)
                                                            end
                            )
                            UIView.addKeyframeWithRelativeStartTime(0.5,
                                                    relativeDuration:0.5,
                                                          animations: lambda do
                                        # 8. rotate the to view
                                        toView.layer.transform = self.yRotation 0.0
                                    end
                            )
      end,
       completion: lambda do |finished|
        transitionContext.completeTransition !transitionContext.transitionWasCancelled
      end
    )
  end


  def yRotation(angle)
    CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0)
  end


  def transitionDuration(transitionContext)
    1.0
  end


end
