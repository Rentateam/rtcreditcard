//
//  ScanCardViewController.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 15/02/2018.
//

import Foundation
import UIKit

class ScanCardViewController: UIViewController, CardIOViewDelegate {
    private var cardIOView: CardIOView!
    
    override func viewDidLoad() {
        if ([CardIOUtilities canReadCardWithCamera]) {
            cardIOView = [[CardIOView alloc] initWithFrame:self.view.frame];
            cardIOView.hideCardIOLogo = YES;
            cardIOView.guideColor = [UIColor colorWithRed:255/255.0 green:211/255.0 blue:59/255.0 alpha:1.0];
            cardIOView.allowFreelyRotatingCardGuide = NO;
            [CardIOUtilities preload];
            cardIOView.delegate = self;
            [self.cameraContainerView addSubview:cardIOView];
            [self.cameraContainerView sendSubviewToBack:cardIOView];
        }
    }
}
