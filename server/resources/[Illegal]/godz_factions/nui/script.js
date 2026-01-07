window.addEventListener("message", function(event) {
    if (event.data.action == "open") {
        document.getElementById("app").style.display = "flex";
        setupDashboard(event.data);
    }
});

function closeNUI() {
    document.getElementById("app").style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function setupDashboard(data) {
    document.getElementById("faction-name").innerText = data.faction.toUpperCase();
    document.getElementById("online-count").innerText = data.members.length;
    
    const tbody = document.getElementById("members-body");
    tbody.innerHTML = "";
    
    data.members.forEach(member => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>#${member.user_id}</td>
            <td>${member.name}</td>
            <td>${member.role}</td>
            <td><span class="status-online">${member.status.toUpperCase()}</span></td>
            <td>
                <button class="btn-action btn-kick" onclick="manageMember(${member.user_id}, 'kick')">DEMITIR</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function manageMember(targetId, action) {
    fetch(`https://${GetParentResourceName()}/manageMember`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            target_id: targetId,
            action: action
        })
    }).then(() => {
        // Opcional: Recarregar ou remover linha visualmente
    });
}

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeNUI();
    }
};
