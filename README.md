# ArenIA: Descubre y Protege nuestro Humedal

ArenIA es una aplicación móvil inteligente y accesible, diseñada especialmente para enriquecer la experiencia de los visitantes del Humedal Costero Poza de La Arenilla (La Punta, Callao). 

Nuestro objetivo principal es conectar a las personas con la naturaleza utilizando la tecnología como puente, haciéndola inclusiva, educativa y muy fácil de usar para todo el mundo.

---

## ¿Qué hace especial a ArenIA? (Principales Funcionalidades)

### 1. Reconocimiento Visual con Inteligencia Artificial
No necesitas ser un biólogo experto para reconocer las aves del humedal. ArenIA incluye un escáner inteligente en la cámara. Solo tienes que apuntar con tu celular hacia un ave y el modelo identificará automáticamente de qué especie se trata en tiempo real, mostrándote toda su información. 

*(Nota para el jurado: Para esta versión desarrollada durante la Hackatón, el catálogo de la app cuenta con información documentada de 12 especies. Por temas de tiempo computacional, el modelo de Inteligencia Artificial ha sido entrenado para reconocer a 4 de ellas con alta precisión, funcionando como una prueba de concepto sólida y completamente funcional).*

### 2. Inclusión y Multilingüismo (Turismo Global)
Queremos que el humedal sea valorado por turistas de todo el mundo y también por nuestros compatriotas. La aplicación está completamente traducida a 5 idiomas, incluyendo una lengua originaria:
- Español
- Inglés
- Francés
- Portugués
- Quechua

### 3. Accesibilidad Total (Modo de Voz)
Pensando en personas con discapacidades visuales (o para quienes prefieren escuchar mientras pasean y miran el paisaje), la app te habla. Cada artículo, instrucción y descripción de especie cuenta con audios descriptivos disponibles en todos los idiomas.

### 4. Funciona 100% sin Internet (Offline)
Sabemos que en algunas zonas al aire libre no hay buena señal de internet. Por eso, todo el sistema de Inteligencia Artificial y los audios están empaquetados dentro de la aplicación. Funciona perfecto en modo avión, ahorrando los datos móviles del visitante.

---

## Para el Jurado Técnico: ¿Cómo está construida?

Detrás de su interfaz sencilla, ArenIA utiliza tecnologías de punta:
* Frontend en Flutter: Desarrollada en el lenguaje Dart para garantizar animaciones fluidas y compatibilidad total con Android y iOS desde un mismo código base.
* Machine Learning Integrado (Edge AI): Utilizamos TensorFlow Lite. Al correr el modelo localmente en el procesador del celular, la identificación es casi instantánea y respeta la privacidad del usuario al no enviar fotos a la nube.
* Patrones de Arquitectura: Uso del patrón Provider para manejar los cambios de estado globales de forma reactiva (por ejemplo, al cambiar de idioma en vivo o encender el Modo Accesibilidad).

---

## Visiones para el futuro: ¿Qué sigue después?

ArenIA ha sido diseñada con una arquitectura escalable. Nuestros próximos pasos para llevar esta herramienta al siguiente nivel son:

1. Ampliación del Modelo de Inteligencia Artificial: Recolectar bases de datos masivas de fotografías para entrenar la red neuronal y abarcar a la totalidad de las especies de aves que habitan o transitan por el humedal.
2. Gamificación y Coleccionismo: Implementar un "Pasaporte de Aves" digital donde los visitantes ganen insignias o puntos por cada nueva especie escaneada, fomentando las visitas recurrentes y el interés de los más jóvenes.
3. Alertas de Conservación Ciudadana: Añadir un módulo que permita a los usuarios reportar incidentes ambientales (zonas contaminadas, aves heridas) geolocalizados, enviando una alerta directa a la municipalidad o autoridades pertinentes.
4. Expansión a otras Reservas: El motor de ArenIA es altamente replicable. El objetivo a largo plazo es expandir la plataforma para proteger y visibilizar otras reservas nacionales y ecosistemas vulnerables en el país.

---

## Nuestro Impacto
ArenIA no es solo código; es una herramienta de conservación ambiental y concientización. Al ayudar a los ciudadanos a conocer por su nombre a las especies que los rodean, pasamos de ser simples observadores a ser guardianes activos de nuestro valioso ecosistema.
