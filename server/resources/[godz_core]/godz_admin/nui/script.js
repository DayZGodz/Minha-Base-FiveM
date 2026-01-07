let currentCallback = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === 'OPEN') {
        document.getElementById('app').style.display = 'flex';
        loadAlerts(data.alerts);
    } else if (data.type === 'NEW_ALERT') {
        addAlert(data.alert);
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
    event.currentTarget.classList.add('active');
}

// ALERTS SYSTEM
function loadAlerts(alerts) {
    const container = document.getElementById('alertList');
    container.innerHTML = '';
    if (!alerts || alerts.length === 0) {
        container.innerHTML = '<div class="alert-item placeholder"><span>Sem alertas recentes.</span></div>';
        return;
    }
    alerts.forEach(addAlert);
}

function addAlert(alert) {
    const container = document.getElementById('alertList');
    const placeholder = container.querySelector('.placeholder');
    if (placeholder) placeholder.remove();

    const div = document.createElement('div');
    div.className = 'alert-item';
    div.innerHTML = `
        <div class="alert-info">
            <span class="alert-type">${alert.type}</span>
            <span class="alert-user">User ID: ${alert.user_id}</span>
            <small>${alert.details}</small>
        </div>
        <span>${alert.time}</span>
    `;
    container.prepend(div);
}

// ACTIONS
function doAction(action) {
    const targetId = document.getElementById('target_id').value;
    
    if (action === 'ban') {
        if (!targetId) return showNotification('Informe o ID!', 'error');
        openModal('Motivo do Banimento', '<input type="text" id="modalInput" placeholder="Motivo">', () => {
            const reason = document.getElementById('modalInput').value;
            sendAction('ban', { target_id: targetId, reason: reason });
        });
    } else if (action === 'unban') {
        if (!targetId) return showNotification('Informe o ID!', 'error');
        sendAction('unban', { target_id: targetId });
    }
}

function promptSpawnVehicle() {
    openModal('Spawnar Veículo', '<input type="text" id="modalInput" placeholder="Nome do modelo (ex: adder)">', () => {
        const model = document.getElementById('modalInput').value;
        if (model) sendAction('spawnVehicle', { model: model });
    });
}

function promptRevive() {
    openModal('Reviver Jogador', '<input type="number" id="modalInput" placeholder="ID do Jogador">', () => {
        const id = document.getElementById('modalInput').value;
        if (id) sendAction('revive', { target_id: id });
    });
}

function promptGiveItem() {
    const targetId = document.getElementById('target_id').value;
    if (!targetId) return showNotification('Informe o ID no campo acima!', 'error');
    
    const html = `
        <input type="text" id="modalItem" placeholder="Nome do Item (ex: water)" style="margin-bottom:10px">
        <input type="number" id="modalAmount" placeholder="Quantidade">
    `;
    
    openModal('Dar Item', html, () => {
        const item = document.getElementById('modalItem').value;
        const amount = document.getElementById('modalAmount').value;
        if (item && amount) sendAction('giveItem', { target_id: targetId, item: item, amount: amount });
    });
}

function sendAction(action, data) {
    fetch(`https://${GetParentResourceName()}/action`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ action: action, ...data })
    });
    closeModal();
}

// MODAL SYSTEM
function openModal(title, html, callback) {
    document.getElementById('modalTitle').innerText = title;
    document.getElementById('modalBody').innerHTML = html;
    
    currentCallback = callback;
    document.getElementById('customModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('customModal').style.display = 'none';
    document.getElementById('modalBody').innerHTML = '';
    currentCallback = null;
}

function confirmModal() {
    if (currentCallback) currentCallback();
}

function showNotification(msg, type) {
    // Simple alert for now, or custom toast
    // alert(msg);
    // Use NUI feedback?
}
