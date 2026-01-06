let currentTarget = null;

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "open") {
        document.getElementById("app").classList.remove("hidden");
    } else if (data.action === "close") {
        document.getElementById("app").classList.add("hidden");
        hideModals();
    } else if (data.action === "updateWarrants") {
        renderAllWarrants(data.warrants);
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeMDT();
    }
};

function closeMDT() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function switchTab(tabName) {
    document.querySelectorAll(".tab-content").forEach(el => el.classList.remove("active"));
    document.querySelectorAll(".nav-btn").forEach(el => el.classList.remove("active"));
    
    document.getElementById(`tab-${tabName}`).classList.add("active");
    event.currentTarget.classList.add("active");
}

function searchUser() {
    const query = document.getElementById("search-input").value;
    if (!query) return;

    fetch(`https://${GetParentResourceName()}/search`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: query })
    }).then(resp => resp.json()).then(data => {
        if (data) {
            currentTarget = data;
            renderSearchResult(data);
        } else {
            alert("Cidadão não encontrado.");
        }
    });
}

function renderSearchResult(data) {
    document.getElementById("search-result").classList.remove("hidden");
    
    // Header
    document.getElementById("profile-img").src = data.foto || "https://i.imgur.com/r7x6y7v.png";
    document.getElementById("profile-name").innerText = `${data.name} ${data.firstname}`;
    document.getElementById("profile-id").innerText = data.id;
    document.getElementById("profile-age").innerText = data.age;
    document.getElementById("profile-reg").innerText = data.registration;
    document.getElementById("profile-phone").innerText = data.phone;
    
    // Bank
    document.getElementById("bank-balance").innerText = "$ " + parseInt(data.bank).toLocaleString('pt-BR');
    const logsList = document.getElementById("bank-logs");
    logsList.innerHTML = "";
    if (data.bank_logs) {
        data.bank_logs.forEach(log => {
            logsList.innerHTML += `
                <div class="log-item">
                    <span>${log.type}</span>
                    <span class="${log.value < 0 ? 'negative' : 'positive'}">$${log.value}</span>
                </div>
            `;
        });
    }

    // Vehicles
    const vehList = document.getElementById("vehicle-list");
    vehList.innerHTML = "";
    if (data.vehicles && data.vehicles.length > 0) {
        data.vehicles.forEach(veh => {
            vehList.innerHTML += `
                <div class="vehicle-item">
                    <span>${veh.vehicle}</span>
                    <span>${veh.plate || 'Sem Placa'}</span>
                </div>
            `;
        });
    } else {
        vehList.innerHTML = "<div style='opacity:0.5'>Nenhum veículo encontrado.</div>";
    }

    // Warrants
    const wList = document.getElementById("user-warrants-list");
    wList.innerHTML = "";
    if (data.warrants && data.warrants.length > 0) {
        data.warrants.forEach(w => {
            wList.innerHTML += `
                <div class="warrant-item">
                    <span>${w.reason}</span>
                    <button onclick="deleteWarrant(${w.id})" style="font-size:0.8rem; background:none; border:none; color:red; cursor:pointer"><i class="fas fa-trash"></i></button>
                </div>
            `;
        });
    } else {
        wList.innerHTML = "<div style='opacity:0.5'>Sem mandados ativos.</div>";
    }
}

function renderAllWarrants(warrants) {
    const list = document.getElementById("all-warrants-list");
    document.getElementById("total-warrants").innerText = warrants.length;
    list.innerHTML = "";
    
    warrants.forEach(w => {
        list.innerHTML += `
            <div class="warrant-item">
                <div style="flex:1">
                    <strong>ID ${w.user_id}</strong> - ${w.reason}
                    <div style="font-size:0.8rem; opacity:0.6">${new Date(w.created_at).toLocaleString()}</div>
                </div>
                <button onclick="deleteWarrant(${w.id})" style="background:#e74c3c; color:white; border:none; padding:5px 10px; border-radius:4px; cursor:pointer">Dar Baixa</button>
            </div>
        `;
    });
}

// Modal Logic
function showFineModal() {
    if (!currentTarget) return;
    document.getElementById("modal-fine").classList.remove("hidden");
}

function showWarrantModal() {
    if (!currentTarget) return;
    document.getElementById("modal-warrant").classList.remove("hidden");
}

function hideModals() {
    document.querySelectorAll(".modal").forEach(el => el.classList.add("hidden"));
    document.querySelectorAll("input, textarea").forEach(el => el.value = "");
}

function applyFine() {
    const amount = document.getElementById("fine-amount").value;
    const reason = document.getElementById("fine-reason").value;
    
    if (amount <= 0 || !reason) return;

    fetch(`https://${GetParentResourceName()}/fine`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            user_id: currentTarget.id,
            amount: amount,
            reason: reason
        })
    }).then(resp => resp.json()).then(success => {
        if (success) {
            hideModals();
            searchUser(); // Refresh data
        } else {
            alert("Erro ao aplicar multa.");
        }
    });
}

function createWarrant() {
    const reason = document.getElementById("warrant-reason").value;
    if (!reason) return;

    fetch(`https://${GetParentResourceName()}/addWarrant`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            user_id: currentTarget.id,
            reason: reason
        })
    }).then(resp => resp.json()).then(success => {
        if (success) {
            hideModals();
            searchUser(); // Refresh user view
        }
    });
}

function deleteWarrant(id) {
    if (!confirm("Tem certeza que deseja dar baixa neste mandado?")) return;

    fetch(`https://${GetParentResourceName()}/deleteWarrant`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id })
    }).then(resp => resp.json()).then(success => {
        if (success) {
            // Refresh logic handled by client message usually, or we can just refresh current search if open
             if (currentTarget) searchUser();
        }
    });
}
