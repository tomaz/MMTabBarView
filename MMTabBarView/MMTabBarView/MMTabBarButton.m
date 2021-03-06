//
//  MMTabBarButton.m
//  MMTabBarView
//
//  Created by Michael Monscheuer on 9/5/12.
//
//

#import "MMTabBarButton.h"
#import "MMRolloverButton.h"
#import "MMTabBarButtonCell.h"
#import "MMTabBarView.h"
#import "MMTabDragAssistant.h"
#import "NSView+MMTabBarViewExtensions.h"

// Pointer value that we use as the binding context
NSString *kMMTabBarButtonOberserverContext = @"MMTabBarView.MMTabBarButton.ObserverContext";

@interface MMTabBarButton (/*Private*/)

- (void)_commonInit;
- (NSRect)_closeButtonRectForBounds:(NSRect)bounds;
- (NSRect)_indicatorRectForBounds:(NSRect)bounds;

@end

@implementation MMTabBarButton

@synthesize stackingFrame = _stackingFrame;
@synthesize closeButton = _closeButton;
@dynamic closeButtonAction;
@synthesize indicator = _indicator;

+ (void)initialize {
    [super initialize];
    
    [self exposeBinding:@"isProcessing"];
    [self exposeBinding:@"isEdited"];    
    [self exposeBinding:@"objectCount"];
    [self exposeBinding:@"objectCountColor"];
    [self exposeBinding:@"icon"];
    [self exposeBinding:@"largeImage"];
    [self exposeBinding:@"hasCloseButton"];
}

+ (Class)cellClass {
    return [MMTabBarButtonCell class];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    
    return self;
}

- (void)dealloc
{
    _closeButton = nil;
    _indicator = nil;    
}

- (MMTabBarButtonCell *)cell {
    return (MMTabBarButtonCell *)[super cell];
}

- (void)setCell:(MMTabBarButtonCell *)aCell {
    [super setCell:aCell];
}

- (MMTabBarView *)tabBarView {
    return [self enclosingTabBarView];
}
    
- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {

    [super resizeSubviewsWithOldSize:oldSize];
    
        // We do not call -calcSize before drawing (as documented).
        // We only need to calculate size when resizing.
    [self calcSize];
}

