# 🛡️ Delta Multi-Game Hub [PROTECTED v3.3 - Turbo & Game-Isolated Edition]
**Attack on Titan: Revolution (AOT:R) + Pixel Blade**

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS والكمبيوتر PC) يدعم لعبتين في رابط واحد مع **فصل كامل للواجهة والتابات حسب الماب النشط**:
1. **Pixel Blade** (تفريم الدنجن الشامل + قتل الأعداء بضربة واحدة 1-Shot + تكسير الصناديق الخشبية والبراميل `Breakables` تلقائياً + فتح جميع الصناديق `Auto Open All Chests` عبر `ReplicatedStorage.Drops` والمخزون + الصيد التلقائي السريع التيربو بالصنارة `Turbo Auto Fishing 60FPS`).
2. **Attack on Titan: Revolution (AOT:R)** (جميع الخرائط والغارات شاملة خريطة أوتغارد Utgard + لف العائلات + رماح الرعد + الحماية من الباند).

---

## ✨ التحديثات والإصلاحات الجديدة في الإصدار v3.3

1. **💥 إصلاح جذري لقتل الأعداء وتكسير الصناديق في الدنجن (`Kill Enemies & Break Boxes`)**:
   - **إزالة تعارض `-math.huge` في `onHit`**: إرسال `-math.huge` مع `9e9` في الإصدار السابق كان يرفع صحة الوحش/الصندوق إلى `+inf` أو `NaN` فيصبح غير قابل للقتل أو الكسر. تم استبداله بـ `abilityHit:FireServer(hum, math.huge, { stun = { dur = 0.001 } })` + `onHit` موجب (`100000` و `9e9`) + `swing:FireServer()`.
   - **بف الضرر الخارق `999,999,999%` بضربة واحدة (`One-Shot Weapon Buff`)**: ربط `abilityEvent` بالـ `Character` الفعلي في `workspace` (`workspace[DisplayName]` أو `workspace[Name]`) مع ضربة سيف حقيقية في منتصف الشاشة `(500, 500)` لمدة `0.05s`.
   - **تكسير الصناديق الخشبية والبراميل والجرار تلقائياً (`Auto Breakables`)**: تم دمج الصناديق القابلة للكسر (`Breakable`, `Crate`, `Barrel`, `Box`, `Pot`) مباشرة داخل نظام استهداف الدنجن وتفعيلها افتراضياً مع سحب الأعداء وتكبير الـ `basehitbox`.
2. **🗡️ إصلاح حركة وتقدم تفريم الدنجن التلقائي (`Smart 5-Tier Dungeon Auto Farm`)**:
   - **إلغاء التعليق عند نار المخيم (`CamnpfireRocky`)**: لم يعد اللاعب يعلق عند نار المخيم في بداية الدنجن، بل يتحرك تلقائياً نحو الوحوش والصناديق القابلة للكسر ويتقدم بأمان عبر الغرف (`ExitZone` + `ProximityPrompt` + فحص الأرضية `Raycast Anti-Void`).
3. **🎁 إصلاح فتح الصناديق التلقائي بالكامل (`Auto Open All Chests`)**:
   - يفحص مجلد `ReplicatedStorage.Drops` ويفتح جميع الصناديق بكافة المستويات (`Tier 1..3` مثل `Wooden1..3`, `Royal1..3`, `Godly1..3`, `Electric1..3`) عبر `openLoot:InvokeServer` بدون تعليق (`task.spawn`), بالإضافة إلى صناديق الحقيبة (`Loot`) والصناديق/الغنائم الموجودة على الأرض داخل الدنجن.
   - إضافة زر **🎁 فتح وجمع كل الصناديق فوراً** وزر **⬆️ ترقية جميع الأسلحة والدروع (1-9)** بضغطة واحدة.
4. **🧩 فصل كامل لخانات وتابات كل لعبة + 🎣 صيد تلقائي تيربو 60FPS**.

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي والصقه في **Delta Executor** واضغط **Execute**:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```
