let playerName = "Cidadão";
let isWhitelisted = false;
let hasReceivedStatus = false;
let isStaff = false;
let userGroup = "cidadao";

function startNexusProtocol() {
    try {
        if (window.isCreatorMode) {
            const msg = `Assinatura de comando detectada. Protocolo do Criador ativado. Bem-vindo de volta, Senhor. Todos os sistemas da GODZ estão operando em 100% sob seu comando.`;
            speakAi(msg);
            return;
        }

        // [GODZ UNIFIED] Role-Based Greetings
        if (isStaff) {
            if (userGroup === "ceo" || userGroup === "ceos") {
                const msg = `Protocolo de comando mestre detectado. Bem-vindo, Diretor. Todos os protocolos de segurança foram suspensos para seu acesso.`;
                window.shouldAutoCloseAfterElite = true;
                speakAi(msg);
                return;
            } else if (userGroup === "bot") {
                 const msg = `NEXUS SYSTEM: Sincronização neural completa.`;
                 speakAi(msg);
                 return;
            } else if (userGroup === "staff" || userGroup === "admin") {
                const msg = `Credenciais de administrador validadas. Bem-vindo, ${playerName}. Painel de monitoramento pronto.`;
                window.shouldAutoCloseAfterElite = true;
                speakAi(msg);
                return;
            }
        }
        
        if (userGroup === "policia") {
             const msg = `Assinatura de autoridade detectada. Bem-vindo, Oficial. Os sistemas da cidade estão à sua disposição.`;
             speakAi(msg);
             return;
        } else if (userGroup === "faccao") {
             const msg = `Perfil identificado nos registros de segurança. Tenha cuidado nas ruas, a vigilância está ativa.`;
             speakAi(msg);
             return;
        }

        if (isWhitelisted) {
            const msg = `Bem-vindo de volta, ${playerName}. Sincronizando seus dados... Todos os sistemas prontos.`;
            speakAi(msg);
        } else {
            const msg = `Bem-vindo à GODZ. Valide sua identidade no Discord.`;
            speakAi(msg);
        }
    } catch (e) { console.log(e); }
}

// FAILSAFE: Force close if stuck at 100%
setInterval(() => {
    if (loadingFill && loadingFill.style.width === '100%') {
        // [GODZ] Visual Cleanup at 100%
        document.body.style.transition = "opacity 1s ease-out";
        document.body.style.opacity = "0";
        
        setTimeout(() => {
            document.body.style.display = 'none';
            fetch('https://godz_connect/close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(e => {});
        }, 1000);
    }
}, 1000);

/* ==========================================================================
   GODZ NEXUS AI INTERFACE & LOADING SYSTEM
   ========================================================================== */

// Message Handler for NUI Actions
window.addEventListener('message', function(event) {
    if (event.data.action === "hide") {
        forceKillNexusUI();
        hideLoadingScreen();
        // [GODZ SUPREME] Total Cleanup
        document.body.innerHTML = '';
    } else if (event.data.action === "toggleVoice") {
        if (micBtn) micBtn.click();
    } else if (event.data.action === "startIntro") {
        const playerName = event.data.playerName || "Cidadão";
        const isCreator = event.data.isCreator;

        window.isIntroMode = true;
        
        // Show HUD
        const introHud = document.querySelector('.intro-hud');
        if (introHud) introHud.style.opacity = '1';
        
        // [GODZ] Play Pre-Generated Nexus Voice
        // playNexusIntro(); // Removed to play immediately on load
    }
});

// [GODZ] Immediate Audio Playback with Fade-In
window.addEventListener('load', () => {
    playNexusAudioImmediate();
});

function playNexusAudioImmediate() {
    console.log("[GODZ] Starting Nexus Audio Sequence...");
    // [GODZ] User Requested Simple Audio Logic
    const introAudio = new Audio('sounds/nexus_voice.wav');
    introAudio.volume = 0.8;
    
    // Visual Sync
    if (statusText) statusText.innerText = "TRANSMITINDO...";
    if (aiAvatarWrapper) aiAvatarWrapper.classList.add("speaking");

    introAudio.play().then(() => {
        console.log("[GODZ] Audio playing successfully.");
    }).catch(e => {
        console.error("[GODZ] Audio play failed:", e);
        speakAi("Sistemas da Nexus online. Bem-vindo.");
    });

    introAudio.onended = () => {
        console.log("[GODZ] Audio finished.");
        if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "SISTEMA NEXUS: ONLINE";
        
        // Notify Client
        fetch('https://godz_connect/introFinished', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
        
        const introHud = document.querySelector('.intro-hud');
        if (introHud) introHud.style.opacity = '0';
    };

    introAudio.onerror = () => {
        console.error("[GODZ] Audio file not found or error.");
        if (statusText) statusText.innerText = "ERRO DE AUDIO";
    };
}

function playNexusIntro() {
    // Legacy function kept for reference or manual triggers
    // implementation merged into playNexusAudioImmediate
}

function forceKillNexusUI() {
    const ids = ["protocols-list", "system-status", "mic-container"];
    ids.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.style.setProperty("display", "none", "important");
            el.style.setProperty("opacity", "0", "important");
        }
    });
    
    // Also hide class based elements if needed
    const protocols = document.querySelector(".protocols");
    if (protocols) {
        protocols.style.setProperty("display", "none", "important");
        protocols.style.setProperty("opacity", "0", "important");
    }
}

