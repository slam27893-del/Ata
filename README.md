# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.4]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - إصلاح جذري للكلكات والقفز على الجوال + أولوية الأعداء البعيدين مثل القوس والسحر + صفر لاق)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث الجذري (v4.4)؟

### 1️⃣ إصلاح جذري للكلكات والقفز بالسيف على الجوال (`Overhead` Jump-Click Fix)
- **إصلاح خطأ `ScreenGui` في `pbGetMobileCombatButtons()`**: في `v4.3` كان الفحص يستدعي `obj:IsDescendantOf(ScreenGui)` قبل تعريف المتغير `ScreenGui` مما كان يوقف البحث عن أزرار الجوال عند أول عنصر؛ تم ربطه الآن بـ `State.HubScreenGui` مع تخزين مؤقت (`Cache` لمدة `4.0` ثوانٍ بدون أي لاق) لزر السيف (`🗡️`) وزر القفز (`^`) وجميع الـ `Connections` الخاصة بهما.
- **إصلاح جدول `env.dashCD` داخل `Character.localChar`**: منع استبدال جدول `dashCD` بالرقم `0` حتى لا يتوقف سكربت الشخصية الأساسي المسؤول عن تلويح السيف (`localChar`) عن العمل، وتفريغ الجدول بالطريقة الصحيحة مع تصفير تباطؤ السلاح (`env.weapon`).
- **تطبيق مدة ضغطة الكلك الفعلي (`0.045s Hold Duration`) وتمرير `InputObject` كامل**: محاكاة الضغطة واللمس الحقيقي (`SendMouseButtonEvent` و `SendTouchEvent` و `InputBegan` مع كائن `Touch` / `MouseButton1` كامل) أثناء القفز المستمر لتفعيل تطويرة **`Overhead`** في السيف بلا توقف.

### 2️⃣ الأولوية القصوى للأعداء الذين يضربون من بعيد (القوس، السحر، المدافع، العيون، إلخ) 🏹🪄
- إضافة نظام كشف ذكي وسريع جداً (`pbIsRangedEnemy` مع `Weak Table Cache` يفحص كل عدو مرة واحدة فقط عند ظهوره بدون أي لاق `O(1)`) يتعرف على جميع وحوش القوس والسحر والمدافع والمقذوفات في جميع العوالم (`Archer`, `Bow`, `Crossbow`, `Mage`, `Wizard`, `Witch`, `MoonWitch`, `CorruptMoonWitch`, `Eyeball`, `CorruptEyeBall`, `FleshCannon`, `InfestedTree`, `Summoner`, `Cultist`, `Priest`, `Shaman`, `Warlock`, `Necromancer`, إلخ) وكذلك أي وحش يحمل سلاحاً بعيد المدى (`Bow`, `Staff`, `Wand`, `Spellbook`, `Orb`, `Crossbow`, `Cannon`, `Arrow`).
- داخل الغرفة الحالية، يقوم اللاعب **بتصفية جميع الأعداء البعيدين (القوس/السحر) أولاً** قبل الانتقال لأي وحش قريب المدى، مع الحفاظ التام على نظام التنقل السليم بين الغرف الذي تم حله في `v4.3`.

### 3️⃣ أداء فائق السلاسة بدون أي لاق (`Zero Lag Guaranteed`)
- تخزين تصنيف الأعداء البعيدين لكل وحش في الذاكرة المؤقتة (`O(1)`) وتخزين أزرار الجوال واتصالاتها لمدة `4.0` ثوانٍ بحيث يعمل السكربت بأقصى سرعة وبدون أي تقطيع.