- (void)calcSize {

        // Let cell update (invokes -calcDrawInfo:)
        // Cell will update control's sub buttons too.
    [[self cell] calcDrawInfo:[self bounds]];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {

    MMTabBarView *tabBarView = [self tabBarView];
    
    return [tabBarView menuForTabBarButton:self withEvent:event];
}

- (void)updateCell {    
    [self updateCell:[self cell]];
}

#pragma mark -
#pragma mark Accessors

- (SEL)closeButtonAction {

    @synchronized(self) {
        return [_closeButton action];
    }
}

- (void)setCloseButtonAction:(SEL)closeButtonAction {

    @synchronized(self) {
        [_closeButton setAction:closeButtonAction];
    }
}

#pragma mark -
#pragma mark Dividers

- (BOOL)shouldDisplayLeftDivider {

    MMTabStateMask tabStateMask = [self tabState];
    
    BOOL retVal = NO;
    if (tabStateMask & MMTab_LeftIsSliding)
        retVal = YES;

    return retVal;
}

- (BOOL)shouldDisplayRightDivider {

    MMTabStateMask tabStateMask = [self tabState];
    
    BOOL retVal = NO;
    if (tabStateMask & MMTab_RightIsSliding)
        retVal = YES;

    return retVal;
}

#pragma mark -
#pragma mark Determine Sizes

- (CGFloat)minimumWidth {
    return [[self cell] minimumWidthOfCell];
}

- (CGFloat)desiredWidth {
    return [[self cell] desiredWidthOfCell];
}

#pragma mark -
#pragma mark Interfacing Cell

    // Overidden method of superclass.
    // Note: We use standard binding for title property.
    // Standard binding uses a binding adaptor we cannot access.
    // That means though title property is bound, our -observeValueForKeyPath:ofObject:change:context: will not called
    // if title property changes.
    // This is why we need to invoke update of layout manually.
-(void)setTitle:(NSString *)aString
{
    [super setTitle:aString];

    if ([[self tabBarView] sizeButtonsToFit])
        {
        [[NSOperationQueue mainQueue] addOperationWithBlock:
            ^{
            [[self tabBarView] update];
            }];
        }
    
}  // -setTitle:

- (id <MMTabStyle>)style {
    return [[self cell] style];
}

- (void)setStyle:(id <MMTabStyle>)newStyle {
    [[self cell] setStyle:newStyle];
    [self updateCell];
}

- (MMTabStateMask)tabState {
    return [[self cell] tabState];
}

- (void)setTabState:(MMTabStateMask)newState {

    [[self cell] setTabState:newState];
    [self updateCell];
}

- (BOOL)shouldDisplayCloseButton {
    return [[self cell] shouldDisplayCloseButton];
}

- (BOOL)hasCloseButton {
    return [[self cell] hasCloseButton];
}

- (void)setHasCloseButton:(BOOL)newState {
    [[self cell] setHasCloseButton:newState];
    [self updateCell];
}

- (BOOL)suppressCloseButton {
    return [[self cell] suppressCloseButton];
}

- (void)setSuppressCloseButton:(BOOL)newState {
    [[self cell] setSuppressCloseButton:newState];
    [self updateCell];
}

- (NSImage *)icon {
    return [[self cell] icon];
}

- (void)setIcon:(NSImage *)anIcon {
    [[self cell] setIcon:anIcon];
    [self updateCell];
}

- (NSImage *)largeImage {
    return [[self cell] largeImage];
}

- (void)setLargeImage:(NSImage *)anImage {
    [[self cell] setLargeImage:anImage];
    [self updateCell];
}

- (BOOL)showObjectCount {
    return [[self cell] showObjectCount];
}

- (void)setShowObjectCount:(BOOL)newState {
    [[self cell] setShowObjectCount:newState];
    [self updateCell];
}

- (NSInteger)objectCount {
    return [[self cell] objectCount];
}

- (void)setObjectCount:(NSInteger)newCount {
    [[self cell] setObjectCount:newCount];
    [self updateCell];
}

- (NSColor *)objectCountColor {
    return [[self cell] objectCountColor];
}

- (void)setObjectCountColor:(NSColor *)newColor {
    [[self cell] setObjectCountColor:newColor];
    [self updateCell];
}

- (BOOL)isEdited {
    return [[self cell] isEdited];
}

- (void)setIsEdited:(BOOL)newState {
    [[self cell] setIsEdited:newState];
    [self updateCell];
}

- (BOOL)isProcessing {
    return [[self cell] isProcessing];
}

- (void)setIsProcessing:(BOOL)newState {
    [[self cell] setIsProcessing:newState];
    [self updateCell];
}

- (void)updateImages {
    [[self cell] updateImages];
}

#pragma mark -
#pragma mark Bindings

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options 
{
    if ([binding isEqualToString:@"objectCount"])
        {
        _objectCountBindingObservedObject = observable;
        _objectCountBindingKeyPath = [keyPath copy];
        _objectCountBindingOptions = [options copy];
        
        [_objectCountBindingObservedObject addObserver:self forKeyPath:_objectCountBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }
    else if ([binding isEqualToString:@"objectCountColor"])
        {
        _objectCountColorBindingObservedObject = observable;
        _objectCountColorBindingKeyPath = [keyPath copy];
        _objectCountColorBindingOptions = [options copy];
        
        [_objectCountColorBindingObservedObject addObserver:self forKeyPath:_objectCountColorBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }         
    else if ([binding isEqualToString:@"isProcessing"])
        {
        _isProcessingBindingObservedObject = observable;
        _isProcessingBindingKeyPath = [keyPath copy];
        _isProcessingBindingOptions = [options copy];        
        
        [_isProcessingBindingObservedObject addObserver:self forKeyPath:_isProcessingBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }
    else if ([binding isEqualToString:@"isEdited"])
        {
        _isEditedBindingObservedObject = observable;
        _isEditedBindingKeyPath = [keyPath copy];
        _isEditedBindingOptions = [options copy];
        
        [_isEditedBindingObservedObject addObserver:self forKeyPath:_isEditedBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }        
    else if ([binding isEqualToString:@"icon"])
        {
        _iconBindingObservedObject = observable;
        _iconBindingKeyPath = [keyPath copy];
        _iconBindingOptions = [options copy];
        
        [_iconBindingObservedObject addObserver:self forKeyPath:_iconBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }
    else if ([binding isEqualToString:@"largeImage"])
        {
        _largeImageBindingObservedObject = observable;
        _largeImageBindingKeyPath = [keyPath copy];
        _largeImageBindingOptions = [options copy];
        
        [_largeImageBindingObservedObject addObserver:self forKeyPath:_largeImageBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }
    else if ([binding isEqualToString:@"hasCloseButton"])
        {
        _hasCloseButtonBindingObservedObject = observable;
        _hasCloseButtonBindingKeyPath = [keyPath copy];
        _hasCloseButtonBindingOptions = [options copy];
        
        [_hasCloseButtonBindingObservedObject addObserver:self forKeyPath:_hasCloseButtonBindingKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(kMMTabBarButtonOberserverContext)];
        }                 
    else 
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];

}  // -bind:toObject:withKeyPath:options:

- (void)unbind:(NSString *)binding 
{
    if ([binding isEqualToString:@"objectCount"]) 
        {
        [_objectCountBindingObservedObject removeObserver:self forKeyPath:_objectCountBindingKeyPath];
        _objectCountBindingObservedObject = nil;
        _objectCountBindingKeyPath = nil;
        _objectCountBindingOptions = nil;
        }
    if ([binding isEqualToString:@"objectCountColor"]) 
        {
        [_objectCountColorBindingObservedObject removeObserver:self forKeyPath:_objectCountColorBindingKeyPath];
        _objectCountColorBindingObservedObject = nil;
        _objectCountColorBindingKeyPath = nil;
        _objectCountColorBindingOptions = nil;
        }        
    else if ([binding isEqualToString:@"isProcessing"])
        {
        [_isProcessingBindingObservedObject removeObserver:self forKeyPath:_isProcessingBindingKeyPath];
        _isProcessingBindingObservedObject = nil;
        _isProcessingBindingKeyPath = nil;
        _isProcessingBindingOptions = nil;
        }
    else if ([binding isEqualToString:@"isEdited"])
        {
        [_isEditedBindingObservedObject removeObserver:self forKeyPath:_isEditedBindingKeyPath];
        _isEditedBindingObservedObject = nil;
        _isEditedBindingKeyPath = nil;
        _isEditedBindingOptions = nil;
        }        
    else if ([binding isEqualToString:@"icon"])
        {
        [_iconBindingObservedObject removeObserver:self forKeyPath:_iconBindingKeyPath];
        _iconBindingObservedObject = nil;
        _iconBindingKeyPath = nil;
        _iconBindingOptions = nil;
        }
    else if ([binding isEqualToString:@"largeImage"])
        {
        [_largeImageBindingObservedObject removeObserver:self forKeyPath:_largeImageBindingKeyPath];
        _largeImageBindingObservedObject = nil;
        _largeImageBindingKeyPath = nil;
        _largeImageBindingOptions = nil;
        }
    else if ([binding isEqualToString:@"hasCloseButton"])
        {
        [_hasCloseButtonBindingObservedObject removeObserver:self forKeyPath:_hasCloseButtonBindingKeyPath];
        _hasCloseButtonBindingObservedObject = nil;
        _hasCloseButtonBindingKeyPath = nil;
        _hasCloseButtonBindingOptions = nil;
        }           
    else
        [super unbind:binding];

}  // -unbind:

-(NSDictionary *)infoForBinding:(NSString *)binding
{
    if ([binding isEqualToString:@"objectCount"])
        {
        return @{NSObservedObjectKey: _objectCountBindingObservedObject,
                NSObservedKeyPathKey: _objectCountBindingKeyPath,
                NSOptionsKey: _objectCountBindingOptions};
        }
    if ([binding isEqualToString:@"objectCountColor"])
        {
        return @{NSObservedObjectKey: _objectCountColorBindingObservedObject,
                NSObservedKeyPathKey: _objectCountColorBindingKeyPath,
                NSOptionsKey: _objectCountColorBindingOptions};
        }        
    else if ([binding isEqualToString:@"isProcessing"]) 
        {
        return @{NSObservedObjectKey: _isProcessingBindingObservedObject,
                NSObservedKeyPathKey: _isProcessingBindingKeyPath,
                NSOptionsKey: _isProcessingBindingOptions};
        }
    else if ([binding isEqualToString:@"isEdited"]) 
        {
        return @{NSObservedObjectKey: _isEditedBindingObservedObject,
                NSObservedKeyPathKey: _isEditedBindingKeyPath,
                NSOptionsKey: _isEditedBindingOptions};
        }        
    else if ([binding isEqualToString:@"icon"])
        {
        return @{NSObservedObjectKey: _iconBindingObservedObject,
                NSObservedKeyPathKey: _iconBindingKeyPath,
                NSOptionsKey: _iconBindingOptions};
        }
    else if ([binding isEqualToString:@"largeImage"])
        {
        return @{NSObservedObjectKey: _largeImageBindingObservedObject,
                NSObservedKeyPathKey: _largeImageBindingKeyPath,
                NSOptionsKey: _largeImageBindingOptions};
        }
    else if ([binding isEqualToString:@"hasCloseButton"]) 
        {
        return @{NSObservedObjectKey: _hasCloseButtonBindingObservedObject,
                NSObservedKeyPathKey: _hasCloseButtonBindingKeyPath,
                NSOptionsKey: _hasCloseButtonBindingOptions};
        }            
    else
        return [super infoForBinding:binding];
}  // -infoForBinding:

#pragma mark -
#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ([keyPath isEqualTo:_objectCountBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {
    
        id objectCountValue = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting: {
            
                objectCountValue = [object valueForKeyPath:_objectCountBindingKeyPath];
                if (objectCountValue == NSNoSelectionMarker) {
                    [self setObjectCount:0.f];
                } else if ([objectCountValue isKindOfClass:[NSNumber class]]) {
                    NSValueTransformer *valueTransformer = nil;                
                    NSString *valueTransformerName = _objectCountBindingOptions[NSValueTransformerNameBindingOption];
                    if (valueTransformerName != nil)
                        valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];

                    if (valueTransformer == nil)
                        valueTransformer = _objectCountBindingOptions[NSValueTransformerBindingOption];
                        
                    if (valueTransformer != nil)
                        objectCountValue = [valueTransformer transformedValue:objectCountValue];
                                        
                    [self setObjectCount:[objectCountValue integerValue]];
                } else {
                    [self setObjectCount:0];
                }

                id autoHideValue = _objectCountBindingOptions[NSConditionallySetsHiddenBindingOption];
                if (autoHideValue != nil)
                    {
                    if ([autoHideValue boolValue] == YES)
                        {
                        if (objectCountValue == NSNoSelectionMarker || objectCountValue == nil || [objectCountValue integerValue] == 0)
                            [self setShowObjectCount:NO];
                        else
                            [self setShowObjectCount:YES];
                        }
                    }
                else
                    [self setShowObjectCount:YES];
                break;
            
            }
            default:
                break;

        }
    } else if ([keyPath isEqualTo:_objectCountColorBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        NSColor *color = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                color = [object valueForKeyPath:_objectCountColorBindingKeyPath];
                if (color == NSNoSelectionMarker) {
                    [self setObjectCountColor:nil];
                    }
                else if ([color isKindOfClass:[NSColor class]]) {
                    [self setObjectCountColor:color];
                    }
                else
                    [self setObjectCountColor:nil];
                break;
            
            default:
                break;

        }        
    } else if ([keyPath isEqualTo:_isProcessingBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        id isProcessingValue = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                isProcessingValue = [object valueForKeyPath:_isProcessingBindingKeyPath];
                if (isProcessingValue == NSNoSelectionMarker) {
                    [self setIsProcessing:NO];
                    }
                else if ([isProcessingValue isKindOfClass:[NSNumber class]]) {

                    NSValueTransformer *valueTransformer = nil;                
                    NSString *valueTransformerName = _isProcessingBindingOptions[NSValueTransformerNameBindingOption];
                    if (valueTransformerName != nil)
                        valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];

                    if (valueTransformer == nil)
                        valueTransformer = _isProcessingBindingOptions[NSValueTransformerBindingOption];
                        
                    if (valueTransformer != nil)
                        isProcessingValue = [valueTransformer transformedValue:isProcessingValue];

                    BOOL newIsProcessingState = NO;
                    if (isProcessingValue != nil)
                        newIsProcessingState = [isProcessingValue boolValue];
                    else
                        newIsProcessingState = NO;
                                        
                    [self setIsProcessing:newIsProcessingState];
                    }
                else
                    [self setIsProcessing:NO];
                break;
            
            default:
                break;

        }
    } else if ([keyPath isEqualTo:_isEditedBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        id isEditedValue = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                isEditedValue = [object valueForKeyPath:_isEditedBindingKeyPath];
                if (isEditedValue == NSNoSelectionMarker) {
                    [self setIsEdited:NO];
                    }
                else if ([isEditedValue isKindOfClass:[NSNumber class]]) {

                    NSValueTransformer *valueTransformer = nil;                
                    NSString *valueTransformerName = _isEditedBindingOptions[NSValueTransformerNameBindingOption];
                    if (valueTransformerName != nil)
                        valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];

                    if (valueTransformer == nil)
                        valueTransformer = _isEditedBindingOptions[NSValueTransformerBindingOption];
                        
                    if (valueTransformer != nil)
                        isEditedValue = [valueTransformer transformedValue:isEditedValue];

                    BOOL newIsEditedState = NO;
                    if (isEditedValue != nil)
                        newIsEditedState = [isEditedValue boolValue];
                    else
                        newIsEditedState = NO;
                                        
                    [self setIsEdited:newIsEditedState];
                    }
                else
                    [self setIsEdited:NO];
                break;
            
            default:
                break;

        }        
    } else if ([keyPath isEqualTo:_iconBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        NSImage *icon = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                icon = [object valueForKeyPath:_iconBindingKeyPath];
                if (icon == NSNoSelectionMarker) {
                    [self setIcon:nil];
                    }
                else if ([icon isKindOfClass:[NSImage class]]) {
                    [self setIcon:icon];
                    }
                else
                    [self setIcon:nil];
                break;
            
            default:
                break;

        }
    } else if ([keyPath isEqualTo:_largeImageBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        NSImage *largeImage = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                largeImage = [object valueForKeyPath:_largeImageBindingKeyPath];
                if (largeImage == NSNoSelectionMarker) {
                    [self setLargeImage:nil];
                    }
                else if ([largeImage isKindOfClass:[NSImage class]]) {
                    [self setLargeImage:largeImage];
                    }
                else
                    [self setLargeImage:nil];
                break;
            
            default:
                break;

        }
    } else if ([keyPath isEqualTo:_hasCloseButtonBindingKeyPath] && context == (__bridge void *)(kMMTabBarButtonOberserverContext)) {

        id hasCloseButtonValue = nil;
    
        switch([change[NSKeyValueChangeKindKey] integerValue]) {
            case NSKeyValueChangeSetting:
                
                hasCloseButtonValue = [object valueForKeyPath:_hasCloseButtonBindingKeyPath];
                if (hasCloseButtonValue == NSNoSelectionMarker) {
                    [self setHasCloseButton:NO];
                    }
                else if ([hasCloseButtonValue isKindOfClass:[NSNumber class]]) {

                    NSValueTransformer *valueTransformer = nil;                
                    NSString *valueTransformerName = _hasCloseButtonBindingOptions[NSValueTransformerNameBindingOption];
                    if (valueTransformerName != nil)
                        valueTransformer = [NSValueTransformer valueTransformerForName:valueTransformerName];

                    if (valueTransformer == nil)
                        valueTransformer = _hasCloseButtonBindingOptions[NSValueTransformerBindingOption];
                        
                    if (valueTransformer != nil)
                        hasCloseButtonValue = [valueTransformer transformedValue:hasCloseButtonValue];

                    BOOL newState = NO;
                    if (hasCloseButtonValue != nil)
                        newState = [hasCloseButtonValue boolValue];
                    else
                        newState = NO;
                                        
                    [self setHasCloseButton:newState];
                    }
                else
                    [self setHasCloseButton:NO];
                break;
            
            default:
                break;

        }                
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

    if (context == (__bridge void *)(kMMTabBarButtonOberserverContext))
        {
        if ([[self tabBarView] sizeButtonsToFit])
            {
            [[NSOperationQueue mainQueue] addOperationWithBlock:
                ^{
                [[self tabBarView] update];
                }];
            }
        }
 
}  // -observeValueForKeyPath:ofObject:change:context:

#pragma mark -
#pragma mark Private Methods

- (void)_commonInit {

    NSRect closeButtonRect = [self _closeButtonRectForBounds:[self bounds]];
    _closeButton = [[MMRolloverButton alloc] initWithFrame:closeButtonRect];
    
    [_closeButton setTitle:@""];
    [_closeButton setImagePosition:NSImageOnly];
    [_closeButton setRolloverButtonType:MMRolloverActionButton];
    [_closeButton setBordered:NO];
    [_closeButton setBezelStyle:NSShadowlessSquareBezelStyle];
    [self addSubview:_closeButton];

    _indicator = [[MMProgressIndicator alloc] initWithFrame:NSMakeRect(0.0, 0.0, kMMTabBarIndicatorWidth, kMMTabBarIndicatorWidth)];
    [_indicator setStyle:NSProgressIndicatorSpinningStyle];
    [_indicator setAutoresizingMask:NSViewMinYMargin];
    [_indicator setControlSize: NSSmallControlSize];
    NSRect indicatorRect = [self _indicatorRectForBounds:[self bounds]];
    [_indicator setFrame:indicatorRect];
    [self addSubview:_indicator];
}

- (NSRect)_closeButtonRectForBounds:(NSRect)bounds {
    return [[self cell] closeButtonRectForBounds:bounds];
}

- (NSRect)_indicatorRectForBounds:(NSRect)bounds {
    return [[self cell] indicatorRectForBounds:bounds];
}

@end