# Közreműködői Útmutató (CONTRIBUTING)

Köszönjük, hogy érdeklődsz a UniCheck projekt fejlesztése iránt! Ez a dokumentum útmutatást nyújt ahhoz, hogyan járulhatsz hozzá a projekthez.

## Tartalomjegyzék

1. [Magatartási Kódex](#magatartási-kódex)
2. [Hogyan Járulhatok Hozzá?](#hogyan-járulhatok-hozzá)
3. [Fejlesztői Környezet Beállítása](#fejlesztői-környezet-beállítása)
4. [Kódolási Konvenciók](#kódolási-konvenciók)
5. [Commit Útmutató](#commit-útmutató)
6. [Pull Request Folyamat](#pull-request-folyamat)
7. [Issue Jelentés](#issue-jelentés)
8. [Tesztelés](#tesztelés)

## Magatartási Kódex

### Elvárásaink

A projekt közreműködőitől elvárjuk, hogy:

- ✅ Legyenek tiszteletteljesek és befogadóak
- ✅ Konstruktív visszajelzést adjanak
- ✅ Fogadják el a kritikát
- ✅ Tartsák tiszteletben mások idejét és erőfeszítéseit
- ❌ Ne használjanak diszkriminatív vagy sértő nyelvezetet
- ❌ Ne végezzenek személyeskedést vagy trollkodást

## Hogyan Járulhatok Hozzá?

Többféleképpen is hozzájárulhatsz a projekthez:

### 1. 🐛 Bug Jelentések

Ha hibát találsz:
1. Ellenőrizd, hogy nincs-e már jelentve az [Issues](https://github.com/ZippoLord/UniCheck/issues) között
2. Nyiss egy új issue-t részletes leírással
3. Add meg a reprodukálás lépéseit
4. Csatolj képernyőképeket, ha lehetséges

### 2. ✨ Új Funkciók Javaslása

Új funkció ötleted van?
1. Nyiss egy **Feature Request** issue-t
2. Írd le részletesen a funkciót
3. Indokold meg, miért lenne hasznos
4. Várj visszajelzésre a fenntartóktól

### 3. 📝 Dokumentáció Javítása

A dokumentáció mindig fejleszthető:
- Helyesírási hibák javítása
- Példák hozzáadása
- Magyarázatok tisztázása
- Fordítások javítása

### 4. 💻 Kód Hozzájárulás

Kód hozzájárulás előtt:
1. Nézd meg a [Good First Issues](https://github.com/ZippoLord/UniCheck/labels/good%20first%20issue) címkét
2. Kommenteld, hogy dolgozol rajta
3. Fork-old a repository-t
4. Dolgozz egy külön branch-en
5. Nyiss Pull Request-et

## Fejlesztői Környezet Beállítása

### Előfeltételek

```bash
# Flutter ellenőrzés
flutter --version
# Legalább 3.9.2 kell

# Dart ellenőrzés
dart --version
# Legalább 3.9.2 kell
```

### Projekt Klónozása

```bash
# Fork-old a projektet GitHub-on, majd:
git clone https://github.com/YOUR_USERNAME/UniCheck.git
cd UniCheck

# Upstream beállítása
git remote add upstream https://github.com/ZippoLord/UniCheck.git
```

### Függőségek Telepítése

```bash
# Flutter függőségek
flutter pub get

# Android build tools frissítése (opcionális)
cd android
./gradlew --refresh-dependencies
cd ..
```

### Linter Beállítása

A projekt `analysis_options.yaml` fájlt használ:

```bash
# Linting futtatása
flutter analyze

# Auto-fix lehetőség
dart fix --apply
```

### Pre-commit Hook Beállítása (Ajánlott)

```bash
# .git/hooks/pre-commit fájl létrehozása
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
flutter analyze
if [ $? -ne 0 ]; then
  echo "Flutter analyze failed. Please fix errors before committing."
  exit 1
fi

flutter format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "Code not formatted. Run 'flutter format .' before committing."
  exit 1
fi
EOF

chmod +x .git/hooks/pre-commit
```

## Kódolási Konvenciók

### Dart Stílus

Kövessük a [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)-ot.

#### Fájl Elnevezés

```dart
// ✅ Helyes - snake_case
login_page.dart
user_profile_controller.dart

// ❌ Helytelen
LoginPage.dart
UserProfileController.dart
```

#### Osztály Elnevezés

```dart
// ✅ Helyes - PascalCase
class LoginController extends GetxController {}
class UserModel {}

// ❌ Helytelen
class loginController extends GetxController {}
class user_model {}
```

#### Változó és Metódus Elnevezés

```dart
// ✅ Helyes - camelCase
String userName = "János";
void loginFunction() {}

// ❌ Helytelen
String UserName = "János";
void LoginFunction() {}
```

#### Privát Változók

```dart
// ✅ Helyes
class MyController extends GetxController {
  RxBool _isLoading = false.obs;  // Privát
  bool get isLoading => _isLoading.value;
}
```

### Kommentek

```dart
// Egyszerű magyarázatok - egy soros komment
// Bonyolultabb logikánál

/// Dokumentációs komment osztályokhoz és publikus metódusokhoz
/// 
/// Ez a metódus bejelentkezteti a felhasználót.
/// 
/// Paraméterek:
/// - [data]: JSON string a login adatokkal
void loginFunction(String data) {
  // Implementáció
}
```

### Widget Struktúra

```dart
class MyWidget extends StatelessWidget {
  // 1. Konstans konstruktor
  const MyWidget({super.key});

  // 2. Mezők
  final String title;
  
  // 3. Build metódus
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 4. Segéd metódusok
  void _helperMethod() {}
}
```

### GetX Controller Struktúra

```dart
class MyController extends GetxController {
  // 1. Reaktív változók (privát)
  final RxBool _isLoading = false.obs;
  final RxString _data = ''.obs;
  
  // 2. Getterek/Setterek
  bool get isLoading => _isLoading.value;
  set setLoading(bool value) => _isLoading.value = value;
  
  // 3. Lifecycle metódusok
  @override
  void onInit() {
    super.onInit();
  }
  
  @override
  void onClose() {
    super.onClose();
  }
  
  // 4. Publikus metódusok
  Future<void> fetchData() async {}
  
  // 5. Privát metódusok
  void _processData() {}
}
```

### Konstansok

```dart
// constants.dart fájlban
const String kBaseUrl = "http://localhost:5188";
const int kTimeoutDuration = 30;
const double kButtonHeight = 48.0;
```

## Commit Útmutató

### Commit Üzenet Formátum

Használjuk a [Conventional Commits](https://www.conventionalcommits.org/) formátumot:

```
<típus>(<scope>): <rövid leírás>

<részletes leírás - opcionális>

<footer - opcionális>
```

### Commit Típusok

| Típus | Leírás | Példa |
|-------|--------|-------|
| `feat` | Új funkció | `feat(auth): add biometric login` |
| `fix` | Hibajavítás | `fix(nfc): resolve connection timeout` |
| `docs` | Dokumentáció | `docs(readme): update installation guide` |
| `style` | Formázás | `style(login): format code with dart format` |
| `refactor` | Kód átstrukturálás | `refactor(controllers): extract common logic` |
| `test` | Tesztek | `test(auth): add login controller tests` |
| `chore` | Build/tooling | `chore(deps): update flutter to 3.10` |
| `perf` | Teljesítmény | `perf(list): optimize list rendering` |

### Példa Commitok

```bash
# Egyszerű commit
git commit -m "feat(attendance): add QR code scanning"

# Részletes commit
git commit -m "fix(nfc): resolve HCE service crash

The HCE service was crashing when handling large JSON payloads.
This fix implements chunked transfer to handle payloads of any size.

Closes #123"
```

### Commit Legjobb Gyakorlatok

- ✅ Egy commit = egy logikai változtatás
- ✅ Rövid, de leíró üzenetek
- ✅ Imperatív hangnem ("add" nem "added")
- ✅ Issue referencia, ha van (Closes #123)
- ❌ "WIP" vagy "test" commit üzenetek
- ❌ Több független változtatás egy commitban

## Pull Request Folyamat

### 1. Branch Létrehozása

```bash
# Frissítsd a main branch-et
git checkout main
git pull upstream main

# Új feature branch
git checkout -b feature/my-feature

# Vagy bugfix branch
git checkout -b fix/issue-123
```

### Branch Elnevezési Konvenciók

```
feature/feature-name    # Új funkció
fix/issue-number       # Hibajavítás
docs/what-changed      # Dokumentáció
refactor/what-changed  # Refactor
test/what-tested       # Tesztek
```

### 2. Fejlesztés

```bash
# Változtatások
git add .
git commit -m "feat(scope): description"

# További commitok...
git commit -m "test(scope): add tests"
```

### 3. Pull Request Létrehozása

```bash
# Push a branch-re
git push origin feature/my-feature
```

Majd GitHub-on:
1. Nyiss Pull Request-et
2. Válaszd ki a base branch-et (általában `main`)
3. Töltsd ki a PR template-et

### PR Template

```markdown
## Változtatások Leírása

Rövid leírás arról, mit változtattál.

## Típus

- [ ] Új funkció
- [ ] Hibajavítás
- [ ] Dokumentáció
- [ ] Refaktorálás
- [ ] Egyéb (írd le):

## Tesztelés

Hogyan tesztelted a változtatásokat?

- [ ] Unit tesztek
- [ ] Widget tesztek
- [ ] Manuális tesztelés
- [ ] Még nem teszteltem

## Screenshots (ha releváns)

Adj hozzá képernyőképeket a UI változtatásokról.

## Checklist

- [ ] Kódom követi a projekt stílust
- [ ] Futtattam `flutter analyze`-t
- [ ] Futtattam `flutter format .`-ot
- [ ] Teszteltem Android eszközön
- [ ] Frissítettem a dokumentációt
- [ ] Commit üzeneteim megfelelőek

## Related Issues

Closes #123
```

### 4. Code Review

- Várj visszajelzésre a maintainerektől
- Válaszolj a kommentekre
- Eszközölj változtatásokat, ha szükséges

```bash
# További változtatások
git add .
git commit -m "fix: address review comments"
git push origin feature/my-feature
```

### 5. Merge

Miután a PR jóváhagyásra került:
- A maintainerek merge-elik
- A branch törölhető

```bash
# Branch törlése lokálisan
git branch -d feature/my-feature

# Remote branch törlése
git push origin --delete feature/my-feature
```

## Issue Jelentés

### Bug Report Template

```markdown
**Bug Leírása**
Világos és rövid leírás a hibáról.

**Reprodukálás**
Lépések a hiba reprodukálásához:
1. Menj a '...'
2. Kattints a '...'
3. Scroll down to '...'
4. Megjelenik a hiba

**Elvárt Viselkedés**
Mit vártál, hogy történjen.

**Tényleges Viselkedés**
Mi történt valójában.

**Screenshots**
Ha releváns, adj hozzá képernyőképeket.

**Környezet:**
 - Eszköz: [pl. Samsung Galaxy S21]
 - OS: [pl. Android 12]
 - App verzió: [pl. 1.0.0]
 - Flutter verzió: [pl. 3.9.2]

**További Kontextus**
Bármilyen más információ a problémáról.

**Logok**
```
Ide illeszd be a relevéns logokat
```
```

### Feature Request Template

```markdown
**Funkció Leírása**
Világos és rövid leírás az új funkcióról.

**Probléma Megoldása**
Milyen problémát old meg ez a funkció?

**Javasolt Megoldás**
Hogyan képzeled el ezt a funkciót?

**Alternatívák**
Más megoldások, amiket fontolóra vettél.

**További Kontextus**
Bármilyen más információ vagy screenshot.

**Prioritás**
- [ ] Kritikus
- [ ] Fontos
- [ ] Nice to have
```

## Tesztelés

### Unit Tesztek Írása

```dart
// test/controllers/login_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prog24/controllers/login_controller.dart';

void main() {
  group('LoginController', () {
    late LoginController controller;

    setUp(() {
      controller = LoginController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial loading state should be false', () {
      expect(controller.isLoading, false);
    });

    test('setLoading should update loading state', () {
      controller.setLoading = true;
      expect(controller.isLoading, true);
      
      controller.setLoading = false;
      expect(controller.isLoading, false);
    });
  });
}
```

### Widget Tesztek Írása

```dart
// test/widgets/custom_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prog24/widgets/customButton.dart';

void main() {
  testWidgets('CustomButton renders with text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Test Button',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('CustomButton triggers onTap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Test',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(tapped, true);
  });
}
```

### Tesztek Futtatása

```bash
# Összes teszt
flutter test

# Egy fájl tesztelése
flutter test test/controllers/login_controller_test.dart

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Integration Tesztek

```bash
# Integration tesztek futtatása
flutter drive --target=test_driver/app.dart
```

## Kérdések?

Ha kérdésed van:
1. Nézd meg a meglévő dokumentációt
2. Keresd meg a [Discussions](https://github.com/ZippoLord/UniCheck/discussions) között
3. Nyiss egy új discussion-t
4. Vagy írj emailt: dev@unichez.edu

## Köszönetnyilvánítás

Minden hozzájárulást nagyra értékelünk! 🎉

A projekt fenntartói:
- [@ZippoLord](https://github.com/ZippoLord)

---

**Verzió:** 1.0.0  
**Utolsó Frissítés:** 2025-01-15
