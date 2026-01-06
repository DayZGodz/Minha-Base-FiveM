window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'eye') {
        const eye = document.getElementById('target-eye');
        if (data.display) {
            eye.className = data.active ? 'eye-visible eye-active' : 'eye-visible';
        } else {
            eye.className = 'eye-hidden';
        }
    } else if (data.type === 'open') {
        openMenu(data.options);
    } else if (data.type === 'close') {
        closeMenu();
    }
});

function openMenu(options) {
    const container = document.getElementById('options-container');
    container.innerHTML = '';
    
    document.getElementById('target-menu').classList.remove('menu-hidden');
    document.getElementById('target-eye').className = 'eye-hidden'; // Hide eye when menu is open

    options.forEach((opt, index) => {
        const div = document.createElement('div');
        div.className = 'menu-option';
        div.innerHTML = `<i class="${opt.icon || 'fas fa-circle'}"></i> ${opt.label}`;
        div.onclick = () => selectOption(index);
        container.appendChild(div);
    });
}

function closeMenu() {
    document.getElementById('target-menu').classList.add('menu-hidden');
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

function selectOption(index) {
    fetch(`https://${GetParentResourceName()}/select`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ index: index })
    });
    closeMenu();
}

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        closeMenu();
    }
};
