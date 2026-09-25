local _, NS = ...

local languages = {"enUS", "deDE", "esES", "frFR", "trTR", "zhCN"}
NS.LANGUAGES = languages
NS.LANGUAGE_NAMES = {"English", "Deutsch", "Español", "Français", "Türkçe", "简体中文"}

-- English, German, Spanish, French, Turkish, Simplified Chinese.
local phrases = {
    title = {"Quest Targets", "Quest Targets", "Objetivos de misión", "Cibles de quête", "Görev Hedefleri", "任务目标"},
    all = {"All quests", "Alle Quests", "Todas las misiones", "Toutes les quêtes", "Tüm görevler", "所有任务"},
    tracked = {"Tracked quests", "Verfolgte Quests", "Misiones seguidas", "Quêtes suivies", "Takip edilen görevler", "追踪的任务"},
    settings = {"Settings", "Einstellungen", "Configuración", "Paramètres", "Ayarlar", "设置"},
    refresh = {"Refresh", "Aktualisieren", "Actualizar", "Actualiser", "Yenile", "刷新"},
    language = {"Language", "Sprache", "Idioma", "Langue", "Dil", "语言"},
    languageNote = {"The language changes immediately.", "Die Sprache wechselt sofort.", "El idioma cambia inmediatamente.", "La langue change immédiatement.", "Dil hemen değişir.", "语言会立即切换。"},
    autoMark = {"Automatically mark targets", "Ziele automatisch markieren", "Marcar objetivos automáticamente", "Marquer automatiquement les cibles", "Hedefleri otomatik işaretle", "自动标记目标"},
    markers = {"Star,Circle,Diamond,Triangle,Moon,Square,Cross,Skull", "Stern,Kreis,Diamant,Dreieck,Mond,Quadrat,Kreuz,Totenkopf", "Estrella,Círculo,Diamante,Triángulo,Luna,Cuadrado,Cruz,Calavera", "Étoile,Cercle,Diamant,Triangle,Lune,Carré,Croix,Crâne", "Yıldız,Çember,Elmas,Üçgen,Ay,Kare,Çarpı,Kafatası", "星形,圆形,菱形,三角,月亮,方块,叉号,骷髅"},
    marker = {"Marker: %s", "Symbol: %s", "Marca: %s", "Marqueur : %s", "İşaret: %s", "标记：%s"},
    markerNote = {"Marks targets when clicked. Group permissions still apply. Combat changes take effect afterward.", "Markierung beim Zielklick. Gruppenrechte gelten weiterhin. Änderungen im Kampf werden nach Kampfende übernommen.", "Marca al seleccionar. Se respetan los permisos de grupo. Los cambios en combate se aplican después.", "Marque au clic. Les droits du groupe restent applicables. Les changements en combat prennent effet ensuite.", "Tıklanınca işaretler. Grup izinleri geçerlidir. Savaştaki değişiklikler sonra uygulanır.", "点击目标时标记。仍受队伍权限限制。战斗中的更改将在战斗后生效。"},
    display = {"Display", "Anzeige", "Pantalla", "Affichage", "Görünüm", "显示"},
    showMaster = {"Show master button", "Masterbutton anzeigen", "Mostrar botón principal", "Afficher le bouton principal", "Ana düğmeyi göster", "显示主按钮"},
    showMenu = {"Show quest window", "Questmenü anzeigen", "Mostrar ventana de misiones", "Afficher la fenêtre des quêtes", "Görev penceresini göster", "显示任务窗口"},
    showTooltips = {"Show button tooltips", "Button-Tooltips anzeigen", "Mostrar descripciones de botones", "Afficher les infobulles des boutons", "Düğme ipuçlarını göster", "显示按钮提示"},
    showMinimap = {"Show minimap button", "Minikarten-Button anzeigen", "Mostrar botón del minimapa", "Afficher le bouton de la minicarte", "Mini harita düğmesini göster", "显示小地图按钮"},
    menuScale = {"Window size: %.0f %%", "Menügröße: %.0f %%", "Tamaño de ventana: %.0f %%", "Taille de fenêtre : %.0f %%", "Pencere boyutu: %.0f %%", "窗口大小：%.0f %%"},
    pressKey = {"Press a key…", "Taste drücken …", "Pulsa una tecla…", "Appuyez sur une touche…", "Bir tuşa basın…", "按下按键…"},
    clear = {"Clear", "Löschen", "Borrar", "Effacer", "Temizle", "清除"},
    editMaster = {"Edit master button", "Masterbutton bearbeiten", "Editar botón principal", "Modifier le bouton principal", "Ana düğmeyi düzenle", "编辑主按钮"},
    hotkeyNote = {"The hotkey activates the master button. ESC cancels assignment.", "Hotkey aktiviert den Masterbutton. ESC bricht die Zuweisung ab.", "La tecla activa el botón principal. ESC cancela la asignación.", "Le raccourci active le bouton principal. Échap annule l’attribution.", "Kısayol ana düğmeyi etkinleştirir. ESC atamayı iptal eder.", "快捷键激活主按钮。ESC 取消设置。"},
    hotkey = {"Target quest objective: %s", "Questziel anvisieren: %s", "Apuntar a objetivo: %s", "Cibler l’objectif : %s", "Görev hedefine nişan al: %s", "选定任务目标：%s"},
    unbound = {"unassigned", "nicht belegt", "sin asignar", "non attribué", "atanmadı", "未设置"},
    master = {"Master button", "Masterbutton", "Botón principal", "Bouton principal", "Ana düğme", "主按钮"},
    masterClassic = {"Classic", "Klassisch", "Clásico", "Classique", "Klasik", "经典"},
    masterModern = {"Modern", "Modern", "Moderno", "Moderne", "Modern", "现代"},
    masterModernScale = {"Button size: %.0f %%", "Buttongröße: %.0f %%", "Tamaño del botón: %.0f %%", "Taille du bouton : %.0f %%", "Düğme boyutu: %.0f %%", "按钮大小：%.0f %%"},
    masterAppearance = {"Appearance", "Darstellung", "Apariencia", "Apparence", "Görünüm", "外观"},
    masterDefault = {"Target quest objective", "Questziel anvisieren", "Apuntar a objetivo", "Cibler l’objectif", "Görev hedefini seç", "选定任务目标"},
    sizeNote = {"Set width (X) and height (Y) independently.", "Breite (X) und Höhe (Y) unabhängig einstellen.", "Ajusta ancho (X) y alto (Y) por separado.", "Réglez largeur (X) et hauteur (Y) séparément.", "Genişliği (X) ve yüksekliği (Y) ayrı ayarla.", "分别调整宽度 (X) 和高度 (Y)。"},
    width = {"Width (X): %.0f %%", "Breite (X): %.0f %%", "Ancho (X): %.0f %%", "Largeur (X) : %.0f %%", "Genişlik (X): %.0f %%", "宽度 (X)：%.0f %%"},
    height = {"Height (Y): %.0f %%", "Höhe (Y): %.0f %%", "Alto (Y): %.0f %%", "Hauteur (Y) : %.0f %%", "Yükseklik (Y): %.0f %%", "高度 (Y)：%.0f %%"},
    caption = {"Button text", "Schriftzug", "Texto del botón", "Texte du bouton", "Düğme yazısı", "按钮文字"},
    emptyCaption = {"Leave blank to show the button without text.", "Leer lassen, um den Button ohne Schriftzug anzuzeigen.", "Déjalo vacío para mostrar el botón sin texto.", "Laissez vide pour afficher le bouton sans texte.", "Yazısız düğme için boş bırakın.", "不填则按钮不显示文字。"},
    active = {"All active quests", "Alle aktiven Quests", "Todas las misiones activas", "Toutes les quêtes actives", "Tüm etkin görevler", "所有进行中的任务"},
    minimapTip = {"Left click: quest window · Right click: settings", "Linksklick: Questmenü  ·  Rechtsklick: Einstellungen", "Clic izquierdo: misiones · derecho: configuración", "Clic gauche : quêtes · droit : paramètres", "Sol tık: görevler · sağ tık: ayarlar", "左键：任务窗口 · 右键：设置"},
    summary = {"%d quests · %d open objectives", "%d Quests  ·  %d offene Ziele", "%d misiones · %d objetivos pendientes", "%d quêtes · %d objectifs ouverts", "%d görev · %d açık hedef", "%d 个任务 · %d 个未完成目标"},
    detail = {"%s · %d objectives · %d mobs", "%s  ·  %d Ziele  ·  %d Mobs", "%s · %d objetivos · %d enemigos", "%s · %d objectifs · %d ennemis", "%s · %d hedef · %d yaratık", "%s · %d 个目标 · %d 种怪物"},
    open = {"Open", "Offen", "Pendiente", "Ouvert", "Açık", "未完成"},
    emptyTracked = {"No open objectives in tracked quests.\n\nChoose All quests to show the full quest log.", "Keine offenen Ziele in verfolgten Quests.\n\nMit Alle Quests das gesamte Questlog anzeigen.", "No hay objetivos pendientes en las misiones seguidas.\n\nElige Todas las misiones.", "Aucun objectif ouvert dans les quêtes suivies.\n\nChoisissez Toutes les quêtes.", "Takip edilen görevlerde açık hedef yok.\n\nTüm görevleri seçin.", "追踪的任务中没有未完成目标。\n\n选择所有任务。"},
    emptyAll = {"No open quest objectives.\n\nAccept a quest to see its objectives here.", "Keine offenen Questziele.\n\nNimm eine Quest an – ihre Ziele erscheinen hier automatisch.", "No hay objetivos pendientes.\n\nAcepta una misión para verlos aquí.", "Aucun objectif de quête ouvert.\n\nAcceptez une quête pour les voir ici.", "Açık görev hedefi yok.\n\nBurada görmek için bir görev alın.", "没有未完成的任务目标。\n\n接受任务后将在此显示。"},
    combat = {"In combat: the target list remains until combat ends.", "Im Kampf: Zielliste bleibt bis Kampfende bestehen.", "En combate: la lista se mantiene hasta que termine.", "En combat : la liste reste jusqu’à la fin du combat.", "Savaşta: hedef listesi savaş bitene kadar kalır.", "战斗中：目标列表将在战斗结束后更新。"},
    search = {"Looking for matching mobs nearby…", "Suche passende Mobs in der sichtbaren Umgebung …", "Buscando enemigos cercanos…", "Recherche d’ennemis proches…", "Yakındaki uygun yaratıklar aranıyor…", "正在寻找附近的目标怪物…"},
    click = {"Click: target · Drag title: move", "Klick: anvisieren  ·  Titelleiste: verschieben", "Clic: apuntar · Arrastrar título: mover", "Clic : cibler · Glisser le titre : déplacer", "Tıkla: hedefle · Başlığı sürükle: taşı", "点击：选定 · 拖动标题栏：移动"},
    masterTip1 = {"Left click: open mob targets first, then turn-in NPCs for ready quests. Name targeting works without nameplates.", "Linksklick: offene Mobziele zuerst, danach Abgabe-NPCs bereiter Quests. Namenssuche funktioniert auch ohne Namensplaketten.", "Clic izquierdo: primero enemigos pendientes, luego NPC de entrega. La selección por nombre funciona sin placas.", "Clic gauche : ennemis d’abord, puis PNJ des quêtes à rendre. Le ciblage par nom fonctionne sans barres de nom.", "Sol tık: önce açık yaratık hedefleri, sonra teslim NPC'leri. İsimle hedefleme ad plakaları olmadan çalışır.", "左键：先选未完成的怪物目标，再选可交任务的 NPC。无需姓名板也可按名称选定。"},
    masterTip2 = {"Hold right mouse button and drag to move. Settings: /qt settings", "Rechte Maustaste halten und ziehen: verschieben. Einstellungen: /qt settings", "Mantén pulsado el botón derecho y arrastra para mover. Configuración: /qt settings", "Maintenez le bouton droit et glissez pour déplacer. Paramètres : /qt settings", "Taşımak için sağ tuşa basılı tutup sürükleyin. Ayarlar: /qt settings", "按住右键拖动可移动。设置：/qt settings"},
    masterTip3 = {"Independent of quest filter and hidden window. Object-only turn-ins cannot be targeted. In combat, name selection is limited by macro length.", "Unabhängig vom Questfilter und vom ausgeblendeten Menü. Reine Objekt-Abgaben können nicht anvisiert werden. Im Kampf Namensauswahl im Rahmen des Makrolimits.", "Independiente del filtro y la ventana oculta. No se pueden seleccionar objetos de entrega. En combate rige el límite de macros.", "Indépendant du filtre et de la fenêtre masquée. Les objets à rendre ne peuvent pas être ciblés. En combat, la macro limite les noms.", "Görev filtresinden ve gizli pencereden bağımsızdır. Nesne teslimleri hedeflenemez. Savaşta makro sınırı geçerlidir.", "不受任务筛选或窗口隐藏影响。无法选定交付物体。战斗中受宏长度限制。"},
    tooltipUnknown = {"Mob not yet detected", "Mob noch nicht automatisch erkannt", "Enemigo aún no detectado", "Ennemi pas encore détecté", "Yaratık henüz algılanmadı", "尚未识别怪物"},
    tooltipDb = {"Mob type from QuestieDB", "Mobart aus QuestieDB", "Tipo de enemigo de QuestieDB", "Type d’ennemi de QuestieDB", "QuestieDB yaratık türü", "来自 QuestieDB 的怪物类型"},
    tooltipDetected = {"Detected from mob quest information", "Automatisch über Mob-Questinformationen erkannt", "Detectado por información de misión del enemigo", "Détecté via les informations de quête de l’ennemi", "Yaratığın görev bilgisinden algılandı", "从怪物任务信息中识别"},
    tooltipRight = {"Right click: open quest in the quest log.", "Rechtsklick: Quest im Questlog öffnen.", "Clic derecho: abrir misión en el registro.", "Clic droit : ouvrir la quête dans le journal.", "Sağ tık: görevi görev günlüğünde aç.", "右键：在任务日志中打开任务。"},
    tooltipNames = {"Valid mob types for open objectives:", "Gültige Mobarten für offene Unterziele:", "Enemigos válidos para objetivos pendientes:", "Ennemis valides pour les objectifs ouverts :", "Açık hedefler için geçerli yaratık türleri:", "未完成目标的有效怪物类型："},
    tooltipClick = {"Left click: target a valid quest mob by name. Visible matching names are preferred.", "Linksklick: gültiges Questziel nach Namen anvisieren. Sichtbare passende Namen werden bevorzugt.", "Clic izquierdo: seleccionar un objetivo de misión por nombre. Se priorizan los nombres visibles válidos.", "Clic gauche : cibler un objectif de quête par nom. Les noms visibles valides sont prioritaires.", "Sol tık: geçerli görev hedefini isimle seç. Görünür uygun isimlere öncelik verilir.", "左键：按名称选定有效任务目标，优先选择可见的匹配名称。"},
    tooltipCycle = {"Name targeting cannot select a specific instance among mobs with the same name. No guaranteed cycling between identical names.", "Die Namenssuche kann keine bestimmte Einheit unter gleichnamigen Mobs auswählen. Kein garantiertes Durchschalten gleicher Namen.", "La selección por nombre no permite elegir un enemigo concreto entre varios del mismo nombre.", "Le ciblage par nom ne permet pas de choisir une unité précise parmi celles portant le même nom.", "İsimle hedefleme, aynı adlı yaratıklar arasından belirli birini seçemez.", "按名称选定无法区分同名怪物，不保证在同名单位之间轮换。"},
    tooltipUnresolved = {"The quest text has no clear mob name. With hostile nameplates shown, the addon detects nearby matching mobs when the client provides their quest information. No prior assignment needed.", "Der Questtext nennt keinen eindeutigen Mobnamen. Mit sichtbaren gegnerischen Namensplaketten erkennt das Addon passende Mobs in der Umgebung automatisch, sobald der Client ihre Questinformationen liefert. Kein vorheriges Auswählen nötig.", "El texto no indica un enemigo claro. Con placas hostiles visibles, el addon detecta enemigos cercanos cuando el cliente proporciona sus datos. No hace falta asignarlos antes.", "Le texte ne nomme aucun ennemi précis. Avec les barres ennemies visibles, l’addon détecte les ennemis proches quand le client fournit leurs données. Aucune attribution préalable.", "Görev metni kesin yaratık adı vermiyor. Düşman ad plakaları görünürse istemci bilgi verdiğinde yakındaki uygun yaratıklar algılanır. Ön atama gerekmez.", "任务文本未指出明确怪物。显示敌方姓名板后，客户端提供任务信息时插件会识别附近目标。无需预先指定。"},
    scannerUnavailable = {"Automatic nearby detection is unavailable in this client.", "Automatische Umgebungserkennung in diesem Client nicht verfügbar.", "La detección cercana no está disponible en este cliente.", "Détection des ennemis proches indisponible dans ce client.", "Bu istemcide yakın hedef algılama kullanılamıyor.", "此客户端不支持自动识别附近目标。"},
    scannerPlates = {"Show hostile nameplates for nearby detection.", "Für die Umgebungserkennung gegnerische Namensplaketten einblenden.", "Muestra las placas enemigas para detectar objetivos cercanos.", "Affichez les barres de nom ennemies pour détecter les cibles proches.", "Yakın hedefleri algılamak için düşman ad plakalarını açın.", "显示敌方姓名板以识别附近目标。"},
    scannerLimited = {"The client is not providing all mob information right now.", "Der Client gibt derzeit nicht alle Mobinformationen frei.", "El cliente no proporciona toda la información de enemigos.", "Le client ne fournit pas toutes les informations des ennemis.", "İstemci şu anda tüm yaratık bilgilerini vermiyor.", "客户端目前未提供全部怪物信息。"},
    dbMissing = {"QuestieDB missing", "QuestieDB fehlt", "Falta QuestieDB", "QuestieDB manquant", "QuestieDB yok", "缺少 QuestieDB"},
    dbUpdate = {"Update QuestieDB", "QuestieDB aktualisieren", "Actualiza QuestieDB", "Mettez QuestieDB à jour", "QuestieDB'yi güncelle", "请更新 QuestieDB"},
    dbIncompatible = {"QuestieDB incompatible", "QuestieDB inkompatibel", "QuestieDB incompatible", "QuestieDB incompatible", "QuestieDB uyumsuz", "QuestieDB 不兼容"},
    dbIncomplete = {"QuestieDB incomplete", "QuestieDB unvollständig", "QuestieDB incompleta", "QuestieDB incomplet", "QuestieDB eksik", "QuestieDB 不完整"},
    dbLocale = {"QuestieDB: language missing", "QuestieDB: Sprache fehlt", "QuestieDB: falta idioma", "QuestieDB : langue absente", "QuestieDB: dil eksik", "QuestieDB：缺少语言"},
    dbClassic = {"QuestieDB: Classic required", "QuestieDB: Classic benötigt", "QuestieDB: requiere Classic", "QuestieDB : Classic requis", "QuestieDB: Classic gerekli", "QuestieDB：需要经典旧世"},
    dbSource = {"QuestieDB · source data", "QuestieDB · Quelldaten", "QuestieDB · datos fuente", "QuestieDB · données source", "QuestieDB · kaynak veri", "QuestieDB · 原始数据"},
    dbRead = {"QuestieDB: read error", "QuestieDB: Lesefehler", "QuestieDB: error de lectura", "QuestieDB : erreur de lecture", "QuestieDB: okuma hatası", "QuestieDB：读取错误"},
    dbInstallTitle = {"QuestieDB Classic is missing", "QuestieDB Classic fehlt", "Falta QuestieDB Classic", "QuestieDB Classic est absent", "QuestieDB Classic eksik", "缺少 QuestieDB Classic"},
    dbInstallForeverTitle = {"QuestieDB Forever is missing", "QuestieDB Forever fehlt", "Falta QuestieDB Forever", "QuestieDB Forever est absent", "QuestieDB Forever eksik", "缺少 QuestieDB Forever"},
    selectLink = {"Select URL", "URL markieren", "Seleccionar URL", "Sélectionner l’URL", "URL'yi seç", "选中网址"},
    dbInstallForeverText = {"Install QuestieDB-Forever.zip from the release page for WoW Forever:", "Installiere für WoW Forever die Datei QuestieDB-Forever.zip von der Release-Seite:", "Para WoW Forever, instala QuestieDB-Forever.zip desde la página de versiones:", "Pour WoW Forever, installez QuestieDB-Forever.zip depuis la page des versions :", "WoW Forever için sürüm sayfasından QuestieDB-Forever.zip yükleyin:", "请从发布页面安装适用于 WoW Forever 的 QuestieDB-Forever.zip："},
    dbInstallText = {"Install QuestieDB-Vanilla.zip from the release page for WoW Classic:", "Installiere für WoW Classic die Datei QuestieDB-Vanilla.zip von der Release-Seite:", "Para WoW Classic, instala QuestieDB-Vanilla.zip desde la página de versiones:", "Pour WoW Classic, installez QuestieDB-Vanilla.zip depuis la page des versions :", "WoW Classic için sürüm sayfasından QuestieDB-Vanilla.zip yükleyin:", "请从发布页面安装适用于 WoW Classic 的 QuestieDB-Vanilla.zip："},
    debugState = {"Diagnostics 1.0.5 · Combat: %s · Last prepared click: %s", "Diagnose 1.0.5 · Kampf: %s · letzter vorbereiteter Klick: %s", "Diagnóstico 1.0.5 · Combate: %s · Último clic preparado: %s", "Diagnostic 1.0.5 · Combat : %s · Dernier clic préparé : %s", "Tanılama 1.0.5 · Savaş: %s · Son hazırlanan tıklama: %s", "诊断 1.0.5 · 战斗：%s · 上次准备的点击：%s"},
    debugCounts = {"Current target valid: %s · Nameplates: %d · Candidates: %d · Next token: %s", "Aktuelles Ziel gültig: %s · Namensplaketten: %d · Kandidaten: %d · nächstes Token: %s", "Objetivo actual válido: %s · Placas: %d · Candidatos: %d · Siguiente token: %s", "Cible actuelle valide : %s · Barres de nom : %d · Candidats : %d · Prochain jeton : %s", "Mevcut hedef geçerli: %s · Ad plakaları: %d · Adaylar: %d · Sonraki simge: %s", "当前目标有效：%s · 姓名板：%d · 候选：%d · 下个标记：%s"},
    debugResult = {"Target result after click: %s", "Zielergebnis nach Klick: %s", "Resultado tras el clic: %s", "Résultat après le clic : %s", "Tıklama sonrası hedef sonucu: %s", "点击后的目标结果：%s"},
    debugName = {"Searched name: %s · Matching a name does not identify a specific same-name unit", "Gesuchter Name: %s · Namensabgleich wählt keine bestimmte gleichnamige Einheit", "Nombre buscado: %s · La coincidencia no identifica una unidad concreta", "Nom recherché : %s · La correspondance ne distingue pas les homonymes", "Aranan isim: %s · İsim eşleşmesi aynı adlı belirli birimi ayırt etmez", "查找名称：%s · 名称匹配不能区分同名单位"},
    debugNone = {"none", "keines", "ninguno", "aucun", "yok", "无"},
    debugUnchecked = {"not checked", "nicht geprüft", "sin comprobar", "non vérifié", "kontrol edilmedi", "未检查"},
    debugYes = {"yes", "ja", "sí", "oui", "evet", "是"},
    debugNo = {"no", "nein", "no", "non", "hayır", "否"},
    debugPathNone = {"no mob names", "Keine Mobnamen", "sin nombres de enemigos", "aucun nom d’ennemi", "yaratık adı yok", "没有怪物名称"},
    debugPathKeep = {"keep target", "Ziel behalten", "conservar objetivo", "garder la cible", "hedefi koru", "保留目标"},
    debugPathSearch = {"name search", "Namenssuche", "búsqueda por nombre", "recherche par nom", "isimle arama", "名称搜索"},
    debugPathPlate = {"name search from nameplate", "Namenssuche aus Namensplakette", "búsqueda desde placa", "recherche depuis une barre de nom", "ad plakasından isimle arama", "从姓名板按名称搜索"},
    apiMissing = {"The quest API is unavailable in this client.", "Die Quest-API ist in diesem Client nicht verfügbar.", "La API de misiones no está disponible en este cliente.", "L’API de quête est indisponible dans ce client.", "Bu istemcide görev API'si yok.", "此客户端无法使用任务 API。"},
    filterMissing = {"Quest tracking is unavailable in this client.", "Der Questfilter ist in diesem Client nicht verfügbar.", "El seguimiento de misiones no está disponible.", "Le suivi des quêtes est indisponible.", "Bu istemcide görev takibi yok.", "此客户端无法使用任务追踪。"},
    logPending = {"Quest log not available yet.", "Questlog noch nicht verfügbar.", "El registro de misiones aún no está disponible.", "Journal de quêtes pas encore disponible.", "Görev günlüğü henüz hazır değil.", "任务日志尚不可用。"},
    windowDeferred = {"Window change queued until combat ends.", "Fensteränderung für nach dem Kampf vorgemerkt.", "Cambio de ventana pendiente hasta después del combate.", "Changement de fenêtre reporté après le combat.", "Pencere değişikliği savaş sonrasına ertelendi.", "窗口更改将在战斗后生效。"},
    filterCombat = {"Change the quest filter after combat.", "Questfilter nach dem Kampf ändern.", "Cambia el filtro tras el combate.", "Changez le filtre après le combat.", "Görev filtresini savaştan sonra değiştirin.", "请在战斗后更改任务筛选。"},
    pageCombat = {"Change pages after combat.", "Seitenwechsel nach dem Kampf möglich.", "Cambia de página tras el combate.", "Changez de page après le combat.", "Sayfayı savaştan sonra değiştirin.", "请在战斗后翻页。"},
    settingsCombat = {"Open settings after combat.", "Einstellungen nach dem Kampf öffnen.", "Abre la configuración tras el combate.", "Ouvrez les paramètres après le combat.", "Ayarları savaştan sonra açın.", "请在战斗后打开设置。"},
    commandCombat = {"Use this command after combat.", "Diesen Befehl nach dem Kampf ausführen.", "Usa este comando tras el combate.", "Utilisez cette commande après le combat.", "Bu komutu savaştan sonra kullanın.", "请在战斗后使用此命令。"},
    rescanDone = {"Automatic detection reset.", "Automatische Erkennung erneuert.", "Detección automática restablecida.", "Détection automatique réinitialisée.", "Otomatik algılama sıfırlandı.", "自动识别已重置。"},
    help1 = {"/qt: toggle window · /qt settings: options · /qt refresh: update · /qt reset: reset position · /qt rescan: reset detection · /qt debug: diagnostics.", "/qt: Fenster ein/aus · /qt einstellungen: Optionen · /qt aktualisieren: erneuern · /qt zurücksetzen: Position · /qt neu-erkennen: Erkennung · /qt diagnose: Diagnose.", "/qt: mostrar/ocultar · /qt configuración: opciones · /qt actualizar: renovar · /qt restablecer: posición · /qt reexaminar: detección · /qt diagnóstico: diagnóstico.", "/qt : afficher/masquer · /qt paramètres : options · /qt actualiser : mettre à jour · /qt réinitialiser : position · /qt réexaminer : détection · /qt diagnostic : diagnostic.", "/qt: göster/gizle · /qt ayarlar: seçenekler · /qt yenile: güncelle · /qt sıfırla: konum · /qt yeniden-tara: algılama · /qt tanıla: tanılama.", "/qt：显示/隐藏 · /qt 设置：选项 · /qt 刷新：更新 · /qt 重置：位置 · /qt 重新扫描：识别 · /qt 诊断：诊断。"},
    help2 = {"One button per quest. All mob types for open objectives are valid. The master button favors mobs over turn-in NPCs.", "Ein Button pro Quest: Alle Mobarten ihrer offenen Unterziele sind gültig. Der Masterbutton versucht offene Mobziele vor Abgabe-NPCs bereiter Quests.", "Un botón por misión. Todos los enemigos de objetivos pendientes son válidos. El botón principal prioriza enemigos.", "Un bouton par quête. Tous les ennemis des objectifs ouverts sont valides. Le bouton principal privilégie les ennemis.", "Görev başına bir düğme. Açık hedeflerdeki tüm yaratıklar geçerlidir. Ana düğme yaratıklara öncelik verir.", "每个任务一个按钮。所有未完成目标的怪物均有效。主按钮优先选定怪物。"},
    help3 = {"QuestieDB supplies known kill targets and NPC item drops. Multiple mob types remain valid; no manual assignment is needed.", "QuestieDB liefert bekannte Killziele und alle hinterlegten NPC-Dropquellen. Mehrere Mobarten bleiben gemeinsam gültig. Vorheriges Auswählen oder Zuordnen ist nicht nötig.", "QuestieDB aporta objetivos y botines de NPC. Varios enemigos son válidos; no hace falta asignarlos manualmente.", "QuestieDB fournit les ennemis connus et les sources d’objets. Plusieurs types restent valides, sans attribution manuelle.", "QuestieDB bilinen öldürme hedeflerini ve eşya düşüren NPC'leri sağlar. Ön atama gerekmez.", "QuestieDB 提供已知击杀目标和 NPC 掉落来源。多种怪物均有效，无需手动指定。"},
    help4 = {"Unknown goals can be learned from visible hostile nameplates and quest information.", "Unbekannte Forever-Ziele ergänzen wir aus Questtexten und Questinformationen sichtbarer Namensplaketten. Dafür gegnerische Namensplaketten einblenden.", "Los objetivos desconocidos se aprenden de placas hostiles visibles e información de misión.", "Les objectifs inconnus sont appris via les barres de nom ennemies et les informations de quête.", "Bilinmeyen hedefler görünen düşman ad plakaları ve görev bilgilerinden öğrenilir.", "未知目标可通过可见的敌方姓名板和任务信息识别。"},
    help5 = {"Click: target matching quest names, preferring visible candidates outside combat. No guaranteed same-name cycling. No attack.", "Klick: passende Questnamen anvisieren, außerhalb des Kampfes sichtbare Kandidaten bevorzugen. Kein garantiertes Durchschalten gleichnamiger Mobs. Kein Angriff.", "Clic: seleccionar nombres válidos, priorizando los visibles fuera de combate. No garantiza alternar entre enemigos del mismo nombre. No ataca.", "Clic : cibler par nom, avec priorité aux candidats visibles hors combat. Pas de défilement garanti entre homonymes. Pas d’attaque.", "Tıkla: uygun görev isimlerini hedefle; savaş dışında görünür adaylara öncelik ver. Aynı adlı yaratıklar arasında geçiş garantisi yoktur. Saldırmaz.", "点击：按任务目标名称选定，脱战时优先可见目标。不保证同名目标轮换，不发动攻击。"},
    help6 = {"Automatic skull marking is enabled by default. Choose another marker or disable it in settings; group permissions still apply.", "Automatischer Totenkopf ist voreingestellt. In den Einstellungen ausschalten oder eines der acht Symbole wählen; Gruppenrechte gelten weiterhin.", "La calavera automática está activada por defecto. Cambia o desactiva la marca en configuración; se respetan permisos.", "Le crâne automatique est activé par défaut. Changez ou désactivez le marqueur dans les paramètres ; les droits du groupe s’appliquent.", "Otomatik kafatası varsayılandır. Ayarlardan değiştirin veya kapatın; grup izinleri geçerlidir.", "默认自动标记骷髅。可在设置中更换或关闭；仍受队伍权限限制。"},
}

