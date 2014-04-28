@warmColor: hsl(0.15, 1.0, 1.0);
@hotColor:  hsl(0.0, 1.0, 1.0);
@coolColor: hsl(0.5, 1.0, 1.0);
@coldColor: hsl(0.6, 1.0, 1.0);
@oldColor: hsl(0.3, 1.0, 0.5);
@veryOldColor: hsl(0.3, 1.0, 1.0);

Entry {
    font-name: Helvetica;
    font-color: black;
}

EntryInactive {
    background-color: rgb(228, 228, 228);
}

EntryComplete {
    background-color: rgb(228, 228, 228);
}

Status {
    border-width: 1;
    border-color: rgb(200, 200, 200);
}

Time {
    font-color: rgb(170, 170, 170);
}

DueDate {
    font-color: @hotColor;
}

StartDate {
    font-color: @coldColor;
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
    font-size: 16;
}

ImportanceHigh {
    font-size: 28;
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