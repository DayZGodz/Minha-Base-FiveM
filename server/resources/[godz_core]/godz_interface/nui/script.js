window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'updateHUD') {
        updateCircle('health', data.health);
        updateCircle('armour', data.armour);
        updateCircle('hunger', data.hunger);
        updateCircle('thirst', data.thirst);

        // Ocultar colete se estiver vazio
        const armourContainer = document.getElementById('armour-container');
        if (data.armour <= 0) {
            armourContainer.style.opacity = '0';
        } else {
            armourContainer.style.opacity = '1';
        }
    } 
    else if (data.action === 'notify') {
        createNotify(data.type, data.title, data.message, data.duration);
    }
  else if (data.action === 'toggleHUD') {
      document.getElementById('hud-container').style.opacity = data.show ? '1' : '0';
  }
  else if (data.action === 'openShop') {
      openShop(data.items || []);
  }
  else if (data.action === 'closeShop') {
      closeShop();
  }
});

function updateCircle(type, percent) {
    // Percent is 0-100.
    // Stroke dasharray: "current, 100".
    // Since the path length is ~100 (for r=15.9155, C=2*pi*r = 100), we can just use percent directly.
    
    // Safety clamp
    percent = Math.max(0, Math.min(100, percent));
    
    const circle = document.querySelector(`.${type}-fill`);
    if (circle) {
        circle.setAttribute('stroke-dasharray', `${percent}, 100`);
    }
}

function createNotify(type, title, message, duration = 5000) {
    const container = document.getElementById('notify-container');
    
    const notify = document.createElement('div');
    notify.className = `notify ${type}`;
    
    let iconClass = 'fa-info-circle';
    if (type === 'sucesso') iconClass = 'fa-check-circle';
    if (type === 'erro') iconClass = 'fa-times-circle';
    if (type === 'aviso') iconClass = 'fa-exclamation-triangle';
    if (type === 'ia_tip') iconClass = 'fa-robot';

    notify.innerHTML = `
        <i class="fas ${iconClass}"></i>
        <div class="notify-content">
            <h4>${title || type}</h4>
            <p>${message}</p>
        </div>
    `;

    // Animation override for duration
    const style = document.createElement('style');
    style.innerHTML = `
        .notify::after { animation-duration: ${duration}ms !important; }
    `;
    notify.appendChild(style);

    container.appendChild(notify);

    // Remove after duration
    setTimeout(() => {
        notify.style.animation = 'fadeOut 0.5s ease forwards';
        setTimeout(() => {
            if (notify.parentNode) {
                notify.parentNode.removeChild(notify);
            }
        }, 500);
    }, duration);
}

function openShop(items) {
    const modal = document.getElementById('shop-modal');
    const container = document.getElementById('shop-items');
    container.innerHTML = '';
    items.forEach(it => {
        const el = document.createElement('div');
        el.className = 'shop-item';
        el.innerHTML = `
            <div class="shop-item-image">
                <img src="images/items/${it.item}.png" alt="${it.name}" onerror="this.style.display='none'">
            </div>
            <div class="shop-item-name">${it.name}</div>
            <div class="shop-item-price">$${it.price}</div>
            <button class="shop-item-buy">Comprar</button>
        `;
        el.querySelector('.shop-item-buy').addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/shopBuy`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ item: it.item, price: it.price })
            });
        });
        container.appendChild(el);
    });
    modal.style.display = 'block';
}

function closeShop() {
    const modal = document.getElementById('shop-modal');
    modal.style.display = 'none';
}

document.getElementById('shop-close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/shopClose`, { method: 'POST' });
    closeShop();
});
