/**
 * Created by RChavtaraev on 01.03.2018.
 */
var gridTable;
var selectionInfo;
var earler_time_in_seconds;
var ajaxCallInProcess = false;
var pixel_per_hour = 27*4;
var pixel_per_second = pixel_per_hour / 3600

function init(addEventsBtn) {
    initSelection(addEventsBtn)
    setTimeout(function() {
        rangeEvents();
    }, 0);
}

function initSelection(addEventsBtn)
{
    gridTable = document.querySelector(".timetable-grid");
    earler_time_in_seconds = gridTable.dataset.earlertime;
    selectionInfo = {};
    selectionInfo.addEventsBtn = addEventsBtn;
    selectionInfo.eventsintervalPnl = selectionInfo.addEventsBtn.querySelector(".eventsinterval");

    gridTable.onmousedown = function(e) {
        if (e.buttons & 1 > 0 && e.target.tagName == "TD") //left btn pressed
        {

            startSelection(e.target, e.shiftKey);
            return false;
        };
    };
}

function Date_parse(strDate){ // просто Date.parse возвращает NaN если дата разделенв символами '-'
    var str = strDate.replace(/-/g, '/')
    return new Date(Date.parse(str));
}

function rangeEvents(){
    var events = document.body.querySelectorAll(".timetable-element");

    for (i=0; i < events.length; i++){
        var tdInd = events[i].dataset.td.split(";");
        var parentRect = events[i].parentNode.getBoundingClientRect();
        var td = gridTable.rows[+tdInd[1]].cells[+tdInd[0]];
        var tdRect = td.getBoundingClientRect();
        var timedelta = (Date_parse(events[i].dataset.starttime) - Date_parse(td.dataset.eventtime)) * pixel_per_second / 1000;
        //if (timedelta < 0) {
            //console.info("timedelta:" + timedelta + " starttime:" + events[i].dataset.starttime + " eventtime:" + td.dataset.eventtime);
        //}
        //console.info(timedelta);
        events[i].style.top = tdRect.top - parentRect.top + timedelta + "px";
    }
}

function startSelection(firstSelectedTD, isShiftPressed) {
    if (ajaxCallInProcess)
        return;
    if (isShiftPressed == false) {
        clearSelection();
        selectionInfo.firstSelectedTD = firstSelectedTD;
        select(selectionInfo.firstSelectedTD);
    }
    else {
        changeSelection(selectionInfo.firstSelectedTD, firstSelectedTD);
    }
     //selectionInfo.firstSelectedTD.classList.add("selected");
    document.body.addEventListener("selectstart", docSelectStart);
    //document.body.addEventListener("mousemove", docMouseMove);
    document.addEventListener("mouseup", docMouseUp);

    gridTable.style.zIndex = 110;
    gridTable.onmousemove = tableMouseMove;

}

function cleanup() {
    document.body.removeEventListener("selectstart", docSelectStart);
    document.removeEventListener("mouseup", docMouseUp);
    gridTable.onmousemove = null;
    gridTable.onmouseup = null;
    gridTable.style.zIndex = 100;
    //selectionInfo.firstSelectedTD = null;
}

function endSelection() {
    //показать кнопку
    var _tdToAddButton = selectionInfo.firstSelectedTD;
    //var info = selectionInfo;
    setTimeout(function() {
        showButton(_tdToAddButton);
        //_tdToAddButton.appendChild(info.addEventsBtn);
        //info.addEventsBtn.style.display = "block";
        //info.addEventsBtn.classList.add("visible");
    }, 500);
    cleanup();
}

function showButton(_tdToAddButton) {
    //настройка выбора интервала
    var rangeInfo = getSelectionRangeInfo ();
    selectionInfo.rangeInfo = rangeInfo;
    if (rangeInfo && rangeInfo.hasEnabled) {
        selectionInfo.eventsintervalPnl.style.display = "none";
        $(selectionInfo.eventsintervalPnl).find("li").css("display", "none");
        if (rangeInfo.enabledRowCount > 1) {
            selectionInfo.eventsintervalPnl.style.display = "block";
            var lis = selectionInfo.eventsintervalPnl.querySelectorAll("li");
            for (var i = 0; i < rangeInfo.enabledRowCount && i < 4; i++) {
                lis[i].style.display = "block";
            }
            lis[i - 1].querySelector("input").checked = true; //check last radio
        }
        _tdToAddButton.appendChild(selectionInfo.addEventsBtn);
        selectionInfo.addEventsBtn.style.display = "block";
        selectionInfo.addEventsBtn.classList.add("visible");
    }
}

