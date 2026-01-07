let currentSlot = 1;

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
        renderCharacters(data.characters || []);
    }
    else if (data.action == 'hide') {
        closeAll();
    }
});

function renderCharacters(characters) {
    const container = document.getElementById('char-slots');
    container.innerHTML = '';

    for (let i = 1; i <= 3; i++) {
        const char = characters.find(c => c.slot == i);
        const div = document.createElement('div');
        
        if (char) {
            div.className = 'char-card';
            div.innerHTML = `
                <div class="char-name" style="margin-bottom: 5px;">${char.name} ${char.firstname}</div>
                <div class="char-info" style="font-size: 14px; color: #fff;">ID: ${char.user_id}</div>
                <div class="char-info">${char.age} anos | ${char.job}</div>
                <button onclick="playCharacter(${char.user_id})" style="margin-top:auto; margin-bottom:20px; padding: 10px 30px; background: var(--gold); border: none; font-weight: bold; cursor: pointer;">JOGAR</button>
            `;
        } else {
            div.className = 'char-card empty';
            div.onclick = () => openCreate(i);
            div.innerHTML = `
                <div class="char-plus">+</div>
                <div class="char-info">Criar Novo</div>
            `;
        }
        container.appendChild(div);
    }
}

function closeAll() {
    document.body.style.display = 'none';
    fetch('http://godz_identity/close', { method: 'POST' });
}

function openCreate(slot) {
    currentSlot = slot;
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
    let name = document.getElementById('c-name').value;
    let firstname = document.getElementById('c-firstname').value;
    let age = document.getElementById('c-age').value;
    let job = document.getElementById('c-job').value;
    let bio = document.getElementById('generated-lore').textContent;
    
    if (bio.includes("A biografia aparecerá aqui") || bio.includes("IA está escrevendo")) bio = "Cidadão novo na cidade.";

    fetch('http://godz_identity/createCharacter', {
        method: 'POST',
        body: JSON.stringify({ name, firstname, age, job, bio, slot: currentSlot })
    })
    .then(resp => resp.json())
    .then(data => {
        if (data.success) {
            closeCreate();
            renderCharacters(data.characters);
        } else {
            // Show error (console for now or alert if allowed)
            console.error(data.message);
        }
    });
}

function playCharacter(user_id) {
    fetch('http://godz_identity/playCharacter', {
        method: 'POST',
        body: JSON.stringify({ user_id })
    });
}
