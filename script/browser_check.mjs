// Browser-Prüfung mit echtem JavaScript (Chromium-Browser wie Chrome oder Brave), gesteuert über das
// DevTools-Protokoll. Prüft Reservieren, Stornieren und Löschen mit den echten Bestätigungsdialogen,
// die Meldungen, die Abweisung eines Reisenden im Admin-Bereich und dass keine JavaScript-Fehler auftreten.
//
// Voraussetzungen: Node 22 oder neuer, ein Chromium-Browser, der Entwicklungsserver läuft (bin/dev) und
// die Demo-Daten sind geladen. Der Test VERÄNDERT die Entwicklungsdaten (er löscht das Cronenberg-Portal):
// danach `bin/rails db:seed` ausführen.
//
//   node script/browser_check.mjs
//   BROWSER="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" node script/browser_check.mjs
import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const BASE = process.env.BASE_URL || 'http://localhost:3000', PORT = 9333;
const BRAVE = process.env.BROWSER || '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser';
const userDir = mkdtempSync(join(tmpdir(), 'brave-'));
const proc = spawn(BRAVE, ['--headless=new', '--disable-gpu', `--remote-debugging-port=${PORT}`, `--user-data-dir=${userDir}`,
  '--no-first-run', '--no-default-browser-check', 'about:blank'], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
const results = [], jsErrors = [], dialogs = [];
const check = (name, ok, detail = '') => { results.push({ name, ok }); console.log(`${ok ? 'OK  ' : 'FAIL'} ${name}${detail ? '  [' + detail + ']' : ''}`); };

let ws, nextId = 1, dialogPlan = 'accept'; const pending = new Map();
async function connect() {
  for (let i = 0; i < 40; i++) { try { const t = await (await fetch(`http://127.0.0.1:${PORT}/json`)).json(); const page = t.find(x => x.type === 'page'); if (page) { ws = new WebSocket(page.webSocketDebuggerUrl); await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; }); return; } } catch {} await sleep(250); }
  throw new Error('Brave nicht erreichbar');
}
const send = (method, params = {}) => new Promise(res => { const id = nextId++; pending.set(id, res); ws.send(JSON.stringify({ id, method, params })); });
function wire() {
  ws.onmessage = async ev => {
    const m = JSON.parse(ev.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result ?? m.error); pending.delete(m.id); return; }
    if (m.method === 'Page.javascriptDialogOpening') { dialogs.push({ type: m.params.type, message: m.params.message }); send('Page.handleJavaScriptDialog', { accept: dialogPlan === 'accept' }); }
    if (m.method === 'Runtime.exceptionThrown') jsErrors.push(m.params.exceptionDetails?.exception?.description || m.params.exceptionDetails?.text);
    if (m.method === 'Log.entryAdded' && m.params.entry.level === 'error' && !/favicon|icon\.(png|svg)/.test(m.params.entry.url || '') ) jsErrors.push(m.params.entry.text);
  };
}
const ev = async expr => (await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true })).result?.value;
const goto = async path => { await send('Page.navigate', { url: BASE + path }); await sleep(900); };
async function login(user) {
  await send('Network.clearBrowserCookies'); await goto('/session/new');
  await ev(`document.querySelector('input[name=email_address]').value='${user}@portalhub.test'; document.querySelector('input[name=password]').value='wubba-lubba'; document.querySelector('form input[type=submit]').click()`);
  await sleep(1000);
}
const rows = () => ev(`document.querySelectorAll('main li').length`);
const rowNames = () => ev(`[...document.querySelectorAll('main h2')].map(h=>h.textContent.trim())`);
const flash = sel => ev(`document.querySelector('${sel}')?.textContent.trim() || ''`);
const clickIn = (rowSel, titleSel, title, btnSel) => ev(`(()=>{ const r=[...document.querySelectorAll('${rowSel}')].find(x=>x.querySelector('${titleSel}').textContent.trim()==='${title}'); const b=r?.querySelector('${btnSel}'); if(!b) return false; b.click(); return true; })()`);

