window.addEventListener("message", (e) => {
  const data = e.data || {}
  if (data.action === "update") {
    setWidth("health", data.health)
    setWidth("armor", data.armor)
    setWidth("hunger", data.hunger)
    setWidth("thirst", data.thirst)
    setWidth("oxygen", data.oxygen)
    toggleHud(data.show)
  }
  if (data.action === "toggle") {
    toggleHud(data.show)
  }
  if (data.action === "showXP") {
    showXP(data.label, data.xp, data.progress)
  }
})

let xpTimeout;
function showXP(label, xp, progress) {
  const toast = document.getElementById("xp-toast");
  const jobEl = document.getElementById("xp-job");
  const amountEl = document.getElementById("xp-amount");
  const barEl = document.getElementById("xp-bar-fill");
  
  if (!toast) return;

  jobEl.innerText = label;
  amountEl.innerText = `+${xp} XP`;
  barEl.style.width = `${progress}%`;

  toast.classList.remove("hidden");

  if (xpTimeout) clearTimeout(xpTimeout);
  xpTimeout = setTimeout(() => {
    toast.classList.add("hidden");
  }, 4000);
}

function setWidth(id, v) {
  const el = document.getElementById(id)
  if (!el) return
  const val = Math.max(0, Math.min(100, Number(v || 0)))
  el.style.width = val + "%"
}

function toggleHud(show) {
  const hud = document.getElementById("hud")
  if (!hud) return
  hud.classList.toggle("hidden", show === false)
}
