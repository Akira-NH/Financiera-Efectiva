# Firestore y Power BI

La app de fuerza de ventas usa el mismo proyecto Firebase que la app cliente:

- Proyecto: `financiera-efectiva-movil`
- Base: Cloud Firestore

Colecciones principales:

- `sales_clients`
- `sales_credit_requests`
- `sales_route_visits`
- `sales_scoring_features`

El panel de estados mantiene la exportacion CSV para Power BI y agrega una accion de sincronizacion hacia Firestore. Si las colecciones estan vacias, la app usa datos mock para poder probar la interfaz sin datos remotos.
