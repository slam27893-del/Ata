# ⚔️ سكربت Multi-Game Delta Hub [PROTECTED v3.7 - World 5: The Sunken Depths / CHRONOS]

سكربت شامل ومحمي بالكامل يعمل عبر **رابط واحد فقط** مع **الكشف التلقائي عن اللعبة وعزل القوائم تلقائياً (Strict Per-Game UI Isolation)** على مشغل **Delta Executor** (أندرويد، iOS، وكمبيوتر):
1. **🗡️ Pixel Blade (تحديث World 5: The Sunken Depths / بداية Arc 2 وحدث CHRONOS — v3.7)**:
   - عند فتح السكربت داخل **Pixel Blade** تظهر **فقط** تبويبات Pixel Blade (ولن تظهر أي قوائم خاصة بـ Attack on Titan).
   - **محرك v3.7 الهجين المدمج من أشهر سكربتات Pixel Blade العاملة (`thha3203 v2..v5` + `Vortex_PixelBlade` + `TexRBLX` + `Killer-hub` + `Mana-scripts` + `LelHub`)**:
     - **إصلاح مشكلة توقف الضرر والتعليق أثناء القتال (Non-Desync Movement & Velocity Lock)**: تصفير السرعة فقط داخل `Heartbeat` (`AssemblyLinearVelocity = Vector3.zero`) دون فرض إعادة التليبورت 60 مرة في الثانية، وتحديث الموقع خلف العدو بـ `8` studs (`CFrame.lookAt`) فقط عندما تكون المسافة `>= 10`، مما يمنع رفض الضربات في السيرفر نهائياً.
     - **عزل كامل للأعداء الحقيقيين وتجاهل الفخاخ والديكورات (`teeth trap` & Static Props)**: فلترة فخاخ الأرضية الخالدة (`teeth trap` / `Teeth Trap` / `teeth_trap`) وفصل كسر الصناديق (`breakable`) عن قائمة أهداف القتال حتى لا ينحرف اللاعب أبداً عن الوحوش.
     - **تدمير الصناديق القابلة للكسر عن بُعد (`Mana-scripts Remote Breakables`)**: كسر جميع الكائنات التي تحتوي على `"breakable"` في اسمها تلقائياً في الخلفية عبر `onHit:FireServer(hum, -math.huge, {}, 0)` و `abilityHit` دون الحاجة للابتعاد عن الأعداء.
     - **نظام الانتقال الكامل بين المراحل والغرف (`Killer-hub ExitZone` + `ProximityPrompt` + `AncientSands`/`Grasslands`/`BossRoom`)**: التوجه التلقائي لأي `ProximityPrompt` مفعل وتفعيله، والمرور عبر جميع بوابات `ExitZone` للانتقال للغرفة التالية، ودعم انتقال الغرف الآمنة (`6->7` Normal، `7->8` Heroic، `8->9` Nightmare، و `20->BossRoom`، وغرفة البوس `Korth` مع قتل `BookHand` أولاً، وغرفة `Vault` لبوس `Atticus`).
     - **تفعيل باف الضرر الخارق مرة واحدة لكل حياة (`TexRBLX 999,999,999%` + `Vortex 5,500,000,000%` + `5000 Poison`) + `Tornado Mass Kill`**: منع إغراق السيرفر بالبافات المتكررة مع دمج ضربات السيف (`swing` + `onHit`) مع إعصار القتل الجماعي (`useAbility("tornado")` + `abilityHit`).
     - **فتح الصناديق التلقائي (`Inventory Loot` + `ReplicatedStorage.Drops Tiers 1..3` + `Workspace Chests`)** وإخفاء نافذة الترقيات المزعجة (`upgradeFrame.Visible = false` + `deathBlur`/`screenBlur`).
   - **🎣 صيد تلقائي تيربو بالصنارة (Turbo Auto Fishing)**:
     - تفاعل فوري **60 مرة في الثانية (`RenderStepped`)** مع ميني جيم الصيد (الضغط المستمر للدائرة الخضراء + النقر التيربو السريع للسحب الأزرق).

2. **⚔️ Attack on Titan: Revolution (AOT:R)**:
   - عند فتح السكربت داخل **AOT:R** تظهر **فقط** تبويبات هجوم العمالقة (الفارم والعمالقة، المهمات والتعبئة، العائلات والتنقل).

---

## 📲 كود التشغيل السريع في Delta Executor (انسخ والصق مباشرة)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```
