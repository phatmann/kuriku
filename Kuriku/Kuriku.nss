@warmColor: hsl(0.15, 1.0, 1.0);
@hotColor:  hsl(0.0, 1.0, 1.0);
@coolColor: hsl(0.5, 1.0, 1.0);
@coldColor: hsl(0.6, 1.0, 1.0);
@oldColor: hsl(0.09, 0.04, 1.0);
@veryOldColor: hsl(0.09, 0.11, 0.95); /*[UIColor colorWithRed:0.970 green:0.933 blue:0.858 alpha:1.000]*/
@dateFontSize: 9;
@dateDraggingFontSize: 11;
@completedTextColor: rgb(164, 164, 164);
@inactiveTextColor: white;
@normalFont: Helvetica;
@boldFont: Helvetica-Bold;

Entry {
    font-name: @normalFont;
    font-color: black;
}

EntryInactive {
    background-color: rgb(228, 228, 228);
}

Progress {
    background-color: rgb(0.74, 1.000, 0.811);
}

Time {
    font-name:  @normalFont;
    font-color: rgb(170, 170, 170);
}

TimeInactive {
    font-name:  @boldFont;
    font-color: @inactiveTextColor;
}

TimeCompleted {
    font-name:  @normalFont;
    font-color: @completedTextColor;
}

DueDate {
    font-color: @hotColor;
    font-size: @dateFontSize;
}

StartDate {
    font-color: white;
    font-size: @dateFontSize;
}

DueDateDragging {
    font-color: black;
    font-size: @dateDraggingFontSize;
}

StartDateDragging {
    font-color: black;
    font-size: @dateDraggingFontSize;
}

DatePrompt {
    font-color: black;
    font-size: @dateDraggingFontSize;
}

TemperatureNone {
    background-color: white;
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

StalenessVeryOld {
    background-color: @veryOldColor;
}

StalenessOld {
    background-color: @oldColor;
}

ImportanceLow {
    font-size: 14;
}

ImportanceHigh {
    font-size: 26;
}

StatusCompleted {
    text-decoration: line-through;
    font-color: @completedTextColor;
}

StateInactive {
    font-name: Helvetica;
    font-color: @inactiveTextColor;
}