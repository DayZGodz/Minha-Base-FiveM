$(document).ready(function(){
    window.addEventListener('message', function(event){
        var item = event.data;
        if(item.action == 'notify'){
            var icon = '📌';
            if(item.type == 'sucesso') icon = '✅';
            if(item.type == 'negado') icon = '⛔';
            if(item.type == 'aviso') icon = '⚠️';
            if(item.type == 'azul') icon = '💎';
            if(item.type == 'policia') icon = '👮';
            if(item.type == 'medico') icon = '🚑';

            // Capitalize title if not provided or default
            var title = item.title || 'NOTIFICAÇÃO';

            var html = `
            <div class="notify ${item.type}">
                <div class="icon">${icon}</div>
                <div class="content">
                    <div class="title">${title}</div>
                    <div class="message">${item.message}</div>
                </div>
                <div class="progress"><div class="bar" style="width: 100%; transition: width ${item.time}ms linear;"></div></div>
            </div>`;

            var $notify = $(html);
            $('#notifications').prepend($notify);

            // Force reflow
            $notify[0].offsetHeight;

            setTimeout(function(){
                $notify.find('.bar').css('width', '0%');
            }, 50);

            setTimeout(function(){
                $notify.css('animation', 'slideOut 0.5s ease forwards');
                setTimeout(function(){
                    $notify.remove();
                }, 500);
            }, item.time);
        }
    });
});
