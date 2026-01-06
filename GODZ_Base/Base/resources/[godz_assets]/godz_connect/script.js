const audio = document.getElementById("bg-music");
const progressBar = document.getElementById("progress-bar");
const loadingPercent = document.getElementById("loading-percent");
const currentResource = document.getElementById("current-resource");
const muteBtn = document.getElementById("mute-btn");
const volumeSlider = document.getElementById("volume-slider");

// Initial Volume
audio.volume = 0.2;
let isMuted = false;

// Audio Auto-Play
document.addEventListener("click", () => {
    if (audio.paused) {
        audio.play().catch(e => console.log("Audio play blocked", e));
    }
});

// Try auto-play immediately (browsers might block)
window.onload = () => {
    audio.play().catch(e => {
        console.log("Autoplay blocked. User interaction required.");
    });
};

function toggleMute() {
    isMuted = !isMuted;
    audio.muted = isMuted;
    muteBtn.innerHTML = isMuted ? '<i class="fas fa-volume-mute"></i>' : '<i class="fas fa-volume-up"></i>';
}

function setVolume(val) {
    audio.volume = val / 100;
}

// FiveM Loading Events
const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },

    initFunctionInvoking(data) {
        document.querySelector('.progress-bar-fill').style.left = '0%';
        document.querySelector('.progress-bar-fill').style.width = ((data.idx / count) * 100) + '%';
    },

    startDataFileEntries(data) {
        count = data.count;
    },

    onDataFileEntry(data) {
        document.querySelector('.progress-bar-fill').style.left = '0%';
        document.querySelector('.progress-bar-fill').style.width = ((data.idx / count) * 100) + '%';
    },

    endDataFileEntries() {
        document.querySelector('.progress-bar-fill').style.left = '0%';
        document.querySelector('.progress-bar-fill').style.width = '100%';
    },

    performMapLoadFunction(data) {
        ++thisCount;
        document.querySelector('.progress-bar-fill').style.left = '0%';
        document.querySelector('.progress-bar-fill').style.width = ((thisCount / count) * 100) + '%';
    },

    onLogLine(data) {
        document.querySelector('.progress-bar-fill').style.left = '0%';
        document.querySelector('.progress-bar-fill').style.width = (data.idx / count * 100) + '%';
    }
};

window.addEventListener('message', function (e) {
    if (e.data.eventName === 'loadProgress') {
        const pct = parseInt(e.data.loadFraction * 100);
        progressBar.style.width = pct + "%";
        loadingPercent.innerText = pct + "%";
    }
    
    if (e.data.eventName === 'onLogLine') {
        // e.data.message contains info like "Loading resource xyz"
        currentResource.innerText = e.data.message;
    }
});
