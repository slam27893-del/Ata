# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.2]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - نظام القفز والضرب المتواصل لتطويرة Overhead)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث الجذري (v4.2)؟

### 1️⃣ نظام القفز والضرب المتواصل (`Overhead Jump-Click Engine`) بدون توقف
- **حل سبب توقف الضرب في v4.1 (`block:FireServer(true)`)**: في الإصدار `v4.1` كان إرسال `block:FireServer(true)` بعد كل ضربة يضع اللاعب في وضعية رفع الدرع (`Block`) مما يمنع السيف من التلويح والضرب تماماً! تم إيقاف رفع الدرع أثناء الهجوم (`block:FireServer(false)`) ليصبح السيف حراً للضرب المتواصل بدون أي انقطاع.
- **القفز المستمر مع الكلكات المتواصلة لتفعيل تطويرة `Overhead`**:
  - يقوم اللاعب بالقفز المستمر في الهواء خلف الوحش (`Humanoid.Jump = true` + `Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)` + موجة قفز بارتفاع `2.0` إلى `6.0` خطوات مع سرعة رفع `AssemblyLinearVelocity = Vector3.new(0, 24, 0)`).
  - حلقة كلكات فائقة السرعة (`Loop 2A` كل `0.08` ثانية = أكثر من `12` كلك في الثانية بدون توقف) تجمع بين:
    1. `VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true/false, game, 0)`
    2. `mouse1click()` الخاصة بـ Delta Executor
    3. `VirtualUser:ClickButton1`
    4. `swing:FireServer()` + `onHit:FireServer(...)`
  - بفضل القفز المستمر أثناء الكلكات، تتفعل تطويرة **`Overhead`** في السيف مع كل ضربة وتقضي على الوحوش فوراً مع بف الضرر الخارق (`5,500,000,000%` + `stunDur = 20`).

### 2️⃣ استعادة نظام عدم الانتقال لغرفة الزعيم من الإصدار `v4.0`
- في `v4.1` عادت مشكلة الانتقال لغرفة الزعيم لأن `collectAllPBModels()` عاد لفحص المجلدات الفرعية وقبول النماذج التي لا تملك سمة `hadEntrance` (مما التقط مجسمات غرفة الزعيم المخفية).
- في **`v4.2`** تمت استعادة فلتر **`v4.0`** الصارم (الذي أثبت نجاحه في عدم القفز لغرفة الزعيم والتقدم حتى منتصف الدانجن) مع إضافة مهلة `1.8` ثانية بعد تنظيف كل غرفة قبل تشغيل `checkPBDungeonRoomTransition()` حتى تظهر وحوش الغرفة التالية بهدوء.
