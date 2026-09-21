// Live-Prüfung mit ZWEI echten Browsern (Chromium, z. B. Brave oder Chrome): Rick beobachtet, Morty
// handelt. Geprüft wird, dass sich Ricks Seite von selbst ändert, ohne neu geladen zu werden, und dass
// Morty seine eigene Bestätigungsmeldung behält.
//
// Voraussetzungen: Node 22 oder neuer, ein Chromium-Browser, Entwicklungsserver läuft (bin/dev) und die
// Demo-Daten sind frisch geladen (bin/rails db:seed): Morty hat keine Reservierung im Nacht-Portal.
// Der Test reserviert und storniert dort und schreibt dabei Einträge ins Protokoll.
//
//   node script/live_check.mjs
//   BROWSER="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" node script/live_check.mjs

import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const BASE = process.env.BASE_URL || 'http://localhost:3000';
const BROWSER = process.env.BROWSER || '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const results = [];
const check = (name, ok, detail = '') => { results.push(ok); console.log(`${ok ? 'OK  ' : 'FAIL'} ${name}${detail ? '  [' + detail + ']' : ''}`); };

// Ein Browser mit eigenem Profil, damit Rick und Morty getrennte Sitzungen haben.
class Person {
  constructor(name, port) { this.name = name; this.port = port; this.id = 1; this.pending = new Map(); this.dir = mkdtempSync(join(tmpdir(), `live-${name}-`)); }
  async start() {
    this.proc = spawn(BROWSER, ['--headless=new', '--disable-gpu', `--remote-debugging-port=${this.port}`, `--user-data-dir=${this.dir}`, '--no-first-run', '--window-size=1280,900', 'about:blank'], { stdio: 'ignore' });
    for (let i = 0; i < 40; i++) {
      try {
        const page = (await (await fetch(`http://127.0.0.1:${this.port}/json`)).json()).find(t => t.type === 'page');
        if (page) { this.ws = new WebSocket(page.webSocketDebuggerUrl); await new Promise((ok, no) => { this.ws.onopen = ok; this.ws.onerror = no; }); break; }
      } catch {}
      await sleep(250);
    }
    this.ws.onmessage = m => {
      const d = JSON.parse(m.data);
      if (d.id && this.pending.has(d.id)) { this.pending.get(d.id)(d.result ?? d.error); this.pending.delete(d.id); }
      if (d.method === 'Page.javascriptDialogOpening') this.send('Page.handleJavaScriptDialog', { accept: true });
    };
    await this.send('Page.enable');
  }
  send(method, params = {}) { return new Promise(res => { const i = this.id++; this.pending.set(i, res); this.ws.send(JSON.stringify({ id: i, method, params })); }); }
  async ev(expr) { return (await this.send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true })).result?.value; }
  async goto(path) { await this.send('Page.navigate', { url: BASE + path }); await sleep(1000); }
  async login(user) {
    await this.goto('/session/new');
    await this.ev(`document.querySelector('input[name=email_address]').value='${user}@portalhub.test'; document.querySelector('input[name=password]').value='wubba-lubba'; document.querySelector('form input[type=submit]').click()`);
    await sleep(1000);
  }
  // Wartet, bis der Ausdruck etwas Wahres liefert, und meldet, wie lange es gedauert hat.
  async waitFor(expr, ms = 6000) {
    const start = Date.now();
    while (Date.now() - start < ms) { const v = await this.ev(expr); if (v) return { value: v, took: Date.now() - start }; await sleep(100); }
    return { value: null, took: ms };
  }
  async stop() { try { this.ws.close(); } catch {} this.proc?.kill(); await sleep(400); rmSync(this.dir, { recursive: true, force: true }); }
}

const freeSeats = `(() => { const row = [...document.querySelectorAll('main li')].find(r => r.querySelector('h2')?.textContent.trim() === 'Nacht-Portal'); const m = row?.textContent.match(/(\\d+) von (\\d+) Plätzen frei/); return m ? Number(m[1]) : null })()`;
const logRows = `document.querySelectorAll('tbody tr').length`;
const rick = new Person('rick', 9335), morty = new Person('morty', 9336);

async function mortyReserves() {
  await morty.goto('/');
  await morty.ev(`[...document.querySelectorAll('main li')].find(r => r.querySelector('h2').textContent.trim()==='Nacht-Portal').querySelector('a').click()`); await sleep(900);
  await morty.ev(`document.querySelector('form[action$="/bookings"] button').click()`);
}
async function mortyCancels() {
  await morty.goto('/bookings');
  await morty.ev(`[...document.querySelectorAll('main li')].find(r => r.querySelector('h2').textContent.trim()==='Nacht-Portal').querySelector('form[data-turbo-confirm] button').click()`);
}

