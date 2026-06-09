# Manejo de datos actual

La app usa una base de datos local simulada en memoria.

Archivo principal:

`lib/core/services/client_database_service.dart`

## Que contiene

- Lista precargada de clientes.
- Login por tipo de documento, número de documento y contraseña.
- Registro de nuevos clientes durante la sesión.
- Cliente actualmente autenticado.
- Cambio de contraseña funcional.

## Clientes precargados

| Tipo | Documento | Contraseña | Nombre |
| --- | --- | --- | --- |
| DNI | 12345678 | 123456 | Ana Martinez |
| CC | 1002003004 | credito1 | Carlos Gomez |
| CE | A123456 | ahorro1 | Mariana Rojas |

## Limitacion importante

Los datos viven en memoria mientras la app esta abierta. Si la app se cierra o se reinstala, los cambios se pierden.

Para produccion se recomienda migrar esta capa a:

- SQLite local, usando `sqflite` o `drift`, si se quiere persistencia offline.
- Firebase/Supabase/API propia, si se quiere una base de datos real en servidor.
- Backend con autenticación segura, hash de contraseñas y tokens de sesión.
