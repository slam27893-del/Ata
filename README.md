# 🛡️ Delta Multi-Game Hub [PROTECTED v3.4 - Turbo & Game-Isolated Edition]
**Attack on Titan: Revolution (AOT:R) + Pixel Blade**

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS والكمبيوتر PC) يدعم لعبتين في رابط واحد مع **فصل كامل للواجهة والتابات حسب الماب النشط**:
1. **Pixel Blade** (تفريم الدنجن الشامل بدون التعليق عند الصندوق الوردي أو `ShroomKnight` + قراءة ضرر السلاح الفعلي `plrStats.wpnStats.Dmg` مع بف `550,000,000%` لتجاوز حماية السيرفر وقتل الأعداء فوراً + تكسير الصناديق الخشبية `Breakables` عن بُعد + فتح جميع الصناديق `Auto Open All Chests` بدون حظر/تأخير + الصيد التلقائي السريع التيربو بالصنارة `Turbo Auto Fishing 60FPS`).
2. **Attack on Titan: Revolution (AOT:R)** (جميع الخرائط والغارات شاملة خريطة أوتغارد Utgard + لف العائلات + رماح الرعد + الحماية من الباند).

---

## ✨ التحديثات والإصلاحات الجديدة في الإصدار v3.4

1. **🚫 إصلاح التعليق عند الصندوق الوردي / المجسمات في الغرفة الأولى (`Anti-Chest/Prop Lock`)**:
   - في الصورة المرفقة، كان السكربت يلتقط الصندوق الوردي في الغرفة الأولى (الذي يحتوي على `Root` و `Top` و `Humanoid`) كأنه عدو بسبب `FindFirstChild("Root")`، فيثبت اللاعب أمامه ولا ينتقل للوحوش في الغرفة التالية.
   - تم حظر استهداف أي مجسم يحتوي على `Root` + `Top` أو أي صندوق/NPC (`ShroomKnight`, `blender`, `Chest`, `Breakable`, `Rig`)، وأصبح الاستهداف مقتصراً على الوحوش الحقيقية التي تملك `HumanoidRootPart` + `hadEntrance` أو `Health`، مع نظام **تخطي تلقائي خلال 3 ثوانٍ (`Anti-Stuck Skipper`)**.
2. **💥 إصلاح قتل الأعداء وتجاوز فحص الضرر في السيرفر (`plrStats.wpnStats.Dmg` + `550,000,000% Buff` + `Tornado`)**:
   - يقرأ السكربت الآن ضرر سلاحك الفعلي من `require(LocalPlayer.plrStats).wpnStats.Dmg` ويرسله في `onHit` مع تفعيل بف `tempbuff` (`550,000,000%`) ومهارة `tornado` + `abilityHit` لقتل جميع الوحوش والزعماء فوراً دون أن يرفض السيرفر الضربة.
3. **📦 تكسير الصناديق القابلة للكسر عن بُعد (`Remote Auto Breakables`)**:
   - يتم تكسير جميع الصناديق الخشبية والجرار (`Breakable`) عن بُعد عبر `onHit` دون الحاجة للانتقال إليها أو الوقوف عندها.
4. **🎁 إصلاح فتح الصناديق التلقائي بدون حظر السيرفر (`Sequential Anti-Throttle Chest Opener`)**:
   - فتح الصناديق بالتتابع (`0.08s` بين كل صندوق) من `PlayerGui.gameUI.armory.inventory.clip.Loot` ومجلد `ReplicatedStorage.Drops` (المستويات 1 إلى 3) والصناديق الموجودة داخل الدنجن حتى لا يقوم السيرفر بتجاهل الطلبات المتزامنة.
   - إضافة **شريط حالة مباشر في تبويب الدنجن** يعرض اسم الوحش المستهدف والمسافة وضرر السلاح الحالي، وتجاوز الكاش (`?v=34`) لضمان تحميل أحدث إصدار فوراً.

---

## 📲 كود التشغيل المباشر في Delta Executor (محدث لـ v3.4 بدون كاش)

انسخ السطر التالي والصقه في **Delta Executor** واضغط **Execute**:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua?v=34"))()
```
