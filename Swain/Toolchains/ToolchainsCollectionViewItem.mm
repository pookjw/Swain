//
//  ToolchainsCollectionViewItem.mm
//  Swain
//
//  Created by Jinwoo Kim on 1/19/24.
//

#import "ToolchainsCollectionViewItem.hpp"
#import "NSTextField+ApplyLabelStyle.hpp"

NSUserInterfaceItemIdentifier const identifier = NSStringFromClass(ToolchainsCollectionViewItem.class);

__attribute__((objc_direct_members))
@interface ToolchainsCollectionViewItem ()
@property (copy, nonatomic) NSManagedObjectID * _Nullable managedObjectID;
@end

@implementation ToolchainsCollectionViewItem

+ (NSUserInterfaceItemIdentifier)identifier {
    return identifier;
}

- (void)dealloc {
    [_managedObjectID release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:self.view.bounds];
    [textField applyLabelStyle];
    textField.maximumNumberOfLines = 4;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:textField];
    [NSLayoutConstraint activateConstraints:@[
        [textField.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [textField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [textField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [textField.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    self.textField = textField;
    [textField release];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)loadWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext managedObjectID:(NSManagedObjectID *)managedObjectID {
    self.managedObjectID = managedObjectID;
    
    [managedObjectContext performBlock:^{
        NSManagedObject *managedObject = [managedObjectContext objectWithID:managedObjectID];
        NSString *name = [managedObject valueForKey:@"name"];
        if (name == nil) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.managedObjectID isEqual:managedObjectID]) return;
            self.textField.stringValue = name;
        });
    }];
}

@end
