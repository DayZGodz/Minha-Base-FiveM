document.addEventListener('keydown', function(event) {
    if(event.key === "Escape") {
        closeAll();
    }
});

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action == 'openRG') {
        document.body.style.display = 'flex';
        document.getElementById('rg-container').style.display = 'block';
        document.getElementById('char-container').style.display = 'none';
        
        document.getElementById('rg-photo').src = data.foto || 'img/default.png';
        document.getElementById('rg-name').textContent = data.nome + ' ' + data.sobrenome;
        document.getElementById('rg-age').textContent = data.idade;
        document.getElementById('rg-id').textContent = data.user_id;
        document.getElementById('rg-reg').textContent = data.registro;
        document.getElementById('rg-job').textContent = data.emprego;
        document.getElementById('rg-bio').textContent = data.biografia || "Sem biografia registrada.";
    } 
    else if (data.action == 'openMulticharacter') {
        document.body.style.display = 'flex';
        document.getElementById('rg-container').style.display = 'none';
        document.getElementById('char-container').style.display = 'flex';
        // Populate slots (mockup or real data if passed)
    }
    else if (data.action == 'hide') {
        closeAll();
    }
});

function closeAll() {
    document.body.style.display = 'none';
    fetch('http://godz_identity/close', { method: 'POST' });
}

function openCreate() {
    document.getElementById('create-modal').style.display = 'flex';
}

function closeCreate() {
    document.getElementById('create-modal').style.display = 'none';
}

function generateLore() {
    let name = document.getElementById('c-name').value;
    let firstname = document.getElementById('c-firstname').value;
    let age = document.getElementById('c-age').value;
    let job = document.getElementById('c-job').value;

    if(!name || !age) return;

    document.getElementById('generated-lore').textContent = "🤖 A IA está escrevendo sua história...";
    
    fetch('http://godz_identity/generateLore', {
        method: 'POST',
        body: JSON.stringify({ name, firstname, age, job })
    })
    .then(resp => resp.json())
    .then(data => {
        document.getElementById('generated-lore').textContent = data.lore;
    });
}

function confirmCreate() {
    // Logic to save character
    // ...
    closeCreate();
}
