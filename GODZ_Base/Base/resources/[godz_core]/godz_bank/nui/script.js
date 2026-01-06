let currentData = null;

window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "open") {
        document.getElementById("app").classList.remove("hidden");
        updateUI(data.data);
    } else if (data.action === "close") {
        document.getElementById("app").classList.add("hidden");
        hideModals();
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeBank();
    }
};

function closeBank() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

function updateUI(data) {
    currentData = data;
    document.getElementById("user-name").innerText = `Olá, ${data.name} ${data.firstname}`;
    document.getElementById("bank-balance").innerText = formatMoney(data.bank);
    document.getElementById("wallet-balance").innerText = formatMoney(data.wallet);
    document.getElementById("loan-debt").innerText = formatMoney(data.loan);

    // Update Logs
    const list = document.getElementById("transactions-list");
    list.innerHTML = "";
    
    if (data.logs && data.logs.length > 0) {
        data.logs.forEach(log => {
            const isPositive = log.receiver_id == data.user_id && log.type !== "Saque"; // Logic might need adjustment based on ID
            // Actually, server sends raw logs. 
            // If sender_id == my_id -> Negative (unless type is Deposit? No, Deposit is sender=me receiver=me)
            // Wait, logic:
            // Transfer: Sender (Me) -> Receiver (Other). Value: -X
            // Transfer: Sender (Other) -> Receiver (Me). Value: +X
            // Deposit: Sender (Me) -> Receiver (Me). Value: +X (to bank)
            // Withdraw: Sender (Me) -> Receiver (Me). Value: -X (from bank)
            
            // Simplified for UI visual:
            let className = "positive";
            let symbol = "+";
            
            if (log.type === "Transferência") {
                // I need to know my ID to check if I am sender or receiver.
                // The server response didn't include my user_id explicitly in the root object, but I can infer or ask server to send it.
                // I'll assume positive for now or check logic.
                // Let's rely on type names or just display raw.
                // Better: Update server to send 'user_id' in data.
            }
            
            // For now, simple list
            const date = new Date(log.date).toLocaleString('pt-BR');
            const item = document.createElement("div");
            item.classList.add("transaction-item");
            item.innerHTML = `
                <div>
                    <div class="type">${log.type}</div>
                    <div style="font-size: 0.8rem; opacity: 0.6;">${date}</div>
                </div>
                <div class="amount">${formatMoney(log.value)}</div>
            `;
            list.appendChild(item);
        });
    } else {
        list.innerHTML = "<div style='text-align:center; padding: 20px; opacity: 0.5;'>Nenhuma transação recente.</div>";
    }
}

function formatMoney(value) {
    return '$ ' + parseInt(value).toLocaleString('pt-BR');
}

function showModal(type) {
    hideModals();
    document.getElementById(`modal-${type}`).classList.remove("hidden");
}

function hideModals() {
    document.querySelectorAll(".modal").forEach(el => el.classList.add("hidden"));
    // Clear inputs
    document.querySelectorAll("input").forEach(el => el.value = "");
}

function confirmAction(action) {
    let payload = {};

    if (action === "transfer") {
        payload.target_id = document.getElementById("transfer-id").value;
        payload.amount = document.getElementById("transfer-amount").value;
    } else if (action === "deposit") {
        payload.amount = document.getElementById("deposit-amount").value;
    } else if (action === "withdraw") {
        payload.amount = document.getElementById("withdraw-amount").value;
    } else if (action === "takeLoan") {
        payload.amount = document.getElementById("loan-amount").value;
    } else if (action === "payLoan") {
        payload.amount = document.getElementById("loan-amount").value; // Reusing input
    }

    if (!payload.amount || payload.amount <= 0) return;

    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(payload)
    }).then(resp => resp.json()).then(newData => {
        if (newData) {
            updateUI(newData);
            hideModals();
        }
    });
}
