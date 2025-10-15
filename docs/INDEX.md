# UniCheck - Dokumentáció Index

Üdvözlünk a UniCheck projekt dokumentációjában! Ez az index segít eligazodni a különböző dokumentumok között.

## 📚 Dokumentációs Struktúra

### 🏠 Főoldal
- **[README.md](../README.md)** - Projekt fő dokumentációja
  - Projekt áttekintés és célok
  - Funkciók listája (hallgató, oktató, admin)
  - Technológiai stack
  - Gyors telepítési útmutató
  - Használati útmutató
  - Hibaelhárítás
  - Biztonsági megfontolások

### 🏗️ Technikai Dokumentációk

#### [ARCHITECTURE.md](ARCHITECTURE.md)
**Architektúrális dokumentáció** - 649 sor
- Részletes réteg-architektúra
- UI/Prezentációs réteg
- Üzleti logika réteg (GetX Controllers)
- Adat réteg (Models)
- Hálózati réteg (HTTP)
- Perzisztencia réteg (GetStorage)
- Platform natív integráció
- State management részletesen
- Design patterns (MVC, Repository, Singleton, Observer)
- Biztonsági architektúra
- Teljesítmény optimalizálás
- Tesztelhetőség

**Ajánlott kinek:**
- ✅ Új fejlesztők, akik megértik a projekt struktúráját
- ✅ Architektúrális döntések megértéséhez
- ✅ Refactoring tervezéséhez

#### [API.md](API.md)
**API referencia dokumentáció** - 891 sor
- Teljes API endpoint lista
- Request/Response példák minden endpointra
- Autentikációs folyamatok
- Felhasználói endpointok
- Jelenléti endpointok
- Kurzus kezelési endpointok
- Oktatói funkciók
- Admin funkciók
- Státusz kódok
- Rate limiting
- Webhook események
- Dart használati példák

**Ajánlott kinek:**
- ✅ Backend fejlesztők
- ✅ Frontend fejlesztők, akik API-t hívnak
- ✅ API integrációhoz
- ✅ Teszteléshez

#### [NFC_IMPLEMENTATION.md](NFC_IMPLEMENTATION.md)
**NFC HCE implementációs útmutató** - 715 sor
- Mi az a Host Card Emulation (HCE)?
- Előnyök és hátrányok
- Teljes architektúra diagram
- AndroidManifest.xml konfiguráció
- AID (Application ID) beállítása
- Kotlin HCE Service teljes implementáció
- APDU parancsok részletesen (SELECT, GET_CHUNK, GET_LENGTH)
- Status Word (SW) kódok
- MainActivity - Method Channel implementáció
- Flutter oldali használat
- Python NFC olvasó példakód
- Tesztelési módszerek (ADB, fizikai eszközök)
- Hibaelhárítás
- Biztonsági javaslatok (titkosítás, certificate pinning)

**Ajánlott kinek:**
- ✅ NFC fejlesztők
- ✅ Android natív fejlesztők
- ✅ Platform Channel integrációhoz
- ✅ NFC olvasó alkalmazás fejlesztőknek

### 🤝 Közreműködés

#### [CONTRIBUTING.md](CONTRIBUTING.md)
**Közreműködői útmutató** - 621 sor
- Magatartási kódex
- Hogyan járulj hozzá a projekthez
  - Bug jelentések
  - Új funkciók javaslása
  - Dokumentáció javítása
  - Kód hozzájárulás
- Fejlesztői környezet részletes beállítása
- Pre-commit hook-ok
- Kódolási konvenciók (Dart Style Guide)
  - Fájl elnevezés
  - Osztály elnevezés
  - Változó elnevezés
  - Kommentek
  - Widget struktúra
  - Controller struktúra
- Commit üzenet formátum (Conventional Commits)
- Branch elnevezési konvenciók
- Pull Request folyamat lépésről lépésre
- PR template
- Code review folyamat
- Issue reporting template-ek
  - Bug report
  - Feature request
