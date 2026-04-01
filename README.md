# SplitBillFriends 🧾⚖️

**SplitBillFriends** es una aplicación móvil desarrollada en Flutter diseñada para facilitar la división de cuentas al salir con amigos a restaurantes, bares o al realizar compras en supermercados.

## ✨ Características Principales

*   **División Flexible**: Calcula fácilmente cuánto debe cada persona. Puedes dividir la cuenta equitativamente entre todos o de forma itemizada (asignando platos o bebidas específicos a distintas personas).
*   **Propinas e Impuestos Proporcionales**: Si la boleta tiene recargos extra, la aplicación calcula matemáticamente a quién le corresponde qué porcentaje de ese recargo según lo que consumió en el total.
*   **Multimoneda (Próximamente UI)**: El cerebro matemático de la app soporta redondeo y cálculos exactos para múltiples divisas (CLP, USD, EUR, MXN, ARS, COP, CNY).
*   **Soporte Multiplataforma**: Al estar desarrollada en Flutter, podrá ser compilada de forma nativa para dispositivos iOS y Android.
*   **Escáner OCR (En desarrollo)**: Integración futura con ML Kit de Google para tomar una foto a la boleta y agregar ítems automáticamente sin tener que introducirlos manualmente.

## 🛠 Entorno de Desarrollo

Este proyecto fue generado mediante `flutter create`. Para compilar y probar en tu entorno local:

1. Asegúrate de tener el [SDK de Flutter](https://docs.flutter.dev/get-started/install) instalado.
2. Clona el repositorio e instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta las pruebas unitarias de la lógica matemática para verificar que todo esté en orden:
   ```bash
   flutter test
   ```

---
*Diseñado bajo una licencia estricta de derechos reservados. Ninguna modificación externa comercial o distribución no autorizada está permitida.*
