# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.5]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - استعادة تنقل الغرف السليم من v4.3 + تفعيل الكلكات الفعلية عبر Character.localChar + أولوية الأعداء البعيدين)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث الجذري (v4.5)؟

### 1️⃣ استعادة تنقل الغرف السليم 100% من `v4.3` ومنع القفز لغرفة البوس نهائياً
- **لماذا عادت مشكلة غرفة البوس في `v4.4`؟**
  - في `v4.4` كان `currentRangedMob` لا يشترط `hadEntrance == true` وكان `nextAdjacentRangedMob` يتجاوز أقرب وحش بمسافة `+30` خطوة، بالإضافة إلى قائمة التجاهل المؤقت `PB_LockedMobIgnoreUntil` التي كانت تتخطى الغرفة الثانية ثم الثالثة وصولاً لغرفة البوس عند تأخر فتح الباب!
- **الحل في `v4.5`**:
  - استعادة منطق التنقل الدقيق من `v4.3` بالكامل، وحصر أولوية الأعداء البعيدين (`pbIsRangedEnemy`) على **الأعداء المفعلين فقط داخل الغرفة الحالية (`hadEntrance == true`)** مع استبعاد جميع الزعماء (`PB_BOSS_NAMES`) وإزالة `nextAdjacentRangedMob` و `PB_LockedMobIgnoreUntil` نهائياً.

### 2️⃣ إصلاح جذري للكلكات والقفز بالسيف (`Overhead` Jump-Click) 🗡️
- **إلغاء `blockRemote:FireServer` نهائياً**: كان إرسال `blockRemote` عند بدء التشغيل يضع الشخصية في حالة صد (Block) على السيرفر مما يمنع تلويح السيف والكلكات.
- **استدعاء دوال الضرب الأصلية داخل `Character.localChar` مباشرة (`pbGetLocalCharSwingTriggers`)**:
  - يستخرج السكربت دوال `UserInputService.InputBegan` و `Mouse.Button1Down` ودوال `"swing"` من داخل `Character.localChar` عبر `getconnections` و `getgc` (يتم تخزينها مرة واحدة فقط عند ظهور الشخصية بدون أي لاق) ويستدعيها مباشرة مع `MouseButton1` و `gameProcessed = false` حتى على الجوال!
- **عدم قفل `HumanoidRootPart.CFrame` عندما تكون المسافة أقل من `10` خطوات (طريقة `thha3203` الأصلية)**:
  - في السابق كان تحديث `CFrame` المستمر والرفع بمقدار `+3.5` يمنع قدمي اللاعب من لمس الأرض فيلغي القفز والتلويح بالسيف؛ الآن عند الاقتراب (`dist < 10`) يتوقف تعديل `CFrame` تماماً ليقفز اللاعب بحرية (`Humanoid.Jump = true`) ويضرب كلكات متواصلة لتفعيل تطويرة **`Overhead`**.
