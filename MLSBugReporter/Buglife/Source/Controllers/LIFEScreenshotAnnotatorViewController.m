//
//  LIFEScreenshotAnnotatorViewController.m
//  Copyright (C) 2017 Buglife, Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//       http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

#import "LIFEScreenshotAnnotatorViewController.h"
#import "LIFEScreenshotAnnotatorView.h"
#import "LIFEAnnotation.h"
#import "LIFEAnnotationView.h"
#import "LIFEArrowAnnotationView.h"
#import "LIFEBlurAnnotationView.h"
#import "LIFELoupeAnnotationView.h"
#import "LIFEAnnotatedImage.h"
#import "UIImage+LIFEAdditions.h"
#import "NSArray+LIFEAdditions.h"
#import "LIFECompatibilityUtils.h"
#import "LIFEContinuousForceTouchGestureRecognizer.h"
#import "LIFEPanGestureRecognizer.h"
#import "LIFEMenuPopoverView.h"
#import "LIFEMacros.h"
#import "LIFEGeometry.h"
#import "LIFEImageProcessor.h"
#import "LIFEScreenshotContext.h"

// These probably don't need to be constants, but they
// are the "default" values for when annotations are created,
// and after they are edited
static const CGFloat kDefaultAnnotationRotationAmount = 0.0;
static const CGFloat kDefaultAnnotationScaleAmount = 1.0;

CGPoint LIFECGPointApplyRotation(CGPoint pointToRotate, CGPoint anchor, CGFloat angleInRadians);
CGPoint LIFECGPointApplyScale(CGPoint pointToScale, CGPoint anchor, CGFloat scaleAmount);

@interface LIFEScreenshotAnnotatorViewController () <LIFEContinuousForceTouchDelegate, LIFEMenuPopoverViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) LIFEMutableAnnotatedImage *annotatedImage;
@property (nonatomic, strong) LIFEScreenshotAnnotatorView *screenshotAnnotatorView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer; // Used for drawing, not moving
@property (nonatomic, strong) NSMutableArray<UIGestureRecognizer *> *activeEditingGestureRecognizers; // Move, rotate, etc
@property (nonatomic, strong) LIFEAnnotationView *annotationViewInProgress;
@property (nonatomic, weak) LIFEAnnotationView *annotationSelectedWithPopover;
@property (nonatomic, assign) CGPoint previousStartPointForMovingAnnotation;
@property (nonatomic, assign) CGPoint previousEndPointForMovingAnnotation;
@property (nonatomic, assign) CGPoint translationForMovingAnnotation;
@property (nonatomic, assign) CGFloat angleForRotatingAnnotation;
@property (nonatomic, assign) CGFloat scaleForPinchingAnnotation;
@property (nonatomic, readonly, assign) LIFEChromeVisibility chromeVisibility;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, strong) LIFEImageProcessor *imageProcessor;
@property (nonatomic, nullable, strong) LIFEScreenshotContext *screenshotContext;
@property (nonatomic, assign) BOOL statusBarHidden;

@end

@implementation LIFEScreenshotAnnotatorViewController

- (instancetype)initWithAnnotatedImage:(LIFEAnnotatedImage *)annotatedImage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _annotatedImage = annotatedImage.mutableCopy;
        _imageProcessor = [[LIFEImageProcessor alloc] init];
        _activeEditingGestureRecognizers = [[NSMutableArray alloc] init];
        _scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
    }
    return self;
}

- (instancetype)initWithScreenshot:(UIImage *)screenshot context:(LIFEScreenshotContext *)context
{
    LIFEAnnotatedImage *annotatedImage = [[LIFEAnnotatedImage alloc] initWithScreenshot:screenshot];
    self = [self initWithAnnotatedImage:annotatedImage];
    if (self) {
        _screenshotContext = context;
        _statusBarHidden = _screenshotContext.statusBarHidden;
    }
    return self;
}

