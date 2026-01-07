window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === "open") {
        document.getElementById("job-menu").style.display = "flex";
        loadJobs(data.jobs);
    } else if (data.action === "close") {
        document.getElementById("job-menu").style.display = "none";
    } else if (data.action === "showHUD") {
        document.getElementById("job-hud").style.display = "block";
        document.getElementById("hud-job-name").innerText = data.jobName.toUpperCase();
        document.getElementById("hud-context-text").innerText = data.context || "Missão iniciada.";
        updateProgress(data.progress || 0);
    } else if (data.action === "updateHUD") {
        if (data.text) document.getElementById("hud-context-text").innerText = data.text;
        updateProgress(data.progress);
    } else if (data.action === "hideHUD") {
        document.getElementById("job-hud").style.display = "none";
    }
});

function loadJobs(jobs) {
    const container = document.getElementById("jobs-container");
    container.innerHTML = "";
    
    jobs.forEach(job => {
        const card = document.createElement("div");
        card.className = "job-card";
        card.innerHTML = `
            <i class="${job.icon} job-icon"></i>
            <div class="job-title">${job.name}</div>
            <div class="job-desc">${job.description}</div>
            <button class="start-btn" onclick="startJob('${job.id}')">INICIAR</button>
        `;
        container.appendChild(card);
    });
}

function startJob(jobId) {
    fetch(`https://${GetParentResourceName()}/startJob`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ jobId: jobId })
    });
    document.getElementById("job-menu").style.display = "none";
}

function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    });
    document.getElementById("job-menu").style.display = "none";
}

function updateProgress(percent) {
    document.getElementById("hud-progress-fill").style.width = `${percent}%`;
    document.getElementById("hud-progress-text").innerText = `${percent}%`;
}

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeMenu();
    }
};
