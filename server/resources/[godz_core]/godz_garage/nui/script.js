let vehicleList = [];
let selectedVehicle = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "open") {
        document.getElementById("app").style.display = "flex";
        vehicleList = data.vehicles;
        renderList();
        selectVehicle(null);
    } else if (data.action === "close") {
        document.getElementById("app").style.display = "none";
    }
});

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
    document.getElementById("app").style.display = "none";
}

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeMenu();
    }
};

function renderList() {
    const list = document.getElementById("vehicle-list");
    list.innerHTML = "";
    
    vehicleList.forEach(veh => {
        const li = document.createElement("li");
        li.className = "vehicle-item";
        li.innerHTML = `
            <span class="veh-name-list">${veh.name}</span>
            <span class="veh-plate-list">${veh.plate}</span>
        `;
        li.onclick = () => {
            selectVehicle(veh, li);
        };
        list.appendChild(li);
    });
}

function selectVehicle(veh, element) {
    selectedVehicle = veh;
    
    // Update active class
    document.querySelectorAll(".vehicle-item").forEach(el => el.classList.remove("active"));
    if (element) element.classList.add("active");
    
    const emptyState = document.getElementById("empty-state");
    const detailsContent = document.getElementById("details-content");
    
    if (!veh) {
        emptyState.style.display = "flex";
        detailsContent.style.display = "none";
        return;
    }
    
    emptyState.style.display = "none";
    detailsContent.style.display = "block";
    
    // Populate Data
    document.getElementById("veh-name").innerText = veh.name;
    document.getElementById("veh-plate").innerText = veh.plate;
    
    // Stats
    updateBar("bar-fuel", veh.fuel || 0);
    updateBar("bar-engine", (veh.engine || 1000) / 10); // assuming 1000 max
    updateBar("bar-body", (veh.body || 1000) / 10); // assuming 1000 max
    
    // Report
    const reportText = document.getElementById("mechanic-report-text");
    if (veh.report && veh.report.length > 0) {
        reportText.innerText = `"${veh.report}"`;
        reportText.style.color = "#ffffff";
    } else {
        reportText.innerText = "Este veículo ainda não passou pela consultoria mecânica GODZ.";
        reportText.style.color = "rgba(255,255,255,0.3)";
    }
}

function updateBar(id, value) {
    // value 0-100
    const bar = document.getElementById(id);
    if (bar) bar.style.width = `${Math.min(value, 100)}%`;
}

function spawnVehicle() {
    if (!selectedVehicle) return;
    
    fetch(`https://${GetParentResourceName()}/spawn`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({
            plate: selectedVehicle.plate,
            model: selectedVehicle.model // if available
        })
    });
    
    // Close on spawn
    document.getElementById("app").style.display = "none";
}