- (void)loadView
{
    _screenshotAnnotatorView = [[LIFEScreenshotAnnotatorView alloc] initWithAnnotatedImage:_annotatedImage];
    self.view = _screenshotAnnotatorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isInitialViewController) {
        self.title = LIFELocalizedString(LIFEStringKey_ReportABug);
    } else {
        self.title = self.annotatedImage.filename;
    }
    
    self.panGestureRecognizer.enabled = YES;
    
    if (self.isInitialViewController) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.nextButton;
        
        [self setChromeVisibility:LIFEChromeVisibilityHiddenForViewControllerTransition animated:NO completion:NULL];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // When we add annotation views for the first time, we need
    // to first cache the various source images (i.e. blurs, loupes, etc)
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    __weak typeof(self) weakSelf = self;
    
    [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
        __strong LIFEScreenshotAnnotatorViewController *strongSelf = weakSelf;
        if (strongSelf) {
            for (LIFEAnnotation *annotation in strongSelf.annotatedImage.annotations) {
                LIFEAnnotationView *annotationView = [strongSelf _addAnnotationViewForAnnotation:annotation animated:animated];
                [strongSelf _addGestureHandlersToAnnotationView:annotationView];
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.isInitialViewController) {
        [self _notifyDelegateOfCompletion];
    }
}

- (void)dealloc
{
    [self.view removeGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer = nil;
}

#pragma mark - UIViewController status bar appearance

- (BOOL)prefersStatusBarHidden
{
    // The status bar can be toggled on / off via setChromeVisibility.
    // If the status bar is NOT hidden by setChromeVisibility,
    // then use the screenshot context
    if (_statusBarHidden) {
        return YES;
    }
    
    if (self.screenshotContext != nil) {
        return self.screenshotContext.statusBarHidden;
    } else {
        return [super prefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.screenshotContext != nil) {
        return self.screenshotContext.statusBarStyle;
    } else {
        return [super preferredStatusBarStyle];
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

#pragma mark - Next button

- (UIBarButtonItem *)nextButton
{
    if (_nextButton == nil) {
        _nextButton = [[UIBarButtonItem alloc] initWithTitle:LIFELocalizedString(LIFEStringKey_Next) style:UIBarButtonItemStyleDone target:self action:@selector(_nextButtonTapped:)];
    }
    
    return _nextButton;
}

- (void)_nextButtonTapped:(id)sender
{
    self.cancelButton.enabled = NO;
    self.nextButton.enabled = NO;
    
    [self _notifyDelegateOfCompletion];
}

#pragma mark - Cancel button

- (UIBarButtonItem *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelButtonTapped:)];
    }
    
    return _cancelButton;
}

- (void)_cancelButtonTapped:(id)sender
{
    self.cancelButton.enabled = NO;
    self.nextButton.enabled = NO;
    [self.delegate screenshotAnnotatorViewControllerDidCancel:self];
}

#pragma mark - Private methods

- (void)_notifyDelegateOfCompletion
{
    NSParameterAssert(self.delegate);
    LIFEAnnotatedImage *result = self.annotatedImage.copy;
    [self.delegate screenshotAnnotatorViewController:self willCompleteWithAnnotatedImage:result];
}

- (void)setChromeVisibility:(LIFEChromeVisibility)chromeVisibility animated:(BOOL)animated completion:(void (^)(void))completion
{
    _chromeVisibility = chromeVisibility;
    
    BOOL chromeHidden =
#if !LIFE_DEMO_MODE
            // Chrome does not hide in demo mode
            (_chromeVisibility & LIFEChromeVisibilityHiddenForDrawing) ||
#endif
            (_chromeVisibility & LIFEChromeVisibilityHiddenViaTap) ||
            (_chromeVisibility & LIFEChromeVisibilityHiddenForViewControllerTransition);

    [self.navigationController setNavigationBarHidden:chromeHidden animated:animated];
    [_screenshotAnnotatorView setToolbarsHidden:chromeHidden animated:animated completion:completion];
    
    BOOL statusBarHidden = chromeHidden;
    
    if (_chromeVisibility == LIFEChromeVisibilityHiddenForViewControllerTransition) {
        statusBarHidden = NO;
    }
    
    _statusBarHidden = statusBarHidden;
    
    if (animated) {
        NSTimeInterval duration = [LIFEScreenshotAnnotatorView toolbarTransitionDuration];
        [UIView animateWithDuration:duration animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)_setChromeVisibilityHiddenForDrawing:(BOOL)hiddenForDrawing
{
    if (hiddenForDrawing) {
        // flip on .HiddenForDrawing
        LIFEChromeVisibility visibility = _chromeVisibility | LIFEChromeVisibilityHiddenForDrawing;
        [self setChromeVisibility:visibility animated:YES completion:NULL];
    } else {
        // flip off .HiddenForDrawing
        LIFEChromeVisibility visibility = _chromeVisibility & ~LIFEChromeVisibilityHiddenForDrawing;
        [self setChromeVisibility:visibility animated:YES completion:NULL];
    }
}

#pragma mark - Accessors

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_drawGestureHandler:)];
        [self.screenshotAnnotatorView.sourceImageView addGestureRecognizer:_panGestureRecognizer];
    }
    
    return _panGestureRecognizer;
}

