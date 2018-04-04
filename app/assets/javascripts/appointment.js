/**
 * Created by RChavtaraev on 20.03.2018.
 */
var gridTable;
var pixel_per_hour = 27*4;
var pixel_per_second = pixel_per_hour / 3600;

function init() {
    gridTable = document.querySelector(".timetable-grid");
    setTimeout(function () {
        rangeEvents();
        rangeAppendButtons();
    }, 0);
    //console.info("init ok");
}

function Date_parse(strDate){
    var str = strDate.replace(/-/g, '/');
    return Date.parse(str);
}

function rangeEvents(){
    var events = document.body.querySelectorAll(".appointment-element");

    for (i=0; i < events.length; i++){
        var tdInd = events[i].dataset.td.split(";");
        var parentRect = events[i].parentNode.getBoundingClientRect();
        var td = gridTable.rows[+tdInd[1]].cells[+tdInd[0]];
        var tdRect = td.getBoundingClientRect();
        var timedelta = (Date_parse(events[i].dataset.starttime) - Date_parse(td.dataset.eventtime)) * pixel_per_second / 1000;
        //console.info(timedelta);
        /*if ((tdRect.top - parentRect.top + timedelta) < 0) {
            console.info(tdRect.top);
            console.info(parentRect.top);
            console.info(timedelta);
            console.info(events[i].parentNode.offsetHeight);
        }*/
        events[i].style.top = tdRect.top - parentRect.top + timedelta + "px";
    }
}

function rangeAppendButtons() {
    var buttons = document.body.querySelectorAll(".insert-appointment");

    for (i=0; i < buttons.length; i++){

        var tdInd = buttons[i].dataset.td.split(";");
        var parentRect = buttons[i].parentNode.getBoundingClientRect();
        var td = gridTable.rows[+tdInd[1]].cells[+tdInd[0]];
        var tdRect = td.getBoundingClientRect();
        buttons[i].style.top = tdRect.top - parentRect.top + "px";
    }
}