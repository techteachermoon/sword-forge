// 직업별 DPS 측정: node tools/dps.js [허수아비 수=1] [강화=25]  (먼저 sh tools/mk_test.sh)
// 카드·인챈트·각인 없음, 방어 0 허수아비, 직업마다 8초 × 2회 평균. 랜덤 편차가 있어 여러 번 비교할 것
let pw; try{ pw = require('playwright'); }catch(e){ pw = require('/opt/node-tools/node_modules/playwright'); }
const fs = require('fs'), path = require('path'), N = +(process.argv[2] || 1), LV = +(process.argv[3] || 25);
(async () => { const b = await pw.chromium.launch(fs.existsSync('/opt/pw-browsers/chromium') ? { executablePath: '/opt/pw-browsers/chromium' } : {});
  const pg = await b.newPage(); const errs = []; pg.on('pageerror', e => errs.push(e.message));
  await pg.goto('file://' + path.join(__dirname, 'test.html')); await pg.waitForTimeout(800);
  const out = {}, classes = await pg.evaluate(LV => WORDER.map(l => [l, Math.min(WL[l].to, Math.max(WL[l].from, LV))]), LV);
  for(const [line, lv] of classes){ let tot = 0;
    for(let rep = 0; rep < 2; rep++) tot += await pg.evaluate(async ([line, N, LV]) => {
      S.name = 'bot'; S.opts.sfx = false; S.opts.bgm = false; S.opts.gfx = 'low'; G.scr = 'game'; S.lv = LV; S.line = line; S.ench = {}; S.eng = []; engrSync(); startSurv(1);
      const P = B.P; G.noSpawn = true; B.mons = []; for(let i = 0; i < N; i++){ svSpawn('normal', 'golem'); const m = B.mons[B.mons.length - 1]; m.hp = m.max = 1e14; m.spd = 0; m.dmg = 0; m.ai = 'none'; m.def = 0; m.mdef = 0; m.dummy = 1; m.x = P.x + 26 + (i % 3) * 8; m.y = P.y + (i - N / 2) * 6; m.born = 1; }
      const iv = setInterval(() => { B.mons = B.mons.filter(m => m.dummy); B.P.hp = B.P.max; B.pick = null; }, 30);
      B.dmgDone = 0; const t0 = B.t; await new Promise(r => setTimeout(r, 8000)); clearInterval(iv); const d = B.dmgDone / (B.t - t0); leaveBattle(); return d; }, [line, N, lv]);
    out[line] = Math.round(tot / 2); }
  console.log('허수아비', N, '요청 강화', LV, '실제 단계', JSON.stringify(Object.fromEntries(classes)), JSON.stringify(out), errs.slice(0, 2)); await b.close(); if(errs.length) process.exitCode = 1; })();
