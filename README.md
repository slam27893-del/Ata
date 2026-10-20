# ⚔️🗡️ Multi-Game Delta Hub [PROTECTED v4.9]

سكربت شامل ومحمي بالكامل لتطبيق **Delta Executor** (جوال Android / iOS وكمبيوتر PC) يدعم لعبتين في رابط واحد مع **كشف تلقائي للعبة وعزل كامل للتبويبات**:

1. **🗡️ Pixel Blade (بكسل بليد - يدعم تحديث World 5: The Sunken Depths / حدث CHRONOS Arc 2 - أوتو كليكر آمن 100% بدون كراش + أولوية قصوى للأعداء المعالجين والمستنزفين + ثبات تنقل الغرف من v4.6 بدون أي لاق)**
2. **⚔️ Attack on Titan: Revolution (هجوم العمالقة: الثورة - AOT:R)**

---

## 📲 كود التشغيل المباشر في Delta Executor

انسخ السطر التالي وضعه في **Delta Executor** ثم اضغط **Execute** داخل أي من اللعبتين:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"))()
```

---

## 🔥 ما الجديد في التحديث (v4.9)؟

### 1️⃣ إصلاح ظهور الواجهة وإزالة الكراش نهائياً (`v4.9 Syntax & Crash Fix`) 🛡️
- **سبب عدم ظهور الواجهة في `v4.8`**: كان هناك خطأ في ترتيب `else ... elseif` عند السطر `3345` داخل `Loop 2F` تسبب في إيقاف تحميل ملف `loadstring` قبل بناء الواجهة.
- **الحل في `v4.9`**:
  - تصحيح ترتيب `elseif Config.PB_AutoClicker and HumanoidRootPart then ... else` بالكامل والتحقق الآلي من قواعد اللغة (`if/elseif/else/end`) في كامل الملف.
  - الإبقاء على نظام الأوتو كليكر الآمن 100% عبر `VirtualInputManager:SendMouseButtonEvent` بدون أي دوال تسبب كراش على الجوال (`VirtualUser` / `firesignal` / `getconnections`).
  - الإبقاء على **أولوية الأعداء الذين يستنزفون أو يعالجون الأعداء الآخرين (`💉 [معالج/مستنزف]`) كأولوية رقم #1** مع تنقل الغرف السليم من `v4.6` بدون أي لاق.
