let selectedCategory = null;

window.addEventListener('message', function(event) {
    if (event.data.action === "open") {
        $('#app').css('display', 'flex');
        loadCategories(event.data.categories);
    } else if (event.data.action === "aiResponse") {
        showAIResponse(event.data.text);
    }
});

document.onkeyup = function(data) {
    if (data.which == 27) {
        closeUI();
    }
};

function closeUI() {
    $('#app').fadeOut(200);
    $('#aiOverlay').fadeOut(200);
    $.post('https://godz_support/close', JSON.stringify({}));
}

function loadCategories(categories) {
    const list = $('#categoryList');
    list.empty();
    
    categories.forEach((cat, index) => {
        const active = index === 0 ? 'active' : '';
        if (index === 0) selectedCategory = cat.id;
        
        list.append(`
            <div class="category-btn ${active}" onclick="selectCategory(this, '${cat.id}')">
                <span>${cat.label}</span>
            </div>
        `);
    });
    
    $('#ticketDescription').val('');
}

function selectCategory(el, id) {
    $('.category-btn').removeClass('active');
    $(el).addClass('active');
    selectedCategory = id;
}

function submitTicket() {
    const desc = $('#ticketDescription').val();
    if (!desc || desc.length < 5) return;
    
    // Show loading state?
    
    $.post('https://godz_support/submit', JSON.stringify({
        category: selectedCategory,
        description: desc
    }));
    
    // Don't close immediately, wait for server response (AI or Success)
}

function showAIResponse(text) {
    $('#aiText').html(text.replace(/\n/g, '<br>'));
    $('#aiOverlay').fadeIn(300);
}

function resolveTicket() {
    $.post('https://godz_support/resolveAI', JSON.stringify({}));
    closeUI();
}

function escalateTicket() {
    $.post('https://godz_support/escalateAI', JSON.stringify({}));
    closeUI(); // Or show "Ticket Sent" message
}
