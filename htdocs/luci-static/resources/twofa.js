'use strict';
'require ui';
'require rpc';

// 确保在 DOM 加载完成后执行，兼容不同的 LuCI 版本加载机制
// 注意：luci-loaded 事件可能在脚本加载前已经触发，所以直接执行 check
// 或者使用 window.onload 作为后备

function initTwoFA() {
    // 避免重复初始化
    if (window._twofa_initialized) return;
    window._twofa_initialized = true;

    function check() {
        // 检查 L 对象是否存在，这是 LuCI JS 框架的核心
        if (typeof L === 'undefined' || !L.sessionid) {
            // 如果 L 未就绪，稍后重试
            setTimeout(check, 500);
            return;
        }

        // 增加错误处理，避免 uci/get 失败导致脚本崩溃
        L.Request.get(L.url('admin/services/twofa/status'), null, function(xhr, data) {
            if (xhr.status !== 200) {
                console.warn("2FA status check failed:", xhr.status);
                return;
            }
            if (data && data.enabled && !data.verified) {
                show();
            }
        });
    }

    function show() {
        if (document.getElementById('twofa-lock')) return;
        
        // 使用更通用的 DOM 创建方式，防止 E 函数不可用
        var body = document.createElement('div');
        body.className = 'cbi-map';
        body.innerHTML = '<p>Please enter your 6-digit TOTP code.</p>' +
                         '<input type="text" id="twofa-token" class="cbi-input-text" style="width:100%;text-align:center;font-size:20px;" autocomplete="off" />';

        // 尝试使用 ui.showModal，如果失败则回退到简单的 alert/prompt 或者自定义遮罩
        if (ui && ui.showModal) {
            ui.showModal('2FA Verification', body);
        } else {
            console.error("LuCI ui library not found");
            return;
        }

        var m = document.querySelector('.modal');
        if (m) { 
            m.id = 'twofa-lock'; 
            m.style.zIndex = "9999"; // 提高层级
            var closeBtn = m.querySelector('.close');
            if (closeBtn) closeBtn.style.display = 'none'; 
        }
        
        var input = document.getElementById('twofa-token');
        if (input) {
            input.focus();
            input.onkeypress = function(e){ if(e.key === 'Enter') verify(); };
        }

        var btn = document.querySelector('.modal .cbi-button-primary') || document.querySelector('.modal .cbi-button-apply') || document.querySelector('.modal .btn-primary');
        if(btn) btn.onclick = verify;
    }

    function verify() {
        var input = document.getElementById('twofa-token');
        if (!input) return;
        var t = input.value;
        
        L.Request.post(L.url('admin/services/twofa/verify'), {token: t}, function(xhr, data) {
            if (data && data.success) { 
                if (ui && ui.hideModal) ui.hideModal(); 
                location.reload(); 
            } else { 
                alert('Invalid Code'); 
                input.value = ''; 
                input.focus();
            }
        });
    }

    check();
}

// 尝试多种方式挂载
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTwoFA);
} else {
    initTwoFA();
}
