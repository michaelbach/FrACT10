/*
This file is part of FrACT10, a vision test battery.
© 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

QRPanel.j
For the remote response box: create a QR code with url + session code

Created by Bach on 2026-02-20.

*/



@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@global QRCode //to get rid of the warnings
@global document
// QRCode.js loaded in index.html:
// <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

@implementation QRPanel : CPPanel {
    CPImageView _imageWell;
}

- (id)initWithQRString: (CPString) aString {
    const panelRect = CGRectMake(0, 0, 300, 400);
    self = [super initWithContentRect: panelRect styleMask: CPTitledWindowMask | CPClosableWindowMask];
    if (self) {
        [self setTitle: "QR Code"];
        [self center];
        const contentView = [self contentView];
        const bounds = [contentView bounds];

        //CPImageWell to display the QR code
        const wellSize = 240.0;
        const wellX = (bounds.size.width - wellSize) / 2.0;
        _imageWell = [[CPImageView alloc] initWithFrame: CGRectMake(wellX, 20, wellSize, wellSize)];
        [_imageWell setImageScaling: CPScaleProportionally];
        [_imageWell setEditable: NO];
        [contentView addSubview: _imageWell];

        const lbl = [CPTextField labelWithTitle: "Scan QR code↑ with smartphone;\nopen webpage to pair.\nThen you can respond remotely."];

        [lbl setFrame: CGRectMake(0, 0, bounds.size.width, 0)]; //ensures multiline
        [lbl setLineBreakMode: CPLineBreakByWordWrapping];
        [lbl setAlignment: CPCenterTextAlignment];
        [lbl setFont:[CPFont systemFontOfSize: 16.0]];
        [lbl sizeToFit];
        const lblWidth = [lbl frame].size.width;
        [lbl setFrameOrigin: CGPointMake((bounds.size.width - lblWidth) / 2, 280)];
        [contentView addSubview: lbl];

        //OK Button
        const btnWidth = 80.0, btnHeight = 30.0;
        const okButton = [[CPButton alloc] initWithFrame:
            CGRectMake((bounds.size.width - btnWidth) / 2.0,
                       bounds.size.height - btnHeight - 15.0,
                       btnWidth, btnHeight)];
        [okButton setTitle: "OK"];
        [okButton setTarget: self];
        [okButton setAction: @selector(okClicked:)];
        [okButton setKeyEquivalent: "\r"];
        [contentView addSubview: okButton];

        [self generateQRCode: aString]; //Generate the QR code and load it into the image well
    }
    return self;
}

- (void)generateQRCode: (CPString) aString {
    // Create a temporary hidden div for QRCode.js to render into
    const hiddenDiv = document.createElement("div");
    hiddenDiv.style.cssText = "position:absolute;left:-9999px;top:-9999px;";
    document.body.appendChild(hiddenDiv);

    // QRCode.js renders a <canvas> (and/or <img>) inside the div
    new QRCode(hiddenDiv, {
        text: aString, width: 256, height: 256, correctLevel: QRCode.CorrectLevel.M
    });

    // QRCode.js generates the canvas asynchronously on some browsers,
    // so give it a short moment before we harvest the data URL.
    const self_ = self;
    window.setTimeout(function() {
        const canvas = hiddenDiv.querySelector("canvas");
        let dataURL;
        if (canvas) {
            dataURL = canvas.toDataURL("image/png");
        } else {// Fallback: QRCode.js may have created an <img> instead
            const img = hiddenDiv.querySelector("img");
            dataURL = img ? img.src : nil;
        }
        document.body.removeChild(hiddenDiv); //clean up
        if (dataURL) [self_ _applyDataURL: dataURL];
    }, 100); //100 ms is plenty
}

- (void)_applyDataURL: (CPString) dataURL {
    const qrImage = [[CPImage alloc] initWithContentsOfFile: dataURL size: CGSizeMake(256, 256)];
    //CPImage loads asynchronously, so wait for it to be ready
    if ([qrImage loadStatus] === CPImageLoadStatusCompleted)     {
        [_imageWell setImage: qrImage];
    } else { //Use a delegate or notification to set the image once loaded
        [qrImage setDelegate: self];
        [qrImage load];
    }
}

// CPImage delegate — called when the image finishes loading
- (void)imageDidLoad: (CPImage) anImage {
    [_imageWell setImage: anImage];
}

- (void)okClicked: (id) sender {
    [self close];
}


@end