- (LIFEAnnotationView *)_addAnnotationViewForAnnotation:(LIFEAnnotation *)annotation animated:(BOOL)animated
{
    LIFEAnnotationView *annotationView;
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    
    switch (annotation.annotationType) {
        case LIFEAnnotationTypeArrow: {
            annotationView = [[LIFEArrowAnnotationView alloc] initWithAnnotation:annotation];
            break;
        }
        case LIFEAnnotationTypeLoupe: {
            LIFELoupeAnnotationView *loupeAnnotationView = [[LIFELoupeAnnotationView alloc] initWithAnnotation:annotation];
            annotationView = loupeAnnotationView;
            
            [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
                loupeAnnotationView.scaledSourceImage = result;
            }];
            break;
        }
        case LIFEAnnotationTypeBlur: {
            LIFEBlurAnnotationView *blurAnnotationView = [[LIFEBlurAnnotationView alloc] initWithAnnotation:annotation];
            annotationView = blurAnnotationView;
            
            [self.imageProcessor getBlurredScaledImageForImageIdentifier:self.annotatedImage.identifier sourceImage:self.annotatedImage.sourceImage targetSize:targetSize toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
                blurAnnotationView.scaledSourceImage = result;
            }];
            break;
        }
        case LIFEAnnotationTypeFreeform: {
            NSAssert(NO, @"Freeform drawing type is handled elsewhere");
            break;
        }
    }

    [self.screenshotAnnotatorView addAnnotationView:annotationView];
    
    if (animated) {
        [self.screenshotAnnotatorView animateAddedAnnotationView:annotationView];
    }
    
    return annotationView;
}

- (void)_drawGestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    LIFEAnnotationType annotationType = self.screenshotAnnotatorView.selectedAnnotationType;
    CGPoint gestureLocation = [_panGestureRecognizer locationInView:_panGestureRecognizer.view];
    CGSize size = gestureRecognizer.view.bounds.size;
    CGVector gestureVector = LIFEVectorFromPointAndSize(gestureLocation, size);
    
    switch (_panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self _setChromeVisibilityHiddenForDrawing:YES];
            
            LIFEAnnotation *annotation = [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:gestureVector endVector:gestureVector];
            LIFEAnnotationView *annotationView = [self _addAnnotationViewForAnnotation:annotation animated:YES];
            
            if (annotationType == LIFEAnnotationTypeLoupe) {
                [self _updateLoupeAnnotationViews];
            }
            
            NSParameterAssert(self.annotationViewInProgress == nil);

            self.annotationViewInProgress = annotationView;
            [self.annotationViewInProgress setSelected:YES animated:YES];
            [self.annotatedImage addAnnotation:annotation];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            LIFEAnnotationView *annotationView = self.annotationViewInProgress;
            LIFEAnnotation *oldAnnotation = annotationView.annotation;
            LIFEAnnotation *newAnnotation = [[LIFEAnnotation alloc] initWithAnnotationType:oldAnnotation.annotationType startVector:oldAnnotation.startVector endVector:gestureVector];
            newAnnotation = [self _annotationAdjustedForMinimumAndMaximumSize:newAnnotation];
            annotationView.annotation = newAnnotation;
            [self.annotatedImage replaceAnnotation:oldAnnotation withAnnotation:newAnnotation];
            
            if (newAnnotation.annotationType == LIFEAnnotationTypeBlur) {
                [self _updateLoupeAnnotationViews];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self _addGestureHandlersToAnnotationView:self.annotationViewInProgress];
            [self.annotationViewInProgress setSelected:NO animated:YES];
            self.annotationViewInProgress = nil;

            [self _setChromeVisibilityHiddenForDrawing:NO];
            
            break;
        }
        default:
            break;
    }
}

