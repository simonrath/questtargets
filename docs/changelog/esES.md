# Next – Notas del parche

Cambios para jugadores, empezando por la versión más reciente. Las indicaciones de instalación históricas se aplican a la versión indicada.

## 1.8.5 – 28 de noviembre de 2026

### Primeros pasos
- **Intro de Next:** Mrrml ayuda a los nuevos jugadores a empezar con Next. Abre **Next > General > Introducción > Iniciar** en las opciones de addons o escribe **/qt intro**.

## 1.8.4 – 27 de noviembre de 2026

### SilverDragon
- **¡Nuevo: compatibilidad con SilverDragon!** El botón morado y su atajo seleccionan el raro que enfoques en el mapa de SilverDragon. **Buscar todos los raros de la zona** está activada por defecto y busca los raros conocidos de tu zona. RareScanner tiene prioridad si ambos addons están disponibles. El botón aparece automáticamente cuando hay un complemento compatible disponible.

### Notas del parche
- Un enano y un múrloc te dan la bienvenida con bocadillos en la ventana de notas del parche.
- **Mostrar las nuevas notas del parche al iniciar** está desactivado por defecto. Puedes activarlo al pie de la ventana de notas.

### Ajustes predeterminados
- **Activación automática de módulos:** Cuando se carga un addon compatible, Next activa su integración y muestra sus botones de objetivo. Los módulos que desactives seguirán desactivados.
- La ventana de misiones empieza desactivada. La búsqueda en módulos, los separadores, las descripciones y el silencio al quitar un objetivo empiezan activados. El espacio es de 0 px. El botón de raros usa avisos en clientes compatibles.
- El botón de valores predeterminados de Next en Forever solo restablece las opciones de Next.

## 1.8.3 – 26 nov 2026

### FlareUI
- **¡Nuevo: compatibilidad con FlareUI!** Activa **Integración con FlareUI** en **Botones y barra** para mostrar un botón de Next junto a las misiones compatibles en el rastreador de FlareUI. Haz clic izquierdo para seleccionar un objetivo y derecho para enfocar la misión. Requiere FlareUI 7.0.17 o posterior en Forever. Los botones se ocultan en combate.

### Lista de misiones
- **Botones de misión:** Otro clic mantiene seleccionado un objetivo vivo de esa misión. Se aplica a la lista de Next y a los botones de Questie, EllesmereUI y FlareUI.

### ItemTree
- La descripción del **botón de ItemTree** muestra todos los enemigos importados actualmente.

### Barra de objetivos
- Los títulos de la **barra de objetivos** empiezan por **Next**. El botón maestro explica qué busca y cómo mover la barra.

## 1.8.2 – 25 nov 2026

### Follow The Arrow
- **Novedad: integración con Follow The Arrow.** En **Botones y barra**, activa **Seguir objetivos de Follow The Arrow**. El botón principal usa los objetivos del paso actual de la macro **FTA Target**, incluso sin QuestieDB. Activa la macro en Follow The Arrow. La versión Retail actual de Follow The Arrow no la incluye.

¡Gracias a **EscapeKeyEscapee** por sugerir la integración con Follow The Arrow!

### Polestar
- El **botón principal** intenta seleccionar primero el objetivo actual de Polestar si falta QuestieDB y RestedXP no aporta objetivos.
- Si Polestar es tu único addon de guías, al iniciar sesión ya no aparece el aviso de que falta QuestieDB.
- El **botón principal** incluye ahora a las criaturas que Polestar indica para recoger o usar objetos de misión.
- Si usas Polestar sin QuestieDB, la ventana de misiones indica cómo activar la búsqueda de Polestar en Next.

### RareScanner
- El **botón de RareScanner** ahora respeta la opción **Mostrar descripciones de botones**.
- Si solo hay un raro en la lista, el botón morado deselecciona los objetivos muertos con cualquier ajuste de marcado.
- La **búsqueda por zona** carga los puntos de aparición en pequeños grupos. Los nombres están disponibles de inmediato.

### Rendimiento
- Los cambios en las placas de nombre ya no recargan todo el registro de misiones. La barra de objetivos y los botones del rastreador hacen menos trabajo cuando los objetivos y los ajustes no cambian.

## 1.8.1 – 24 nov 2026

