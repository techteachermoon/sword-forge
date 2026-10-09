// 회귀 테스트: node tools/reg.js  (먼저 sh tools/mk_test.sh). 마지막 줄이 'ERR []' 이면 통과
let pw; try{ pw = require('playwright'); }catch(e){ pw = require('/opt/node-tools/node_modules/playwright'); }
const { chromium } = pw, fs = require('fs');
(async () => {
  const b = await chromium.launch(fs.existsSync('/opt/pw-browsers/chromium') ? { executablePath: '/opt/pw-browsers/chromium' } : {});
  const pg = await b.newPage({ viewport: { width: 540, height: 960 } }); const errs = []; pg.on('pageerror', e => errs.push(e.message));
  await pg.goto('file://' + require('path').join(__dirname, 'test.html')); await pg.waitForTimeout(1000);
  const out = {};
  errs.push(...await pg.evaluate(() => [...validateWeaponTree(), ...validateClassRules()]));
  // full runs on every difficulty (invulnerable bot, only checks the flow)
  out.runs = await pg.evaluate(async () => {
    S.opts.gfx = 'low'; S.name = '봇'; S.opts.sfx = false; S.opts.bgm = false; G.scr = 'game'; const res = [];
    for(const d of ['easy', 'normal', 'hard', 'hell']){
      S.prog[d] = S.prog[d] || { stage: 1, clear: {} }; if(d === 'hard') S.prog.normal.clear[NST] = 1; if(d === 'hell') S.prog.hard.clear[NST] = 1;
      S.opts.diff = d; S.lv = 29; S.line = 'g1'; startBattle(1); let t = 0;
      while(B && !B.over && t < 4000){ if(B.pick){ B.pick.t0 = -10; svPick(B.pick.opts[0]); continue; } B.P.hp = B.P.max; survUpdate(1 / 30); t += 1 / 30; }
      res.push([d, B.over ? B.over.end : 'cap', stLabel(B.s), Math.round(t)]); B.over = B.over || { win: true, end: 'retreat', t: 0 }; leaveBattle();
    }
    // endless to floor 40
    S.lv = 25; S.line = 't2'; startEndless('crit'); let t = 0;
    while(B && !B.over && B.n < 40 && t < 2500){ if(B.pick){ B.pick.t0 = -10; svPick(B.pick.opts[0]); continue; } B.P.hp = B.P.max; survUpdate(1 / 30); t += 1 / 30; }
    res.push(['endless', B.n, Math.round(t), B.kits || 0, (B.rw || []).length]); B.over = { win: false, end: 'dead', t: 0 }; enRecord && enRecord(); leaveBattle();
    return res;
  });
  // 2000 random forge swings with random toggles
  out.forge = await pg.evaluate(() => {
    G.scr = 'game'; G.tab = 'forge'; S.gold = 1e12; S.gh = [0, 500, 500, 50, 5]; S.bls = [0, 5000, 5000, 5000, 5000]; S.rp = 2000; S.lv = 0; S.line = 'c';
    let br = 0, mx = 0, bad = 0;
    for(let i = 0; i < 2000; i++){
      G.modal = null; F.st = 'idle'; G.reveal = null; S.enchPend = 0; S.inhPend = null;
      if(needsJob()) chooseJob(KIDS[S.line || 'c'][0]);
      S.opts.guard = Math.random() < .8; S.opts.bless = Math.random() < .8; S.opts.bareOk = band(S.lv);
      if(Math.random() < .5 && crackN()) repair();
      const L0 = S.lv; startForge(); if(F.st === 'idle') continue;
      F.grade = 'GOOD'; F.st = 'swing'; resolveForge();
      if(F.st === 'broken'){ const L = F.lastL; G.modal = { k: 'destroy', L, id: F.lastId, sg: 0, stg: 0 }; destroyChoose(false); br++; F.st = 'idle'; F.hidden = false; }
      if(G.modal && G.modal.k === 'inherit') inheritDone([]);
      if(G.modal && G.modal.k === 'job') chooseJob(KIDS[S.line || 'c'][0]);
      mx = Math.max(mx, S.lv);
      if(!(S.lv >= 0 && S.lv <= MAX) || !Number.isFinite(S.gold) || S.gold < 0 || !Number.isFinite(S.crack) || S.crack < 0 || !Number.isFinite(S.sh) || S.sh < 0 || S.breakPend) bad++;
    }
    return { breaks: br, maxLv: mx, bad, gh: S.gh, best: S.best };
  });
  for(const r of out.runs) if(r[0] === 'endless' ? r[1] < 40 : r[1] !== 'all' || r[2] !== '6-3') errs.push('flow: ' + JSON.stringify(r));
  if(out.forge.bad !== 0) errs.push('forge: ' + out.forge.bad + ' invalid states');
  console.log(JSON.stringify(out)); console.log('ERR', errs); await b.close(); if(errs.length) process.exitCode = 1;
})();