function hideLoadingScreen() {
    document.body.style.setProperty("display", "none", "important");
    const overlays = document.querySelectorAll(".overlay, .protocols, .mic-container");
    overlays.forEach(el => el.style.setProperty("display", "none", "important"));
    
    if (recognition) recognition.stop();
}

// DOM Elements
const aiAvatarWrapper = document.querySelector(".ai-avatar-wrapper");
const statusText = document.getElementById("status-text");
const micBtn = document.getElementById("mic-btn");
const loadingFill = document.querySelector(".cyber-fill");
const loadingPercent = document.getElementById("loading-percent");
const currentFile = document.querySelector(".current-file");

// State Variables
let isListening = false;
let recognition;
let synth = window.speechSynthesis;
let count = 0;
let thisCount = 0;

// Ensure voices are loaded
window.speechSynthesis.onvoiceschanged = () => {
    try {
        window.__voices = window.speechSynthesis.getVoices() || [];
    } catch (e) { console.log(e); }
};

function initSpeech() {
    try {
        const voices = window.speechSynthesis.getVoices();
        if (!voices || voices.length === 0) {
            // Retry until voices become available
            let tries = 0;
            const iv = setInterval(() => {
                const v = window.speechSynthesis.getVoices();
                tries++;
                if (v && v.length > 0 || tries > 20) {
                    clearInterval(iv);
                }
            }, 200);
        }
    } catch (e) { console.log(e); }
}

/* ==========================================================================
   WEB SPEECH API (STT) - VOICE RECOGNITION
   ========================================================================== */
if ('webkitSpeechRecognition' in window) {
    recognition = new webkitSpeechRecognition();
    recognition.continuous = false;
    recognition.lang = 'pt-BR';
    recognition.interimResults = false;

    recognition.onstart = function() {
        isListening = true;
        if (micBtn) micBtn.classList.add("active");
        if (aiAvatarWrapper) aiAvatarWrapper.classList.add("listening");
        if (statusText) statusText.innerText = "OUVINDO...";
    };

    recognition.onend = function() {
        isListening = false;
        if (micBtn) micBtn.classList.remove("active");
        if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("listening");
        if (!synth.speaking && statusText) {
            statusText.innerText = "SYSTEM: ONLINE";
        }
    };

    recognition.onresult = function(event) {
        const transcript = event.results[0][0].transcript;
        console.log("Player Input: " + transcript);
        if (statusText) statusText.innerText = "PROCESSANDO DADOS...";
        sendToGodzAi(transcript);
    };

    recognition.onerror = function(event) {
        console.error("STT Error:", event.error);
        if (statusText) statusText.innerText = "ERRO: INPUT DE VOZ";
    };
} else {
    console.log("Web Speech API not supported.");
    if (micBtn) micBtn.style.display = "none";
    if (statusText) statusText.innerText = "ERRO: SISTEMA DE VOZ INCOMPATÍVEL";
}

// Microphone Toggle Handler
if (micBtn) {
    micBtn.addEventListener("click", () => {
        if (isListening) {
            recognition.stop();
        } else {
            try {
                recognition.start();
            } catch (e) {
                console.error("Mic Start Error:", e);
                if (statusText) statusText.innerText = "ERRO: ACESSO AO MIC NEGADO";
            }
        }
    });
}

/* ==========================================================================
   GODZ AI BRIDGE (PYTHON SERVER)
   ========================================================================== */
