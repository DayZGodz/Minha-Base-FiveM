let currentTarget = null;

window.addEventListener('message', function(event) {
    if (event.data.type === 'open') {
        $('#container').fadeIn(300);
    } else if (event.data.type === 'close') {
        $('#container').fadeOut(300);
        resetUI();
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
};

function resetUI() {
    $('#patient-info').addClass('hidden');
    $('#search-id').val('');
    currentTarget = null;
}

function searchPatient() {
    let id = $('#search-id').val();
    if (!id) return;

    fetch(`https://${GetParentResourceName()}/searchPatient`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: id })
    }).then(resp => resp.json()).then(data => {
        if (data) {
            currentTarget = id;
            $('#p-name').text(data.name);
            $('#p-age').text(data.age + ' anos');
            $('#p-blood').text(data.blood_type);
            
            let historyHtml = '';
            if (data.history && data.history.length > 0) {
                data.history.forEach(h => {
                    let date = new Date(h.date).toLocaleDateString();
                    historyHtml += `<li>
                        <span>${h.action}</span>
                        <span style="opacity:0.7">${date}</span>
                    </li>`;
                });
            } else {
                historyHtml = '<li>Sem histórico recente.</li>';
            }
            $('#history-list').html(historyHtml);
            
            $('#patient-info').removeClass('hidden');
        } else {
            alert('Paciente não encontrado ou sem acesso.');
        }
    });
}

function finishTreatment() {
    if (!currentTarget) return;
    
    fetch(`https://${GetParentResourceName()}/finishTreatment`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: currentTarget })
    }).then(resp => resp.json()).then(success => {
        if (success) {
            // alert('Tratamento finalizado!'); // Not needed if notify is used
            fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
        } else {
            // alert('Erro ao finalizar.');
        }
    });
}
