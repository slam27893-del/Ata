# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.7]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - أوتو كليكر سريع ونقي للضرب المستمر + أولوية قصوى للأعداء المعالجين والمستنزفين + ثبات تنقل الغرف من v4.6 بدون أي لاق)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث (v4.7)؟

### 1️⃣ نظام أوتو كليكر نقي وسريع (`Pure Fast Auto-Clicker M1 Engine`) 🗡️
- **لماذا لم تكن الكلكات تضرب بالسيف في `v4.6`؟**
  1. كان السكربت يمرر جدول Lua وهمي (`mockInput`) إلى حدث `InputBegan` داخل `Character.localChar`، بينما كود اللعبة الأصلي يحاول استدعاء `input.Changed:Connect(...)` (الموجود فقط في `InputObject` الحقيقي)، مما كان يسبب خطأ داخل `localChar` فيعلق زر السيف (`🗡️`) في وضع الشحن الوردي ويتوقف عن الضرب!
  2. كما كان البحث عن زر السيف يصعد إلى الإطار الأب (`swordBtn.Parent`) فيضغط معه أزرار الصد (`🛡️`) والداش والمهارات.
- **الحل في `v4.7` (أوتو كليكر نقي `11` ضربة/ثانية)**:
  - إزالة تمرير الجداول الوهمية لـ `InputBegan` نهائياً وعدم لمس الإطار الأب (`Parent`) إطلاقاً.
  - تشغيل حلقة **أوتو كليكر مستقل وسريع (`Loop 2G` كل `0.09` ثانية)** يرسل نقرات فورية بدون تأخير (`0-delay tap`) عبر:
    - `VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true/false, game, 0)` (طريقة `thha3203` الأصلية).
    - `VirtualUser:CaptureController()` + `VirtualUser:ClickButton1(Vector2.new(0, 0))`.
    - النقر المباشر على مركز زر السيف (`🗡️`) فقط (`MouseButton1Click` + `Activated` + `SendMouseButtonEvent`) مع `mouse1click()` و `Tool:Activate()` و `remotes.swing:FireServer()` وتصفير أي تعليق شحن أو انتظار في `getsenv(Character.localChar)`.

### 2️⃣ أولوية قصوى للأعداء الذين يستنزفون أو يعالجون الأعداء الآخرين (`Healer / Drainer #1 Priority`) 💉
- **دون أي تعديل على نظام تنقل الغرف أو الأداء (`Zero Lag`)**:
  1. **الأولوية الأولى داخل الغرفة الحالية (`💉 [معالج/مستنزف]`)**:
     - يكشف السكربت تلقائياً أي عدو يمتلك شعاع علاج أو استنزاف نشط (`Beam` / `Tether` / `Heal` / `Drain` / `Siphon` / `Leech`) أو ينتمي لفئة المعالجين والمستنزفين (`Healer`, `Priest`, `Shaman`, `Druid`, `Cultist`, `Witch`, `MoonWitch`, `BloodDemon`, `Vampire`, `Eyeball`, `Necromancer`, `Totem`, `Siphoner`, إلخ) ويضعه في **المرتبة الأولى قبل أي عدو آخر في الغرفة**!
  2. **الأولوية الثانية (`🏹 [بعيد المدى]`)**: الأعداء الذين يضربون من بعيد (`Archer`, `Bow`, `Crossbow`, `Cannon`, إلخ).
  3. **الأولوية الثالثة (`⚔️`)**: باقي وحوش الاشتباك القريب في نفس الغرفة.
  4. **شلّ وضرب جميع المعالجين والمستنزفين في الغرفة في نفس اللحظة**: أثناء ضرب الهدف الحالي، يرسل `pbDamageModel` تلقائياً `onHit` + `abilityHit (stun = 2s)` لأي معالج أو مستنزف نشط آخر داخل نفس الغرفة حتى لا يتمكن من علاج الوحوش أو استنزافك إطلاقاً!