function changeSelection(td1, td2) {
    if (td1 && td2) {
        var parent = gridTable.parentNode;
        var nextElem = gridTable.nextSibling;
        parent.removeChild(gridTable);

        var topleft = {};
        var bottomright = {};
        topleft.Y = Math.min(td1.parentNode.rowIndex, td2.parentNode.rowIndex);
        topleft.X = Math.min(td1.cellIndex, td2.cellIndex);
        bottomright.Y = Math.max(td1.parentNode.rowIndex, td2.parentNode.rowIndex);
        bottomright.X = Math.max(td1.cellIndex, td2.cellIndex);

        var selectedcells = gridTable.querySelectorAll("td.selected");
        for (i=0; i< selectedcells.length; i++)
            unselect(selectedcells[i]); // selectedcells[i].classList.remove("selected");

        for (y=topleft.Y; y <= bottomright.Y; y++)
            for (x=topleft.X; x <= bottomright.X; x++)
                select(gridTable.rows[y].cells[x]); //gridTable.rows[y].cells[x].classList.add("selected");


        parent.insertBefore(gridTable, nextElem);
    };

}

function select(td) {
    td.classList.add("selected");
    if (!td.dataset.canselected)
        td.classList.add("disabled");

}

function unselect(td) {
    td.classList.remove("selected");
    td.classList.remove("disabled");
}

function docSelectStart(e){
    e.preventDefault();
}

function tableMouseMove(e) {
    if  (e.buttons & 1 > 0 && e.target.tagName == "TD") {

        changeSelection(selectionInfo.firstSelectedTD, e.target);
        select(e.target); //e.target.classList.add("selected");
    }
}

function docMouseUp(e) {
    endSelection();
}

function clearSelection() {
    var selectedcells = gridTable.querySelectorAll("td.selected");
    for (i=0; i< selectedcells.length; i++)
        unselect(selectedcells[i]); //selectedcells[i].classList.remove("selected");
    selectionInfo.firstSelectedTD = null;

    addEventsBtn.style.display = "none";
    addEventsBtn.classList.remove("visible");
}

function getSelectionRangeInfo () {
    var someSelectedCell = gridTable.querySelector("td.selected");
    var firstCell = null;
    var lastCell = null;
    if (!someSelectedCell)
        return null;
    lastCell = firstCell = someSelectedCell;
    var y = someSelectedCell.parentNode.rowIndex
    var x = someSelectedCell.cellIndex
    //find first cell: move up and left to edge or unselected
    for (;y >= 0 && $(gridTable.rows[y].cells[x]).hasClass("selected");y--);
    y++;
    for (;x >= 0 && $(gridTable.rows[y].cells[x]).hasClass("selected");x--);
    x++;

    firstCell = gridTable.rows[y].cells[x];
    //find last cell: move down and right to edge or unselected
    y = someSelectedCell.parentNode.rowIndex;
    x = someSelectedCell.cellIndex;
    for (; y < gridTable.rows.length && $(gridTable.rows[y].cells[x]).hasClass("selected"); y++);
    y--;
    for (;x < gridTable.rows[y].cells.length && $(gridTable.rows[y].cells[x]).hasClass("selected"); x++);
    x--;

    //console.info ("last: " + x + "; " + y);
    lastCell = gridTable.rows[y].cells[x];

    retVal = {};
    retVal.enabledRowCount = 0; //gridTable.querySelectorAll(".selected:not(.disabled)").length;


//    console.info(retVal.hasEnabled);
    retVal.rowCount =  lastCell.parentNode.rowIndex - firstCell.parentNode.rowIndex + 1;
    retVal.days = new Array(lastCell.cellIndex - firstCell.cellIndex + 1);
    //retVal.placeSelectors = new Array(lastCell.cellIndex - firstCell.cellIndex + 1);

    for (x = firstCell.cellIndex; x <= lastCell.cellIndex; x++) {

        var firstTime = Date_parse(gridTable.rows[firstCell.parentNode.rowIndex].cells[x].dataset.eventtime);
        var lastTime = Date_parse(gridTable.rows[lastCell.parentNode.rowIndex].cells[x].dataset.eventtime);
        lastTime.setMinutes(lastTime.getMinutes() + 15);

        for (y = firstCell.parentNode.rowIndex; y <= lastCell.parentNode.rowIndex; y++) { //get first enabled time
            //console.info(!gridTable.rows[y].cells[x].classList.contains("disabled"));
            if (!gridTable.rows[y].cells[x].classList.contains("disabled")) {
                firstTime = gridTable.rows[y].cells[x].dataset.eventtime;
                retVal.enabledRowCount = Math.max(retVal.enabledRowCount, lastCell.parentNode.rowIndex - y + 1);
                break;
            };
        };
        var dayInfo = {firstTime: firstTime, lastTime:lastTime, colnum: x};
        retVal.days[x - firstCell.cellIndex] = dayInfo; //{firstTime: firstTime, lastTime:lastTime, colnum: x};
    }
    retVal.hasEnabled = retVal.enabledRowCount > 0;
    fillPlaces(retVal);
    //console.info(retVal);
    //retVal.intervals = new Array(lastCell)

    return retVal;
}

