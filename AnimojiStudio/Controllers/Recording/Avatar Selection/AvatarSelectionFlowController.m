//
//  AvatarSelectionFlowController.m
//  AnimojiStudio
//
//  Created by Guilherme Rambo on 17/08/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

#import "AvatarSelectionFlowController.h"

#import "PuppetSelectionViewController.h"

#import "AVTAvatarStore.h"
#import "AVTAvatarLibraryViewController.h"

#import "MemojiSupport.h"
#import "AVTAnimoji.h"

#import "UIViewController+Children.h"

#import "WelcomeViewController.h"
#import "MemojiSelectionViewController.h"

@interface AvatarSelectionFlowController () <WelcomeViewControllerDelegate, PuppetSelectionDelegate>

@property (nonatomic, strong) WelcomeViewController *welcomeController;

@end

@implementation AvatarSelectionFlowController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    if ([MemojiSupport deviceSupportsMemoji]) {
        self.welcomeController = [WelcomeViewController new];
        self.welcomeController.delegate = self;

        [self installChildViewController:self.welcomeController];
    } else {
        self.title = @"Select Character";
        [self _showAnimojiPuppetSelection];
    }
}

- (void)welcomeViewControllerDidSelectMemojiMode:(WelcomeViewController *)controller
{
    [self _pushMemojiSelection];
}

- (void)welcomeViewControllerDidSelectClassicAnimojiMode:(WelcomeViewController *)controller
{
    [self _showAnimojiPuppetSelection];
}

#pragma mark Memoji

- (void)_pushMemojiSelection
{
    AVTAvatarStore *store = [[ASAvatarStore alloc] initWithDomainIdentifier:[NSBundle mainBundle].bundleIdentifier];
    AVTAvatarLibraryViewController *libraryController = [[ASAvatarLibraryViewController alloc] initWithAvatarStore:store];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleMemojiSelectedWithNotification:) name:DidSelectMemoji object:nil];

    MemojiSelectionViewController *selection = [MemojiSelectionViewController memojiSelectionViewControllerWithEmbeddedController:libraryController];
    [self.navigationController pushViewController:selection animated:YES];
}

- (void)_handleMemojiSelectedWithNotification:(NSNotification *)note
{
    NSData *memojiData = (NSData *)note.object;
    if (![memojiData isKindOfClass:[NSData class]]) return;

    NSError *error;
    id avatar = [AVTAvatar avatarWithDataRepresentation:memojiData error:&error];

    if (error) {
        // TODO: Present error
        return;
    }

    [self.delegate avatarSelectionFlowController:self didSelectAvatarInstance:(AVTAvatarInstance *)avatar];
}

#pragma mark Animoji

- (void)_showAnimojiPuppetSelection
{
    PuppetSelectionViewController *controller = [PuppetSelectionViewController new];
    controller.delegate = self;

    if ([MemojiSupport deviceSupportsMemoji]) {
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self installChildViewController:controller];
    }
}

- (void)puppetSelectionViewController:(PuppetSelectionViewController *)controller didSelectPuppetWithName:(NSString *)puppetName
{
    AVTAvatarInstance *instance = (AVTAvatarInstance *)[AVTAnimoji animojiNamed:puppetName];
    [self.delegate avatarSelectionFlowController:self didSelectAvatarInstance:instance];
}

@end
