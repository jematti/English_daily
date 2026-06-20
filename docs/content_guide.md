# English Drops Daily Content Guide

Esta guia define como cargar muchas palabras offline sin crear un solo `lessons.json` gigante.

## 1. Crear nuevas palabras

Usa `assets/data/templates/lesson_template.json` como referencia. Cada palabra debe tener todos los campos del modelo `LessonModel`: identificador, palabra, significado, pronunciacion, ejemplos, uso, gramatica, errores comunes, uso diario, ejercicios, nivel, categoria, pack y texto corto para notificaciones.

La microleccion no debe ensenar traducciones aisladas. Cada palabra necesita contexto real, uso practico, memoria activa y un error comun cuando aplique.

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
    "activeRecallPrompt": "Como dirias 'Abro la app todos los dias' en ingles?",
    "activeRecallAnswer": "I open the app every day.",
    "learningTip": "Usa esta palabra en una frase propia hoy.",
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

## 2. Calidad educativa de una microleccion

La pantalla de microleccion se divide en seis partes cortas:

- `Significado rapido`: una explicacion simple en espanol. Debe ayudar a entender, no solo traducir.
- `Ejemplo real`: una frase natural en ingles y su version en espanol.
- `Uso diario`: explica cuando usar la palabra y agrega frases listas para copiar en `dailyUse`.
- `Mini gramatica`: una regla pequena y accionable. Evita explicaciones largas.
- `Error comun`: agrega el error mas probable en `commonMistakes`. Si no hay uno claro, explica una confusion de uso o tono.
- `Reto rapido`: usa `activeRecallPrompt`, `activeRecallAnswer` y `learningTip` para obligar al usuario a recordar activamente.

Ejemplo de memoria activa:

```json
"activeRecallPrompt": "Como dirias 'Corro todos los dias' en ingles?",
"activeRecallAnswer": "I run every day.",
"learningTip": "Di la respuesta en voz alta antes de mirar la solucion."
```

## 3. Elegir nivel

- `A1`: palabras concretas y de uso inmediato: casa, comida, tiempo, acciones basicas, saludos.
- `A2`: rutinas, trabajo simple, viajes basicos, conectores comunes, verbos frecuentes con matices.
- `B1`: ideas mas abstractas, conectores, conversaciones de trabajo/estudio y explicaciones.
- `B2`: matices, opinion, argumentos, phrasal verbs frecuentes y vocabulario profesional.
- `C1`: precision, tono, colocaciones, expresiones avanzadas y vocabulario academico/profesional.

## 4. Marcar premium

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

## 5. Crear ejercicios

Cada palabra debe tener al menos un ejercicio. Por ahora usa `multiple_choice`:

- `question`: pregunta breve.
- `options`: cuatro opciones.
- `correctAnswer`: debe coincidir exactamente con una opcion.
- `explanation`: explica en espanol por que es correcta.

## 6. Crear notificaciones cortas

`shortNotificationText` debe ser corto y util:

- Verbos: `Regular: open / opened / opened. Example: Open the app.`
- Uso: `Uso: para pedir ayuda. Example: Can you help me?`
- Error comun: `No digas an advice. Usa some advice.`

## 7. Evitar palabras repetidas

- Revisa todos los archivos del mismo pack antes de agregar una palabra.
- No repitas `word`.
- No repitas `id`.
- Si una palabra aparece en preview premium y luego en pack real, usa IDs distintos y decide si debe quedar una sola.

## 8. Dividir archivos por batches

Usa archivos pequenos:

- `a1_basic_words.json`: base inicial curada.
- `a1_batch_001.json`: primer lote ampliado.
- `a1_batch_002.json`: siguiente lote.
- `a2_batch_001.json`: primer lote A2.

Cada batch debe tener entre 20 y 100 palabras para revisar facil.

## 9. Ejemplo correcto

Ver `assets/data/templates/lesson_template.json`.

## 10. Errores comunes

- JSON invalido por coma final.
- `correctAnswer` no coincide con ninguna opcion.
- Falta `shortNotificationText`.
- Nivel mal escrito: usa `A1`, `A2`, `B1`, `B2`, `C1`.
- `packId` incorrecto.
- `isPremium` en `true` para contenido gratis.
- IDs duplicados entre batches.
- `commonMistakes` vacio cuando la palabra suele confundirse con otra.
- `dailyUse` con frases artificiales que nadie diria en una conversacion real.
- `activeRecallPrompt` que solo pregunta una traduccion suelta, sin frase completa.
- `learningTip` demasiado largo o abstracto.

## 11. Checklist antes de publicar un batch

- La palabra aparece dentro de una frase real.
- El ejemplo en ingles suena natural.
- El ejemplo en espanol ayuda al usuario hispanohablante.
- Hay al menos una frase util en `dailyUse`.
- Hay un error comun si aplica.
- Hay un reto de memoria activa con respuesta.
- El ejercicio refuerza uso practico, no solo traduccion.
- El JSON carga offline sin internet ni APIs.