function fillPlaces(SelectionRangeInfo) { //correct places for event from selector at header
    for (i=0; i < SelectionRangeInfo.days.length; i++) {
        headerSelect = document.body.querySelector("div.timetable-day-header[data-wday=\"" + (SelectionRangeInfo.days[i].colnum + 1) + "\"] select");
        SelectionRangeInfo.days[i].placeId = headerSelect.options[headerSelect.selectedIndex].value;
    }
}

function appendrangesAjax(){
    addEventsBtn.style.display = "none";
    ajaxCallInProcess = true;
    fillPlaces(selectionInfo.rangeInfo);
    selectionInfo.rangeInfo.interval = 15;
    if (selectionInfo.rangeInfo.enabledRowCount > 1) {
        var rbuttons = $("input[type='radio'][name='interval']");
        for (i = 0; i < rbuttons.length; i++) {
            if (rbuttons[i].checked) {
                selectionInfo.rangeInfo.interval = +rbuttons[i].value * 15;
                break;
            }
        }
    }
    var val = JSON.stringify(selectionInfo.rangeInfo.days);
    $.ajax({
        type: "POST",
        url: "/timetables/appendranges",
        data: { selectiondata: val, interval: selectionInfo.rangeInfo.interval  },
        success: function(data) {
            ajaxCallInProcess = false;
            clearSelection();
            for (i=0; i<data.events.length; i++) {
                var wday = data.events[i]["wday"];
                var tdayElem = document.body.querySelector(".timetable-day-body.wday-" + wday);
                tdayElem.insertAdjacentHTML('beforeend',data.events[i]["html"] );
            }
            rangeEvents();
            return false; },
        error:function(data) {
            ajaxCallInProcess = false;
            addEventsBtn.style.display = "block";
            alert ("Элементы расписания не добавлены - " + data.errormessage);
            return false; }
    });
}

function deleteDayEvents(button) //delete all events of day
{
    if (ajaxCallInProcess)
        return;
    if (confirm("Удалить все элемены расписания за день?")) {
        var timetableElements = button.closest("TD").querySelectorAll(".timetable-element");
        var ids = [];
        for (i = 0; i < timetableElements.length; i++) {
            ids.push(timetableElements[i].dataset.id);
        }
        //console.info(ids);
        deleteEventAjax.apply(this, ids);
    }
}

function deleteEventAjax(){ //delete events by id in arguments 
    
    if (ajaxCallInProcess)
        return;
    ajaxCallInProcess = true;
    var eventidsStr = JSON.stringify(arguments);
    var eventids = arguments;
    $.ajax({
        type: "POST",
        url: "/timetables/deleteevents",
        data: { eventids: eventidsStr },
        success: function(data) {
            ajaxCallInProcess = false;
            for (i=0; i<eventids.length; i++) {
                var elem = document.body.querySelector(".timetable-element[data-id='"+ eventids[i] +"']");
                if (elem) elem.parentNode.removeChild(elem);
            }
            return false; },
        error:function(data) {
            ajaxCallInProcess = false;
            alert ("Элементы расписания не удалены - " + data.errormessage);
            return false; }
    });
}

function changePlaces(select) { //change places of all events of day
    if (ajaxCallInProcess)
        return;
    //if (confirm("Изменить место приема для всех элементов расписания за день?")) {
        var timetableElements = select.closest("TD").querySelectorAll(".timetable-element");
        var places = []
        for (i = 0; i < timetableElements.length; i++) {
            var obj = {}
            obj[timetableElements[i].dataset.id] = select.value;
            places.push(obj);
        }
    //}
    changePlaceAjax.apply(this, places);
}

function changePlace(id, select) {
    if (ajaxCallInProcess)
        return;
    var obj = {}
    obj[id] = select.value;
    changePlaceAjax(obj);
}

function changePlaceAjax() { //change places. each argument - hash (key - id, value - place_id) 
    if (ajaxCallInProcess)
        return;
    ajaxCallInProcess = true;
    var placesStr = JSON.stringify(arguments);
    var places = arguments;
    $.ajax({
        type: "POST",
        url: "/timetables/changeplaces",
        data: { places: placesStr },
        success: function(data) {
            for (i=0; i < places.length; i++){ //correct select values
                var id = Object.keys(places[i])[0];
                var select = document.getElementById("place_" + id);
                if (select)
                    select.value = places[i][id];
            }
            ajaxCallInProcess = false;

            return false; },
        error:function(data) {
            ajaxCallInProcess = false;
            alert ("Элементы расписания не изменены - " + data.errormessage);
            return false; }
    });
}
