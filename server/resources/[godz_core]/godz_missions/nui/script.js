window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === "showHack") {
        if (data.show) {
            document.getElementById("hack-container").style.display = "block";
        } else {
            document.getElementById("hack-container").style.display = "none";
        }
    } else if (data.action === "updateHack") {
        const bar = document.getElementById("hack-bar-fill");
        bar.style.width = data.progress + "%";
        
        // Mudar cor se estiver crítico
        if (data.progress > 90) {
            bar.style.backgroundColor = "#00ff00";
        } else if (data.progress > 50) {
            bar.style.backgroundColor = "#ffff00";
        } else {
            bar.style.backgroundColor = "#ff0000";
        }
    }
});