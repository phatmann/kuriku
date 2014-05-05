@warmColor: hsl(0.15, 1.0, 1.0);
@hotColor:  hsl(0.0, 1.0, 1.0);
@coolColor: hsl(0.5, 1.0, 1.0);
@coldColor: hsl(0.6, 1.0, 1.0);
@oldColor: hsl(0.07, 0.1, 0.75);
@veryOldColor: hsl(0.07, 0.3, 0.75);
@dateFontSize: 9;
@dateDraggingFontSize: 11;

Entry {
    font-name: Helvetica;
    font-color: black;
}

EntryInactive {
    background-color: white;
}

EntryComplete {
    background-color: white;
}

Status {

}

Progress {
    background-color: rgb(0.74, 1.000, 0.811);
}

Time {
    font-color: rgb(170, 170, 170);
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
    font-color: black;
    font-color: #D8D9DC;
}

StateInactive {
    font-name: Helvetica;
    font-color: #D8D9DC;
}