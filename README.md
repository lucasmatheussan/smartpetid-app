# SmartPet ID • App Flutter

Aplicativo Flutter com fluxo de login, cadastro/listagem de animais, identificação por imagem, leitura de QR e RFID/NFC.

## Pré‑requisitos
- Flutter SDK
- Xcode (para iOS) / Android Studio (para Android)

## Configuração
Instalar dependências:
```bash
flutter pub get
```

Configurar URL do backend (se necessário):
Editar `lib/services/pet_identification_service.dart` e ajustar `baseUrl` para o host onde o backend está rodando (ex.: `http://192.168.x.x:8000`).

## Execução
Web (debug):
```bash
flutter run -d chrome
```

iOS (dispositivo físico):
```bash
flutter devices      # conferir device
flutter run -d <deviceId>
```

Android (dispositivo físico ou emulador):
```bash
flutter run -d <deviceId>
```

## Funcionalidades
- Login/Registro de usuário
- Cadastro e listagem de pets
- Identificação por imagem
- Ler QRCode (menu “Ler QRCode”) → abre o animal
- Ler RFID/NFC (menu “Ler RFID”) → lê NDEF e abre o animal
- Gravar RFID no animal (botão “Gravar RFID” na tela de detalhes)

## NFC/RFID (iOS/Android)
- Android: permissões NFC já incluídas no `AndroidManifest.xml`.
- iOS: para ler/gravar RFID em dispositivo físico é necessário:
  - Conta Apple Developer paga
  - Provisionamento com capacidade “Near Field Communication Tag Reading”
  - Entitlements já configurados para Release/Profile

Sem essa capacidade, o app instala e roda, mas a leitura RFID exibirá “NFC/RFID não disponível neste dispositivo”.

## Dicas
- Mantenha o iPhone desbloqueado ao testar NFC/RFID.
- O leitor aceita NDEF Texto `focinhoid:pet:<id>` e URI `.../pets/<id>`.