try {
  await connect(); wire();
  await send('Page.enable'); await send('Runtime.enable'); await send('Log.enable'); await send('Network.enable');

  // --- Reisender Morty
  await login('morty'); await goto('/bookings');
  check('Turbo ist im Browser geladen', await ev(`typeof window.Turbo === 'object'`));
  const before = await rows();

  // Reservieren (kein Dialog), landet auf Meine Reservierungen mit Meldung
  await goto('/');
  await ev(`[...document.querySelectorAll('main li')].find(r=>r.querySelector('h2').textContent.trim()==='Nacht-Portal').querySelector('a').click()`); await sleep(900);
  dialogs.length = 0;
  await ev(`document.querySelector('form[action$="/bookings"] button').click()`); await sleep(1200);
  check('Reservieren ohne Rückfrage, Weiterleitung auf Meine Reservierungen', (await ev('location.pathname')) === '/bookings' && dialogs.length === 0);
  check('Meldung "Platz reserviert" erscheint', /Platz reserviert/.test(await flash('.flash--notice')), await flash('.flash--notice'));
  check('neue Reservierung steht in der Liste', (await rowNames()).includes('Nacht-Portal') && (await rows()) === before + 1);

  // Stornieren: Rückfrage ABBRECHEN -> nichts wird gelöscht
  dialogs.length = 0; dialogPlan = 'dismiss'; const n = await rows();
  await clickIn('main li', 'h2', 'Nacht-Portal', 'form[data-turbo-confirm] button'); await sleep(1000);
  check('Stornieren fragt zuerst nach (echter Dialog)', dialogs.length === 1 && dialogs[0].type === 'confirm', dialogs[0]?.message);
  check('Dialog nennt das Portal', /Nacht-Portal/.test(dialogs[0]?.message || ''));
  check('Abbrechen im Dialog löscht nichts', (await rows()) === n && (await rowNames()).includes('Nacht-Portal'));

  // Stornieren: Rückfrage BESTÄTIGEN -> gelöscht
  dialogs.length = 0; dialogPlan = 'accept';
  await clickIn('main li', 'h2', 'Nacht-Portal', 'form[data-turbo-confirm] button'); await sleep(1200);
  check('Bestätigen im Dialog löscht die Reservierung', (await rows()) === n - 1 && !(await rowNames()).includes('Nacht-Portal'));
  check('Meldung "Reservierung storniert" erscheint', /Reservierung storniert/.test(await flash('.flash--notice')));
  check('abgeflogenes Portal hat keinen Stornieren-Button', await ev(`![...document.querySelectorAll('main li')].find(r=>r.querySelector('h2').textContent.trim()==='Gestern-Portal')?.querySelector('button')`));

  // --- Berechtigung: Reisender auf Admin-Seite
  await goto('/admin/portals');
  check('Reisender wird von /admin/portals abgewiesen', (await ev('location.pathname')) === '/' && /Berechtigung fehlt/.test(await flash('.flash--alert')));

  // --- Admin Rick
  await login('rick'); await goto('/admin/portals');
  const booked = await ev(`[...document.querySelectorAll('tbody tr')].find(r=>r.querySelector('th').textContent.trim()==='Morgen-Portal').querySelectorAll('td')[3].textContent.trim()`);
  dialogs.length = 0; dialogPlan = 'dismiss'; const portalsBefore = await ev(`document.querySelectorAll('tbody tr').length`);
  await clickIn('tbody tr', 'th', 'Morgen-Portal', 'form[data-turbo-confirm] button'); await sleep(900);
  check('Löschen fragt zuerst nach und nennt die Anzahl Reservierungen', dialogs.length === 1 && new RegExp(`Es gibt ${booked} Reservierung`).test(dialogs[0].message), dialogs[0]?.message);
  check('Abbrechen im Dialog löscht das Portal nicht', (await ev(`document.querySelectorAll('tbody tr').length`)) === portalsBefore);
  dialogs.length = 0; dialogPlan = 'accept';
  await clickIn('tbody tr', 'th', 'Cronenberg-Express', 'form[data-turbo-confirm] button'); await sleep(1200);
  check('Bestätigen im Dialog löscht das Portal', (await ev(`document.querySelectorAll('tbody tr').length`)) === portalsBefore - 1 && /Portal gelöscht/.test(await flash('.flash--notice')), await flash('.flash--notice'));

  // --- Benutzerverwaltung, Profil, Protokoll (als Rick)
  await goto('/admin/users');
  const bethBookings = await ev(`[...document.querySelectorAll('tbody tr')].find(r=>r.querySelector('th').textContent.trim()==='Beth Smith').querySelectorAll('td')[2].textContent.trim()`);
  const usersBefore = await ev(`document.querySelectorAll('tbody tr').length`);
  dialogs.length = 0; dialogPlan = 'dismiss';
  await clickIn('tbody tr', 'th', 'Beth Smith', 'form[data-turbo-confirm] button'); await sleep(900);
  check('Benutzer löschen fragt zuerst nach und nennt die Reservierungen', dialogs.length === 1 && /Benutzer Beth Smith wirklich löschen/.test(dialogs[0].message) && new RegExp(`Es gibt ${bethBookings} Reservierung`).test(dialogs[0].message), dialogs[0]?.message);
  check('Abbrechen im Dialog löscht den Benutzer nicht', (await ev(`document.querySelectorAll('tbody tr').length`)) === usersBefore);
  check('das eigene Konto hat keinen Löschen-Button', await ev(`![...document.querySelectorAll('tbody tr')].find(r=>r.querySelector('th').textContent.trim()==='Rick Sanchez').querySelector('button')`));
  await goto('/profile');
  check('Profil zeigt die eigenen Daten', (await ev(`document.querySelector('input[name="user[name]"]')?.value`)) === 'Rick Sanchez');
  await goto('/admin/activities');
  check('Protokoll zeigt die bisherigen Aktionen', (await ev(`document.querySelectorAll('tbody tr').length`)) > 0 && /storniert|gelöscht/.test(await ev(`document.querySelector('tbody').textContent`)));

  check('keine JavaScript-Fehler in der Konsole', jsErrors.length === 0, jsErrors.join(' | '));
} catch (e) { console.log('ABBRUCH:', e.message); results.push({ name: 'Ablauf', ok: false }); }
finally {
  const failed = results.filter(r => !r.ok).length; console.log(`\n${results.length - failed} von ${results.length} Prüfungen bestanden`);
  try { ws?.close(); } catch {} proc.kill(); await sleep(500); rmSync(userDir, { recursive: true, force: true }); process.exit(failed ? 1 : 0);
}
