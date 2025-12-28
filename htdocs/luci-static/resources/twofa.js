'use strict';
'require ui';
'require rpc';

document.addEventListener('luci-loaded', function() {
    function check() {
        if (!L.sessionid) return;
        L.Request.get(L.url('admin/services/twofa/status'), null, function(xhr, data) {
            if (data && data.enabled && !data.verified) show();
        });
    }

    function show() {
        if (document.getElementById('twofa-lock')) return;
        var body = E('div', {'class': 'cbi-map'}, [
            E('p', {}, 'Please enter your 6-digit TOTP code.'),
            E('input', {'type': 'text', 'id': 'twofa-token', 'class': 'cbi-input-text', 'style': 'width:100%;text-align:center;font-size:20px;'})
        ]);
        ui.showModal('2FA Verification', body);
        var m = document.querySelector('.modal');
        if (m) { m.id = 'twofa-lock'; m.style.zIndex = "3000"; m.querySelector('.close').style.display = 'none'; }
        document.getElementById('twofa-token').focus();
        document.getElementById('twofa-token').onkeypress = function(e){ if(e.key === 'Enter') verify(); };
        var btn = document.querySelector('.modal .cbi-button-primary') || document.querySelector('.modal .cbi-button-apply');
        if(btn) btn.onclick = verify;
    }

    function verify() {
        var t = document.getElementById('twofa-token').value;
        L.Request.post(L.url('admin/services/twofa/verify'), {token: t}, function(xhr, data) {
            if (data.success) { ui.hideModal(); location.reload(); }
            else { alert('Invalid Code'); document.getElementById('twofa-token').value = ''; }
        });
    }

    check();
});