### Nombre del addon
- **Next** es el nombre del addon a partir de la versión 1.8.1. Al actualizar, se conservan tus ajustes y atajos de teclado.

## 1.8.0 – 24 nov 2026

### Grandes mejoras
- **Búsqueda combinada** — El botón principal busca en el registro de misiones y en las fuentes activadas de RestedXP, Polestar, ItemTree y RareScanner. Cada clic fuera de combate prioriza los objetivos con coordenadas conocidas más cercanas, incluidos los PNJ de entrega. El botón azul solo busca objetivos de RestedXP.
- **Buscar en todos los módulos** aparece debajo de **Mostrar botón principal** y está activada de forma predeterminada. Desactívala para que el botón principal solo busque objetivos del registro de misiones.
- **Botón de RareScanner** — Actualiza el orden por distancia aunque haya un raro seleccionado y comprueba las placas cercanas legibles antes de la siguiente página de la macro. Incluso sin moverte, cada clic puede volver a buscar al raro más cercano si queda espacio para otro nombre en la macro.

### Marcas de objetivo
- **Marcado por botón:** En **Marcadores**, elige **Marca de banda** o **Sin marca** para cada botón de selección de objetivos. En WoW Forever y Retail también puedes elegir **Aviso**. Las opciones de WoW controlan si ves los avisos en el chat.

¡Gracias a **Caedis** por sugerir los pings para los objetivos!

### Opciones
- Las opciones nativas se agrupan en **Quest Targets** y **Botones y barra**. Abre **Notas del parche** o **Comentarios** en **General**. Las opciones indentadas se habilitan cuando su función está disponible y activada.
- Activa **Mostrar fondo de la barra** en **Aspecto y posición** para añadir un fondo oscuro de WoW detrás de la barra. El borde de bronce es un poco más grueso.

### Problemas conocidos
- **Problema conocido en el cliente alemán de WoW Forever** — Algunos PNJ tienen nombres distintos según su género. QuestieDB proporciona una variante por PNJ. Si falta la forma del juego, el botón principal puede omitir al PNJ al buscar por nombre, como ocurre con «Diebin der Wüstenläufer».

## 1.7.5 – 22 nov. 2026

### Polestar
- **Objetivos de Polestar:** En WoW Forever, con Polestar instalado, activa **Botones → Barra de objetivos → Seguir objetivos de Polestar**, desactivado por defecto. El botón maestro busca objetivos abiertos con nombre del paso mostrado; si no hay ninguno, busca objetivos de misión. Los cambios se aplican después del combate. Si RestedXP también está activado y disponible, tiene prioridad.
- Para los objetivos de recolección, el botón maestro también busca fuentes PNJ alternativas. Si ya tienes seleccionado un PNJ amistoso válido, vuelve a hacer clic para conservarlo como objetivo.

¡Gracias a **postblink** por la integración con Polestar!

## 1.7.4 – 21 nov. 2026

### Lista de misiones
- La **lista de misiones** agrupa las misiones por las zonas del registro en orden alfabético. Fuera de combate, haz clic en una zona para plegarla o desplegarla. La selección se guarda por personaje.

### Barra de objetivos
- **Bloquear la posición de la barra** evita que se mueva por accidente al arrastrar con el botón derecho. Activa la opción en **Botones → Barra de objetivos** o mantén pulsada **Mayús** sobre la barra fuera de combate y haz clic en el candado de arriba a la izquierda.

¡Gracias a **virtual_pip** por la sugerencia en CurseForge!

### Ventana de notas del parche
- Marca **No mostrar las próximas notas** abajo a la derecha para omitir la apertura automática tras las actualizaciones. Abre **Opciones → AddOns → Quest Targets → Notas del parche** para leerlas o volver a activar su apertura automática.

### Comentarios
- Las **instrucciones de escaneo** aparecen encima del código QR y las de copia justo encima del campo de la URL.

## 1.7.3 – 20.11.2026

### Opciones
- Corregido un error en los **ajustes sociales** de Blizzard.

## 1.7.2 – 19.11.2026

### RareScanner
- **Primero los raros más cercanos:** El botón morado ordena los raros marcados y los de la zona por distancia a su punto de aparición conocido más cercano en RareScanner.

