@warmColor: hsl(0.15, 1.0, 1.0);
@hotColor:  hsl(0.0, 1.0, 1.0);
@coolColor: hsl(0.5, 1.0, 1.0);
@coldColor: hsl(0.6, 1.0, 1.0);
@oldColor: hsl(0.09, 0.04, 1.0);
@veryOldColor: hsl(0.09, 0.11, 0.95);
@completedTextColor: rgb(164, 164, 164);
@inactiveTextColor: white;
@normalFont: AvenirNext-Regular;
@boldFont: AvenirNext-Bold;
@italicFont: AvenirNext-UltraLightItalic;
@timeFontSize: 9;
@timeFont: AvenirNext-Medium;

/* Computed styles */

EntryLabelImportanceLow {
    font-size: 14;
}

EntryLabelImportanceHigh {
    font-size: 26;
}

EntryCellInactive {
    background-color: rgb(228, 228, 228);
}

EntryCellActive {
    background-color: white;
}

EntryCellUncommitted {
    background-color: rgb(0.85, 0.95, 1.0);
}

EntryCellStalenessVeryOld {
    background-color: @veryOldColor;
}

EntryCellStalenessOld {
    background-color: @oldColor;
}

TemperatureCold {
    background-color: @coldColor;
}

TemperatureCool {
    background-color: @coolColor;
}

TemperatureWarm {
    background-color: @warmColor;
}

TemperatureHot {
    background-color: @hotColor;
}

/* Normal styles */

JournalSectionHeader {
    font-name: @italicFont;
    font-color: black;
    background-color: white;
}

EntryLabel {
    font-name: @normalFont;
    font-color: black;
}

EntryLabelCompleted {
    font-name: @normalFont;
    font-color: @completedTextColor;
    text-decoration: line-through;
}

EntryLabelInactive {
    font-name: @normalFont;
    font-color: @inactiveTextColor;
}

Progress {
    background-color: rgb(0.74, 1.000, 0.811);
}

Time {
    font-name:  @timeFont;
    font-color: rgb(170, 170, 170);
    font-size: @timeFontSize;
}

TimeInactive {
    font-name:  @timeFont;
    font-color: @inactiveTextColor;
    font-size: @timeFontSize;
}

TimeCompleted {
    font-name:  @timeFont;
    font-color: @completedTextColor;
    font-size: @timeFontSize;
}

DueDate {
    font-name: @timeFont;
    font-color: @hotColor;
    font-size: @timeFontSize;
}

StartDate {
    font-name: @timeFont;
    font-color: white;
    font-size: @timeFontSize;
}



