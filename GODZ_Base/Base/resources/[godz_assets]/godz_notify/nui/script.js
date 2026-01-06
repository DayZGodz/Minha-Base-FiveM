window.addEventListener("message", (event) => {
    const data = event.data;

    if (data.action === "notify") {
        createNotification(data.type, data.message, data.length);
    }
});

function createNotification(type, message, length = 5000) {
    const container = document.getElementById("notifications-container");
    const notify = document.createElement("div");
    
    // Map types to icons/titles
    const config = {
        success: { icon: "fa-check-circle", title: "Sucesso" },
        error: { icon: "fa-times-circle", title: "Erro" },
        warning: { icon: "fa-exclamation-triangle", title: "Aviso" },
        info: { icon: "fa-info-circle", title: "Informação" }
    };

    const style = config[type] || config.info;
    const safeType = config[type] ? type : "info";

    notify.classList.add("notification", safeType);
    notify.innerHTML = `
        <div class="icon-container">
            <i class="fas ${style.icon}"></i>
        </div>
        <div class="content">
            <div class="title">${style.title}</div>
            <div class="message">${message}</div>
        </div>
    `;

    container.appendChild(notify);

    // Play sound if needed (optional)
    // const audio = new Audio('sounds/notify.ogg');
    // audio.play();

    setTimeout(() => {
        notify.classList.add("hide");
        notify.addEventListener("animationend", () => {
            notify.remove();
        });
    }, length);
}