const AI_BASE_URL = 'http://127.0.0.1:5000/';

const fetchWithTimeout = (url, options, timeout = 20000) => {
    return Promise.race([
        fetch(url, options),
        new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), timeout))
    ]);
};

const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

async function fetchJsonWithRetry(url, options, attempts = 6, timeoutMs = 20000) {
    let lastError = null;
    for (let i = 0; i < attempts; i++) {
        try {
            const response = await fetchWithTimeout(url, options, timeoutMs);
            return await response.json();
        } catch (e) {
            lastError = e;
            await delay(4000);
        }
    }
    throw lastError;
}

async function sendToGodzAi(text) {
    try {
        // Dev Mode: 127.0.0.1. Production: Change to Server IP.
        const response = await fetch(`${AI_BASE_URL}loading_chat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ question: text })
        });

        const data = await response.json();
        if (data.response) {
            speakAi(data.response);
        } else {
            speakAi("Não foi possível processar os dados solicitados.");
        }
    } catch (error) {
        console.error("AI Bridge Error:", error);
        speakAi("Falha na conexão com o núcleo neural.");
        
        // [GODZ SUPREME] RESGATE DA CONEXÃO: Fecha a UI se a IA falhar
        setTimeout(() => {
             forceKillNexusUI();
             hideLoadingScreen();
             document.body.innerHTML = '';
             fetch('https://godz_connect/close', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
        }, 3000); // 3s delay to let the fallback message play
    }
}

/* ==========================================================================
   TEXT TO SPEECH (TTS) - NEXUS VOICE
   ========================================================================== */
function speakAi(text) {
    // [GODZ] IMMEDIATE VISUAL UNLOCK
    // Force transparency/hide immediately so player is not stuck
    const loadingSector = document.querySelector(".loading-sector");
    if (loadingSector) loadingSector.style.display = 'none';

    // Stop any existing speech
    if (synth.speaking) synth.cancel();

    if (statusText) statusText.innerText = "TRANSMITINDO...";
    if (aiAvatarWrapper) aiAvatarWrapper.classList.add("speaking");

    (async () => {
        let data;
        try {
            data = await fetchJsonWithRetry(`${AI_BASE_URL}tts?text=${encodeURIComponent(text)}`, {}, 6, 20000);
        } catch (e) {
            console.error("Bridge Connection Error/Timeout:", e);
            fallbackSpeak(text);
            return;
        }

        if (data.status === "ok") {
             const fileName = data.file || 'nexus_voice.wav';
             const baseUrl = data.url || `${AI_BASE_URL}static/voices/${fileName}`;
             const audioUrl = `${baseUrl}${baseUrl.includes('?') ? '&' : '?'}t=${new Date().getTime()}`;
             const audio = new Audio(audioUrl);
             
             // Lip Sync Triggers
             fetch(`https://godz_connect/startLipSync`, { method: 'POST', body: JSON.stringify({}) }).catch(()=>{});

             audio.play().catch(e => {
                console.error("Audio Play Error:", e);
                fallbackSpeak(text);
             });

             audio.onended = () => {
                if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("speaking");
                if (statusText) statusText.innerText = "SYSTEM: ONLINE";
                fetch(`https://godz_connect/stopLipSync`, { method: 'POST', body: JSON.stringify({}) }).catch(()=>{});

                if (window.isIntroMode) {
                    window.isIntroMode = false;
                    fetch('https://godz_connect/introFinished', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
                    const introHud = document.querySelector('.intro-hud');
                    if (introHud) introHud.style.opacity = '0';
                    return;
                }

                if (window.shouldAutoCloseAfterElite) {
                    forceKillNexusUI();
                    hideLoadingScreen();
                    document.body.innerHTML = '';
                    fetch('https://godz_connect/close', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
                }
             };

             audio.onerror = () => {
                console.error("Audio Load Error");
                fallbackSpeak(text);
             };
        } else {
            console.error("TTS Generation Failed:", data.error);
            fallbackSpeak(text);
        }
    })();
}

function fallbackSpeak(text) {
    if (synth.speaking) return;
    
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'pt-BR';
    
    // Find a female voice if possible
    const voices = window.speechSynthesis.getVoices();
    const femaleVoice = voices.find(v => v.lang.includes('pt-BR') && (v.name.includes('Google') || v.name.includes('Luciana') || v.name.includes('Maria')));
    if (femaleVoice) utterance.voice = femaleVoice;

    utterance.onend = () => {
        if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "SYSTEM: ONLINE";
        fetch(`https://godz_connect/stopLipSync`, { method: 'POST', body: JSON.stringify({}) }).catch(()=>{});

        if (window.isIntroMode) {
            window.isIntroMode = false;
            fetch('https://godz_connect/introFinished', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
            const introHud = document.querySelector('.intro-hud');
            if (introHud) introHud.style.opacity = '0';
            return;
        }

        if (window.shouldAutoCloseAfterElite) {
            forceKillNexusUI();
            hideLoadingScreen();
            document.body.innerHTML = '';
            fetch('https://godz_connect/close', { method: 'POST', body: JSON.stringify({}) }).catch(e => {});
        }
    };

    synth.speak(utterance);
}

// Initial Greeting removed from onload as it is now triggered by setupIdentity
window.onload = () => {
    try { initSpeech(); } catch (e) { console.log(e); }
    setTimeout(() => {
        if (!hasReceivedStatus) {
            // [GODZ SUPREME] Safety Lock: 30s Timeout (ChatTTS Latency Adjustment)
            console.log("GODZ SAFETY: JSON Timeout (30s). Forcing UI shutdown.");
            forceKillNexusUI();
            hideLoadingScreen();
            document.body.innerHTML = ''; // [GODZ SUPREME] Total Cleanup
            
            // Notify client to kill NUI focus
            fetch('https://godz_connect/close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(e => {});
        }
    }, 30000);
};

/* ==========================================================================
   FIVEM LOADING HANDLERS
   ========================================================================== */
const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },

    initFunctionInvoking(data) {
        if (loadingFill) loadingFill.style.width = ((data.idx / count) * 100) + '%';
    },

    startDataFileEntries(data) {
        count = data.count;
    },

    onDataFileEntry(data) {
        if (loadingFill) loadingFill.style.width = ((data.idx / count) * 100) + '%';
    },

    endDataFileEntries() {
        if (loadingFill) loadingFill.style.width = '100%';
    },

    performMapLoadFunction(data) {
        ++thisCount;
        if (loadingFill) loadingFill.style.width = ((thisCount / count) * 100) + '%';
    },

    onLogLine(data) {
        if (loadingFill) loadingFill.style.width = (data.idx / count * 100) + '%';
    }
};

window.addEventListener('message', function (e) {
    if (e.data.eventName === 'setCreatorMode') {
        window.isCreatorMode = e.data.isCreator;
    }

    if (e.data.eventName === 'receiveStatus') {
        hasReceivedStatus = true;
        playerName = e.data.playerName || "Cidadão";
        isWhitelisted = !!e.data.isWhitelisted;
        window.isCreatorMode = !!e.data.isCreator;
        
        // [GODZ UNIFIED]
        isStaff = !!e.data.isStaff;
        userGroup = e.data.group || "cidadao";
        
        startNexusProtocol();
    }

    if (e.data.action === 'setupIdentity') {
        // Legacy compatibility
        if (!hasReceivedStatus) {
            playerName = e.data.name || "Cidadão";
            startNexusProtocol();
        }
    }
    
    if (e.data.eventName === 'loadProgress') {
        const pct = parseInt(e.data.loadFraction * 100);
        if (loadingFill) loadingFill.style.width = pct + "%";
        if (loadingPercent) loadingPercent.innerText = pct + "%";
    }
    
    if (e.data.eventName === 'onLogLine') {
        if (currentFile) currentFile.innerText = e.data.message;
    }
});

// Show Block Code Overlay
function showBlockCode(token) {
    try {
        const el = document.getElementById('block-code-container');
        const val = document.getElementById('block-code-value');
        if (el && val) {
            val.innerText = token || 'GZ-0000';
            el.style.display = 'block';
        }
    } catch (e) { console.log(e); }
}

// Listen for block-code signal from client
window.addEventListener('message', function (e) {
    if (e.data && e.data.action === 'openBlockCode') {
        showBlockCode(e.data.token);
    }
});

// Bridge between FiveM Native UI and standard web events
if (!window.invokeNative) {
    // Fallback for browser testing
    let progress = 0;
    setInterval(() => {
        progress += 1;
        if (progress > 100) progress = 100;
        if (loadingFill) loadingFill.style.width = progress + "%";
        if (loadingPercent) loadingPercent.innerText = progress + "%";
    }, 100);
}
