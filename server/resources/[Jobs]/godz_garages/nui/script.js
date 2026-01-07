const app = document.getElementById('app');
const vehicleList = document.getElementById('vehicle-list');
const garageNameEl = document.getElementById('garage-name');

window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'open') {
        app.classList.remove('hidden');
        garageNameEl.innerText = data.garageName;
        renderVehicles(data.vehicles);
    } else if (data.action === 'updateList') {
        renderVehicles(data.vehicles);
    }
});

window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeGarage();
    }
});

function closeGarage() {
    app.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function renderVehicles(vehicles) {
    vehicleList.innerHTML = '';
    
    vehicles.forEach(veh => {
        const card = document.createElement('div');
        card.className = 'card';
        
        // Determine Status
        let statusClass = 'status-garage';
        let statusText = 'Garagem';
        let btnText = 'Retirar';
        let btnClass = 'btn-action';
        let action = () => spawnVehicle(veh.vehicle);
        let disabled = false;

        if (veh.detido > 0) {
            statusClass = 'status-impound';
            statusText = 'Apreendido';
            btnText = 'Bloqueado';
            disabled = true;
            action = null;
        } else if (veh.in_road > 0) {
            statusClass = 'status-street';
            statusText = 'Na Rua';
            btnText = 'Pagar Seguro';
            btnClass = 'btn-action insurance';
            action = () => payInsurance(veh.vehicle);
        } else if (veh.engine <= 0 || veh.body <= 0) { // Destroyed?
            // Assuming 0 is destroyed. vRP usually uses 1000 base.
            // If engine < 100, maybe consider "Seguro"?
            // For now rely on in_road logic.
        }

        card.innerHTML = `
            <div class="card-header">
                <div class="veh-name">${veh.vehicle}</div>
                <div class="status-badge ${statusClass}">${statusText}</div>
            </div>
            
            <div class="veh-icon">
                <i class="fas fa-car-side"></i>
            </div>
            
            <div class="stats">
                <div class="stat-row">
                    <span>Motor</span>
                    <div class="progress-bg">
                        <div class="progress-fill" style="width: ${veh.engine / 10}%"></div>
                    </div>
                </div>
                <div class="stat-row">
                    <span>Gasolina</span>
                    <div class="progress-bg">
                        <div class="progress-fill" style="width: ${veh.fuel}%"></div>
                    </div>
                </div>
            </div>

            <button class="${btnClass} ${disabled ? 'disabled' : ''}">${btnText}</button>
        `;
        
        const btn = card.querySelector('button');
        if (!disabled && action) {
            btn.addEventListener('click', action);
        }

        vehicleList.appendChild(card);
    });
}

function spawnVehicle(model) {
    fetch(`https://${GetParentResourceName()}/spawn`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ vehicle: model })
    });
    // Close handled by client callback or manually here
    // app.classList.add('hidden'); // Let client close it
}

function payInsurance(model) {
    fetch(`https://${GetParentResourceName()}/payInsurance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ vehicle: model })
    });
}
