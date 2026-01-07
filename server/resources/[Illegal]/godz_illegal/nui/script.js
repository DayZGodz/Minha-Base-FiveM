window.addEventListener("message", (event) => {
    const data = event.data;
    if (data.action === "open") {
        document.getElementById("app").classList.remove("hidden");
        updateUI(data.data);
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        closePanel();
    }
};

function closePanel() {
    document.getElementById("app").classList.add("hidden");
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function updateUI(data) {
    document.getElementById("faction-name").innerText = data.name;
    document.getElementById("faction-balance").innerText = "$ " + parseInt(data.balance).toLocaleString('pt-BR');
    
    const membersList = document.getElementById("members-list");
    membersList.innerHTML = "";
    
    if (data.members) {
        data.members.forEach(member => {
            membersList.innerHTML += `
                <div class="item">
                    <span>${member.name}</span>
                    <div class="status" title="Online"></div>
                </div>
            `;
        });
    }
}
