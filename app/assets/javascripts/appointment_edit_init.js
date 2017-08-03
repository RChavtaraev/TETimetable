/**
 * Created by RChavtaraev on 03.08.2017.
 */
$(document).ready(function() {

    $('div.expandable').expander({
        slicePoint:       0,
        expandText: 'подробнее...',
        userCollapseText: 'скрыть подробности'
    });
});
function clr()
{
    if ($('#id').val() != '') {
        $('#id').val("");
        $('#email').val("");
        $('#phone').val("");
        $('#birth_date').val("");
        $('#address').val("");
    }
}
