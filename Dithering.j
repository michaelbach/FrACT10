/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

PopulateAboutPanel.j

Created by Bach on 2024-03-23.

 Deals with dither patterns
 
*/

/**
 * Dithering
 *
 * Deals with dither patterns
 *
 * */

 
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


@implementation Dithering: CPObject {
    CPImage patternImage;
    id offCanvas, offContext;
}


+ (void) init { // console.log("Dithering>init");
    offCanvas = document.createElement('canvas');
    offCanvas.width = 2;  offCanvas.height = 2;
    offContext = offCanvas.getContext('2d');
}


function setPixelRGBA(imageData, x, y, r, g, b, a=255) {
    var index = 4 * (x + y * imageData.width);
    imageData.data[index] = r;
    imageData.data[index+1] = g;
    imageData.data[index+2] = b;
    imageData.data[index+3] = a;
}
function setPixelRGB(imageData, x, y, r, g, b) {
    var index = 4 * (x + y * imageData.width);
    imageData.data[index] = r;
    imageData.data[index+1] = g;
    imageData.data[index+2] = b;    //imageData.data[index+3] = 255;
}


+ (CPImage) image2x2byte: (int) b { //console.log("Dithering>image2x2byte");
    const t = typeof(offCanvas);
    if (t == 'undefined') [self init];
    const imageData = offContext.createImageData(2, 2);// all0 = transparent
    for (let i=0; i < 4; i++) imageData.data[3 + i * 4] = 255; // set alpha
    setPixelRGB(imageData, 0, 0, b, b, b);
    setPixelRGB(imageData, 1, 0, b, b, b);
    setPixelRGB(imageData, 0, 1, b, b, b);
    setPixelRGB(imageData, 1, 1, b, b, b);
    offContext.putImageData(imageData, 0, 0);
    const dataURL = offContext.canvas.toDataURL("image/png");// need to drop "data:image/png;base64,"
    patternImage = [[CPImage alloc] initWithData: [CPData dataWithBase64: dataURL.substring(22)]];
    return patternImage;
}

@end
