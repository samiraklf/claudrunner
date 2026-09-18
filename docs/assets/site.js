// claudrunner website: theme toggle, copy buttons, heading links, "On this page", search.
// No framework and no build step; every feature degrades to plain HTML without script.
(() => {
  const root = document.documentElement;
  const base = document.querySelector('link[rel="icon"]').getAttribute('href').replace(/assets\/favicon\.svg$/, '');

  // ---- theme: system by default, a click remembers the other one
  document.querySelector('[data-theme-toggle]')?.addEventListener('click', () => {
    const dark = root.dataset.theme ? root.dataset.theme === 'dark' : matchMedia('(prefers-color-scheme: dark)').matches;
    root.dataset.theme = dark ? 'light' : 'dark';
    try { localStorage.setItem('cr-site-theme', root.dataset.theme); } catch (e) {}
  });

  // ---- copy buttons on every code block
  const COPY = '<svg class="icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="14" height="14" x="8" y="8" rx="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>';
  const DONE = '<svg class="icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>';
  document.querySelectorAll('pre').forEach(pre => {
    const wrap = document.createElement('div');
    wrap.className = 'code-wrap';
    pre.replaceWith(wrap); wrap.appendChild(pre);
    const b = document.createElement('button');
    b.type = 'button'; b.className = 'copy'; b.innerHTML = COPY + '<span>Copy</span>';
    b.setAttribute('aria-label', 'Copy to clipboard');
    b.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(pre.innerText.trim());
        b.innerHTML = DONE + '<span>Copied</span>'; b.classList.add('ok');
      } catch (e) { b.innerHTML = '<span>Select and copy</span>'; }
      setTimeout(() => { b.innerHTML = COPY + '<span>Copy</span>'; b.classList.remove('ok'); }, 1800);
    });
    wrap.appendChild(b);
  });

  // ---- heading links and "On this page"
  const prose = document.querySelector('.prose');
  const toc = document.querySelector('.toc');
  if (prose) {
    const heads = [...prose.querySelectorAll('h2[id], h3[id]')];
    heads.forEach(h => {
      const a = document.createElement('a');
      a.className = 'anchor'; a.href = '#' + h.id; a.textContent = '#';
      a.setAttribute('aria-label', 'Link to this section');
      h.appendChild(a);
    });
    const h2s = heads.filter(h => h.tagName === 'H2');
    if (toc && h2s.length >= 3) {
      const list = toc.querySelector('ol');
      h2s.forEach(h => {
        const li = document.createElement('li');
        const a = document.createElement('a');
        a.href = '#' + h.id; a.textContent = h.firstChild.textContent.trim();
        li.appendChild(a); list.appendChild(li);
      });
      toc.hidden = false;
      const links = [...list.querySelectorAll('a')];
      const spy = new IntersectionObserver(entries => {
        entries.forEach(e => {
          if (!e.isIntersecting) return;
          links.forEach(l => l.removeAttribute('aria-current'));
          links.find(l => l.hash === '#' + e.target.id)?.setAttribute('aria-current', 'true');
        });
      }, { rootMargin: '-80px 0px -70% 0px' });
      h2s.forEach(h => spy.observe(h));
    }
  }

  // ---- the docs menu starts folded on a phone, open on a wide screen
  const sideNav = document.querySelector('.side-nav');
  if (sideNav && matchMedia('(max-width: 900px)').matches) sideNav.open = false;

  // ---- search: a small index, loaded the first time it is needed
  const dlg = document.querySelector('dialog.search');
  if (!dlg || typeof dlg.showModal !== 'function') return;
  const input = dlg.querySelector('input');
  const results = dlg.querySelector('.results');
  let index = null;
  const load = () => index || (index = fetch(base + 'search.json').then(r => r.json()).then(d => d.filter(x => x.t)).catch(() => []));
  const esc = s => s.replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
  const snippet = (text, words) => {
    const low = text.toLowerCase();
    let at = -1; for (const w of words) { at = low.indexOf(w); if (at >= 0) break; }
    if (at < 0) return '';
    const s = Math.max(0, at - 50), piece = text.slice(s, at + 110);
    let out = esc((s ? '…' : '') + piece + '…');
    words.forEach(w => { out = out.replace(new RegExp('(' + w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi'), '<mark>$1</mark>'); });
    return out;
  };
  const render = async () => {
    const q = input.value.trim().toLowerCase();
    const data = await load();
    const words = q.split(/\s+/).filter(Boolean);
    const scored = data.map(p => {
      if (!words.length) return { p, s: 0 };
      let s = 0;
      for (const w of words) {
        const t = p.t.toLowerCase(), d = p.d.toLowerCase(), c = p.c.toLowerCase();
        if (!t.includes(w) && !d.includes(w) && !c.includes(w)) return { p, s: -1 };
        s += (t.includes(w) ? 10 : 0) + (d.includes(w) ? 4 : 0) + Math.min(5, c.split(w).length - 1);
      }
      return { p, s };
    }).filter(x => x.s >= 0).sort((a, b) => b.s - a.s).slice(0, 8);
    results.innerHTML = scored.length ? scored.map(({ p }) =>
      `<li><a href="${p.u}"><b>${esc(p.t)}</b><span>${words.length ? snippet(p.c, words) || esc(p.d) : esc(p.d)}</span></a></li>`
    ).join('') : `<li class="none">Nothing found for “${esc(input.value)}”. Try “jira”, “schedule” or “security”.</li>`;
  };
  const open = () => { if (!dlg.open) { dlg.showModal(); input.select(); render(); } };
  document.querySelectorAll('[data-search-open]').forEach(b => b.addEventListener('click', open));
  addEventListener('keydown', e => {
    const typing = /INPUT|TEXTAREA|SELECT/.test(document.activeElement?.tagName || '');
    if ((e.key === '/' && !typing) || (e.key.toLowerCase() === 'k' && (e.metaKey || e.ctrlKey))) { e.preventDefault(); open(); }
  });
  input.addEventListener('input', render);
  dlg.addEventListener('keydown', e => {
    const links = [...results.querySelectorAll('a')];
    const i = links.indexOf(document.activeElement);
    if (e.key === 'ArrowDown') { e.preventDefault(); (links[i + 1] || links[0])?.focus(); }
    if (e.key === 'ArrowUp') { e.preventDefault(); if (i <= 0) input.focus(); else links[i - 1].focus(); }
    if (e.key === 'Enter' && document.activeElement === input && links[0]) { e.preventDefault(); location.href = links[0].href; }
  });
  dlg.addEventListener('click', e => { if (e.target === dlg) dlg.close(); });   // click outside closes
})();
