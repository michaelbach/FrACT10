/*
 * ResponseInfoPanelController.j
 * FrACT10
 *
 * Created on 2026-03-06.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPPanel.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPCheckBox.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPImage.j>

@import "Globals.j"


const buttonsWidth = 130, buttonsHeight = 23, buttonsOkWidth = 64;
const buttonsY = (kFractHeight - buttonsHeight - 18);


@implementation ResponseInfoPanelController: CPObject {
    CPPanel _panel;
    int _testID @accessors(property=testID);
    CPView contentView;
}


+ (CPPanel) panelForTestID: (int) aTestID { //console.info("panelForTestID", aTestID);
    const controller = [[self alloc] initWithTestID: aTestID];
    return [controller panel];
}


- (id) initWithTestID: (int) aTestID { //console.info("initWithTestID", aTestID);
    self = [super init];
    if (self) {
        _testID = aTestID;  [self _buildPanel];
    }
    return self;
}


- (CPPanel) panel {
    return _panel;
}


- (void) _buildPanel { //console.info("ResponseInfoPanelController>_buildPanel", _testID);
    const content = [self _contentForTestID: _testID];
    _panel = [[CPPanel alloc] initWithContentRect: CGRectMake(0, 0, kFractWidth, kFractHeight) styleMask: CPTitledWindowMask];
    [_panel setTitle: content.title]; [_panel setFloatingPanel: YES]; [_panel setMovable: NO];
    contentView = [_panel contentView];
    
    const textField = [[CPTextField alloc] initWithFrame: CGRectMake(kGuiMarginHorizontal, kGuiMarginHorizontal, 400, 320)];
    [textField setStringValue: content.text];
    [textField setFont: [CPFont systemFontOfSize: 16]];
    [textField setLineBreakMode: CPLineBreakByWordWrapping];
    [textField setSelectable: YES];  [textField setEditable: NO];
    [textField setBezeled: YES];
    [contentView addSubview: textField];

    if (content.imageName) {  //optional image
        const imageView = [[CPImageView alloc] initWithFrame: CGRectMake(450, 0, 320, 300)];
        [imageView setImage: [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: content.imageName]]];
        [imageView setImageScaling: CPImageScaleProportionallyDown];
        if (content.imageToolTip) [imageView setToolTip: content.imageToolTip];
        const frame = [imageView frame];
        const xMid = CGRectGetMidX(frame), yMid = CGRectGetMidY(frame);
        if (content.imageWidth) {
            const x0 = xMid - content.imageWidth / 2, y0 = yMid - content.imageWidth / 2;
            [imageView setFrame: CGRectMake(x0, y0, content.imageWidth, content.imageWidth)];
        }
        [contentView addSubview: imageView];
        if (_testID === kTestAcuityE || _testID === kTestContrastE) { //tumbling Es
            const eImages = ["optotypeE270", "optotypeE000", "optotypeE090", "optotypeE180"];
            const d = 94, xm = xMid - 20, w = 38, h = 32;
            const frames = [CGRectMake(xm, yMid + d / 2, w, h), CGRectMake(xm + d, yMid, w, h), CGRectMake(xm, yMid - d, w, h), CGRectMake(xm - d, yMid, w, h)];
            for (let i = 0; i < 4; i++) {
                const ivE = [[CPImageView alloc] initWithFrame: frames[i]];
                [ivE setImage: [[CPImage alloc] initWithContentsOfFile: [[CPBundle mainBundle] pathForResource: ("optotypeEs/"+ eImages[i] + ".png")]]];
                [contentView addSubview: ivE];
            }
        }
    }
    
    //Checkboxes
    const touchCheckbox = [CPCheckBox checkBoxWithTitle: "Enable Touch Controls (necessary without keyboard)"];
    [touchCheckbox setFrame: CGRectMake(kGuiMarginHorizontal, buttonsY - 50, 400, 18)];
    [touchCheckbox bind: "value" toObject: [CPUserDefaultsController sharedUserDefaultsController] withKeyPath: "values.enableTouchControls" options: nil];
    [contentView addSubview: touchCheckbox];

    const showPanelCheckbox = [CPCheckBox checkBoxWithTitle: "Show the present panel “How to operate” at start of run"];
    [showPanelCheckbox setFrame: CGRectMake(kGuiMarginHorizontal, buttonsY, 480, 18)];
    [showPanelCheckbox setToolTip: "When you start a test, a brief description will appear. Here you can get rid of it."];
    [showPanelCheckbox bind: "value" toObject: [CPUserDefaultsController sharedUserDefaultsController] withKeyPath: "values.showResponseInfoAtStart" options: nil];
    [contentView addSubview: showPanelCheckbox];

    //Buttons
    const okButton = [[CPButton alloc] initWithFrame: CGRectMake(kFractWidth-kGuiMarginHorizontal-buttonsOkWidth,buttonsY, buttonsOkWidth, buttonsHeight)];
    [okButton setTitle: "OK"];
    [okButton setTarget: gAppController];
    [okButton setAction: @selector(runFractController2_actionOK:)];
    [okButton setKeyEquivalent: crlf];
    [contentView addSubview: okButton];

    const cancelButton = [[CPButton alloc] initWithFrame: CGRectMake(kFractWidth-kGuiMarginHorizontal-2*buttonsOkWidth-kGuiMarginHorizontal, buttonsY, buttonsOkWidth, buttonsHeight)];
    [cancelButton setTitle: "Cancel"];
    [cancelButton setTarget: gAppController];
    [cancelButton setAction: @selector(runFractController2_actionCancel:)];
    [cancelButton setKeyEquivalent: CPEscapeFunctionKey];
    [contentView addSubview: cancelButton];

    [_panel center];
}


- (id) _contentForTestID: (int) aTestID {
    const content = {title: "", text: "", imageName: nil, imageToolTip: nil, imageWidth: 200};

    const TOUCH_BOTTOM = "\n\nOn touch devices, use the buttons at the bottom of the screen (when enabled).",
        TOUCH_AROUND = "\n\nOn touch devices, use the buttons around the screen (when enabled).",
        ABORT_55 = "\n\nType 55 or <esc>, or touch Ø to abort the run.",
        GUESS = function(what) { return "\n\nIf you can't recognise the " + what + ", use your best guess."; };

    const dataMapping = {
        [kTestAcuityLetters]: {
            title: "Letter acuity",
            text: "\nUse the letter keys on your keyboard to type the letter appearing on the screen." + TOUCH_BOTTOM + GUESS("letter") + ABORT_55
        },
        [kTestAcuityLandolt]: function() {
            const is4alt = [Settings nAlternatives] === 4;
            return {
                title: "Landolt ring acuity",
                text: (is4alt ? 
                    "\nRings with gaps will appear, how are they oriented?\n\nUse the cursor keys, or on a keypad:\n→ = 6,  ↑ = 8,  ← = 4,  ↓ = 2." :
                    "\nRings with gaps will appear, where is the gap?\n\nUse the number keys on number pad of your keyboard or an external numeric keypad.\n\n[In a pinch, you can use the normal numeric keys if you memorize their arrangement.]") + 
                    TOUCH_AROUND + GUESS(is4alt ? "orientation" : "direction of the gap") + ABORT_55,
                imageName: is4alt ? "keyMaps/keyMap4.png" : "keyMaps/keyMap8.png",
                imageToolTip: is4alt ? 
                    "When 4 alternatives are selected, the keypad (see above) can be used, but also the cursor keys." :
                    "For a Landolt ring, when 8 alternatives are selected, the response keys correspond “geographically” to the position of the gap."
            };
        },
        [kTestAcuityE]: {
            title: "Tumbling E acuity",
            text: "\n“Tumbling Es“ will appear, how are they oriented?\n\nUse the cursor keys, or on a keypad:\n→ = 6,  ↑ = 8,  ← = 4,  ↓ = 2." + TOUCH_AROUND + GUESS("orientation") + ABORT_55,
            imageName: "keyMaps/keyMap4keysOnly.png",
            imageToolTip: "When 4 alternatives are selected, the keypad (see above) can be used, and also the cursor keys.",
            imageWidth: 120
        },
        [kTestAcuityTAO]: {
            title: "TAO (Auckland Optotypes) acuity",
            text: "\nUse the number keys on your keyboard to indicate the symbol appearing on the screen.\n\nIf you can't recognise the symbol, use your best guess.\n\nType ’aa‘ or <esc> to abort the run.\n\nYou MUST have a keyboard for this test. If not, cancel now.\n\n\nHere's a paper on these optotypes (TAO):\nHamm LM, Yeoman JP, Anstice N, Dakin SC (2018) The Auckland Optotypes: An open-access pictogram set for measuring recognition acuity. JOV 18:13\nhttps://doi.org/10.1167/18.3.13"
        },
        [kTestAcuityVernier]: {
            title: "Vernier acuity",
            text: "\nTwo (or three) bars appear, one above the other.\nIs the TOP / MIDDLE line left or right?\n\nUse the cursor keys (←, →) or on a keypad: ← = 4, → = 6." + TOUCH_BOTTOM + GUESS("direction") + ABORT_55,
            //imageName: "keyMaps/keyMapUpDownOnly.png",
            //imageWidth: 80
        },
        [kTestContrastLetters]: {
            title: "Letter contrast assessment",
            text: "\nUse the letter keys on your keyboard to type the letter appearing on the screen." + TOUCH_BOTTOM + GUESS("letter") + ABORT_55
        },
        [kTestContrastLandolt]: {
            title: "Landolt ring contrast assessment",
            text: "\nRings with gaps will appear, where is the gap?\n\nUse the number keys on number pad of your keyboard or an external numeric keypad." + TOUCH_AROUND + GUESS("direction of the gap") + ABORT_55,
            imageName: "keyMaps/keyMap8.png",
            imageToolTip: "For a Landolt ring, when 8 alternatives are selected, the response keys correspond \"geographically\" to the position of the gap."
        },
        [kTestContrastE]: {
            title: "Tumbling E contrast assessment",
            text: "\n“Tumbling Es“ will appear, how are they oriented?\n\nUse the cursor keys, or on a keypad:\n→ = 6,  ↑ = 8,  ← = 4,  ↓ = 2." + TOUCH_AROUND + GUESS("orientation") + ABORT_55,
            imageName: "keyMaps/keyMap4keysOnly.png",
            imageToolTip: "When 4 alternatives are selected, the keypad (see above) can be used, but also the cursor keys.",
            imageWidth: 120
        },
        [kTestContrastG]: {
            title: "Grating contrast assessment",
            text: "\nGratis will appear. What is their orientation?\n\nUse the number keys on your keyboard (geographic mapping)." + GUESS("orientation") + ABORT_55,
            imageName: "keyMaps/keyMap8gratings.avif",
            imageToolTip: "For a Landolt ring, when 8 alternatives are selected, the response keys correspond \"geographically\" to the position of the gap."
        },
        [kTestAcuityLineByLine]: {
            title: "Acuity Line-by-Line",
            text: "\nOne or more lines of 3–5 letters will appear.\n\nUse the cursor keys, or digits on a keypad (↑ = 8,  ↓ = 2), to change their acuity grade.\n\nUse ← and → to create a new letter sample." + TOUCH_AROUND + "\n\nThis is NOT an automated threshold test to access acuity. It was created on request for fully manual operation and help refracting.\n\nType any unused key to exit this module.",
            imageName: "keyMaps/keyMap4keysOnly.png",
            imageToolTip: "When 4 alternatives are selected, the keypad (see above) can be used, but also the cursor keys.",
            imageWidth: 100
        }
    };
    let data = dataMapping[aTestID];
    if (typeof data === "function") data = data(); //because Landot is dynamic
    data.title += " – How to operate this test";
    if (data) for (let key in data) content[key] = data[key];
    return content;
}


@end
