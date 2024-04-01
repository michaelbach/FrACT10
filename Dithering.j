/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

Dithering.j

Created by Bach on 2024-03-23.
 
*/

/**
 * Dithering
 *
 * Creates 3×3 images programmatically with desired dither patterns which can be used to fill, e.g.:
 * `[CPColor colorWithPatternImage: [Dithering image3x3withGray: g]];
 *  g ∈ [0, 1]
 *  g it is multiplied by 255, the integer part is the`greyvalue across all 9 pixels.
 *  The remainder is then used to set 1 to 8 pixesl one bit higher.
 *  The result is a resolution increase by a factor of 9.
 *  The patterns differ only by 1 bit between pixels and are all but invisible.
 *
 * */

 
@import <Foundation/CPObject.j>
@import <AppKit/AppKit.j>


@implementation Dithering: CPObject {
    CPImage patternImage;
}

// https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Pixel_manipulation_with_canvas
/*function setPixelRGBA(imageData, x, y, r, g, b, a=255) {
    const idx = 4 * (x + y * imageData.width);
    imageData.data[idx] = r;
    imageData.data[idx+1] = g;
    imageData.data[idx+2] = b;
    imageData.data[idx+3] = a;
}
function setPixelRGB(imageData, x, y, r, g, b) { // assuming alpha already set
    const idx = 4 * (x + y * imageData.width);
    imageData.data[idx] = r;
    imageData.data[idx+1] = g;
    imageData.data[idx+2] = b;    //imageData.data[idx+3] = 255;
}*/
function setPixelGray(imageData, x, y, g) { // assuming alpha already set
    const idx = 4 * (x + y * imageData.width);
    imageData.data[idx] = g;
    imageData.data[idx+1] = g;
    imageData.data[idx+2] = g;
}


/* Dither patterns used:
   2x2:  1 3     3x3:  7  9  5
         4 2           2  1  4
                       6  3  8 */
+ (CPImage) image3x3withGray: (int) g { //console.log("Dithering>image3x3withGray");
    g *= 255; // 0…1 → 0…255
    const integerPart = Math.floor(g);
    let fractionalPart = g - integerPart;
    fractionalPart = Math.round(fractionalPart * 9); //console.info(g, integerPart, fractionalPart)
    // use only 0…8, 9 would be 1 bit higher for the intPart
    const offCanvas = document.createElement('canvas');  offCanvas.width = 3;  offCanvas.height = 3;
    const offContext = offCanvas.getContext('2d');
    const imageData = offContext.createImageData(3, 3);// this presets all to 0 = transparent black
    //console.info(offCanvas, offContext, imageData)
    for (let i=0; i < 4 * 9; i++) imageData.data[i] = integerPart; // set all to non-dithered gray level
    for (let i=0; i < 9; i++) imageData.data[3 + i * 4] = 255; // set alpha to opaque
    const f = integerPart + 1; // one bit higher than the average gray level
    if (fractionalPart >= 1) { // check which pixels need to be set one index higher
        setPixelGray(imageData, 1, 1, f);
        if (fractionalPart >= 2) {
            setPixelGray(imageData, 0, 1, f);
            if (fractionalPart >= 3) {
                setPixelGray(imageData, 1, 2, f);
                if (fractionalPart >= 4) {
                    setPixelGray(imageData, 2, 1, f);
                    if (fractionalPart >= 5) {
                        setPixelGray(imageData, 2, 0, f);
                        if (fractionalPart >= 6) {
                            setPixelGray(imageData, 0, 2, f);
                            if (fractionalPart >= 7) {
                                setPixelGray(imageData, 0, 0, f);
                                if (fractionalPart >= 8) {
                                    setPixelGray(imageData, 2, 2, f);
                                    if (fractionalPart >= 9) {
                                        //console.info("Dithering>image3x3withGray, ≥9 should not occur");
                                        setPixelGray(imageData,  1, 0, f);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    offContext.putImageData(imageData, 0, 0); // write the generated dither pattern to offscreen
    let dataURL = [CPString stringWithString: offContext.canvas.toDataURL("image/png")];
    dataURL = [dataURL substringFromIndex: 22]; // need to drop "data:image/png;base64,"
    patternImage = [[CPImage alloc] initWithData: [CPData dataWithBase64: dataURL]];
    return patternImage;
    // return [patternImage copy];
    // As written now, ↑ can only store one patternImage, but seems to be ok.
}


@end
