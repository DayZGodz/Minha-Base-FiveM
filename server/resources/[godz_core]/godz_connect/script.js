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
        setTimeout(() => {
            fetch('https://godz_connect/close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(e => {});
        }, 15000); // 15 seconds failsafe
    }
}, 5000);

/* ==========================================================================
   GODZ NEXUS AI INTERFACE & LOADING SYSTEM
   ========================================================================== */

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
async function sendToGodzAi(text) {
    try {
        // Dev Mode: 127.0.0.1. Production: Change to Server IP.
        const response = await fetch('http://127.0.0.1:5000/loading_chat', {
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
    }
}

/* ==========================================================================
   TEXT TO SPEECH (TTS) - NEXUS VOICE
   ========================================================================== */
function speakAi(text) {
    if (synth.speaking) return;

    if (statusText) statusText.innerText = "TRANSMITINDO...";
    if (aiAvatarWrapper) aiAvatarWrapper.classList.add("speaking");

    const utterThis = new SpeechSynthesisUtterance(text);
    utterThis.lang = 'pt-BR';
    utterThis.volume = 1.0;

    // Voice Selection Logic (Prioritizing Natural/Neural voices)
    const voices = synth.getVoices();
    const voice = voices.find(v => v.name.includes('Microsoft Francisca Online (Natural)')) ||
                  voices.find(v => (v.name.includes('Natural') || v.name.includes('Neural')) && (v.name.includes('Female') || v.name.includes('Feminina')) && v.lang.includes('pt-BR')) ||
                  voices.find(v => (v.name.includes('Female') || v.name.includes('Feminina')) && v.lang.includes('pt-BR')) ||
                  voices.find(v => v.lang.includes('pt-BR')) ||
                  voices[0];
                  
    if (voice) utterThis.voice = voice;

    // Android/AI Cadence
    utterThis.pitch = 1.0; 
    utterThis.rate = 0.9; 

    // Start Lip Sync (Client Trigger)
    fetch('https://godz_connect/startLipSync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {});

    // Start Bio Scan (Client Trigger)
    fetch('https://godz_connect/startBioScan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {}); // Ignore errors if not in FiveM environment

    utterThis.onend = function (event) {
        if (!event) return;
        if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "SYSTEM: ONLINE";
        
        // Stop Lip Sync
        fetch('https://godz_connect/stopLipSync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(err => {});

        // [GODZ] Notify client that speech is finished
        fetch('https://godz_connect/speechFinished', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(err => {});

        // Auto-close loading screen para Staff após saudação de elite
        try {
            if (window.shouldAutoCloseAfterElite) {
                window.shouldAutoCloseAfterElite = false;
                fetch('https://godz_connect/close', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                }).catch(() => {});
            }
        } catch (e) { }
    };

    utterThis.onerror = function (event) {
        console.error('TTS Error');
        if (aiAvatarWrapper) aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "ERRO: SÍNTESE DE VOZ";
    };

    synth.speak(utterThis);
}

// Initial Greeting removed from onload as it is now triggered by setupIdentity
window.onload = () => {
    try { initSpeech(); } catch (e) { console.log(e); }
    setTimeout(() => {
        if (!hasReceivedStatus) {
            window.isCreatorMode = false;
            isWhitelisted = false;
            playerName = playerName || "Cidadão";
            startNexusProtocol();
        }
    }, 5000);
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
