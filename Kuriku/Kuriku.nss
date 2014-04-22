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

DueDate {
    font-color: @hotColor;
}

StartDate {
    font-color: white;
}

TemperatureNone {
    background-color: rgb(228, 228, 228);
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
    font-size: 20;
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