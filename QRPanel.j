//
//  QRPanel.m
//  capp
//
//  Created by bach on 2026-02-20.
//  Copyright © 2026 de.michaelbach. All rights reserved.
//


@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

// Make sure QRCode.js is loaded in your index.html:
// <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

@implementation QRPanel : CPPanel {
    CPImageWell _imageWell;
}

- (id)initWithQRString:(CPString)aString {
    var panelRect = CGRectMake(0, 0, 300, 360);

    self = [super initWithContentRect:panelRect
                            styleMask:CPTitledWindowMask | CPClosableWindowMask
                              backing:CPBackingStoreBuffered
                                defer:NO];
    if (self)     {
        [self setTitle:@"QR Code"];
        [self center];

        var contentView = [self contentView];
        var bounds = [contentView bounds];

        // ---- CPImageWell to display the QR code
        var wellSize = 240.0;
        var wellX = (bounds.size.width - wellSize) / 2.0;
        _imageWell = [[CPImageWell alloc] initWithFrame:CGRectMake(wellX, 20, wellSize, wellSize)];
        [_imageWell setImageScaling:CPScaleProportionally];
        [_imageWell setEditable:NO];
        [contentView addSubview:_imageWell];

        // ---- OK Button
        var btnWidth = 80.0, btnHeight = 30.0;
        var okButton = [[CPButton alloc] initWithFrame:
            CGRectMake((bounds.size.width - btnWidth) / 2.0,
                       bounds.size.height - btnHeight - 15.0,
                       btnWidth, btnHeight)];
        [okButton setTitle:@"OK"];
        [okButton setTarget:self];
        [okButton setAction:@selector(okClicked:)];
        [contentView addSubview:okButton];

        // ---- Generate the QR code and load it into the image well
        [self generateQRCode:aString];
    }
    return self;
}

- (void)generateQRCode:(CPString)aString {
    // Create a temporary hidden div for QRCode.js to render into
    var hiddenDiv = document.createElement("div");
    hiddenDiv.style.cssText = "position:absolute;left:-9999px;top:-9999px;";
    document.body.appendChild(hiddenDiv);

    // QRCode.js renders a <canvas> (and/or <img>) inside the div
    new QRCode(hiddenDiv, {
        text:         aString,
        width:        256,
        height:       256,
        correctLevel: QRCode.CorrectLevel.H
    });

    // QRCode.js generates the canvas asynchronously on some browsers,
    // so give it a short moment before we harvest the data URL.
    var self_ = self;
    window.setTimeout(function()     {
        var canvas = hiddenDiv.querySelector("canvas");
        var dataURL;

        if (canvas)         {
            dataURL = canvas.toDataURL("image/png");
        } else {
            // Fallback: QRCode.js may have created an <img> instead
            var img = hiddenDiv.querySelector("img");
            dataURL = img ? img.src : nil;
        }

        document.body.removeChild(hiddenDiv);   // clean up

        if (dataURL)
            [self_ _applyDataURL:dataURL];

    }, 100);  // 100 ms is plenty; increase if needed
}

- (void)_applyDataURL:(CPString)dataURL {
    // CPImage can be initialized directly from a URL — data: URLs work fine
    var qrImage = [[CPImage alloc] initWithContentsOfFile:dataURL size:CGSizeMake(256, 256)];

    // CPImage loads asynchronously, so wait for it to be ready
    if ([qrImage loadStatus] === CPImageLoadStatusCompleted)     {
        [_imageWell setImage:qrImage];
    } else {
        // Use a delegate or notification to set the image once loaded
        [qrImage setDelegate:self];
        [qrImage load];
    }
}

// CPImage delegate — called when the image finishes loading
- (void)imageDidLoad:(CPImage)anImage {
    [_imageWell setImage:anImage];
}

- (void)okClicked:(id)sender {
    [self close];
}

@end


// ---- Usage from your AppController ----------------------------------

- (void)showQRCode:(id)sender
{
    var panel = [[QRPanel alloc] initWithQRString:@"https://www.example.com"];
    [panel makeKeyAndOrderFront:self];
}
