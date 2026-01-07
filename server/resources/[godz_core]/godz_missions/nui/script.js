window.addEventListener('message', function(event) {
    if (event.data.action === "open") {
        const mission = event.data.mission;
        
        $('#missionTitle').text(mission.title);
        $('#missionDesc').text(mission.description);
        $('#missionReward').text("$" + mission.reward.toLocaleString());
        $('#missionTime').text(Math.floor(mission.time / 60) + " min");
        $('#missionLoc').text(mission.location);
        
        $('#app').fadeIn(200).css('display', 'flex');
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeUI();
    }
};

function acceptMission() {
    $.post('https://godz_missions/accept', JSON.stringify({}));
    $('#app').fadeOut(200);
}

function closeUI() {
    $.post('https://godz_missions/close', JSON.stringify({}));
    $('#app').fadeOut(200);
}
