<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8" />
<title>剧情游戏 - 多章节</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
<style>
*{ box-sizing:border-box; }
body{ margin:0; background:#000; color:#e5e7eb; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif; overflow:hidden; }

.bg{ position:fixed; inset:0; z-index:0; background:#000; }
#bgVideo{ position:absolute; inset:0; width:100%; height:100%; object-fit:cover; background:#000; }
.shade{ position:absolute; inset:0; background:linear-gradient(to bottom, rgba(0,0,0,0.04), rgba(0,0,0,0.30)); }

.chapter{
  position:fixed; top:18px; left:18px; z-index:4;
  font-weight:900; font-size:30px; letter-spacing:0.08em;
  color:#e5e7eb; text-shadow:0 6px 22px rgba(0,0,0,0.65);
}
.chapter small{ display:block; font-size:14px; opacity:0.75; letter-spacing:0.15em; margin-top:2px; }

.hud{
  position:fixed; top:14px; right:14px; z-index:4;
  display:flex; gap:10px; align-items:center;
  padding:10px 14px; border-radius:14px;
  background:rgba(15,23,42,.55);
  border:1px solid rgba(148,163,184,.35);
  backdrop-filter:blur(10px);
}
.scoreBox, .timerBox{ font-size:13px; }

button{
  cursor:pointer; border:none; border-radius:999px;
  padding:6px 12px; font-size:13px; color:#fff; background:#2563eb;
}
button.secondary{ background:rgba(15,23,42,.7); border:1px solid rgba(148,163,184,.35); }

.gate{
  position:fixed; inset:0; z-index:6;
  display:flex; justify-content:center; align-items:center;
  background:rgba(0,0,0,.55);
}
.gateCard{
  width:min(560px,92vw);
  border-radius:18px; padding:20px;
  background:rgba(15,23,42,.86);
  border:1px solid rgba(148,163,184,.35);
  text-align:center;
}
.gateCard h2{ margin:0 0 10px; }

.imgLayer{
  position:fixed; inset:0; z-index:5;
  display:none; justify-content:center; align-items:center;
  background:rgba(0,0,0,.45);
}
.imgStage{
  position:relative;
  width:min(1100px,96vw);
  aspect-ratio:2048/1152;
  background:#000;
  border-radius:14px;
  overflow:hidden;
}
.imgStage img{ position:absolute; inset:0; width:100%; height:100%; object-fit:contain; }
.hotspot{ position:absolute; cursor:pointer; }

.toast{
  position:fixed; left:50%; bottom:18px; transform:translateX(-50%);
  z-index:7;
  background:rgba(15,23,42,.72);
  border:1px solid rgba(148,163,184,.35);
  backdrop-filter:blur(10px);
  padding:10px 12px;
  border-radius:12px;
  font-size:13px;
  display:none;
}
</style>
</head>
<body>

<div class="bg">
  <video id="bgVideo" playsinline muted preload="auto"></video>
  <div class="shade"></div>
</div>

<div class="chapter" id="chapterTitle">
  第一章 · 初逢
  <small id="chapterEn">THE FIRST MEETING</small>
</div>

<div class="hud">
  <div class="scoreBox">积分：<b id="score">0</b></div>
  <div class="timerBox">用时：<b id="timer">00:00</b></div>
  <button id="btnReset" class="secondary">重置</button>
</div>

<div class="imgLayer" id="imgLayer">
  <div class="imgStage" id="imgStage">
    <img id="qImg" src="" alt="question"/>
  </div>
</div>

<div class="gate" id="gate">
  <div class="gateCard">
    <h2 id="gateH2">开始第 1 章</h2>
    <button id="btnStart">开始 ▶</button>
  </div>
</div>

<div class="toast" id="toast"></div>
<audio id="bgm" loop preload="auto"></audio>

<script>
const STORE = "wedding_game_v2";

/**
 * ⚠️ 重要：上线到 GitHub Pages / Cloudflare（Linux）会区分大小写。
 * 下面我统一用了小写 .mp4 / .png / .mp3。
 * 你需要把真实文件名也统一成小写，否则会 404。
 */
const CHAPTERS = [
  {
    id: "ch1",
    title: "第一章 · 初逢",
    en: "The First Meeting",
    bgm: "bgm_ch1.mp3",
    videos: [
      "chufeng_merge.mp4",
      "cuoyiban1.mp4"
    ],
    questions: [
      {
        id: "q_trash_sell",
        after: "chufeng_merge.mp4",
        img: "xuanbanzhang.png",
        aspect: "2048/1152",
        hotspots: [
          // 你可按需改成你自己的 right/wrong 视频名
          { score: 0,  left:10, top:63, width:36, height:18, nextVideo: "wrong_selection.mp4" },
          { score: 15, left:55, top:63, width:36, height:18, nextVideo: "right_selection.mp4" }
        ]
      }
    ],
    nextChapterId: "ch2"
  },

  {
    id: "ch2",
    title: "第二章 · 相识",
    en: "Getting to Know You",
    bgm: "bgm_ch2.mp3",
    videos: [
      "mailaji.mp4",
      "liulian.mp4",
      "langsong.mp4"
    ],
    questions: [
      {
        id: "q_ch2_1",
        after: "mailaji.mp4",
        img: "trash_selling1.png",
        aspect: "2048/1152",
        hotspots: [
          { score: 0,  left:10, top:63, width:36, height:18, nextVideo: "wrong_selection.mp4" },
          { score: 15, left:55, top:63, width:36, height:18, nextVideo: "right_selection.mp4" }
        ]
      }
    ],
    nextChapterId: "ch3"
  },

  {
    id: "ch3",
    title: "第三章 · 各行",
    en: "Finding Our Own Paths",
    bgm: "bgm_ch3.mp3",
    videos: [ "gexing_merge.mp4","gexing_merge1.mp4" ,"zaihui1.mp4"],
    questions: [
      {
        id: "q_ch3_1_work",
        after: "gexing_merge.mp4",
        img: "gongzuo.png",
        aspect: "2048/1188",
        hotspots: [
          { score: 0,  left:52.0, top:44.0, width:10.0, height:18.0, nextVideo: "wrong_selection.mp4" }, // A
          { score: 10, left:63.5, top:44.0, width:10.0, height:18.0, nextVideo: "right_selection.mp4" }, // B
          { score: 0,  left:75.5, top:44.0, width:10.0, height:18.0, nextVideo: "wrong_selection.mp4" }  // C
        ]
      }
    ],
    nextChapterId: "ch4"
  },

  {
    id: "ch4",
    title: "第四章 · 再会",
    en: "Reunion",
    bgm: "bgm_ch4.mp3",
    videos: [
      "zaihui_merge.mp4",
      "zaihui5.mp4"
    ],
    questions: [
      {
        id: "q_ch4_beibao",
        after: "zaihui_merge.mp4",
        img: "beibao.png",
        aspect: "2048/1143",
        hotspots: [
          { score: 0,  left:  4.3, top: 73.8, width: 12.4, height: 25.6, nextVideo: "wrong_selection.mp4" }, // A
          { score: 0,  left: 24.2, top: 73.9, width: 12.3, height: 25.5, nextVideo: "wrong_selection.mp4" }, // B
          { score: 0, left: 43.8, top: 73.9, width: 12.3, height: 25.5, nextVideo: "wrong_selection.mp4" }, // C
          { score: 30,  left: 62.7, top: 73.9, width: 12.3, height: 25.5, nextVideo: "right_selection.mp4" }, // D
          { score: 0,  left: 81.0, top: 73.9, width: 11.9, height: 25.5, nextVideo: "wrong_selection.mp4" }  // E
        ]
      }
    ],
    nextChapterId: "ch5"
  },

  {
    id: "ch5",
    title: "第五章 · 向前",
    en: "Moving Forward",
    bgm: "bgm_ch5.mp3",
    videos: [
      "xiangqian_merge.mp4",
      "xiangqian5.mp4"
    ],
    questions: [
      {
        id: "q_ch5_xiangqian_guess",
        after: "xiangqian_merge.mp4",
        img: "yaoshi.png",
        aspect: "2048/1152",
        hotspots: [
          { score: 0,  left: 0,  top: 0, width: 50, height: 100, nextVideo: "wrong_selection.mp4" }, // A：男生
          { score: 30, left: 50, top: 0, width: 50, height: 100, nextVideo: "right_selection.mp4" }  // B：女生
        ]
      }
    ],
    nextChapterId: "ch6"
  },

  {
    id: "ch6",
    title: "第六章 · 经年",
    en: "Years Apart",
    bgm: "bgm_ch6.mp3",
    videos: [
      "jingnian_merge.mp4"
    ],
    questions: [],
    nextChapterId: "ch7"
  },

  {
    id: "ch7",
    title: "第七章 · 此刻",
    en: "This Moment",
    bgm: "bgm_ch7.mp3",
    videos: [ "cike1.mp4","cike2.mp4" ],
    questions: [],
    nextChapterId: null
  }
];

/* DOM */
const bgVideo = document.getElementById("bgVideo");
const bgm = document.getElementById("bgm");
const scoreEl = document.getElementById("score");
const timerEl = document.getElementById("timer");

const chapterTitle = document.getElementById("chapterTitle");
const chapterEn = document.getElementById("chapterEn");

const gate = document.getElementById("gate");
const gateH2 = document.getElementById("gateH2");

const imgLayer = document.getElementById("imgLayer");
const imgStage = document.getElementById("imgStage");
const qImg = document.getElementById("qImg");

const toast = document.getElementById("toast");

/* 状态 */
let curChapter = null;
let curVideoIndex = 0;

// endHandled：防重复处理 ended
let endHandled = false;

// blockEnd：题图打开/关闭过程中，禁止 handleEnd 再跑
let blockEnd = false;

// ===== 分支插播（答题后插入一段视频，再回到主线）=====
let injectedActive = false;
let injectedReturnIndex = 0;

function playInjected(videoName, returnIndex){
  injectedActive = true;
  injectedReturnIndex = returnIndex;

  // 插播视频也要重置 ended 防抖
  blockEnd = false;
  endHandled = false;

  bgVideo.src = videoName;
  bgVideo.load();
}

/* storage */
function get(k){ return localStorage.getItem(`${STORE}:${k}`); }
function set(k,v){ localStorage.setItem(`${STORE}:${k}`, String(v)); }
function loadScore(){ return Number(get("score") || 0); }
function saveScore(v){ set("score", v); scoreEl.textContent = v; }

function answeredKey(chId, qid){ return `answered:${chId}:${qid}`; }
function isAnswered(chId, qid){ return get(answeredKey(chId, qid)) === "1"; }
function markAnswered(chId, qid){ set(answeredKey(chId, qid), "1"); }

function showToast(msg, ms=1400){
  toast.textContent = msg;
  toast.style.display = "block";
  setTimeout(()=> toast.style.display="none", ms);
}

/* ===== 全程计时器 ===== */
const TIMER_START_KEY = "timerStart";   // epoch ms
const TIMER_STOP_KEY  = "timerStop";    // epoch ms (停止时刻)
let timerTick = null;

function fmtTime(ms){
  ms = Math.max(0, ms|0);
  const s = Math.floor(ms/1000);
  const hh = Math.floor(s/3600);
  const mm = Math.floor((s%3600)/60);
  const ss = s%60;
  if (hh > 0) return `${String(hh).padStart(2,"0")}:${String(mm).padStart(2,"0")}:${String(ss).padStart(2,"0")}`;
  return `${String(mm).padStart(2,"0")}:${String(ss).padStart(2,"0")}`;
}
function getTimerStart(){ return Number(get(TIMER_START_KEY) || 0); }
function getTimerStop(){  return Number(get(TIMER_STOP_KEY)  || 0); }
function isTimerRunning(){
  const st = getTimerStart();
  const sp = getTimerStop();
  return st > 0 && sp === 0;
}
function updateTimerUI(){
  const st = getTimerStart();
  const sp = getTimerStop();
  if (!st){
    timerEl.textContent = "00:00";
    return;
  }
  const now = Date.now();
  const elapsed = (sp>0 ? (sp - st) : (now - st));
  timerEl.textContent = fmtTime(elapsed);
}
function startGlobalTimerOnce(){
  const st = getTimerStart();
  const sp = getTimerStop();
  if (st > 0) return;  // 已启动过（或已结束）
  if (sp > 0) return;

  set(TIMER_START_KEY, Date.now());
  set(TIMER_STOP_KEY, 0);

  if (timerTick) clearInterval(timerTick);
  timerTick = setInterval(updateTimerUI, 250);
  updateTimerUI();
}
function resumeTimerIfNeeded(){
  if (timerTick) clearInterval(timerTick);
  timerTick = null;

  if (isTimerRunning()){
    timerTick = setInterval(updateTimerUI, 250);
  }
  updateTimerUI();
}
function stopGlobalTimer(){
  if (!getTimerStart()) return;     // 没启动过
  if (getTimerStop() > 0) return;   // 已停止过

  set(TIMER_STOP_KEY, Date.now());
  if (timerTick) clearInterval(timerTick);
  timerTick = null;
  updateTimerUI();
}

/* helpers */
function findChapterById(id){
  return CHAPTERS.find(c => c.id === id) || null;
}

function setChapterUI(ch){
  // childNodes[0] 是文本节点（你原写法）
  chapterTitle.childNodes[0].nodeValue = ch.title + "\n  ";
  chapterEn.textContent = ch.en;
  gateH2.textContent = `开始 ${ch.title}`;
}

/* 音乐 */
function playBgmForChapter(ch){
  bgm.pause();
  bgm.currentTime = 0;
  bgm.src = ch.bgm;
  bgm.volume = 0.4;
  const p = bgm.play();
  if (p && typeof p.catch === "function") p.catch(()=>{});
}

/* 视频 */
function loadVideo(i){
  if (!curChapter) return;

  // ✅ 进入新视频前，解除 block
  blockEnd = false;
  endHandled = false;

  curVideoIndex = i;
  if (curVideoIndex >= curChapter.videos.length){
    gotoNextChapter();
    return;
  }

  bgVideo.src = curChapter.videos[curVideoIndex];
  bgVideo.load();
}

bgVideo.addEventListener("canplay", ()=>{
  const p = bgVideo.play();
  if (p && typeof p.catch === "function") p.catch(()=>{});
});

function currentVideoName(){
  if (!curChapter) return "";
  return curChapter.videos[curVideoIndex] || "";
}

/* 题图 */
let activeQuestion = null;

function clearHotspots(){
  imgStage.querySelectorAll(".hotspot").forEach(n => n.remove());
}

function openQuestion(q){
  // ✅ 打开题图时：锁住 ended 逻辑 + 暂停视频
  blockEnd = true;
  endHandled = true;
  try{ bgVideo.pause(); }catch(e){}

  activeQuestion = q;

  qImg.src = q.img;
  imgStage.style.aspectRatio = q.aspect || "2048/1152";

  clearHotspots();
  (q.hotspots || []).forEach((h) => {
    const div = document.createElement("div");
    div.className = "hotspot";
    div.dataset.score = String(h.score || 0);
    div.style.left   = (h.left   ?? 0) + "%";
    div.style.top    = (h.top    ?? 0) + "%";
    div.style.width  = (h.width  ?? 0) + "%";
    div.style.height = (h.height ?? 0) + "%";
    div.onclick = () => answerQuestion(h); // ✅ 传整个 h
    imgStage.appendChild(div);
  });

  imgLayer.style.display = "flex";
}

function answerQuestion(h){
  if (!activeQuestion || !curChapter) return;

  // ✅ 点击后立即锁住，避免 timeupdate/ended 再触发 handleEnd
  blockEnd = true;
  endHandled = true;

  const addScore = Number((h && h.score) || 0);
  const branchVideo = (h && h.nextVideo) ? String(h.nextVideo) : "";

  if (!isAnswered(curChapter.id, activeQuestion.id)){
    saveScore(loadScore() + addScore);
    markAnswered(curChapter.id, activeQuestion.id);
  }

  imgLayer.style.display = "none";
  activeQuestion = null;

  const returnIndex = curVideoIndex + 1; // 主线下一段（例如 cuoyiban1.mp4）

  // ✅ 若配置了分支视频：先插播，再回到主线
  if (branchVideo){
    playInjected(branchVideo, returnIndex);
    return;
  }

  loadVideo(returnIndex);
}

/* ended 处理 */
function handleEnd(){
  if (blockEnd) return;
  if (endHandled) return;
  endHandled = true;

  // ✅ 插播结束回主线
  if (injectedActive){
    injectedActive = false;
    loadVideo(injectedReturnIndex);
    return;
  }

  if (!curChapter) return;
  const vidName = currentVideoName();

  const q = (curChapter.questions || []).find(q => q.after === vidName);
  if (q && !isAnswered(curChapter.id, q.id)){
    setTimeout(()=> openQuestion(q), 80);
    return;
  }

  loadVideo(curVideoIndex + 1);
}

bgVideo.addEventListener("ended", handleEnd);
bgVideo.addEventListener("timeupdate", ()=>{
  if (blockEnd || endHandled) return;
  if (!isFinite(bgVideo.duration) || bgVideo.duration <= 0) return;
  if (bgVideo.duration - bgVideo.currentTime < 0.18) handleEnd();
});

/* 章节切换 */
function startChapterById(chId){
  const ch = findChapterById(chId);
  if (!ch){
    alert("找不到章节：" + chId);
    return;
  }

  // ✅ 切章必须清状态
  blockEnd = false;
  endHandled = false;
  activeQuestion = null;
  imgLayer.style.display = "none";

  // 防止插播残留
  injectedActive = false;
  injectedReturnIndex = 0;

  curChapter = ch;
  set("currentChapterId", ch.id);

  setChapterUI(ch);
  playBgmForChapter(ch);
  loadVideo(0);
}

function gotoNextChapter(){
  if (!curChapter) return;

  if (!curChapter.nextChapterId){
    stopGlobalTimer(); // ✅ 结束计时

    gate.style.display = "flex";
    gateH2.textContent = "全章结束";
    document.getElementById("btnStart").style.display = "none";
    showToast("感谢参与", 1600);
    return;
  }

  const next = findChapterById(curChapter.nextChapterId);
  if (!next){
    alert("下一章配置缺失：" + curChapter.nextChapterId);
    return;
  }

  try{ bgVideo.pause(); }catch(e){}
  gate.style.display = "flex";
  setChapterUI(next);

  const btnStart = document.getElementById("btnStart");
  btnStart.style.display = "inline-block";
  btnStart.textContent = `进入 ${next.title} ▶`;
  btnStart.onclick = ()=>{
    gate.style.display = "none";
    startChapterById(next.id);
  };

  showToast(`${curChapter.title} 完成，进入 ${next.title}`, 1600);
}

/* 按钮 */
document.getElementById("btnReset").onclick = ()=>{
  if(!confirm("清空本机积分、作答记录与计时？")) return;
  Object.keys(localStorage).forEach(k=>{
    if(k.startsWith(`${STORE}:`)) localStorage.removeItem(k);
  });
  location.reload();
};

/* init */
saveScore(loadScore());
resumeTimerIfNeeded();

const btnStart = document.getElementById("btnStart");
btnStart.onclick = ()=>{
  gate.style.display = "none";

  // ✅ 第一次开始即启动全程计时（只会执行一次）
  startGlobalTimerOnce();

  const last = get("currentChapterId");
  if (last && findChapterById(last)) startChapterById(last);
  else startChapterById("ch1");
};
</script>
</body>
</html>
