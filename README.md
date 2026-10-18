# 🛡️ Delta Multi-Game Hub [PROTECTED v3.5 - Turbo & Game-Isolated Edition]
**Attack on Titan: Revolution (AOT:R) + Pixel Blade**

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS والكمبيوتر PC) يدعم لعبتين في رابط واحد مع **فصل كامل للواجهة والتابات حسب الماب النشط**:
1. **Pixel Blade** (تفريم الدنجن الشامل لجميع الغرف والمراحل `Rooms 1..25` + قتل الأعداء والزعماء بضربات متعددة إيجابية + تكسير الصناديق والجرار `Breakables` فعلياً بدون شفائها بالخطأ + فتح جميع الصناديق داخل الدنجن وفي الحقيبة `Auto Open All Chests` + الصيد التلقائي السريع التيربو بالصنارة `Turbo Auto Fishing 60FPS`).
2. **Attack on Titan: Revolution (AOT:R)** (جميع الخرائط والغارات شاملة خريطة أوتغارد Utgard + لف العائلات + رماح الرعد + الحماية من الباند).

---

## ✨ التحديثات والإصلاحات الجذرية في الإصدار v3.5

1. **📦 إصلاح تدمير الصناديق والجرار القابلة للكسر (`Breakables Fix`)**:
   - في الإصدار السابق كانت دالة تكسير الصناديق ترسل `-math.huge` إلى `onHit` مما كان يؤدي إلى شفاء الصناديق إلى `+inf` بدلاً من تدميرها، كما كانت تفحص المستوى الأول من `workspace` فقط.
   - في **v3.5** تمت إزالة `-math.huge` نهائياً من كامل السكربت، وإضافة فحص عميق (`collectAllPBModels`) يكتشف جميع الصناديق والجرار داخل مجلدات الغرف وينتقل إليها ويدمرها فعلياً عبر `onHit` الإيجابي + `abilityHit` + `swing` + `firetouchinterest`.
2. **⚔️ إصلاح قتل جميع الأعداء في الدنجن والغارات (`Deep Enemy Scanner & Multi-Hit Damage`)**:
   - إصلاح فلتر الأسماء الذي كان يستبعد وحوش الفطر والفرسان (`Shroom` / `Knight`) في `CHAPTER 1 / 3`، وحصر الاستبعاد على الـ NPC الثابت `ShroomKnight` والصناديق (`Root` + `Top`) فقط.
   - دعم الأعداء الموجودين داخل مجلدات أو موديلات الغرف الفرعية (`collectAllPBModels`) والأعداء العاديين الذين يملكون `Humanoid` + `HumanoidRootPart`/`PrimaryPart`.
   - دمج ضربات متعددة بضرر أساسي `9` (`pixelNerdV1` لتجاوز سقف ضرر السيف الابتدائي في المستويات الأولى) + ضرر السلاح الفعلي `plrStats.wpnStats.Dmg` + `9999999999` + `tornado` + `abilityHit` + بف `550,000,000%`.
3. **🏃 إصلاح الانتقال التلقائي للمرحلة/الغرفة التالية (`Sequential Room Progression 1 -> 25`)**:
   - بدلاً من فحص الغرف الأخيرة (`6..9`) فقط، ينتقل اللاعب الآن تلقائياً عبر جميع الغرف المرقمة بالتسلسل (`"2"` إلى `"25"` و `"BossRoom"` و `"Vault"` و `ExitZone`) ويتحرك للأمام عبر البوابات مع فحص الأرضية (`Raycast`) وتفعيل `ProximityPrompt`.
4. **🎁 إصلاح فتح الصناديق داخل الدنجن وفي الحقيبة (`Deep Workspace + Inventory Chest Opener`)**:
   - البحث العميق في `workspace:GetDescendants()` عن صناديق الغنائم داخل الغرف والتفاعل معها تلقائياً إلى جانب فتح صناديق الحقيبة (`PlayerGui.gameUI.armory.inventory.clip.Loot` و `ReplicatedStorage.Drops`).

---

## 📲 كود التشغيل المباشر في Delta Executor (محدث لـ v3.5 بدون كاش)

انسخ السطر التالي والصقه في **Delta Executor** واضغط **Execute**:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua?v=35"))()
```