- Tesztelési útmutató
  - Unit tesztek írása
  - Widget tesztek írása
  - Integration tesztek
  - Coverage report

**Ajánlott kinek:**
- ✅ Új közreműködők
- ✅ Open source hozzájárulók
- ✅ Minden fejlesztő, mielőtt PR-t nyit

## 🎯 Gyors Navigáció Célok Szerint

### "Először kezdő vagyok a projektben"
1. Olvasd el: [README.md](../README.md) - Projekt Áttekintés
2. Majd: [README.md](../README.md) - Telepítés és Konfiguráció
3. Aztán: [ARCHITECTURE.md](ARCHITECTURE.md) - Architektúra megértése
4. Végül: [CONTRIBUTING.md](CONTRIBUTING.md) - Fejlesztői környezet

### "API-t szeretnék használni"
1. Olvasd el: [API.md](API.md) - Teljes API referencia
2. Nézd meg: [API.md](API.md) - Példa kódokat

### "NFC funkciót fejlesztek"
1. Olvasd el: [NFC_IMPLEMENTATION.md](NFC_IMPLEMENTATION.md) - Teljes útmutató
2. Nézd meg: [README.md](../README.md) - NFC Implementáció szekció
3. Aztán: [ARCHITECTURE.md](ARCHITECTURE.md) - Platform Natív Integráció

### "Új funkciót szeretnék hozzáadni"
1. Olvasd el: [CONTRIBUTING.md](CONTRIBUTING.md) - Feature Request
2. Majd: [ARCHITECTURE.md](ARCHITECTURE.md) - Design Patterns
3. Nézd meg: [CONTRIBUTING.md](CONTRIBUTING.md) - Pull Request Folyamat

### "Bug-ot találtam"
1. Nézd meg: [README.md](../README.md) - Hibaelhárítás szekció
2. Ha nem oldódott meg: [CONTRIBUTING.md](CONTRIBUTING.md) - Issue Jelentés

### "Teszteket írok"
1. Olvasd el: [CONTRIBUTING.md](CONTRIBUTING.md) - Tesztelés szekció
2. Nézd meg: [ARCHITECTURE.md](ARCHITECTURE.md) - Tesztelhetőség

## 📊 Dokumentáció Statisztikák

| Dokumentum | Sorok | Méret | Témák |
|-----------|-------|-------|-------|
| README.md | 977 | ~46 KB | Általános, Telepítés, Használat |
| API.md | 891 | ~18 KB | API Referencia, Endpointok |
| ARCHITECTURE.md | 649 | ~15 KB | Architektúra, Design Patterns |
| CONTRIBUTING.md | 621 | ~13 KB | Közreműködés, Konvenciók |
| NFC_IMPLEMENTATION.md | 715 | ~23 KB | NFC HCE, Platform Natív |
| **Összesen** | **3,853** | **~115 KB** | **Teljes körű dokumentáció** |

## 🔄 Dokumentáció Verzió

- **Verzió:** 1.0.0
- **Utolsó Frissítés:** 2024-01-15
- **Nyelv:** Magyar 🇭🇺
- **Készítette:** UniCheck Fejlesztői Csapat

## 🎨 Dokumentációs Konvenciók

### Emoji Használat

A dokumentációban következetes emoji használat segíti az olvashatóságot:

- 📖 Tartalomjegyzék, dokumentáció
- 🎯 Cél, célkitűzés
- ✨ Funkció, feature
- 🛠 Technológia, eszközök
- 🏗 Architektúra, struktúra
- 📦 Telepítés, csomag
- 📱 Mobil, UI
- 🔐 Biztonság
- 📡 API, hálózat
- 👨‍💻 Fejlesztői
- 🔧 Hibaelhárítás
- 🤝 Közreműködés
- ✅ Jó gyakorlat, helyes
- ❌ Rossz gyakorlat, helytelen
- ⚠️ Figyelmeztetés
- 💡 Tipp, javaslat
- 🔄 Folyamat, workflow

