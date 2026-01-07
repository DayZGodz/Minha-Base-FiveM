let currentMods = {};
let currentPrices = {};
let configCategories = [];

// Sound Helper
function playSound(name) {
    // Optional: Trigger client sound if needed via NUI callback, 
    // or just rely on CSS hover sounds if implemented.
    // Here we will use NUI callback for premium sounds
    fetch(`https://${GetParentResourceName()}/playSound`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ sound: name })
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "open") {
        document.getElementById("app").style.display = "flex";
        currentMods = data.currentMods;
        currentPrices = data.prices;
        configCategories = data.categories;
        loadCategories();
        
        // Initial Stats Update
        if (data.stats) {
            updateStatsDisplay(data.stats);
        }
    } else if (data.action === "updateStats") {
        updateStatsDisplay(data.stats);
    } else if (data.action === "close") {
        document.getElementById("app").style.display = "none";
    }
});

function updateStatsDisplay(stats) {
    // stats: { speed: 0-100, accel: 0-100, brakes: 0-100, traction: 0-100 } (normalized)
    // or raw values. Let's assume client sends normalized 0-100 values for bars, and raw for text.
    
    // Speed
    updateStat('stat-speed', stats.speedPercent, Math.round(stats.speedVal) + " km/h");
    // Accel
    updateStat('stat-accel', stats.accelPercent, stats.accelVal.toFixed(2));
    // Brakes
    updateStat('stat-brakes', stats.brakesPercent, stats.brakesVal.toFixed(2));
    // Traction
    updateStat('stat-traction', stats.tractionPercent, stats.tractionVal.toFixed(2));
}

function updateStat(idPrefix, percent, textVal) {
    const bar = document.getElementById(`${idPrefix}-bar`);
    const val = document.getElementById(`${idPrefix}-val`);
    if (bar) bar.style.width = `${percent}%`;
    if (val) val.innerText = textVal;
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
    document.getElementById("app").style.display = "none";
}

function finishTuning() {
    fetch(`https://${GetParentResourceName()}/finish`, {
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

function loadCategories() {
    const list = document.getElementById("category-list");
    list.innerHTML = "";
    
    configCategories.forEach(cat => {
        const li = document.createElement("li");
        li.className = "category-item";
        li.innerHTML = `<i class="${cat.icon}"></i> ${cat.label}`;
        li.onmouseenter = () => playSound("hover");
        li.onclick = () => {
            playSound("select");
            document.querySelectorAll(".category-item").forEach(el => el.classList.remove("active"));
            li.classList.add("active");
            loadOptions(cat);
        };
        list.appendChild(li);
    });
}

function loadOptions(category) {
    document.getElementById("current-category-title").innerText = category.label;
    const grid = document.getElementById("options-grid");
    grid.innerHTML = "";
    
    let options = [];
    
    // Fallbacks
    const p_engine = currentPrices.engine_base || 5000;
    const p_turbo = currentPrices.turbo_base || 15000;
    const p_brakes = currentPrices.brakes_base || 2000;
    const p_trans = currentPrices.transmission_base || 3000;
    const p_susp = currentPrices.suspension_base || 2500;
    const p_armor = currentPrices.armor_base || 10000;
    
    if (category.name === "engine") {
        options = [
            { label: "Motor Padrão", index: -1, price: 0, level: 0 },
            { label: "Motor Street (Nível 1)", index: 0, price: p_engine, level: 2 },
            { label: "Motor Sport (Nível 2)", index: 1, price: p_engine * 2.5, level: 5 },
            { label: "Motor Pro (Nível 3)", index: 2, price: p_engine * 5, level: 10 },
            { label: "Motor GODZ (Nível 4)", index: 3, price: p_engine * 10, level: 20 }
        ];
    } else if (category.name === "turbo") {
        options = [
            { label: "Sem Turbo", index: false, price: 0, level: 0 },
            { label: "Turbo Tuning", index: true, price: p_turbo, level: 15 }
        ];
    } else if (category.name === "brakes") {
        options = [
            { label: "Freios Padrão", index: -1, price: 0, level: 0 },
            { label: "Freios Street", index: 0, price: p_brakes, level: 2 },
            { label: "Freios Sport", index: 1, price: p_brakes * 2, level: 5 },
            { label: "Freios Corrida", index: 2, price: p_brakes * 3, level: 10 }
        ];
    } else if (category.name === "transmission") {
        options = [
            { label: "Transmissão Padrão", index: -1, price: 0, level: 0 },
            { label: "Transmissão Street", index: 0, price: p_trans, level: 2 },
            { label: "Transmissão Sport", index: 1, price: p_trans * 2, level: 5 },
            { label: "Transmissão Corrida", index: 2, price: p_trans * 3, level: 10 }
        ];
    } else if (category.name === "suspension") {
        options = [
            { label: "Suspensão Padrão", index: -1, price: 0, level: 0 },
            { label: "Suspensão Rebaixada", index: 0, price: p_susp, level: 2 },
            { label: "Suspensão Street", index: 1, price: p_susp * 2, level: 5 },
            { label: "Suspensão Sport", index: 2, price: p_susp * 3, level: 10 },
            { label: "Suspensão Competição", index: 3, price: p_susp * 4, level: 15 }
        ];
    } else if (category.name === "armor") {
        options = [
            { label: "Sem Blindagem", index: -1, price: 0, level: 0 },
            { label: "Blindagem 20%", index: 0, price: p_armor, level: 5 },
            { label: "Blindagem 40%", index: 1, price: p_armor * 2, level: 10 },
            { label: "Blindagem 60%", index: 2, price: p_armor * 3, level: 15 },
            { label: "Blindagem 80%", index: 3, price: p_armor * 4, level: 20 },
            { label: "Blindagem 100%", index: 4, price: p_armor * 5, level: 25 }
        ];
    }
    
    options.forEach(opt => {
        const card = document.createElement("div");
        card.className = "option-card";
        
        // Check if installed
        let isInstalled = false;
        if (category.name === "turbo") {
            // boolean check
            isInstalled = (currentMods[category.name] == opt.index); 
            // Note: == allows true == 1 comparison if needed, but safe to be explicit
            if (typeof currentMods[category.name] === 'boolean' && typeof opt.index === 'boolean') {
                isInstalled = (currentMods[category.name] === opt.index);
            }
        } else {
            // int check
            isInstalled = (currentMods[category.name] == opt.index);
        }
        
        if (isInstalled) card.classList.add("installed");
        
        card.innerHTML = `
            <div class="option-name">${opt.label}</div>
            <div class="option-price">$${opt.price}</div>
        `;
        
        card.onmouseenter = () => playSound("hover");
        
        card.onclick = () => {
            playSound("select");
            fetch(`https://${GetParentResourceName()}/applyMod`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({
                    category: category.name,
                    index: opt.index,
                    level: opt.level,
                    price: opt.price
                })
            });
            
            // Optimistic update
            currentMods[category.name] = opt.index;
            loadOptions(category); // Reload to update "installed" class
        };
        
        grid.appendChild(card);
    });
}