### Barra de objetivos
- **Posición actual con cada clic:** Fuera de combate, los botones de objetivos solo leen tu posición para las búsquedas por distancia al hacer clic o pulsar su atajo. Si te has movido, la búsqueda empieza al principio de la lista actualizada. Si te quedas en el sitio, los siguientes clics comprueban más nombres.

## 1.7.1 – 19.11.2026

### RareScanner
- **Conservar el objetivo:** Un raro vivo de la lista sigue seleccionado si vuelves a pulsar el botón morado o su tecla rápida.

### Barra de objetivos
- **Búsquedas independientes:** El botón principal rojo busca objetivos de misión y, si RestedXP está activado en Quest Targets, también los del paso actual de la guía. Los botones azul de RestedXP, amarillo de ItemTree y morado de RareScanner buscan en sus propias listas.

## 1.7.0 – 19.11.2026

### RareScanner
- **WoW Forever:** La búsqueda requiere el addon RareScanner. Funciona fuera de combate y dentro del alcance de selección de WoW.
- **Mapa del mundo:** Haz clic izquierdo en un PNJ raro para marcarlo. Pulsa el **Botón de RareScanner** morado en la barra de objetivos para buscar todos los raros marcados. El cuadro de información muestra la lista.
- **Macro de RareScanner:** Según la longitud de los nombres, suelen caber **2–4 enemigos raros por clic** en la macro. Si hay más en la lista, pulsa de nuevo para buscar los siguientes.
- **Mostrar botón de RareScanner:** Puedes ocultar la brújula en **Botones → Barra de objetivos**. Se muestra por defecto y aparece en gris cuando no hay objetivos que buscar. Sigue visible en combate, con la búsqueda desactivada.
- **Apuntar a raros de RareScanner:** En **Teclas rápidas**, puedes asignar dos teclas al botón morado. Cada pulsación busca igual que un clic izquierdo.
- **Buscar todos los raros de la zona:** Activa esta opción en **Botones → Barra de objetivos** para buscar todos los PNJ raros que RareScanner lista en tu zona actual, incluidos los que no están marcados. La lista se actualiza al cambiar de zona e incluye los raros de la mazmorra actual si RareScanner tiene datos de ella. Desactivada por defecto.
- **Minimapa:** Haz clic izquierdo en el icono de RareScanner de un raro para buscarlo. Un **pulso de radar** confirma el clic. Si el minimapa gestiona el primer clic, vuelve a pulsar para intentar seleccionar al raro.

### Barra de objetivos
- **Barra de objetivos:** En **Botones → Barra de objetivos**, elige la **Disposición de botones** horizontal o vertical y ajusta la **Separación de botones** entre 0 y 32 px. Activa **Mostrar borde de bronce** para rodear toda la barra con un único borde de bronce con esquinas biseladas inspirado en los marcos de unidad de FlareUI. Por defecto, la barra es horizontal, con 4 px de separación y el borde desactivado.
- **Mostrar separadores:** Activa o desactiva las líneas de oro a plata con estrellas independientemente del borde de bronce. Giran cuando la barra es vertical.
- **Brújula de misiones moderna:** Se han eliminado el botón clásico de texto y sus opciones de anchura, altura y texto. Al actualizar, el botón clásico se convierte en una brújula en la posición guardada. Ajusta su tamaño en **Botones → Barra de objetivos → Tamaño del botón**.

### Ventana de notas del parche
- **Notas del parche:** El historial se abre una vez por cuenta al iniciar sesión por primera vez con una nueva versión y permanece abierto hasta que lo cierres. Puedes abrirlo desde **Opciones → AddOns → Quest Targets → Notas del parche**. Usa el idioma elegido para el addon.

## 1.6.1 – 15.11.2026

### Novedades
- **EllesmereUI:** En Forever, Quest Targets añade botones al Custom Quest Tracker. Haz clic izquierdo para buscar un objetivo o clic derecho para enfocar la misión.
- **Comentarios:** La ventana muestra un código QR para abrir el formulario.

### Mejoras
- Asigna botones del ratón, la rueda o combinaciones de teclas como atajos de selección desde cualquier parte de la ventana del juego.
- Questie y EllesmereUI tienen controles de separación independientes en **Botones**.
- Puedes silenciar el sonido al deseleccionar un objetivo.

