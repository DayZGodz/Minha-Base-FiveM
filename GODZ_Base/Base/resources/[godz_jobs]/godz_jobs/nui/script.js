window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.type === 'open') {
        renderJobs(data.jobs, data.data);
        document.getElementById('app').style.display = 'flex';
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

function renderJobs(jobsConfig, jobsData) {
    const grid = document.getElementById('jobs-grid');
    grid.innerHTML = '';

    for (const [key, config] of Object.entries(jobsConfig)) {
        const userData = jobsData[key] || { level: 1, xp: 0, next_level_xp: 100, bonus: 0 };
        
        const card = document.createElement('div');
        card.className = 'job-card';
        card.innerHTML = `
            <div class="job-icon"><i class="${config.icon}"></i></div>
            <div class="job-title">${config.label}</div>
            <div class="job-desc">${config.description}</div>
            
            <div class="stats">
                <div class="stat-row">
                    <span>Nível</span>
                    <span class="stat-value">${userData.level}</span>
                </div>
                <div class="stat-row">
                    <span>XP Próx.</span>
                    <span class="stat-value">${userData.xp} / ${userData.next_level_xp}</span>
                </div>
                <div class="stat-row">
                    <span>Bônus</span>
                    <span class="stat-value">+$${userData.bonus}</span>
                </div>
            </div>
            
            <button class="btn-start" onclick="startJob('${key}')">INICIAR ROTA</button>
        `;
        
        grid.appendChild(card);
    }
}

function startJob(key) {
    fetch(`https://${GetParentResourceName()}/startJob`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jobKey: key })
    });
    document.getElementById('app').style.display = 'none';
}