- (void)_addGestureHandlersToAnnotationView:(LIFEAnnotationView *)annotationView
{
    // Set up edit gestures
    
    LIFEPanGestureRecognizer *moveGestureRecognizer = [[LIFEPanGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
    moveGestureRecognizer.delegate = self;
    [annotationView addGestureRecognizer:moveGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
    [annotationView addGestureRecognizer:pinchGestureRecognizer];
    
    BOOL isArrow = [annotationView isKindOfClass:[LIFEArrowAnnotationView class]];
    
    if (isArrow) {
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(_editAnnotationViewGestureHandler:)];
        rotationGestureRecognizer.delegate = self;
        [annotationView addGestureRecognizer:rotationGestureRecognizer];
    }
    
    // Tap-to-delete gesture
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAnnotationViewGestureHandler:)];
    [annotationView addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    
    BOOL isBlur = [annotationView isKindOfClass:[LIFEBlurAnnotationView class]];
    
    if (isBlur) {
        if ([LIFECompatibilityUtils isForceTouchAvailableForViewController:self]) {
            LIFEContinuousForceTouchGestureRecognizer *forceTouchGestureRecognizer = [[LIFEContinuousForceTouchGestureRecognizer alloc] init];
            forceTouchGestureRecognizer.forceTouchDelegate = self;
            [self.annotationViewInProgress addGestureRecognizer:forceTouchGestureRecognizer];
        }
    }
}

- (void)_tapAnnotationViewGestureHandler:(UITapGestureRecognizer *)gestureRecognizer
{
    LIFEAnnotationView *annotationView = (LIFEAnnotationView *)gestureRecognizer.view;
    [self _presentPopoverForAnnotationView:annotationView];
}

- (void)_editAnnotationViewGestureHandler:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_activeEditingGestureRecognizers.count == 0) {
                self.panGestureRecognizer.enabled = NO;
                [self _setChromeVisibilityHiddenForDrawing:YES];
                self.annotationViewInProgress = (LIFEAnnotationView *)gestureRecognizer.view;
                [self.annotationViewInProgress setSelected:YES animated:YES];
                
                self.previousStartPointForMovingAnnotation = self.annotationViewInProgress.startPoint;
                self.previousEndPointForMovingAnnotation = self.annotationViewInProgress.endPoint;
            }
            
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                self.translationForMovingAnnotation = CGPointZero;
            } else if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.angleForRotatingAnnotation = kDefaultAnnotationRotationAmount;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                self.scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
            }
            
            [_activeEditingGestureRecognizers addObject:gestureRecognizer];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGSize size = self.annotationViewInProgress.bounds.size;
            
            if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
                self.translationForMovingAnnotation = [panGestureRecognizer translationInView:self.screenshotAnnotatorView];
            } else if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                UIRotationGestureRecognizer *rotationGestureRecognizer = (UIRotationGestureRecognizer *)gestureRecognizer;
                self.angleForRotatingAnnotation = rotationGestureRecognizer.rotation;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                UIPinchGestureRecognizer *pinchGestureRecognizer = (UIPinchGestureRecognizer *)gestureRecognizer;
                self.scaleForPinchingAnnotation = pinchGestureRecognizer.scale;
            }
            
            // Translate
            CGPoint translation = self.translationForMovingAnnotation;
            CGPoint startPoint = LIFECGPointAdd(self.previousStartPointForMovingAnnotation, translation);
            CGPoint endPoint = LIFECGPointAdd(self.previousEndPointForMovingAnnotation, translation);
            
            // Rotate
            CGFloat radians = self.angleForRotatingAnnotation;
            CGPoint anchor = CGPointMake((startPoint.x + endPoint.x) / 2.0, (startPoint.y + endPoint.y) / 2.0);
            startPoint = LIFECGPointApplyRotation(startPoint, anchor, radians);
            endPoint = LIFECGPointApplyRotation(endPoint, anchor, radians);
            
            // Scale
            CGFloat scaleAmount = self.scaleForPinchingAnnotation;
            startPoint = LIFECGPointApplyScale(startPoint, anchor, scaleAmount);
            endPoint = LIFECGPointApplyScale(endPoint, anchor, scaleAmount);
            
            // Put it all together
            CGVector startVector = LIFEVectorFromPointAndSize(startPoint, size);
            CGVector endVector = LIFEVectorFromPointAndSize(endPoint, size);
            LIFEAnnotation *oldAnnotation = self.annotationViewInProgress.annotation;
            LIFEAnnotation *newAnnotation = [[LIFEAnnotation alloc] initWithAnnotationType:self.annotationViewInProgress.annotation.annotationType startVector:startVector endVector:endVector];
            newAnnotation = [self _annotationAdjustedForMinimumAndMaximumSize:newAnnotation];
            
            self.annotationViewInProgress.annotation = newAnnotation;
            [self.annotatedImage replaceAnnotation:oldAnnotation withAnnotation:newAnnotation];
            
            // Update layers above the blur
            if ([gestureRecognizer.view isKindOfClass:[LIFEBlurAnnotationView class]]) {
                [self _updateLoupeAnnotationViews];
            }
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [_activeEditingGestureRecognizers removeObject:gestureRecognizer];
            
            if (_activeEditingGestureRecognizers.count == 0) {
                self.panGestureRecognizer.enabled = YES;
                [self.annotationViewInProgress setSelected:NO animated:YES];
                self.annotationViewInProgress = nil;
                [self _setChromeVisibilityHiddenForDrawing:NO];
            }
            
            if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
                self.angleForRotatingAnnotation = kDefaultAnnotationRotationAmount;
            } else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                self.scaleForPinchingAnnotation = kDefaultAnnotationScaleAmount;
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - DFContinuousForceTouchDelegate

