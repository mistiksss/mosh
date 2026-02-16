(function(){
  function qs(sel, root){ return (root||document).querySelector(sel); }
  function qsa(sel, root){ return Array.from((root||document).querySelectorAll(sel)); }

  const wrap = qs('[data-notif-wrap]');
  if(!wrap) return;

  const btn = qs('[data-notif-btn]', wrap);
  const badge = qs('[data-notif-badge]', wrap);
  const panel = qs('[data-notif-panel]', wrap);
  const list = qs('[data-notif-list]', wrap);
  const markAll = qs('[data-notif-markall]', wrap);

  function fmtDate(iso){
    if(!iso) return '';
    try{
      const d = new Date(iso);
      const dd = String(d.getDate()).padStart(2,'0');
      const mm = String(d.getMonth()+1).padStart(2,'0');
      const yy = d.getFullYear();
      const hh = String(d.getHours()).padStart(2,'0');
      const mi = String(d.getMinutes()).padStart(2,'0');
      return `${dd}.${mm}.${yy} ${hh}:${mi}`;
    }catch(e){ return ''; }
  }

  async function fetchList(){
    const r = await fetch('/api/notifications', {credentials:'same-origin'});
    const j = await r.json();
    if(!j.ok) return;
    const items = j.items || [];
    let unread = 0;
    items.forEach(it => { if(!it.is_read) unread += 1; });
    badge.textContent = String(unread);
    badge.style.display = unread>0 ? 'block' : 'none';

    if(items.length === 0){
      list.innerHTML = '<div class="notifEmpty">Нет уведомлений</div>';
      return;
    }

    list.innerHTML = items.map(it => {
      const cls = it.is_read ? 'notifItem' : 'notifItem unread';
      const t = (it.title || 'Уведомление');
      const m = (it.message || '');
      const dt = fmtDate(it.created_at);
      return `<div class="${cls}" data-notif-id="${it.id}">
        <div class="title">${escapeHtml(t)}</div>
        <div class="msg">${escapeHtml(m)}</div>
        <div class="dt">${escapeHtml(dt)}</div>
      </div>`;
    }).join('');
  }

  async function markReadAll(){
    await fetch('/api/notifications/mark_read', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({all:true}),
      credentials:'same-origin'
    });
    await fetchList();
  }

  function escapeHtml(s){
    return String(s)
      .replace(/&/g,'&amp;')
      .replace(/</g,'&lt;')
      .replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;')
      .replace(/'/g,'&#039;');
  }

  function toggle(){
    panel.classList.toggle('open');
    if(panel.classList.contains('open')) fetchList();
  }

  btn.addEventListener('click', function(e){
    e.preventDefault();
    e.stopPropagation();
    toggle();
  });

  markAll && markAll.addEventListener('click', function(e){
    e.preventDefault();
    markReadAll();
  });

  document.addEventListener('click', function(){
    panel.classList.remove('open');
  });

  panel.addEventListener('click', function(e){
    e.stopPropagation();
  });

  const key = 'notif_last_seen_id';
  let lastSeen = parseInt(localStorage.getItem(key) || '0', 10) || 0;
  async function poll(){
    try{
      const r = await fetch('/api/notifications/poll', {credentials:'same-origin'});
      const j = await r.json();
      if(!j.ok || !j.has_new) return;
      const id = parseInt(j.id || 0, 10) || 0;
      if(id && id !== lastSeen){
        lastSeen = id;
        localStorage.setItem(key, String(id));
        const text = (j.title ? (j.title + ': ') : '') + (j.message || '');
        alert(text);
        fetchList();
      }
    }catch(e){
    }
  }
  setInterval(poll, 10000);

  const initial = parseInt(badge.getAttribute('data-initial') || '0', 10) || 0;
  badge.textContent = String(initial);
  badge.style.display = initial>0 ? 'block' : 'none';
})();