### Kód Blokkok

````markdown
```dart
// Dart kód
```

```kotlin
// Kotlin kód
```

```bash
# Shell parancsok
```

```json
// JSON adatok
```
````

### Bekezdés Formázás

- **Félkövér** - Fontos fogalmak
- *Dőlt* - Hangsúly
- `kód` - Inline kód vagy fájlnevek
- [Link](#) - Belső/külső linkek

## 🔍 Keresési Tippek

### GitHub-on történő keresés

A dokumentációban való kereséshez használd a GitHub keresőt:

```
repo:ZippoLord/UniCheck NFC implementation
repo:ZippoLord/UniCheck GetX controller
repo:ZippoLord/UniCheck JWT token
```

### Gyakori Kulcsszavak

- **Architektúra:** MVC, GetX, Controller, Model, View, Repository
- **NFC:** HCE, APDU, AID, HostApduService, Method Channel
- **API:** REST, JWT, Token, Authentication, Endpoint
- **UI:** Widget, StatefulWidget, StatelessWidget, Scaffold
- **State:** Rx, Observable, Obx, GetX
- **Platform:** Native, Kotlin, Android, Flutter

## 📞 Támogatás

Ha a dokumentációban nem találod a választ:

1. **GitHub Issues** - [Nyiss issue-t](https://github.com/ZippoLord/UniCheck/issues)
2. **GitHub Discussions** - [Kezdj beszélgetést](https://github.com/ZippoLord/UniCheck/discussions)
3. **Email** - dev@unichez.edu

## 🔗 Hasznos Külső Linkek

### Flutter & Dart
- [Flutter Dokumentáció](https://docs.flutter.dev/)
- [Dart Dokumentáció](https://dart.dev/guides)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Packages](https://pub.dev/)

### GetX
- [GetX Dokumentáció](https://pub.dev/packages/get)
- [GetX GitHub](https://github.com/jonataslaw/getx)

### Android NFC
- [Android NFC Guide](https://developer.android.com/guide/topics/connectivity/nfc)
- [Host Card Emulation](https://developer.android.com/guide/topics/connectivity/nfc/hce)
- [ISO/IEC 7816-4](https://www.iso.org/standard/77180.html)

### API & Security
- [JWT.io](https://jwt.io/)
- [RESTful API Best Practices](https://restfulapi.net/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)

### Tools
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

## 🎓 Tanulási Útvonalak

### Junior Fejlesztő
1. Flutter alapok (1-2 hét)
2. Dart nyelv (1 hét)
3. README.md végigolvasása
4. Egyszerű bug fix egy Good First Issue-val

### Mid-level Fejlesztő
1. GetX state management (3-5 nap)
2. ARCHITECTURE.md tanulmányozása
3. API.md átnézése
4. Új feature implementálása

### Senior Fejlesztő
1. Teljes architektúra review
2. NFC_IMPLEMENTATION.md részletes tanulmányozása
3. Architektúrális döntések
4. Code review és mentorálás

## 📝 Jövőbeli Dokumentációs Tervek

- [ ] Video tutoriálok (YouTube)
- [ ] Interaktív diagramok
- [ ] API Playground
- [ ] Fordítás angolra
- [ ] Wiki oldal létrehozása
- [ ] FAQ szekció
- [ ] Troubleshooting decision tree
- [ ] Performance tuning guide
- [ ] Deployment guide (CI/CD)
- [ ] Docker support dokumentáció

## ⭐ Visszajelzés

Ha javaslatod van a dokumentációval kapcsolatban:
- Nyiss egy issue-t "Documentation" címkével
- Vagy küldj Pull Request-et
- Minden visszajelzést nagyra értékelünk! 🙏

---

**Köszönjük, hogy használod a UniCheck-et!** 🎉

*Ez a dokumentáció a projekt részét képezi és folyamatosan frissül.*
