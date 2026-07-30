# 🚕 Tezkor Taksi - Flutter & Firebase Mobil Ilovasi

Ushbu loyiha **Flutter (Dart)** va **Firebase Firestore** yordamida yaratilgan zamonaviy, minimalistik hamda UI/UX standartlariga javob beruvchi taksi chaqirish ilovasi. 

Loyiha ikkita asosiy rolni o'z ichiga oladi: **Mijoz (Customer)** va **Haydovchi (Driver)**.

---

## 🎨 Dizayn xususiyatlari

- **Ranglar palitrasi:**
  - Asosiy rang: To'q ko'k (`#1E293B` - Slate 800)
  - Urg'u rangi: Oltinsimon taksi rangi (`#F59E0B` - Amber 500)
  - Orqa fon: Yorug' va toza (`#F8FAFC` - Slate 50)
- **Vizual UI/UX:** 16px Border Radius, yumshoq `BoxShadow` soyalar, moslashuvchan responsive interfeys hamda Google Fonts (Inter) shriftlari.

---

## 📁 Loyiha Strukturasi (Clean Architecture & Provider)

```text
taxi_app/
├── pubspec.yaml                        # Kutubxonalar va bog'liqliklar
├── README.md                           # Qollanma va yo'riqnoma
└── lib/
    ├── main.dart                       # Ilova kirish nuqtasi hamda Provider/Firebase sozlamalari
    ├── theme/
    │   └── app_theme.dart              # Ranglar, shriftlar va komponent stillari to'plami
    ├── models/
    │   └── order_model.dart            # Firestore ser/deser va Order modeli
    ├── services/
    │   └── firebase_service.dart       # Firestore CRUD, Stream va Demo Fallback servisi
    ├── providers/
    │   └── taxi_provider.dart          # ChangeNotifier holatni boshqarish (State Management)
    ├── widgets/
    │   ├── custom_button.dart          # Reusable zamonaviy tugma
    │   ├── custom_text_field.dart      # Material 3 input maydoni
    │   └── order_card.dart             # Mijoz va haydovchi uchun dinamik buyurtma kartochkasi
    └── screens/
        ├── role_selection_screen.dart  # Rolni tanlash ekrani (Mijoz / Haydovchi)
        ├── customer/
        │   └── customer_screen.dart    # Mijoz ekrani (Forma & Real-time status)
        └── driver/
            └── driver_screen.dart      # Haydovchi ekrani (Switch & Live Feed)
```

---

## ⚡ Qanday ishga tushirish (Getting Started)

### 1. Bog'liqliklarni o'rnatish
Loyiha papkasida quyidagi buyruqni bajaring:

```bash
flutter pub get
```

### 2. Firebase Sozlamalari (Firestore Setup)

Firebase loyihangizni ulash uchun:
1. [Firebase Console](https://console.firebase.google.com/) da yangi loyiha yarating.
2. Android uchun `google-services.json` faylini yuklab olib, `android/app/` papkasiga joylashtiring.
3. iOS uchun `GoogleService-Info.plist` faylini yuklab olib, `ios/Runner/` papkasiga joylashtiring.
4. Yoki `flutterfire configure` CLI yordamida `firebase_options.dart` faylini hosil qiling.

#### Firestore Rules (Xavfsizlik qoidalari):
Firebase Console -> Firestore Database -> Rules bo'limiga quyidagilarni kiriting:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /orders/{orderId} {
      allow read, write: if true; // Ishlab chiqish davrida ochiq rejim
    }
  }
}
```

---

## 📞 `url_launcher` Sozlamalari (Telefon qilish uchun)

### Android (`android/app/src/main/AndroidManifest.xml`):
`<manifest>` tegi ichiga quyidagini qo'shing:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.DIAL" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

### iOS (`ios/Runner/Info.plist`):
`<dict>` tegi ichiga quyidagilarni qo'shing:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
</array>
```

---

## 🚀 Ilovani ishga tushirish

```bash
flutter run
```

> **Eslatma:** Dastur ichida o'rnatilgan **Demo Mode (Fallback)** mexanizmi bor. Firebase ulanmagan yoki test rejimida bo'lgan taqdirda ham ilova xatoliksiz, in-memory stream shaklida to'liq ishlaydi!
