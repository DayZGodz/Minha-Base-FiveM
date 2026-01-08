const { createApp, ref, onMounted } = Vue;

createApp({
    setup() {
        const visible = ref(false);
        const currentApp = ref(null);
        
        // AI App Data
        const aiInput = ref("");
        const isAiThinking = ref(false);
        const aiMessages = ref([]);

        // Contacts App Data
        const contacts = ref([]);
        const showAddContact = ref(false);
        const newContact = ref({ name: "", number: "" });

        // Methods
        const openApp = (appName) => {
            currentApp.value = appName;
            // Scroll chat to bottom if opening AI
            if (appName === 'ai') {
                setTimeout(scrollToBottom, 100);
            }
        };

        const closeApp = () => {
            if (currentApp.value) {
                currentApp.value = null;
            } else {
                // If on home screen, close phone
                closePhone();
            }
        };

        const closePhone = () => {
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({})
            });
        };

        const scrollToBottom = () => {
            const el = document.getElementById('chatArea');
            if (el) el.scrollTop = el.scrollHeight;
        };

        const sendToAi = () => {
            if (!aiInput.value.trim()) return;

            const question = aiInput.value;
            
            // Add user message
            aiMessages.value.push({
                text: question,
                type: 'user'
            });

            aiInput.value = "";
            isAiThinking.value = true;
            scrollToBottom();

            // Send to Client (Lua)
            fetch(`https://${GetParentResourceName()}/askAI`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    question: question
                })
            });
        };

        const addContact = () => {
            if (!newContact.value.name || !newContact.value.number) return;

            fetch(`https://${GetParentResourceName()}/addContact`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify(newContact.value)
            });

            // Optimistic update
            contacts.value.push({ ...newContact.value, id: Date.now() });
            newContact.value = { name: "", number: "" };
            showAddContact.value = false;
        };

        // NUI Message Listener
        window.addEventListener('message', (event) => {
            const data = event.data;

            if (data.type === "toggle") {
                visible.value = data.status;
            }

            if (data.type === "openAI") {
                openApp('ai');
            }

            if (data.type === "aiResponse") {
                isAiThinking.value = false;
                aiMessages.value.push({
                    text: data.text,
                    type: 'ai'
                });
                
                if (data.audio) {
                    try {
                        const audio = new Audio("data:audio/wav;base64," + data.audio);
                        audio.play();
                    } catch (e) {
                        console.error("Erro ao reproduzir áudio da IA:", e);
                    }
                }

                scrollToBottom();
            }

            if (data.type === "updateContacts") {
                contacts.value = data.data;
            }
        });

        // Close on Escape key
        window.addEventListener('keyup', (e) => {
            if (e.key === 'Escape') {
                if (currentApp.value) {
                    currentApp.value = null;
                } else {
                    closePhone();
                }
            }
        });

        return {
            visible,
            currentApp,
            aiInput,
            aiMessages,
            isAiThinking,
            contacts,
            showAddContact,
            newContact,
            openApp,
            closeApp,
            sendToAi,
            addContact
        };
    }
}).mount('#app');
