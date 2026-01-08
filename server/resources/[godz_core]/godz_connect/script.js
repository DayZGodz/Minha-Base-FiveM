const audio = document.getElementById("bg-music");
const progressBar = document.getElementById("progress-bar");
const loadingPercent = document.getElementById("loading-percent");
const currentResource = document.getElementById("current-resource");

// Initial Volume (Ambient Mode)
const AMBIENT_VOL = 0.10; // 10%
const DUCKING_VOL = 0.02; // 2%

audio.volume = AMBIENT_VOL;

// Audio Auto-Play
document.addEventListener("click", () => {
    if (audio.paused) {
        audio.play().catch(e => console.log("Audio play blocked", e));
    }
});

/* ==========================================================================
   GODZ NEXUS AI INTERACTION (Loading Screen)
   ========================================================================== */

const aiAvatar = document.getElementById("ai-avatar");
const aiStatusText = document.getElementById("ai-status-text");
const micBtn = document.getElementById("mic-btn");

let isListening = false;
let recognition;
let synth = window.speechSynthesis;

// 1. Configurar Web Speech API (STT)
if ('webkitSpeechRecognition' in window) {
    recognition = new webkitSpeechRecognition();
    recognition.continuous = false;
    recognition.lang = 'pt-BR';
    recognition.interimResults = false;

    recognition.onstart = function() {
        isListening = true;
        micBtn.classList.add("active");
        aiAvatar.classList.add("listening");
        aiStatusText.innerText = "OUVINDO...";
        audio.volume = DUCKING_VOL; // Ducking
    };

    recognition.onend = function() {
        isListening = false;
        micBtn.classList.remove("active");
        aiAvatar.classList.remove("listening");
        if (!synth.speaking) {
            audio.volume = AMBIENT_VOL; // Restore volume
            aiStatusText.innerText = "GODZ NEXUS: ONLINE";
        }
    };

    recognition.onresult = function(event) {
        const transcript = event.results[0][0].transcript;
        console.log("Player disse: " + transcript);
        aiStatusText.innerText = "PROCESSANDO...";
        sendToGodzAi(transcript);
    };

    recognition.onerror = function(event) {
        console.error("Erro STT:", event.error);
        aiStatusText.innerText = "ERRO NO MICROFONE";
        audio.volume = AMBIENT_VOL;
    };
} else {
    console.log("Web Speech API não suportada neste navegador.");
    if (micBtn) micBtn.style.display = "none";
    if (aiStatusText) aiStatusText.innerText = "IA: RECURSO NÃO SUPORTADO";
}

function toggleMic() {
    if (isListening) {
        recognition.stop();
    } else {
        // Tenta iniciar (requer HTTPS ou localhost)
        try {
            recognition.start();
        } catch (e) {
            console.error(e);
            aiStatusText.innerText = "ERRO AO INICIAR MIC";
        }
    }
}

// 2. Enviar para Python Bridge
async function sendToGodzAi(text) {
    try {
        // NOTA: Em produção, substitua 127.0.0.1 pelo IP Real do Servidor se acessado remotamente.
        // Como é Loading Screen, 127.0.0.1 assume que o servidor roda na máquina local (Dev Mode).
        const response = await fetch('http://127.0.0.1:5000/loading_chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ question: text })
        });

        const data = await response.json();
        if (data.response) {
            speakAi(data.response);
        } else {
            speakAi("Não consegui processar sua solicitação.");
        }
    } catch (error) {
        console.error("Erro ao conectar com GODZ AI:", error);
        speakAi("Falha na conexão neural com o servidor.");
    }
}

// 3. Texto para Fala (TTS)
function speakAi(text) {
    if (synth.speaking) {
        console.error('speechSynthesis.speaking');
        return;
    }

    aiStatusText.innerText = "RESPONDENDO...";
    aiAvatar.classList.add("speaking");
    audio.volume = DUCKING_VOL; // Ducking

    const utterThis = new SpeechSynthesisUtterance(text);
    utterThis.lang = 'pt-BR';
    utterThis.pitch = 0.9; // Levemente mais grave e autoritário
    utterThis.rate = 1.0; // Velocidade clara e firme
    utterThis.volume = 1.0; // Destaque total

    // Tentar selecionar uma voz PT-BR Google ou Microsoft
    const voices = synth.getVoices();
    // Prioridade: Microsoft Maria/Daniel (Premium) -> Google -> Default
    const voice = voices.find(v => v.name.includes('Microsoft') && v.lang.includes('pt-BR')) || 
                  voices.find(v => v.lang.includes('pt-BR') && v.name.includes('Google')) || 
                  voices[0];
                  
    if (voice) utterThis.voice = voice;

    utterThis.onend = function (event) {
        console.log('SpeechSynthesisUtterance.onend');
        aiAvatar.classList.remove("speaking");
        aiStatusText.innerText = "GODZ NEXUS: ONLINE";
        audio.volume = AMBIENT_VOL; // Restore volume
    };

    utterThis.onerror = function (event) {
        console.error('SpeechSynthesisUtterance.onerror');
        aiAvatar.classList.remove("speaking");
        audio.volume = AMBIENT_VOL;
    };

    synth.speak(utterThis);
}

// Try auto-play immediately (browsers might block)
window.onload = () => {
    audio.play().catch(e => {
        console.log("Autoplay blocked. User interaction required.");
    });

    // Proactive AI Narration (Explaining Systems)
    setTimeout(() => {
        const introText = "Bem-vindo à GODZ City. Eu sou a Nexus, sua assistente virtual. " +
                          "Enquanto carregamos seus dados, saiba que contamos com proteção anti-DDOS exclusiva, " +
                          "economia balanceada e um sistema de facções dinâmico. " +
                          "Você pode usar seu microfone para me fazer perguntas agora mesmo.";
        speakAi(introText);
    }, 2000);
};

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
