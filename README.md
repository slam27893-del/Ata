# 🛡️ Delta Multi-Game Hub v3.0 [Attack on Titan: Revolution + Pixel Blade]

سكربت شامل ومتعدد الألعاب (**Multi-Game Hub**) يعمل بنفس الرابط الواحد تلقائياً على كلٍ من:
1. ⚔️ **Attack on Titan: Revolution (AOT:R)** (جميع الخرائط بما فيها أوتغارد Utgard + الغارات Raids + لفات العائلات).
2. 🗡️ **Pixel Blade** (فارم الدنجن والغرف تلقائياً + فارم الغارات + Kill Aura + تقوية الضرر الخارق والشفاء + فتح الصناديق والأمنيات + دخول البوابات تلقائياً).

مزود **بحفظ تلقائي للإعدادات وتشغيل تلقائي بين الغارات والدنجن (`Auto-Save & Queue On Teleport`)** + **نظام حماية متعدد الطبقات (`Multi-Layer Anti-Ban & Stealth Protection`)** لمشغل **Delta Executor** (أندرويد، iOS، والكمبيوتر).

---

## 🚀 رابط التشغيل الموحد في دلتا (Delta Executor)

نفس السطر يشتغل تلقائياً في اللعبتين (يتعرف على الماب الذي دخلته ويفتح تبويباته تلقائياً):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🗡️ مميزات ماب Pixel Blade (جديد في v3.0)

1. **⚔️ قسم الفارم والقتال (`🗡️ Pixel Blade قتال`):**
   - **Auto Farm Dungeon:** الانتقال التلقائي لأقرب وحش حي، تخطي الغرف (`7`, `8`, `9` حسب الصعوبة `Normal` / `Heroic` / `Nightmare`)، والتعامل الخاص مع الزعماء (`Atticus`, `Maneater`, `Nekros`, `DarkNekros`) مع تفعيل `Noclip` وتثبيت السرعة.
   - **Auto Farm Raids:** فارم الغارات التلقائي وقتل زعماء الرايد.
   - **Kill Aura + Tornado:** ضرب جميع الأعداء المحيطين بك تلقائياً (`onHit` + `useAbility: tornado` + `abilityHit`).
   - **God Buff & Auto Heal:** تفعيل تقوية الضرر والسرعة (`tempbuff`) والشفاء التلقائي المستمر (`heal`).
   - **Auto Breakables:** تكسير الصناديق والأغراض القابلة للكسر في الماب تلقائياً.
   - **Expand Enemy Hitbox:** تكبير هيت بوكس الأعداء مع التحكم بالحجم.

2. **🎁 قسم الترقيات والصناديق والبوابات (`🎁 Pixel صناديق وبوابات`):**
   - **Auto Pick Upgrade & Hide Popup:** اختيار بطاقات الترقية تلقائياً أثناء الدنجن وإخفاء نافذة الترقية المزعجة.
   - **Auto Open All Chests:** فتح جميع الصناديق الموجودة في الحقيبة (`Loot`) تلقائياً.
   - **Auto Open Wishes:** فتح الأمنيات (`Wishes`) تلقائياً.
   - **Auto Claim Daily Quests & Achievements:** استلام جوائز المهام اليومية والإنجازات تلقائياً.
   - **Auto Join Dungeon Portal:** اختيار البوابة (`Grasslands` / `AncientSands`) والصعوبة (`Normal` / `Heroic` / `Nightmare`) والدخول التلقائي المستمر مع حفظ الإعدادات وتشغيل السكربت تلقائياً داخل الدنجن!

---

## ⚔️ مميزات ماب Attack on Titan: Revolution (AOT:R)

- **Auto Kill Titans (Blades) & Auto Thunder Spears:** مع أولوية الزعماء وحارس الـ 20 ثانية الآمن لإنهاء المهمة.
- **Auto Refill (Utgard + All Maps) & Auto Reload Blades:** دعم كامل لجميع الخرائط بما فيها قلعة أوتغارد (`Utgard`).
- **Auto Family Roll:** عبر الريموت المباشر والواجهة مع التوقف التلقائي عند العائلات النادرة (`Yeager / Ackerman / Reiss / Fritz / Helos`).
- **Auto Retry, Auto Skip Cutscene, Auto Raid Chests, Auto Escape Grab.**
