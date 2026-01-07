let currentEntity = null;

window.addEventListener('message', function(event) {
    if (event.data.type === 'targeting') {
        if (event.data.state) {
            $('#eye').removeClass('hidden');
        } else {
            $('#eye').addClass('hidden');
            $('#eye').removeClass('active');
            $('#menu').addClass('hidden');
        }
    } else if (event.data.type === 'foundTarget') {
        $('#eye').addClass('active');
        currentEntity = event.data.entity;
        renderOptions(event.data.options);
        $('#menu').removeClass('hidden');
    } else if (event.data.type === 'lostTarget') {
        $('#eye').removeClass('active');
        $('#menu').addClass('hidden');
        currentEntity = null;
    }
});

function renderOptions(options) {
    let html = '';
    options.forEach((opt, index) => {
        html += `
            <div class="option" onclick="selectOption(${index})">
                <i class="${opt.icon || 'fas fa-circle'}"></i>
                <span>${opt.label}</span>
            </div>
        `;
    });
    $('#options-container').html(html);
    // Store options for click handler
    window.currentOptions = options;
}

function selectOption(index) {
    let opt = window.currentOptions[index];
    if (opt) {
        fetch(`https://${GetParentResourceName()}/select`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                event: opt.event,
                serverEvent: opt.serverEvent,
                entity: currentEntity
            })
        });
    }
}

document.onkeyup = function(data) {
    if (data.which == 27) { // ESC
        fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
        $('#menu').addClass('hidden');
    }
};