## 1.6.0 – 10.11.2026

### Novedades
- **Integración con ItemTree:** Instala y activa ItemTree por separado. Abre la vista **Sources** de un ingrediente, despliega **Show more** si hace falta y pulsa **Import mobs**. Quest Targets importa los enemigos que sueltan ese ingrediente.
- **Selección de objetivos de ItemTree:** Activa la brújula amarilla en **Botones → Mostrar botón de ItemTree** o asigna una tecla a **Target ItemTree mobs** en los atajos. Si no encuentras un objetivo, pulsa de nuevo para comprobar más nombres.
- **Macro de la barra de acción:** Si es posible, la importación crea la macro de personaje **ItemTree Mobs**. Arrástrala desde la ventana de macros a la barra de acción. El botón y su atajo funcionan aunque no quede espacio para macros.
- La **barra de objetivos** incluye el botón principal rojo, el botón azul de RestedXP y el amarillo de ItemTree.

### Mejoras
- Mueve y cambia el tamaño de los tres botones juntos y elige cuáles se muestran.
- La búsqueda de ItemTree prioriza objetivos de tu zona y toma en cuenta los puntos de aparición conocidos.

## 1.5.1 – 03.11.2026

### Novedades
- Arrastra la **esquina inferior derecha** para cambiar el tamaño de la ventana de misiones. Se guardan el tamaño y la posición.
- Puedes ocultar los botones de objetivos de Questie o ajustar su separación.

### Mejoras
- El **botón del minimapa** funciona mejor con addons que agrupan estos botones.
- Las opciones muestran la versión instalada. La brújula es el botón principal por defecto en configuraciones nuevas.

## 1.5.0 – 03.11.2026

### Mejoras
- Una sola descarga sirve para Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever y Retail.
- Quest Targets selecciona los datos de misión para tu cliente. Instala QuestieDB por separado si tu cliente lo necesita.

## 1.4.2 – 03.11.2026

### Mejoras
- **QuestieDB** se descarga y actualiza por separado. Retail no lo requiere.

## 1.4.1 – 02.11.2026

### Mejoras
- El botón principal y el de enfoque tienen ambos espacios en las asignaciones de teclas de WoW. Quest Targets pide confirmación antes de reemplazar una tecla ya asignada.
- Quest Targets aparece en las opciones de AddOns al iniciar sesión. Los controles del estilo de botón que no está en uso aparecen en gris.

### Correcciones
- Los cambios y las asignaciones eliminadas en WoW se conservan al recargar la interfaz.
- El clic derecho abre el registro de misiones solo fuera de combate. Las asociaciones de mapas y objetivos son más fiables.

## 1.4.0 – 30.10.2026

### Novedades
- El botón principal y el de enfoque tienen dos asignaciones cada uno para teclado y mandos compatibles.

### Mejoras
- Puedes cambiar o borrar una asignación sin perder la otra. Pulsa Escape para cancelar la asignación.

## 1.3.0 – 29.10.2026

### Mejoras
- La versión 1.3.0 reúne el ajuste de posición del botón principal y QuestieDB 1.0.9 introducidos en 1.2.9.

## 1.2.9 – 28.10.2026

### Novedades
- **Mover el botón principal** añade un asa en las opciones. Confirma para guardar, pulsa Escape para cancelar o restablece la posición para ver dónde queda por defecto.

### Mejoras
- Los paquetes de Classic y Forever incluían QuestieDB 1.0.9 para cada cliente.

## 1.2.8 – 16.10.2026

### Correcciones
- QuestieDB 1.0.6 incluido en los paquetes restauró la compatibilidad con Questie 12.1.0.

## 1.2.7 – 15.10.2026

### Novedades
- Usa **/qt debug** para ver información de la última búsqueda.

### Correcciones
- La **barra de acción** de WoW sigue funcionando tras cambiar las opciones del addon.

## 1.2.6 – 12.10.2026

### Correcciones
- Los botones principal y de RestedXP siguen funcionando si la lista de objetivos se reduce o queda vacía durante un paso de la guía.

## 1.2.5 – 09.10.2026

