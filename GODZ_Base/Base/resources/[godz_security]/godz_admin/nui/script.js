let allPlayers = [];

window.addEventListener('message', function(event) {
    if (event.data.type === 'open') {
        $('#container').fadeIn(300);
        loadPlayers();
        loadAlerts();
    } else if (event.data.type === 'close') {
        $('#container').fadeOut(300);
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
};

function switchTab(tabName) {
    $('.tab-content').removeClass('active');
    $('.tab-btn').removeClass('active');
    $(`#tab-${tabName}`).addClass('active');
    $(`button[onclick="switchTab('${tabName}')"]`).addClass('active');
}

function loadPlayers() {
    fetch(`https://${GetParentResourceName()}/getPlayers`, {
        method: 'POST'
    }).then(resp => resp.json()).then(data => {
        allPlayers = data;
        renderPlayers(data);
    });
}

function renderPlayers(players) {
    let html = '';
    players.forEach(p => {
        html += `
            <div class="player-item">
                <div class="player-info">
                    <img src="https://nui-img/char_default.png" class="player-avatar" onerror="this.src='https://via.placeholder.com/40'">
                    <div>
                        <strong>[${p.id}] ${p.name}</strong>
                    </div>
                </div>
                <div class="actions">
                    <button class="btn-mini goto" onclick="adminAction('goto', ${p.id})">Goto</button>
                    <button class="btn-mini bring" onclick="adminAction('bring', ${p.id})">Bring</button>
                    <button class="btn-mini god" onclick="adminAction('god', ${p.id})">Reviver</button>
                    <button class="btn-mini kick" onclick="adminAction('kick', ${p.id})">Kick</button>
                    <button class="btn-mini ban" onclick="adminAction('ban', ${p.id})">Ban</button>
                </div>
            </div>
        `;
    });
    $('#player-list').html(html);
}

function filterPlayers() {
    let term = $('#search-player').val().toLowerCase();
    let filtered = allPlayers.filter(p => 
        p.name.toLowerCase().includes(term) || p.id.toString().includes(term)
    );
    renderPlayers(filtered);
}

function adminAction(action, id) {
    if (action === 'kick' || action === 'ban') {
        if (!confirm(`Tem certeza que deseja ${action} este jogador?`)) return;
    }
    
    fetch(`https://${GetParentResourceName()}/adminAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: action, id: id })
    });
}

function giveItem() {
    let id = $('#item-id').val();
    let item = $('#item-name').val();
    let amount = $('#item-amount').val();
    
    if (!id || !item || !amount) return;
    
    fetch(`https://${GetParentResourceName()}/giveItem`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id, item: item, amount: amount })
    });
}

function giveVehicle() {
    let id = $('#veh-id').val();
    let vehicle = $('#veh-name').val();
    
    if (!id || !vehicle) return;
    
    fetch(`https://${GetParentResourceName()}/giveVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id, vehicle: vehicle })
    });
}

function loadAlerts() {
    fetch(`https://${GetParentResourceName()}/getAlerts`, {
        method: 'POST'
    }).then(resp => resp.json()).then(data => {
        let html = '';
        if (data.length === 0) {
            html = '<p style="padding:10px; color:#aaa;">Nenhum alerta recente.</p>';
        } else {
            data.forEach(a => {
                html += `<div class="alert-item">
                    <strong>${a.type || 'ALERTA'}</strong>: ${a.message} <br>
                    <small>ID: ${a.user_id}</small>
                </div>`;
            });
        }
        $('#alert-list').html(html);
    });
}
