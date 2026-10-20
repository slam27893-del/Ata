# ⚔️ سكربت Multi-Game Delta Hub [PROTECTED v3.9 - World 5: The Sunken Depths / CHRONOS]

سكربت شامل ومحمي بالكامل يعمل عبر **رابط واحد فقط** مع **الكشف التلقائي عن اللعبة وعزل القوائم تلقائياً (Strict Per-Game UI Isolation)** على مشغل **Delta Executor** (أندرويد، iOS، وكمبيوتر):
1. **🗡️ Pixel Blade (تحديث World 5: The Sunken Depths / بداية Arc 2 وحدث CHRONOS — v3.9)**:
   - عند فتح السكربت داخل **Pixel Blade** تظهر **فقط** تبويبات Pixel Blade ويعمل كل من **الفارم التلقائي، الهالة (Kill Aura)، تكسير الصناديق، اختيار الترقيات، وفتح الصناديق** تلقائياً فور التشغيل.
   - **محرك v3.9 فائق الخفة بدون لاق (Zero-Lag & Strict Sequential Room Progression Engine)**:
     - **إزالة اللاج بالكامل (100% Zero-Lag Optimization)**:
       - إزالة استدعاء `getsenv(localChar)` و`GetDescendants()` من داخل `RunService.Heartbeat` (التي كانت تعمل 60 مرة في الثانية وتسبب تقطيعاً قوياً) وتخزين `getsenv` في الذاكرة لمرة واحدة فقط لكل حياة.
       - تنظيم إرسال مهارة `useAbility("tornado")` بحد أقصى مرة كل `2.5` ثانية لمنع تراكم مؤثرات الإعصار البصرية، مع الإبقاء على الضرر الفوري عبر `onHit` و`abilityHit`.
       - إيقاف تكرار الضرب المزدوج بين حلقة `Kill Aura` وحلقة `Auto Farm Dungeon`، وفحص `workspace:GetChildren()` فقط بدلاً من البحث العميق في آلاف المجسمات.
     - **انتقال متسلسل ودقيق غرفة بغرفة بالترتيب الصحيح (`Strict Room-by-Room Progression`)**:
       - تصفية الأعداء بصرامة عبر `hadEntrance ~= nil` (أو `BookHand` / `worm`) لمنع الانتقال إلى مجسمات الزينة أو الشخصيات الجانبية في الغرف الأخرى.
       - **أولوية الغرفة الحالية أولاً (`hadEntrance == true`)**: لا يغادر اللاعب الغرفة الحالية أبداً طالما بقي فيها عدو واحد حي، وفور تنظيف الغرفة الحالية ينتقل إلى **أقرب عدو في الغرفة المجاورة مباشرة (`hadEntrance == false`)** مع مهلة فتح الباب (`1.1s`)، دون القفز العشوائي عبر `ProximityPrompt` أو `ExitZone`.
       - دعم الانتقال التلقائي في غرف الاستراحة (`CamnpfireRocky` و `6->7` Normal، `7->8` Heroic، `8->9` Nightmare، و`20->BossRoom`).
   - **🎣 صيد تلقائي تيربو بالصنارة (Turbo Auto Fishing)**:
     - تفاعل فوري **60 مرة في الثانية (`RenderStepped`)** مع ميني جيم الصيد (الضغط المستمر للدائرة الخضراء + النقر التيربو السريع للسحب الأزرق).

2. **⚔️ Attack on Titan: Revolution (AOT:R)**:
   - عند فتح السكربت داخل **AOT:R** تظهر **فقط** تبويبات هجوم العمالقة (الفارم والعمالقة، المهمات والتعبئة، العائلات والتنقل).

---

## 📲 كود التشغيل السريع في Delta Executor (انسخ والصق مباشرة)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```
