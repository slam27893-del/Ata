# 🛡️ Delta Multi-Game Hub v3.1 [Attack on Titan: Revolution + Pixel Blade + Auto Fishing]

سكربت شامل ومتعدد الألعاب (**Multi-Game Hub**) يعمل بنفس الرابط الواحد تلقائياً على كلٍ من:
1. ⚔️ **Attack on Titan: Revolution (AOT:R)** (جميع الخرائط بما فيها أوتغارد Utgard + الغارات Raids + لفات العائلات).
2. 🗡️ **Pixel Blade** (فارم الدنجن والغرف تلقائياً + فارم الغارات + **🎣 الصيد التلقائي بالصنارة Auto Fishing** + Kill Aura + تقوية الضرر الخارق والشفاء + فتح الصناديق والأمنيات + دخول البوابات تلقائياً).

مزود **بحفظ تلقائي للإعدادات وتشغيل تلقائي بين الغارات والدنجن (`Auto-Save & Queue On Teleport`)** + **نظام حماية متعدد الطبقات (`Multi-Layer Anti-Ban & Stealth Protection`)** لمشغل **Delta Executor** (أندرويد، iOS، والكمبيوتر).

---

## 🚀 رابط التشغيل الموحد في دلتا (Delta Executor)

نفس السطر يشتغل تلقائياً في اللعبتين (يتعرف على الماب الذي دخلته ويفتح تبويباته تلقائياً):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🎣 الصيد التلقائي بالصنارة في Pixel Blade (`🎣 Pixel صيد بالصنارة` — جديد في v3.1)

- **Auto Fish (رمي الصنارة + حل الميني جيم + السحب التلقائي):**
  1. **تجهيز الصنارة ورميها تلقائياً:** يمسك الصنارة من الحقيبة (`Backpack`) ويتفاعل مع نقطة الصيد (`ProximityPrompt` + ضغط مطول `E` / زر الجوال).
  2. **الدائرة الخضراء (`RGB 39, 162, 71` / `circle_popup`):** يضغط مطولاً تلقائياً عند ظهور الدائرة الخضراء الأولى (`1.5s`) والدوائر الخضراء الإضافية (`1.0s`).
  3. **الدائرة الزرقاء (`RGB 195, 223, 224` / `Reel`):** ينقر بسرعة تلقائياً (`12x` نقرات سريعة + زر الجوال + الريموت) لسحب السمكة فوراً.
  4. **قفل شريط الصيد (`Bar Lock`) + حارس المهلة (`15s Timeout`):** يثبت شريط الصيد على الهدف تلقائياً، وإذا لم يعلق سمك خلال 15 ثانية يعيد رمي الصنارة تلقائياً بدون توقف.
  5. **عداد مباشر للأسماك المصطادة وحالة الصيد** داخل القائمة مع التحكم الكامل بسرعة الرمي والضغط والنقر.

---

## 🗡️ مميزات القتال والدنجن في Pixel Blade

1. **⚔️ قسم الفارم والقتال (`🗡️ Pixel Blade قتال`):**
   - **Auto Farm Dungeon & Auto Farm Raids**
   - **Kill Aura + Tornado**
   - **God Buff & Auto Heal**
   - **Infinite Dash & No Ability Cooldown (`داش لا نهائي وإلغاء انتظار المهارات`)**
   - **Auto Breakables & Expand Enemy Hitbox**

2. **🎁 قسم الترقيات والصناديق والبوابات (`🎁 Pixel صناديق وبوابات`):**
   - **Auto Pick Upgrade & Hide Popup**
   - **Auto Open All Chests & Auto Open Wishes**
   - **Auto Claim Daily Quests & Achievements**
   - **Auto Join Dungeon Portal (`Grasslands` / `AncientSands` — `Normal` / `Heroic` / `Nightmare`)**

---

## ⚔️ مميزات ماب Attack on Titan: Revolution (AOT:R)

- **Auto Kill Titans (Blades) & Auto Thunder Spears:** مع أولوية الزعماء وحارس الـ 20 ثانية الآمن لإنهاء المهمة.
- **Auto Refill (Utgard + All Maps) & Auto Reload Blades:** دعم كامل لجميع الخرائط بما فيها قلعة أوتغارد (`Utgard`).
- **Auto Family Roll:** عبر الريموت المباشر والواجهة مع التوقف التلقائي عند العائلات النادرة (`Yeager / Ackerman / Reiss / Fritz / Helos`).
- **Auto Retry, Auto Skip Cutscene, Auto Raid Chests, Auto Escape Grab.**
