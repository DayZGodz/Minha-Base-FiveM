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
        micBtn.classList.add("active");
        aiAvatarWrapper.classList.add("listening"); // Optional: Add specific listening anim
        if (statusText) statusText.innerText = "OUVINDO...";
    };

    recognition.onend = function() {
        isListening = false;
        micBtn.classList.remove("active");
        aiAvatarWrapper.classList.remove("listening");
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
    aiAvatarWrapper.classList.add("speaking"); // Triggers visualizer overlay

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
        aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "SYSTEM: ONLINE";
        
        // Stop Lip Sync
        fetch('https://godz_connect/stopLipSync', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(err => {});
    };

    utterThis.onerror = function (event) {
        console.error('TTS Error');
        aiAvatarWrapper.classList.remove("speaking");
        if (statusText) statusText.innerText = "ERRO: SÍNTESE DE VOZ";
    };

    synth.speak(utterThis);
}

// Initial Greeting
window.onload = () => {
    // Aguarda um pouco para verificar se recebe o evento de Criador e Nome
    setTimeout(() => {
        if (window.isCreatorMode) {
            const creatorGreeting = `Assinatura de comando detectada. Protocolo do Criador ativado. Bem-vindo de volta, Senhor. Todos os sistemas da GODZ estão operando em 100% sob seu comando.`;
            speakAi(creatorGreeting);
        } else {
            const greetings = [
                `Sincronizando assinatura neural... Seja bem-vindo à GODZ, ${playerName}. Eu sou a Nexus. Seu perfil de cidadão acaba de ser validado.`,
                `Otimizando ambiente de simulação... Olá. Eu sou a Nexus. Estou preparando sua transição para o setor, ${playerName}.`,
                `Conexão segura estabelecida. Identidade confirmada. Bem-vindo à GODZ City, ${playerName}. Protocolos iniciais ativos.`
            ];
            
            // Random Selection
            const randomGreeting = greetings[Math.floor(Math.random() * greetings.length)];
            speakAi(randomGreeting);
        }
    }, 2000);
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
    
    if (e.data.eventName === 'loadProgress') {
        const pct = parseInt(e.data.loadFraction * 100);
        if (loadingFill) loadingFill.style.width = pct + "%";
        if (loadingPercent) loadingPercent.innerText = pct + "%";
    }
    
    if (e.data.eventName === 'onLogLine') {
        if (currentFile) currentFile.innerText = e.data.message;
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