- (void)forceTouchRecognized:(LIFEContinuousForceTouchGestureRecognizer *)recognizer
{
}

- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didEndWithForce:(CGFloat)force maxForce:(CGFloat)maxForce
{
}

- (void)forceTouchRecognizer:(LIFEContinuousForceTouchGestureRecognizer *)recognizer didMoveWithForce:(CGFloat)force maxForce:(CGFloat)maxForce
{
//    CGFloat amount = force / maxForce;
//    amount = MAX(amount, 0.10);
//    LIFEBlurAnnotationView *blurAnnotationView = (LIFEBlurAnnotationView *)recognizer.view;
//    blurAnnotationView.blurAmount = amount;
}

#pragma mark - LIFEMenuPopoverViewDelegate

- (void)_presentPopoverForAnnotationView:(LIFEAnnotationView *)annotationView
{
    LIFEMenuPopoverView *menu = [[LIFEMenuPopoverView alloc] init];
    menu.delegate = self;
    NSString *deleteString = LIFELocalizedString(LIFEStringKey_Delete);
    
    if ([annotationView isKindOfClass:[LIFEArrowAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteArrow);
    } else if ([annotationView isKindOfClass:[LIFEBlurAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteBlur);
    } else if ([annotationView isKindOfClass:[LIFELoupeAnnotationView class]]) {
        deleteString = LIFELocalizedString(LIFEStringKey_DeleteLoupe);
    } else {
        NSAssert(NO, @"Unhandled annotation");
    }
    
    UIBezierPath *path = annotationView.pathForPopoverMenu;
    [menu presentPopoverFromBezierPath:path inView:self.screenshotAnnotatorView.sourceImageView withStrings:@[deleteString]];
    
    self.annotationSelectedWithPopover = annotationView;
    [self.annotationSelectedWithPopover setSelected:YES animated:YES];
}

- (void)popoverView:(LIFEMenuPopoverView *)popoverView didSelectItemAtIndex:(NSInteger)index
{
    CGPoint arrowPoint = popoverView.arrowPoint;
    arrowPoint = [self.screenshotAnnotatorView.sourceImageView convertPoint:arrowPoint fromView:popoverView];
    CGRect deletionRect = CGRectMake(arrowPoint.x, arrowPoint.y, 1, 1);
    
    LIFEScreenshotAnnotatorView *annotatorView = self.screenshotAnnotatorView;
    LIFEAnnotationView *annotationInProgress = self.annotationSelectedWithPopover;
    self.annotationSelectedWithPopover = nil;
    
    __weak typeof(self) weakSelf = self;
    LIFEMutableAnnotatedImage *annotatedImage = self.annotatedImage;
    [annotatedImage removeAnnotation:annotationInProgress.annotation];

    [annotationInProgress animateToTrashCanRect:deletionRect completion:^{
        [annotatorView removeAnnotationView:annotationInProgress];
        
        // Update layers above the blur
        if ([annotationInProgress isKindOfClass:[LIFEBlurAnnotationView class]]) {
            [weakSelf _updateLoupeAnnotationViews];
        }
    }];
}

- (void)popoverViewDidDismiss:(LIFEMenuPopoverView *)popoverView
{
    [self.annotationSelectedWithPopover setSelected:NO animated:YES];
    self.annotationSelectedWithPopover = nil;
}

#pragma mark - Image processing

- (CGSize)_targetSizeForAnnotationViewImages
{
    return self.screenshotAnnotatorView.sourceImageView.bounds.size;
}

// Loupe annotation views must be updated whenever blurs (or anything
// else underneath them) are added/removed
- (void)_updateLoupeAnnotationViews
{
    CGSize size = [self _targetSizeForAnnotationViewImages];
    LIFEScreenshotAnnotatorView *screenshotAnnotatorView = self.screenshotAnnotatorView;
    
    [self.imageProcessor clearCachedLoupeSourceScaledImagesForAnnotatedImage:self.annotatedImage targetSize:size];

    [self.imageProcessor getLoupeSourceScaledImageForAnnotatedImage:self.annotatedImage targetSize:size toQueue:dispatch_get_main_queue() completion:^(LIFEImageIdentifier *identifier, UIImage *result) {
        [screenshotAnnotatorView updateLoupeAnnotationViewsWithSourceImage:result];
    }];
}

#pragma mark - Annotation resizing

static const CGFloat kMinimumArrowLength = 88;
static const CGFloat kMinimumBlurWidth = 66;
static const CGFloat kMinimumBlurHeight = 44;
static const CGFloat kMinimumLoupeRadius = 44;
static const CGFloat kMaximumLoupeRadius = 150;

- (LIFEAnnotation *)_annotationAdjustedForMinimumAndMaximumSize:(LIFEAnnotation *)annotation
{
    CGSize targetSize = [self _targetSizeForAnnotationViewImages];
    LIFEAnnotationType annotationType = annotation.annotationType;
    CGVector startVector = annotation.startVector;
    CGVector endVector = annotation.endVector;
    CGPoint startPoint = LIFEPointFromVectorAndSize(startVector, targetSize);
    CGPoint endPoint = LIFEPointFromVectorAndSize(endVector, targetSize);
    CGFloat length = LIFECGPointDistance(startPoint, endPoint);
    
    switch (annotationType) {
        case LIFEAnnotationTypeArrow: {
            if (length < kMinimumArrowLength) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMinimumArrowLength);
                endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            }
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
            
        case LIFEAnnotationTypeBlur: {
            if (fabs(endPoint.x - startPoint.x) < kMinimumBlurWidth) {
                if (endPoint.x > startPoint.x) {
                    endPoint.x = startPoint.x + kMinimumBlurWidth;
                } else {
                    endPoint.x = startPoint.x - kMinimumBlurWidth;
                }
            }
            
            if (fabs(endPoint.y - startPoint.y) < kMinimumBlurHeight) {
                if (endPoint.y > startPoint.y) {
                    endPoint.y = startPoint.y + kMinimumBlurHeight;
                } else {
                    endPoint.y = startPoint.y - kMinimumBlurHeight;
                }
            }
            
            endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
            
        case LIFEAnnotationTypeLoupe: {
            if (length < kMinimumLoupeRadius) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMinimumLoupeRadius);
            } else if (length > kMaximumLoupeRadius) {
                endPoint = LIFEEndpointAdjustedForDistance(startPoint, endPoint, kMaximumLoupeRadius);
            }
            
            endVector = LIFEVectorFromPointAndSize(endPoint, targetSize);
            
            return [[LIFEAnnotation alloc] initWithAnnotationType:annotationType startVector:startVector endVector:endVector];
        }
            
        case LIFEAnnotationTypeFreeform:
            NSParameterAssert(NO); // This code path is deprecated, this file should be deleted
            return nil;
    }
    
    NSParameterAssert(NO);
    return nil;
}

// MARK: UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // This ensures that an "editing" gesture (e.g. rotation/scale) doesn't
    // get recognized simultaneously with a new draw gesture. It also
    // ensures that for edit gestures to be recognized simultaenously,
    // they must be gestures on the same annotation view
    BOOL isCombiningGesturesOnAnnotationView = ([gestureRecognizer.view isKindOfClass:[LIFEAnnotationView class]] && [otherGestureRecognizer.view isKindOfClass:[LIFEAnnotationView class]] && gestureRecognizer.view == otherGestureRecognizer.view);
    
    if (!isCombiningGesturesOnAnnotationView) {
        return NO;
    }
    
    BOOL isPanAndRotate = ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]);
    
    BOOL isPanAndPinch = ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]);
    
    BOOL isPinchAndRotate = ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) || ([otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]);
    
    // Allow multiple editing gestures to be combined simultaenously
    return isPanAndRotate || isPanAndPinch || isPinchAndRotate;
}

@end