try {
  await rick.start(); await morty.start();
  await rick.login('rick'); await morty.login('morty');

  // ---- A: Ricks Übersicht folgt Mortys Reservierung, ohne neu zu laden
  await rick.goto('/');
  await rick.ev(`window.__samePage = 'ja'`);
  const before = await rick.ev(freeSeats);
  check('Rick sieht das Nacht-Portal in der Übersicht', Number.isInteger(before), `${before} Plätze frei`);

  await mortyReserves();
  const down = await rick.waitFor(`(${freeSeats}) === ${before - 1}`);
  check('Ricks Übersicht zeigt Mortys Reservierung von selbst', !!down.value, `${before} -> ${before - 1} nach ${down.took} ms`);
  check('Ricks Seite wurde dabei nicht neu geladen', (await rick.ev(`window.__samePage`)) === 'ja');
  await sleep(1500);
  check('Morty behält seine Bestätigungsmeldung', /Platz reserviert/.test(await morty.ev(`document.querySelector('.flash--notice')?.textContent || ''`)));

  // ---- B: und die Stornierung
  await mortyCancels();
  const up = await rick.waitFor(`(${freeSeats}) === ${before}`);
  check('Ricks Übersicht zeigt auch die Stornierung von selbst', !!up.value, `${before - 1} -> ${before} nach ${up.took} ms`);
  check('Ricks Seite wurde wieder nicht neu geladen', (await rick.ev(`window.__samePage`)) === 'ja');

  // ---- C: das Protokoll bekommt neue Zeilen live
  await rick.goto('/admin/activities');
  await rick.ev(`window.__samePage = 'ja'`);
  const rowsBefore = await rick.ev(logRows);
  await mortyReserves();
  const more = await rick.waitFor(`${logRows} > ${rowsBefore}`);
  check('Ricks Protokoll zeigt Mortys Aktion von selbst', !!more.value, `${rowsBefore} -> ${await rick.ev(logRows)} Zeilen nach ${more.took} ms`);
  check('Das Protokoll wurde nicht neu geladen', (await rick.ev(`window.__samePage`)) === 'ja');
  await mortyCancels(); await sleep(1500);

  // ---- D: Rick löscht Mortys Reservierung, Morty sieht es live
  await mortyReserves(); await sleep(1500);
  await morty.goto('/bookings');
  await morty.ev(`window.__samePage = 'ja'`);
  await rick.goto('/admin/portals');
  const nachtId = await rick.ev(`(() => { const r=[...document.querySelectorAll('tbody tr')].find(x=>x.querySelector('th').textContent.trim()==='Nacht-Portal'); return r.querySelector('a[href$="/bookings"]').getAttribute('href') })()`);
  await rick.goto(nachtId);
  await rick.ev(`[...document.querySelectorAll('tbody tr')].find(r=>r.textContent.includes('Morty Smith')).querySelector('form[data-turbo-confirm] button').click()`);
  const gone = await morty.waitFor(`![...document.querySelectorAll('main h2')].some(h => h.textContent.trim()==='Nacht-Portal')`);
  check('Mortys Liste verliert die Reservierung, die Rick storniert hat, von selbst', !!gone.value, `nach ${gone.took} ms`);
  check('Mortys Seite wurde dabei nicht neu geladen', (await morty.ev(`window.__samePage`)) === 'ja');

  // ---- E: Formulare hören nicht zu
  await rick.goto('/admin/portals');
  await rick.ev(`[...document.querySelectorAll('tbody tr')].find(r=>r.querySelector('th').textContent.trim()==='Nacht-Portal').querySelector('a[href$="/edit"]').click()`); await sleep(900);
  await rick.ev(`document.querySelector('input[name="portal[name]"]').value = 'Halb getippt'`);
  await mortyReserves(); await sleep(2500);
  check('Ein offenes Formular bleibt unangetastet, während sich anderswo etwas ändert', (await rick.ev(`document.querySelector('input[name="portal[name]"]')?.value`)) === 'Halb getippt');
  await mortyCancels(); await sleep(800);
} catch (e) {
  console.log('ABBRUCH:', e.message); results.push(false);
} finally {
  const failed = results.filter(ok => !ok).length;
  console.log(`\n${results.length - failed} von ${results.length} Prüfungen bestanden`);
  await rick.stop(); await morty.stop();
  process.exit(failed ? 1 : 0);
}
