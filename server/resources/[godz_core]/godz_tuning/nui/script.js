let currentMods = {};
let currentPrices = {};
let configCategories = [];

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "open") {
        document.getElementById("app").style.display = "flex";
        currentMods = data.currentMods;
        currentPrices = data.prices;
        configCategories = data.categories;
        loadCategories();
    } else if (data.action === "close") {
        document.getElementById("app").style.display = "none";
    }
});

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
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
        li.onclick = () => {
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
    
    // Dados Dinâmicos baseados no Config
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
            { label: "Suspensão Corrida", index: 3, price: p_susp * 4, level: 15 }
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
    
    // Render
    options.forEach(opt => {
        const div = document.createElement("div");
        div.className = "option-card";
        
        // Verificar se está instalado
        let isInstalled = false;
        if (category.name === "turbo") {
            if (currentMods.turbo === opt.index) isInstalled = true;
        } else {
            if (currentMods[category.name] === opt.index) isInstalled = true;
        }
        
        if (isInstalled) div.classList.add("installed");
        
        div.innerHTML = `
            <h3>${opt.label}</h3>
            <div class="price">$${opt.price}</div>
            <div class="level-req">Nível Mecânico: ${opt.level}</div>
        `;
        
        div.onclick = () => {
            fetch(`https://${GetParentResourceName()}/applyMod`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({
                    category: category.name,
                    index: opt.index,
                    level: opt.level
                })
            });
        };
        
        grid.appendChild(div);
    });
}