### Novedades
- Haz clic derecho en un icono de misión en Quest Targets o Questie para enfocarla. Un atajo propio busca solo objetivos de esa misión.
- Las opciones nativas y compactas permiten editar directamente el texto del botón principal.

### Mejoras
- Los botones de Questie aparecen automáticamente. RestedXP usa los objetivos pendientes del paso actual.
- La ventana de misiones, el desplazamiento y el arrastre son más fiables. Los objetivos completados se retiran de la búsqueda.

## 1.2.4 – 04.10.2026

### Mejoras
- Si RestedXP no tiene un objetivo válido, la búsqueda puede volver a las misiones pendientes.
- Los clics repetidos mantienen el objetivo válido mientras no aparezca una alternativa compatible.

## 1.2.3 – 03.10.2026

### Novedades
- RestedXP puede buscar a los PNJ mencionados por nombre antes de que aceptes sus misiones.
- Se añade compatibilidad con Burning Crusade Classic y Mists of Pandaria Classic.

### Mejoras
- Quest Targets aparece en la categoría Misiones de la lista de AddOns. En Classic Era, los botones de Questie muestran la brújula.

## 1.2.2 – 03.10.2026

### Novedades
- La integración opcional de RestedXP busca objetivos del paso actual. Aparece un botón de Quest Targets junto a RestedXP.

## 1.2.1 – 02.10.2026

### Novedades
- Hay un botón de objetivo opcional junto a cada misión del rastreador de Questie.

### Mejoras
- Se actualiza la compatibilidad con la interfaz de Forever, el tamaño del botón principal y el marco nativo del botón del minimapa.
- Al pasar el ratón por la ventana transparente aparecen el asa y el interruptor. Las opciones y los comentarios quedan uno junto al otro.

## 1.2.0 – 30.09.2026

### Novedades
- Compatible con **Retail 12.1**. Quest Targets lee el registro de misiones y las placas de nombre visibles sin QuestieDB.

### Correcciones
- Si no se puede leer el registro, la ventana muestra un aviso en lugar de una lista aparentemente vacía.

## 1.1.0 – 28.09.2026

### Novedades
- El **modo transparente** deja visible solo la lista de misiones. Usa el ojo para cambiar de vista. El icono se oculta al cabo de un momento.

### Mejoras
- El botón de cierre y la barra de desplazamiento se adaptan al nuevo diseño.

## 1.0.22 – 28.09.2026

### Mejoras
- Se actualizó la integración con QuestieDB. La descarga pública del addon seguía usando el proveedor adecuado instalado por separado.

## 1.0.16 – 27.09.2026

### Novedades
- El **botón de comentarios** abre un enlace copiable para enviar errores o sugerencias. No necesitas una cuenta de GitHub.

## 1.0.15 – 27.09.2026

### Mejoras
- La **rueda del ratón y la barra de desplazamiento** sustituyen las flechas de página. Un control deslizante ajusta el tamaño de la ventana.
- Se simplificaron los cuadros de información, los atajos tienen su propia sección y se actualizaron los textos de los seis idiomas.

## 1.0.13 – 25.09.2026

### Mejoras
- Si falta QuestieDB, el aviso indica el paquete adecuado para Classic Era o Forever. Selecciona el enlace en la ventana para copiarlo.

## 1.0.12 – 25.09.2026

### Novedades
- Compatible con **WoW Classic Era** 1.15.9, además de la beta de Forever.

### Correcciones
- La lectura, el seguimiento y el estado de las misiones de Classic funcionan correctamente, al igual que el clic derecho para abrir el registro. Se conservan las coordenadas de aparición de Classic.

## 1.0.11 – 25.09.2026

### Novedades
- Primera versión documentada para la beta de Forever. Un botón por misión y un **botón principal** buscan enemigos para misiones activas o PNJ listos para recibir una entrega.
- QuestieDB aporta enemigos para misiones de eliminación, objetivos compartidos y enemigos que sueltan objetos requeridos. Las placas de nombre legibles pueden aportar más objetivos.
- La lista muestra el progreso, filtra las misiones seguidas y abre el registro con clic derecho. /qt abre o cierra la ventana.
- Configura marcas, atajos, cuadros de información y seis idiomas desde las opciones de WoW.
- La brújula aparece en el minimapa y puede actuar como botón principal móvil. El estilo clásico admite texto personalizado.
