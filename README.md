# ⚔️ سكربت Multi-Game Delta Hub [PROTECTED v3.6 - World 5: The Sunken Depths / CHRONOS]

سكربت شامل ومحمي بالكامل يعمل عبر **رابط واحد فقط** مع **الكشف التلقائي عن اللعبة وعزل القوائم تلقائياً (Strict Per-Game UI Isolation)** على مشغل **Delta Executor** (أندرويد، iOS، وكمبيوتر):
1. **🗡️ Pixel Blade (تحديث World 5: The Sunken Depths / بداية Arc 2 وحدث CHRONOS — v3.6)**:
   - عند فتح السكربت داخل **Pixel Blade** تظهر **فقط** تبويبات Pixel Blade (ولن تظهر أي قوائم خاصة بـ Attack on Titan).
   - **إصلاح جذري وشامل لتفريم الدنجن والقتال وتكسير الصناديق وفتح الغنائم (v3.6)**:
     - **دعم كامل لتحديث World 5: The Sunken Depths (Arc 2 / CHRONOS)**: يدعم البوس الجديد **Morvik (Ghost Lord)**، دروع وأسلحة **Chronos Set**، بوابة **SunkenDepths**، وصناديق **SunkenChest / ChronosChest / AbyssalChest**، بالإضافة إلى زر تفعيل جميع أكواد التحديث الجديدة (`WORLD5`, `CHRONOS`, `VAULTED`, `1MILLFAVS`, `FISHINGSTASH`, `DAILYTRACKER`, `COMETWASHERE`).
     - **حل مشكلة عدم فتح الصناديق (Non-Blocking Async Chest Opener)**: تم إصلاح تعليق `openLoot:InvokeServer` عبر تشغيل كل استدعاء داخل `task.spawn` مستقل غير حاجب، مع فتح الصناديق المملوكة فعلياً في `PlayerGui.gameUI.armory.inventory.clip.Loot` + الصناديق الفيزيائية داخل غرف الدنجن (`Root` + `Top` + `ProximityPrompt` + ضرب الصندوق بالسيف).
     - **حل مشكلة عدم قتل الأعداء (Synced Server Position + 5,500,000,000% Buff + 5000 Poison)**:
       - التزامن الكامل مع موقع العدو الحقيقي في السيرفر (`eHrp.Anchored = true` بدون تحريك `eHrp.CFrame` محلياً أثناء الفارم لتجنب فشل فحص المسافة `<= 18` في السيرفر).
       - التمركز الدقيق خلف العدو بـ `6.5` studs (`CFrame.lookAt`) مع تفعيل باف الضرر الخارق `5,500,000,000%` + `poisonElement = 5000` تلقائياً وإرسال `swing` + `onHit` بقوة السلاح الحقيقية (`require(LocalPlayer.plrStats).wpnStats.Dmg`) + `tornado` / `abilityHit` + نقرات السيف الحقيقية `M1`.
       - التعرف الدقيق على جميع الأعداء عبر `v:GetAttribute("hadEntrance") ~= nil` دون حظر الوحوش التي تنتظر انتهاء حركة الدخول (`hadEntrance == false`).
     - **حل مشكلة عدم تكسير الصناديق الخشبية والجرار (Breakable Boxes / Crates / Pots)**: التوجه للصناديق القابلة للكسر وضربها بالسيف + `firetouchinterest` على أجزاء السلاح (`Hitbox`/`Blade`/`Handle`) + `onHit` مع مؤقت ذكي (`1.1s`) لعدم التعليق عليها بعد كسرها.
     - **الانتقال الصحيح بين الغرف (`6->7` Normal، `7->8` Heroic، `8->9` Nightmare، و `Vault` لبوس `Atticus` و `ExitZone`)** دون القفز الخاطئ إلى نهاية الدنجن قبل تصفية الغرفة الحالية.
   - **🎣 صيد تلقائي تيربو بالصنارة (Turbo Auto Fishing)**:
     - تفاعل فوري **60 مرة في الثانية (`RenderStepped`)** مع ميني جيم الصيد (الضغط المستمر للدائرة الخضراء + النقر التيربو السريع للسحب الأزرق).

2. **⚔️ Attack on Titan: Revolution (AOT:R)**:
   - عند فتح السكربت داخل **AOT:R** تظهر **فقط** تبويبات هجوم العمالقة (الفارم والعمالقة، المهمات والتعبئة، العائلات والتنقل).

---

## 📲 كود التشغيل السريع في Delta Executor (انسخ والصق مباشرة)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```
