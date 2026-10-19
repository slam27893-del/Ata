# ⚔️ سكربت Multi-Game Delta Hub [PROTECTED v3.8 - World 5: The Sunken Depths / CHRONOS]

سكربت شامل ومحمي بالكامل يعمل عبر **رابط واحد فقط** مع **الكشف التلقائي عن اللعبة وعزل القوائم تلقائياً (Strict Per-Game UI Isolation)** على مشغل **Delta Executor** (أندرويد، iOS، وكمبيوتر):
1. **🗡️ Pixel Blade (تحديث World 5: The Sunken Depths / بداية Arc 2 وحدث CHRONOS — v3.8)**:
   - عند فتح السكربت داخل **Pixel Blade** تظهر **فقط** تبويبات Pixel Blade ويعمل كل من **الفارم التلقائي، الهالة (Kill Aura)، تكسير الصناديق، اختيار الترقيات، وفتح الصناديق** تلقائياً فور التشغيل.
   - **محرك v3.8 المتوازي سداسي الخيوط (6-Thread Parallel Non-Blocking Engine) المدمج من (`thha3203 v5` + `Mana-scripts` + `thaemmayanh` + `lucas0conhecimento` + `Fog1ch` + `Killer-hub`)**:
     - **فصل الحلقات إلى 6 مسارات مستقلة غير متوقفة (`Loop 2A..2F`)**: حل جذري لمشكلة توقف السكربت بسبب استدعاء `require(plrStats)` أو انتظار انتقال الغرف، بحيث تعمل الهالة وتكسير الصناديق والترقيات والطيران في مسارات منفصلة تماماً وبلا أي تجميد.
     - **تثبيت الطيران خلف وفوق الأعداء 60 مرة في الثانية (`Heartbeat Continuous Aerial Follow`)**: التعلق المستمر خلف العدو بـ `6.5` studs وفوقه بـ `1.5` studs مع توجيه السلاح نحوه وتصفير الجاذبية والتصادم (`CanCollide = false`).
     - **كشف شامل لجميع أعداء الدنجن و World 5 والغارات**: استهداف جميع الأعداء الحقيقيين (`hadEntrance ~= nil` أو `basehitbox` أو `Humanoid + HumanoidRootPart`) مع تجاهل فخاخ الأرضية (`teeth trap`) والصناديق والديكورات.
     - **نظام التدمير الذكي للصناديق والبراميل (`Adaptive Breakables Destroyer`)**: كسر جميع الكائنات القابلة للكسر (`breakable` / `crate` / `barrel` / `box` / `pot` / `vase` / `urn` / `crystal` / والكائنات ذات `Humanoid` بدون `HumanoidRootPart`) دون خلط `-math.huge` مع `+math.huge` في نفس الضربة لمنع تحول صحة الصندوق إلى `NaN`.
     - **اختيار الترقيات التلقائي المتوافق مع الجوال والكمبيوتر**: إرسال `plrUpgrade:FireServer(1..3)` + ضغط زر `Two` + النقر على أزرار `upgradeFrame` مع نقل النافذة خارج الشاشة (`UDim2.new(0, 0, -1.1, 0)`) دون إخفاء `Visible` حتى لا يتعطل نظام الترقية داخل اللعبة.
     - **انتقال ذكي وشامل بين الغرف (`ExitZone` + `Campfire` + `ProximityPrompt` + `6->7` / `7->8` / `8->9` / `20->BossRoom`)**.
   - **🎣 صيد تلقائي تيربو بالصنارة (Turbo Auto Fishing)**:
     - تفاعل فوري **60 مرة في الثانية (`RenderStepped`)** مع ميني جيم الصيد (الضغط المستمر للدائرة الخضراء + النقر التيربو السريع للسحب الأزرق).

2. **⚔️ Attack on Titan: Revolution (AOT:R)**:
   - عند فتح السكربت داخل **AOT:R** تظهر **فقط** تبويبات هجوم العمالقة (الفارم والعمالقة، المهمات والتعبئة، العائلات والتنقل).

---

## 📲 كود التشغيل السريع في Delta Executor (انسخ والصق مباشرة)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```
