# Conexion Firestore - App Cliente

La app ya tiene una capa Firestore para los modulos:

- Inicio
- Ahorros
- Créditos
- Operar

Archivo central:

`lib/core/services/financial_firestore_service.dart`

## Estado actual

Firebase esta preparado, pero falta completar credenciales reales en:

`lib/firebase_options.dart`

Mientras `DefaultFirebaseOptions.isConfigured` siga en `false`, la app usa datos locales para poder compilar y probar sin Firebase.

Cuando tengas tu proyecto Firebase:

1. Crea un proyecto en Firebase.
2. Activa Cloud Firestore.
3. Registra la app Android con el package:
   `com.example.financiera_efectiva`
4. Ejecuta FlutterFire CLI o copia las opciones reales en `lib/firebase_options.dart`.
5. Cambia:
   `static const bool isConfigured = false;`
   por:
   `static const bool isConfigured = true;`

## Colecciones esperadas

Raiz:

`clients/{clientId}`

Documento cliente ejemplo:

```json
{
  "totalBalance": 2450000,
  "savingsBalance": 1800000,
  "activeLoansBalance": 650000
}
```

Subcoleccion movimientos:

`clients/{clientId}/movements/{movementId}`

```json
{
  "title": "Deposito cuenta de ahorro",
  "date": "19/05/2026",
  "amount": 250000,
  "isIncome": true,
  "createdAt": "serverTimestamp"
}
```

Cuenta de ahorros:

`clients/{clientId}/savings/main`

```json
{
  "number": "AHO-102938",
  "balance": 1800000,
  "status": "Activa"
}
```

Depositos:

`clients/{clientId}/deposits/{depositId}`

```json
{
  "date": "19/05/2026",
  "amount": 250000,
  "reference": "DEP-001",
  "createdAt": "serverTimestamp"
}
```

Estados de cuenta:

`clients/{clientId}/statements/{statementId}`

```json
{
  "period": "Mayo 2026",
  "openingBalance": 1550000,
  "closingBalance": 1800000,
  "createdAt": "serverTimestamp"
}
```

Crédito activo:

`clients/{clientId}/credits/activeLoan`

```json
{
  "id": "CRE-44882",
  "amount": 3000000,
  "pendingBalance": 650000,
  "status": "Al dia"
}
```

Cuotas:

`clients/{clientId}/installments/{installmentId}`

```json
{
  "number": 1,
  "dueDate": "05/04/2026",
  "amount": 180000,
  "isPaid": true
}
```

Operaciones:

`clients/{clientId}/operations/{operationId}`

Las pantallas de transferencia y pago ya escriben aqui cuando Firebase esta configurado.

```json
{
  "type": "Transferencia",
  "amount": 120000,
  "status": "Exitosa",
  "date": "19/5/2026",
  "destinationAccount": "AHO-0001",
  "description": "Pago familiar",
  "createdAt": "serverTimestamp"
}
```

## Autenticacion con Firebase Auth

El login y el registro usan Firebase Authentication con correo y contraseña.

Archivos:

- `lib/core/services/firebase_auth_service.dart`
- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/register_screen.dart`
- `lib/features/auth/presentation/forgot_password_screen.dart`

Al registrar un usuario, Firebase Auth crea la cuenta y la app crea/actualiza
un documento en:

`clients/{uid}`

El `uid` de Firebase Auth se usa como identificador del cliente para leer los
modulos financieros en Firestore.

## Recuperación de contraseña

La pantalla `Olvidaste tu contraseña?` usa Firebase Authentication.

Archivo:

`lib/core/services/password_reset_service.dart`

La app llama `sendPasswordResetEmail(email)`, y Firebase envia el correo
oficial de restablecimiento al usuario.

No se guardan contraseñas planas en Firestore.
