# English Drops Daily Content Guide

Esta guia define como cargar muchas palabras offline sin crear un solo `lessons.json` gigante.

## 1. Crear nuevas palabras

Usa `assets/data/templates/lesson_template.json` como referencia. Cada palabra debe tener todos los campos del modelo `LessonModel`: identificador, palabra, significado, pronunciacion, ejemplos, uso, gramatica, errores comunes, uso diario, ejercicios, nivel, categoria, pack y texto corto para notificaciones.

Los archivos de contenido deben ser listas JSON:

```json
[
  {
    "id": "lesson_a1_0101",
    "word": "open",
    "meaningEs": "abrir",
    "pronunciation": "ou-pen",
    "partOfSpeech": "verb",
    "isVerb": true,
    "verbType": "regular",
    "baseForm": "open",
    "pastSimple": "opened",
    "pastParticiple": "opened",
    "exampleEn": "Please open the door.",
    "exampleEs": "Por favor abre la puerta.",
    "usage": "Se usa para hablar de abrir algo.",
    "grammar": "Regular verb: open, opened, opened.",
    "commonMistakes": ["No confundir open con turn on."],
    "dailyUse": ["Open the app.", "Can you open the window?"],
    "exercises": [
      {
        "id": "ex_a1_0101",
        "type": "multiple_choice",
        "question": "What does 'open' mean?",
        "options": ["abrir", "cerrar", "mirar", "comprar"],
        "correctAnswer": "abrir",
        "explanation": "Open significa abrir."
      }
    ],
    "level": "A1",
    "isPremium": false,
    "category": "basic_verbs",
    "packId": "free_basic_1000",
    "shortNotificationText": "Regular: open / opened / opened. Example: Open the app.",
    "links": []
  }
]
```

## 2. Elegir nivel

- `A1`: palabras concretas y de uso inmediato: casa, comida, tiempo, acciones basicas, saludos.
- `A2`: rutinas, trabajo simple, viajes basicos, conectores comunes, verbos frecuentes con matices.
- `B1`: ideas mas abstractas, conectores, conversaciones de trabajo/estudio y explicaciones.
- `B2`: matices, opinion, argumentos, phrasal verbs frecuentes y vocabulario profesional.
- `C1`: precision, tono, colocaciones, expresiones avanzadas y vocabulario academico/profesional.

## 3. Marcar premium

Gratis:

```json
"isPremium": false,
"packId": "free_basic_1000"
```

Premium futuro:

```json
"isPremium": true,
"packId": "premium_5000"
```

No actives compras desde contenido. El acceso se controla con `AccessService`.

## 4. Crear ejercicios

Cada palabra debe tener al menos un ejercicio. Por ahora usa `multiple_choice`:

- `question`: pregunta breve.
- `options`: cuatro opciones.
- `correctAnswer`: debe coincidir exactamente con una opcion.
- `explanation`: explica en espanol por que es correcta.

## 5. Crear notificaciones cortas

`shortNotificationText` debe ser corto y util:

- Verbos: `Regular: open / opened / opened. Example: Open the app.`
- Uso: `Uso: para pedir ayuda. Example: Can you help me?`
- Error comun: `No digas an advice. Usa some advice.`

## 6. Evitar palabras repetidas

- Revisa todos los archivos del mismo pack antes de agregar una palabra.
- No repitas `word`.
- No repitas `id`.
- Si una palabra aparece en preview premium y luego en pack real, usa IDs distintos y decide si debe quedar una sola.

## 7. Dividir archivos por batches

Usa archivos pequenos:

- `a1_basic_words.json`: base inicial curada.
- `a1_batch_001.json`: primer lote ampliado.
- `a1_batch_002.json`: siguiente lote.
- `a2_batch_001.json`: primer lote A2.

Cada batch debe tener entre 20 y 100 palabras para revisar facil.

## 8. Ejemplo correcto

Ver `assets/data/templates/lesson_template.json`.

## 9. Errores comunes

- JSON invalido por coma final.
- `correctAnswer` no coincide con ninguna opcion.
- Falta `shortNotificationText`.
- Nivel mal escrito: usa `A1`, `A2`, `B1`, `B2`, `C1`.
- `packId` incorrecto.
- `isPremium` en `true` para contenido gratis.
- IDs duplicados entre batches.