local indices = {}
for index, code in ipairs(languages) do indices[code] = index end
indices.enGB, indices.esMX, indices.zhTW = 1, 3, 6

function NS.Language()
    local saved = NS.app and NS.app.db and NS.app.db.language
    local code = indices[saved] and saved or "enUS"
    return indices[code] or 1
end

-- Keep English commands available regardless of the chosen interface language.
-- Local aliases are lower-case words that users can type after /qt.
local commandAliases = {
    ["settings"]="settings", ["refresh"]="refresh", ["reset"]="reset",
    ["rescan"]="rescan", ["clear"]="rescan", ["help"]="help", ["debug"]="debug",
    ["einstellungen"]="settings", ["aktualisieren"]="refresh", ["zurücksetzen"]="reset",
    ["neu-erkennen"]="rescan", ["hilfe"]="help", ["diagnose"]="debug",
    ["configuración"]="settings", ["actualizar"]="refresh", ["restablecer"]="reset",
    ["reexaminar"]="rescan", ["ayuda"]="help", ["diagnóstico"]="debug",
    ["paramètres"]="settings", ["actualiser"]="refresh", ["réinitialiser"]="reset",
    ["réexaminer"]="rescan", ["aide"]="help", ["diagnostic"]="debug",
    ["ayarlar"]="settings", ["yenile"]="refresh", ["sıfırla"]="reset",
    ["yeniden-tara"]="rescan", ["yardım"]="help", ["tanıla"]="debug",
    ["设置"]="settings", ["刷新"]="refresh", ["重置"]="reset",
    ["重新扫描"]="rescan", ["帮助"]="help", ["诊断"]="debug",
}
function NS.Command(input)
    return commandAliases[input] or input
end

function NS.L(key)
    local row = phrases[key]
    return row and (row[NS.Language()] or row[1]) or key
end
