# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.8]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - أوتو كليكر آمن 100% بدون كراش + أولوية قصوى للأعداء المعالجين والمستنزفين + ثبات تنقل الغرف من v4.6 بدون أي لاق)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث (v4.8)؟

### 1️⃣ إصلاح الكراش الفوري عند تفعيل السكربت (`100% Crash-Free Pure Auto-Clicker`) 🛡️
- **سبب الكراش (الخروج من تطبيق روبلوكس) في `v4.7`**:
  1. في `v4.7` تمت إضافة استدعاء `VirtualUser:CaptureController()` + `VirtualUser:ClickButton1` بالتزامن مع `firesignal(o.Activated)` و `getconnections` وحلقة `Loop 2G` التي تعمل منذ أول لحظة لتشغيل السكربت، وهو ما يسبب **انهياراً أصلياً (Native C++ Crash) في محرك روبلوكس على أندرويد (Delta Android)** يغلق التطبيق فوراً!
- **الحل الجذري في `v4.8`**:
  - **إزالة `VirtualUser` و `firesignal` و `getconnections` و `Loop 2G` وتعديل جدول `getsenv` بالكامل من نظام الأوتو كليكر!**
  - الاعتماد **حصرياً** على `VirtualInputManager:SendMouseButtonEvent` الرسمي الآمن 100% على أندرويد وPC، مع النقر الدقيق على مركز زر السيف (`🗡️`) بالإحداثيات المقاسة من شاشة الجوال (`0.7855, 0.6962`) والتحقق من عدم تغطية نافذة السكربت لزر السيف.

### 2️⃣ أولوية قصوى للأعداء الذين يستنزفون أو يعالجون الأعداء الآخرين (`Healer / Drainer #1 Priority`) 💉
- **دون أي تعديل على نظام تنقل الغرف أو الأداء (`Zero Lag`)**:
  1. **الأولوية الأولى داخل الغرفة الحالية (`💉 [معالج/مستنزف]`)**: أي عدو يمتلك شعاع علاج أو استنزاف نشط (`Beam` / `Tether` / `Heal` / `Drain` / `Siphon` / `Leech`) أو ينتمي لفئة المعالجين والمستنزفين (`Healer`, `Priest`, `Shaman`, `Druid`, `Cultist`, `Witch`, `MoonWitch`, `BloodDemon`, `Vampire`, `Eyeball`, `Necromancer`, `Totem`, `Siphoner`, إلخ).
  2. **الأولوية الثانية (`🏹 [بعيد المدى]`)**: الأعداء الذين يضربون من بعيد (`Archer`, `Bow`, `Crossbow`, `Cannon`, إلخ).
  3. **الأولوية الثالثة (`⚔️`)**: باقي وحوش الاشتباك القريب في نفس الغرفة.
  4. **شلّ وضرب جميع المعالجين والمستنزفين في الغرفة في نفس اللحظة** عبر `onHit` + `abilityHit (stun = 2s)`.
