$(document).ready(function(){
    window.addEventListener('message', function(event){
        var item = event.data;
        if(item.action == 'open'){
            $('#app').fadeIn(200);
            $('#faction-name').text(item.data.factionName);
            renderMembers(item.data.members);
        } else if(item.action == 'updateMembers') {
            renderMembers(item.members);
        } else if(item.action == 'close') {
            $('#app').fadeOut(200);
        }
    });

    $('#btn-hire').click(function(){
        var id = $('#hire-id').val();
        if(id){
            $.post('http://godz_factions/hire', JSON.stringify({ target_id: id }));
            $('#hire-id').val('');
        }
    });

    $(document).keyup(function(e) {
        if (e.key === "Escape") closeMenu();
    });
});

function renderMembers(members) {
    var container = $('#members-container');
    container.empty();

    members.sort((a, b) => b.farm - a.farm); // Sort by farm contribution

    members.forEach(member => {
        var role = member.is_leader ? '<span class="status-leader">LÍDER</span>' : '<span class="status-member">MEMBRO</span>';
        var actions = member.is_leader ? '' : `<button class="btn-fire" onclick="fireMember(${member.user_id})">DEMITIR</button>`;
        
        var html = `
        <div class="member-row">
            <div>${member.user_id}</div>
            <div>${member.name}</div>
            <div>${role}</div>
            <div>${member.farm}</div>
            <div>${actions}</div>
        </div>
        `;
        container.append(html);
    });
}

function fireMember(id) {
    $.post('http://godz_factions/fire', JSON.stringify({ target_id: id }));
}

function closeMenu() {
    $('#app').fadeOut(200);
    $.post('http://godz_factions/close', JSON.stringify({}));
}
