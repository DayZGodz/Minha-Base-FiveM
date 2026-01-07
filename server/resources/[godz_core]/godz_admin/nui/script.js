let currentCallback = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === 'OPEN') {
        document.getElementById('app').style.display = 'flex';
        if (data.players) loadPlayers(data.players);
        if (data.multiplier) document.getElementById('economy-multiplier').innerText = data.multiplier + 'x';
    } else if (data.type === 'AI_REPORT') {
        showAIReport(data.report);
    } else if (data.type === 'CLOSE') {
        closeMenu();
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        closeMenu();
    }
};

function closeMenu() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav li').forEach(el => el.classList.remove('active'));
    
    document.getElementById(tabId).classList.add('active');
    // Encontra o li que chamou a função (simplificado)
    const navItems = document.querySelectorAll('.nav li');
    if (tabId === 'dashboard') navItems[0].classList.add('active');
    if (tabId === 'players') navItems[1].classList.add('active');
    if (tabId === 'economy') navItems[2].classList.add('active');
    if (tabId === 'shield') navItems[3].classList.add('active');
}

// PLAYERS & AI
function loadPlayers(players) {
    const container = document.getElementById('online-players-list');
    container.innerHTML = '';
    
    players.forEach(p => {
        const div = document.createElement('div');
        div.className = `player-row ${p.suspicious ? 'suspicious' : ''}`;
        div.innerHTML = `
            <div>
                <strong style="color: var(--gold)">ID ${p.user_id}</strong> - ${p.name || 'Desconhecido'}
                <br><small>Ping: ${p.ping}ms</small>
            </div>
            <button class="btn btn-primary" style="padding: 5px 10px; font-size: 0.8rem;" onclick="selectPlayer(${p.user_id})">
                Selecionar
            </button>
        `;
        container.appendChild(div);
    });
}

function selectPlayer(id) {
    document.getElementById('target_id').value = id;
}

function analyzePlayer() {
    const id = document.getElementById('target_id').value;
    if (!id) return showNotification('Informe um ID para analisar!', 'error');
    
    document.getElementById('ai-report-area').style.display = 'block';
    document.getElementById('ai-report-text').innerText = "Conectando ao Neural Core... Analisando logs...";
    
    fetch(`https://${GetParentResourceName()}/analyzePlayer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ user_id: id })
    });
}

function showAIReport(text) {
    document.getElementById('ai-report-area').style.display = 'block';
    document.getElementById('ai-report-text').innerText = text;
}

// ACTIONS GENERICAS
function sendAction(action, data) {
    fetch(`https://${GetParentResourceName()}/action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ action: action, data: data })
    });
    closeModal();
}

function doAction(type) {
    const id = document.getElementById('target_id').value;
    if (type === 'ban') {
        openModal('Banir Jogador', '<input type="text" id="modalInput" placeholder="Motivo">', () => {
            const reason = document.getElementById('modalInput').value;
            sendAction('ban', { target_id: id, reason: reason });
        });
    } else if (type === 'unban') {
        sendAction('unban', { target_id: id });
    }
}

function promptSpawnVehicle() {
    openModal('Spawnar Veículo', '<input type="text" id="modalInput" placeholder="Modelo (ex: t20)">', () => {
        const val = document.getElementById('modalInput').value;
        sendAction('spawnVehicle', { model: val });
    });
}

function promptRevive() {
    openModal('Reviver ID', '<input type="number" id="modalInput" placeholder="ID (vazio = você)">', () => {
        const val = document.getElementById('modalInput').value;
        sendAction('revive', { target_id: val });
    });
}

function promptGiveItem() {
    const id = document.getElementById('target_id').value;
    if(!id) return alert('Selecione um ID');
    
    openModal('Dar Item', 
        '<input type="text" id="mItem" placeholder="Item"><br><br><input type="number" id="mQtd" placeholder="Quantidade">', 
        () => {
            const item = document.getElementById('mItem').value;
            const qtd = document.getElementById('mQtd').value;
            sendAction('giveItem', { target_id: id, item: item, amount: qtd });
    });
}

function resetEconomy() {
    openModal('CONFIRMAR RESET', '<p style="color:red">Tem certeza? Isso recalculará todos os preços baseados na inflação zero.</p>', () => {
        sendAction('resetEconomy', {});
    });
}

// MODAL SYSTEM
function openModal(title, html, callback) {
    document.getElementById('modalTitle').innerText = title;
    document.getElementById('modalBody').innerHTML = html;
    document.getElementById('customModal').style.display = 'flex';
    currentCallback = callback;
}

function confirmModal() {
    if (currentCallback) currentCallback();
    closeModal();
}

function closeModal() {
    document.getElementById('customModal').style.display = 'none';
    currentCallback = null;
}

function showNotification(msg, type) {
    // Simples alert por enquanto, pode ser melhorado
    alert(msg);
}
