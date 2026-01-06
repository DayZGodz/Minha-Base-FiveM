let items = [];
let currentCategory = 'all';

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.type === 'open') {
        items = data.items;
        document.getElementById('app').style.display = 'flex';
        renderItems();
    } else if (data.type === 'close') {
        document.getElementById('app').style.display = 'none';
    }
});

document.getElementById('btn-close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.getElementById('btn-save').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/save`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

document.querySelectorAll('.cat-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
        e.target.classList.add('active');
        currentCategory = e.target.dataset.cat;
        renderItems();
    });
});

function renderItems() {
    const grid = document.getElementById('items-grid');
    grid.innerHTML = '';
    
    items.forEach(item => {
        if (currentCategory === 'all' || item.category === currentCategory) {
            const card = document.createElement('div');
            card.className = 'item-card';
            card.innerHTML = `
                <div class="item-icon"><i class="fas fa-box"></i></div>
                <div class="item-name">${item.label}</div>
                <div class="item-price">$${item.price}</div>
            `;
            
            card.addEventListener('click', () => {
                fetch(`https://${GetParentResourceName()}/spawnPreview`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ model: item.model })
                });
                // Hide UI temporarily to place item?
                // For MVP, we keep UI open or user closes it.
                // Better UX: Close UI automatically to let user place it.
                document.getElementById('app').style.display = 'none';
            });
            
            grid.appendChild(card);
        }
    });
}
