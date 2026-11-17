# 🌌 Calíope — Estudio Poético & Archivo Creativo

**Calíope** es una aplicación multiplataforma desarrollada en **Flutter** diseñada para amantes de la escritura, la poesía, los aforismos, las ideas y la narrativa. Permite archivar, catalogar y organizar archivos de texto mediante enlaces directos (URL) o redacción local, con un diseño altamente artístico, soporte responsivo para **Android** (smartphone) y **Web / PC** (listo para GitHub Pages), y un **motor de Inteligencia Lírica** que detecta emociones, métrica poética y similitudes matemáticas entre tus textos.

---

## ✨ Características Principales

### 📱 Experiencia Dual (Móvil & PC)
- **Modo PC / Web (GitHub Pages)**:
  - Diseño estilo *Studio* de 3 paneles (Barra de colecciones y subtemas ➔ Galería de pergaminos con búsqueda en tiempo real ➔ Lienzo lírico y taller de escritura con panel de Musa IA).
- **Modo Celular (Android)**:
  - Interfaz de lectura inmersiva con navegación táctil, fichas de cristal esmerilado (*glassmorphism*), selector de subtemas horizontal y acceso rápido para agregar URLs y redactar borradores.

### 🌐 Organización y Descarga desde URLs
- **Soporte Universal de Enlaces**:
  - URLs de **GitHub** (`raw.githubusercontent.com/...` o enlaces `blob` normales que se convierten automáticamente).
  - Enlaces de **GitHub Gists**.
  - Enlaces de **Pastebin** (incluyendo enlaces directos o `raw`).
  - Enlaces de archivos planos `.txt`, `.md` o extracción inteligente de texto desde páginas web.
- **Sincronización en 1 Clic**: Botón para actualizar el contenido si el archivo remoto fue editado.
- **Asignación a Subtemas**: Cada escrito se asocia a un tema principal (Poesía, Prosa, Chispas, Filosofía, Diario) y a su subtema específico (ej. *Amor & Anhelo*, *Sonetos*, *Metáforas Huérfanas*, etc.).

### 🔮 Inteligencia de Análisis & Similitudes (IA)
1. **Motor Local NLP (100% Offline, sin costo ni API key)**:
   - **Detector de Atmósfera & Estado de Ánimo**: Identifica la vibración emocional (*Nostalgia & Melancolía*, *Amor & Pasión*, *Luz & Serenidad*, *Filosofía & Misterio*, *Dolor & Sombra*, *Fuerza & Creación*, *Naturaleza*).
   - **Métrica Poética**: Conteo automático de versos (líneas), estrofas, palabras, caracteres y tiempo estimado de recitado lírico.
   - **Extracción de Esencias (Keywords)**: Detecta los motivos literarios recurrentes.
   - **Ecos Temáticos & Similitud Matemática (TF-IDF + Coseno)**: Compara cada texto con todos los demás de tu archivo y te muestra los textos que guardan afinidad temática y vocabulario compartido (¡cumpliendo tu deseo de encontrar similitudes!).
2. **Conexión Opcional con Google Gemini AI**:
   - En el menú de Ajustes puedes agregar tu clave gratuita de Google Gemini para recibir exégesis simbólica, críticas de estilo, análisis de rima y sugerencias creativas.

### 🎨 Diseño Artístico & Paletas Vibrantes
Incluye 6 temas poéticos inspiradores con efectos de *glassmorphism*, degradados orbe y tipografía de Google Fonts (*Cinzel*, *Playfair Display*, *Cormorant Garamond* y *Montserrat*):
1. 🌌 **Nebulosa Mística** (Violetas astrales, índigo y neón cian)
2. 🌅 **Atardecer Bohemio** (Coral tostado, oro crepuscular y borgoña)
3. 🌿 **Bosque de Jade** (Esmeralda nocturno, menta y oro antiguo)
4. 🌸 **Sakura & Terciopelo** (Pétalos de cerezo, rubí suave y obsidiana)
5. 📜 **Tinta & Pergamino** (Sepia literario, cuero noble y bronce)
6. 🌑 **Medianoche OLED** (Negro cósmico absoluto con luces violetas)

### 📦 Sincronización entre Celular y PC
- Exportación e importación de respaldo completo en formato **JSON**.
- Puedes escribir en tu computadora, exportar tu archivo y abrirlo en tu celular Android (o viceversa).

---

## 🚀 Despliegue en GitHub Pages

El proyecto ya incluye el flujo de trabajo automatizado en `.github/workflows/deploy.yml`.

### Pasos para publicar en GitHub Pages:
1. Crea un repositorio en GitHub (ejemplo: `caliope`).
2. Sube el código fuente:
   ```bash
   git init
   git add .
   git commit -m "Calíope: versión inicial"
   git remote add origin https://github.com/TU_USUARIO/caliope.git
   git branch -M main
   git push -u origin main
   ```
3. En GitHub, ve a **Settings** ➔ **Pages**:
   - En **Source**, selecciona **GitHub Actions**.
4. ¡Listo! El workflow compilará la versión Web y la desplegará automáticamente en:
   `https://TU_USUARIO.github.io/caliope/`

---

## 📲 Compilación para Android

Para generar el archivo ejecutable (`.apk`) para tu celular:

```bash
# Compilar APK listo para instalar en celular:
flutter build apk --release
```
El archivo se encontrará en:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 💻 Ejecución en Modo Desarrollo

```bash
# Para probar en navegador (Chrome / Edge):
flutter run -d chrome

# Para probar en Windows Desktop:
flutter run -d windows
```
