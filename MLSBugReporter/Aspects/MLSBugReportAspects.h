//
//  MLSBugReportAspects.h
//  MLSBugReportAspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MLSBugReportAspectOptions) {
    MLSBugReportAspectPositionAfter   = 0,            /// Called after the original implementation (default)
    MLSBugReportAspectPositionInstead = 1,            /// Will replace the original implementation.
    MLSBugReportAspectPositionBefore  = 2,            /// Called before the original implementation.
    
    MLSBugReportAspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque MLSBugReportAspect Token that allows to deregister the hook.
@protocol MLSBugReportAspectToken <NSObject>

/// Deregisters an aspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The MLSBugReportAspectInfo protocol is the first parameter of our block syntax.
@protocol MLSBugReportAspectInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 MLSBugReportAspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. MLSBugReportAspects is meant for view/controller code that is not called a 1000 times per second.

 Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (MLSBugReportAspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block MLSBugReportAspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<MLSBugReportAspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<MLSBugReportAspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the aspect.
+ (id<MLSBugReportAspectToken>)MLS_bug_aspect_hookSelector:(SEL)selector
                           withOptions:(MLSBugReportAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<MLSBugReportAspectToken>)MLS_bug_aspect_hookSelector:(SEL)selector
                           withOptions:(MLSBugReportAspectOptions)options
                            usingBlock:(id)block
                                 error:(NSError **)error;
@end


typedef NS_ENUM(NSUInteger, MLSBugReportAspectErrorCode) {
    MLSBugReportAspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    MLSBugReportAspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    MLSBugReportAspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only MLSBugReportAspectPositionBefore is allowed.
    MLSBugReportAspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    MLSBugReportAspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    MLSBugReportAspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    MLSBugReportAspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    MLSBugReportAspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const MLSBugReportAspectErrorDomain;
