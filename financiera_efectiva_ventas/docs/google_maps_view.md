# Vista de Google Maps

La vista de ruta usa `google_maps_flutter` para mostrar mapa real, marcadores y polyline.

## Android

En `android/local.properties`, agregar:

```properties
googleMapsApiKey=TU_API_KEY_DE_GOOGLE_MAPS
```

`android/local.properties` ya es un archivo local y no debe subirse al repositorio.

## APIs requeridas

En Google Cloud habilitar:

- Maps SDK for Android
- Directions API

La app puede calcular rutas mediante un endpoint HTTP configurable con `GOOGLE_ROUTES_FUNCTION_URL` y usa el SDK de Maps solo para mostrar el mapa. Si no hay endpoint configurado, usa OSRM y luego una estimacion local como respaldo.

## Plataformas sin soporte

Si el widget nativo de Google Maps no esta disponible en la plataforma de prueba, la app muestra un mapa operativo de respaldo con pines y ruta.
