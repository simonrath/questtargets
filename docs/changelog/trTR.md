# Next – Yama Notları

Oyuncuları ilgilendiren değişiklikler en yeni sürümden başlayarak sıralanır. Eski kurulum notları yalnızca belirtilen sürüm için geçerlidir.

## 1.8.5 – 28 Kasım 2026

### Başlangıç
- **Next Tanıtımı:** Mrrml, yeni oyuncuların Next’i kullanmaya başlamasına yardım eder. Eklenti seçeneklerinden **Next > Genel > Tanıtım > Başlat** yolunu izle veya **/qt intro** yaz.

## 1.8.4 – 27 Kasım 2026

### SilverDragon
- **Yeni: SilverDragon desteği!** Mor düğme ve kısayolu SilverDragon dünya haritasında odaklandığın nadiri hedefler. **Bölgedeki tüm nadirleri ara** varsayılan olarak açıktır ve bulunduğun bölgedeki bilinen nadirleri arar. İki eklenti de kullanılabiliyorsa RareScanner önceliklidir. Bu eklentilerden biri kullanılabilir olduğunda düğme otomatik görünür.

### Yama notları
- Yama Notları penceresinde bir cüce ve bir murloc seni konuşma balonlarıyla karşılıyor.
- **Yeni yama notlarını başlangıçta göster** varsayılan olarak kapalıdır. Yama notları penceresinin altından açabilirsin.

### Varsayılan ayarlar
- **Otomatik modül etkinleştirme:** Uyumlu bir eklenti yüklendiğinde Next entegrasyonu etkinleştirir ve hedef düğmelerini gösterir. Kapattığın modüller kapalı kalır.
- Görev penceresi kapalı başlar. Modül araması, ayırıcılar, düğme ipuçları ve hedef bırakma sesini susturma açıktır. Düğme aralığı 0 px olur. Nadir hedef düğmesi destekleyen istemcilerde sinyal gönderir.
- Forever’da Next’in varsayılanlar düğmesi yalnızca Next seçeneklerini sıfırlar.

## 1.8.3 – 26 Kas 2026

### FlareUI
- **Yeni: FlareUI desteği!** FlareUI takipçisindeki desteklenen görevlerin yanında bir Next hedef düğmesi göstermek için **Düğmeler ve Çubuk** bölümünde **FlareUI entegrasyonu** seçeneğini açın. Hedef için sol, göreve odaklanmak için sağ tıklayın. Forever’da FlareUI 7.0.17 veya üstü gerekir. Düğmeler savaşta gizlenir.

### Görev listesi
- **Görev düğmeleri:** Tekrar tıklamak görevin canlı hedefini seçili tutar. Bu, Next görev listesiyle Questie, EllesmereUI ve FlareUI düğmeleri için geçerlidir.

### ItemTree
- **ItemTree düğmesinin** ipucu, içe aktarılan tüm yaratıkları listeler.

### Hedef çubuğu
- **Hedef çubuğu** ipucu başlıkları artık **Next** ile başlıyor. Ana düğme hangi hedefleri aradığını ve çubuğun nasıl taşınacağını açıklıyor.

## 1.8.2 – 25 Kas 2026

### Follow The Arrow
- **Yeni: Follow The Arrow desteği!** **Düğmeler ve çubuk** altında **Follow The Arrow hedeflerini izle** seçeneğini aç. Ana düğme, QuestieDB olmasa bile **FTA Target** içindeki geçerli rehber adımının hedeflerini kullanır. Makroyu Follow The Arrow’da aç. Follow The Arrow’un güncel Retail sürümü bu makroyu sağlamıyor.

Follow The Arrow desteğini öneren **EscapeKeyEscapee**’ye teşekkürler!

### Polestar
- QuestieDB yoksa ve RestedXP hedef sağlamıyorsa **ana düğme** önce Polestar’ın geçerli hedefini dener.
- Tek rehber eklentin Polestar ise girişte QuestieDB eksik uyarısı artık gösterilmez.
- **Ana düğme** artık Polestar’ın eşya toplamak veya görev eşyası kullanmak için gösterdiği yaratıkları da arar.
- QuestieDB olmadan Polestar kullanıyorsan görev penceresi Next’te Polestar hedeflemesini nasıl açacağını gösterir.

### RareScanner
- **RareScanner düğmesi** artık **Düğme ipuçlarını göster** ayarına uyar.
- Listede tek bir nadir yaratık varsa mor düğme, işaretleme ayarından bağımsız olarak ölü hedefi bırakır.
- **Bölge araması** doğma noktalarını küçük gruplar hâlinde yükler. Hedef adları hemen kullanılabilir.

### Performans
- İsim plakası değişiklikleri artık görev günlüğünün tamamını yeniden yüklemez. Hedefler ve ayarlar aynı kaldığında hedef çubuğu ve takip düğmeleri daha az işlem yapar.

## 1.8.1 – 24 Kas 2026

### Eklenti adı
- **Next**, 1.8.1 sürümünden itibaren eklentinin adıdır. Güncelleme sırasında ayarların ve tuş atamaların korunur.

## 1.8.0 – 24 Kas 2026

### Büyük iyileştirmeler
- **Birleşik hedef araması** — Ana düğme görev günlüğünü ve açık RestedXP, Polestar, ItemTree ve RareScanner kaynaklarını birlikte arar. Savaş dışında her tıklama, görev teslim NPC’leri dahil koordinatları bilinen yakın hedeflere öncelik verir. Mavi düğme yalnızca RestedXP rehber hedeflerini arar.
- **Tüm modülleri ara** seçeneği **Ana düğmeyi göster** altında varsayılan olarak açıktır. Ana düğmeyi görev günlüğü hedefleriyle sınırlamak için kapatın.
- **RareScanner düğmesi** — Bir nadir hedefliyken de mesafe sırasını günceller ve sonraki makro sayfasından önce yakındaki okunabilir isim plakalarını kontrol eder. Hareketsizken bile makroya bir ad daha sığıyorsa her tıklama en yakın nadir hedefi yeniden dener.

### Hedef işaretleri
- **Düğme başına işaretleme:** **Hedef işaretleri** altında her hedefleme düğmesi için **Baskın işareti** veya **İşaretleme yok** seçeneğini belirle. WoW Forever ve Retail’de **Sinyal** de seçilebilir. Sinyallerin sohbetinde görünmesini WoW ayarlarından kontrol edebilirsin.

Hedeflere ping atma fikri için **Caedis**’e teşekkürler!

### Seçenekler
- Yerleşik ayarlar **Quest Targets** ve **Düğmeler ve çubuk** altında gruplandı. **Yama Notları** ve **Geri bildirim** artık **Genel** altında. Girintili ayarlar, bağlı oldukları özellik kullanılabilir ve açık olduğunda etkinleşir.
- Çubuğun arkasına koyu bir WoW arka planı eklemek için **Görünüm ve Konum** altında **Çubuk arka planını göster** seçeneğini açın. Bronz çerçeve biraz daha kalın.

### Bilinen sorunlar
- **Almanca WoW Forever istemcisinde bilinen sorun** — Bazı NPC'lerin adı cinsiyete göre değişir. QuestieDB her NPC için tek bir ad biçimi sunar. Oyunda görünen ad eksikse ana düğme, “Diebin der Wüstenläufer” örneğinde olduğu gibi, ada göre aramada NPC'yi atlayabilir.

## 1.7.5 – 22 Kas 2026

### Polestar
- **Polestar rehber hedefleri:** WoW Forever'da Polestar yüklüyken varsayılan olarak kapalı **Düğmeler → Hedef çubuğu → Polestar hedeflerini izle** seçeneğini açın. Ana düğme, görüntülenen rehber adımındaki adlı açık hedefleri arar; hedef yoksa görev aramasına döner. Değişiklikler çatışmadan sonra uygulanır. RestedXP de açık ve kullanılabilir olduğunda önceliklidir.
- Toplama hedeflerinde ana düğme alternatif NPC kaynaklarını da arar. Geçerli bir dost NPC zaten hedefteyse tekrar tıklamak onu hedefte tutar.

Polestar entegrasyonu için **postblink**’e teşekkürler!

## 1.7.4 – 21 Kas 2026

### Görev listesi
- **Görev listesi**, görevleri günlüğündeki bölgelere göre alfabetik olarak gruplar. Savaş dışında bölge başlığına tıklayarak grubu daraltabilir veya genişletebilirsin. Seçimlerin karakter başına kaydedilir.

### Hedef çubuğu
- **Düğme çubuğunun konumunu kilitle** seçeneği, sağ tuşla sürüklerken çubuğun yanlışlıkla taşınmasını önler. **Düğmeler → Hedef çubuğu** altında açabilir veya savaş dışında çubuğun üzerinde **Shift** tuşunu basılı tutup sol üstteki kilide tıklayabilirsin.

CurseForge’daki önerisi için **virtual_pip**’e teşekkürler!

### Yama notları penceresi
- Güncellemelerden sonra pencerenin kendiliğinden açılmasını durdurmak için sağ alttaki **Sonraki yama notlarını gösterme** kutusunu işaretle. Notları okumak veya otomatik açılmayı yeniden etkinleştirmek için **Seçenekler → Eklentiler → Quest Targets → Yama Notları** bölümünü aç.

### Geri bildirim
- **Tarama talimatları** QR kodunun üzerinde, kopyalama talimatları ise adres alanının hemen üzerinde görünür.

## 1.7.3 – 20.11.2026

### Seçenekler
- Blizzard’ın **sosyal ayarlarındaki** bir hata düzeltildi.

## 1.7.2 – 19.11.2026

### RareScanner
- **En yakın nadirler önce:** Mor düğme, işaretli nadirleri ve bölge listesini RareScanner’daki en yakın bilinen ortaya çıkma noktasının uzaklığına göre sıralar.

### Hedef çubuğu
- **Her tıklamada güncel konum:** Savaş dışında hedef düğmeleri, mesafeye göre arama yapmak için konumunu yalnızca tıkladığında veya kısayola bastığında okur. Hareket ettiysen arama güncellenen listenin başından başlar. Yerinde durursan sonraki tıklamalar sıradaki isimleri arar.

## 1.7.1 – 19.11.2026

### RareScanner
- **Hedefi koru:** Mor düğmeye yeniden tıkladığında veya kısayoluna bastığında arama listesindeki canlı nadir yaratık hedefte kalır.

### Hedef çubuğu
- **Ayrı hedef aramaları:** Kırmızı ana düğme görev hedeflerini ve RestedXP entegrasyonu açıksa etkin rehber adımının hedeflerini arar. Mavi RestedXP, sarı ItemTree ve mor RareScanner düğmeleri kendi listelerinde arama yapar.

## 1.7.0 – 19.11.2026

### RareScanner
- **WoW Forever:** Hedefleme için RareScanner eklentisi gerekir. Arama savaş dışında ve WoW’un hedefleme menzili içinde çalışır.
- **Dünya haritası:** Nadir bir NPC’yi işaretlemek için sol tıkla. Tüm işaretli nadir yaratıkları aramak için hedef çubuğundaki mor **RareScanner Düğmesi**ne tıkla. Bilgi kutusunda hedef listesi yer alır.
- **RareScanner makrosu:** Adların uzunluğuna bağlı olarak makroya genellikle **tıklama başına 2–4 nadir yaratık** sığar. Listede daha fazlası varsa sıradakileri aramak için tekrar tıkla.
- **RareScanner düğmesini göster:** Pusulayı **Düğmeler → Hedef çubuğu** bölümünden gizleyebilirsin. Varsayılan olarak görünür ve aranacak hedef olmadığında gri olur. Savaşta görünür kalır ve arama devre dışıdır.
- **RareScanner nadirlerini hedefle:** **Kısayol tuşları** bölümünden mor düğmeye iki tuş atayabilirsin. Her basış sol tık gibi arama yapar.
- **Bölgedeki tüm nadir yaratıkları ara:** RareScanner’ın bulunduğun bölge için listelediği işaretli ve işaretsiz tüm nadir yaratıkları aramak için **Düğmeler → Hedef çubuğu** bölümündeki bu seçeneği aç. Bölge değiştiğinde liste güncellenir ve RareScanner’da kayıtlıysa bulunduğun zindandaki nadir yaratıkları da içerir. Seçenek varsayılan olarak kapalıdır.
- **Mini harita:** Bir nadir yaratığı aramak için RareScanner simgesine sol tıkla. Bir **radar dalgası** tıklamayı doğrular. İlk tıklamayı mini harita alırsa hedeflemeyi denemek için tekrar tıkla.

### Hedef çubuğu
- **Hedef çubuğu:** **Düğmeler → Hedef çubuğu** altında **Düğme düzeni**ni yatay veya dikey seç, **Düğme aralığı**nı 0–32 piksel arasında ayarla. Tüm çubuğu FlareUI birim çerçevelerinden esinlenen köşeleri kırpılmış tek bir bronz kenarlıkla çevrelemek için **Bronz çerçeveyi göster** seçeneğini aç. Varsayılan düzen yataydır, aralık 4 pikseldir ve çerçeve kapalıdır.
- **Ayırıcıları göster:** Yıldız uçlu altın-gümüş çizgileri bronz çerçeveden bağımsız olarak açıp kapat. Çubuk dikey olduğunda çizgiler de döner.
- **Modern görev pusulası:** Klasik yazılı düğme ve genişlik, yükseklik ve yazı seçenekleri kaldırıldı. Güncellemeyle klasik düğmenin yerini kayıtlı konumda pusula alır. Boyutu **Düğmeler → Hedef çubuğu → Düğme boyutu** bölümünden ayarlayabilirsin.

### Yama notları penceresi
- **Yama Notları:** Yeni sürümle ilk girişte geçmiş hesap başına bir kez açılır ve sen kapatana kadar açık kalır. **Seçenekler → AddOns → Quest Targets → Yama Notları** bölümünden açabilirsin. Notlar eklenti için seçtiğin dili kullanır.

## 1.6.1 – 15.11.2026

### Yenilikler
- **EllesmereUI:** Forever’da Custom Quest Tracker’a hedefleme düğmeleri eklenir. Hedef aramak için sol, göreve odaklanmak için sağ tıkla.
- **Geri bildirim:** Penceredeki QR kodla geri bildirim formunu açabilirsin.

### İyileştirmeler
- Fare düğmelerini, tekerleği ve tuş kombinasyonlarını oyun penceresinin herhangi bir yerinden hedef kısayolu olarak ata.
- Questie ve EllesmereUI için ayrı aralık ayarları **Düğmeler** bölümünde yer alır.
- Hedef seçimi kaldırıldığında çalan sesi kapatabilirsin.

## 1.6.0 – 10.11.2026

### Yenilikler
- **ItemTree entegrasyonu:** ItemTree’yi ayrı kur ve etkinleştir. Bir malzemenin **Sources** görünümünü aç, gerekirse **Show more** listesini genişlet ve **Import mobs** düğmesine tıkla. Quest Targets, o malzemeyi düşüren düşmanları içe aktarır.
- **ItemTree hedefleme:** **Düğmeler → ItemTree düğmesini göster** ile sarı pusulayı aç veya kısayollarda **Target ItemTree mobs** için bir tuş ata. Tıklama hedef bulmazsa diğer adları denemek için tekrar tıkla.
- **Eylem çubuğu makrosu:** İçe aktarma, mümkünse **ItemTree Mobs** adlı karakter makrosunu oluşturur. Makro penceresinden eylem çubuğuna sürükle. Hedef düğmesi ve kısayolu boş makro yuvası olmadan da çalışır.
- **Hedef çubuğunda** kırmızı ana düğme, mavi RestedXP düğmesi ve sarı ItemTree düğmesi yer alır.

### İyileştirmeler
- Üç düğmeyi birlikte taşıyabilir, yeniden boyutlandırabilir ve hangilerinin görüneceğini seçebilirsin.
- ItemTree araması bulunduğun bölgedeki hedeflere öncelik verir ve bilinen ortaya çıkma noktalarını kullanır.

## 1.5.1 – 03.11.2026

### Yenilikler
- Görev penceresini yeniden boyutlandırmak için **sağ alt köşeyi** sürükle. Boyut ve konum kaydedilir.
- Questie’nin hedefleme düğmelerini kapatabilir veya aralıklarını ayarlayabilirsin.

### İyileştirmeler
- **Mini harita düğmesi**, mini harita düğmelerini bir araya toplayan eklentilerle daha iyi çalışır.
- Ayarlar yüklü sürümü gösterir. Yeni ayarlarda ana düğme olarak pusula kullanılır.

## 1.5.0 – 03.11.2026

### İyileştirmeler
- Tek indirme Classic Era, Burning Crusade Classic, Mists of Pandaria Classic, Forever ve Retail’i destekler.
- Quest Targets, istemcine uygun görev verilerini seçer. Gereken istemcilerde QuestieDB’yi ayrı kur.

## 1.4.2 – 03.11.2026

### İyileştirmeler
- **QuestieDB** ayrı indirilir ve güncellenebilir. Retail’de gerekli değildir.

## 1.4.1 – 02.11.2026

### İyileştirmeler
- WoW’un tuş atamalarında ana düğme ve odak için iki yuva da yer alır. Quest Targets, atanmış bir tuşu değiştirmeden önce onay ister.
- Quest Targets, girişten hemen sonra eklenti seçeneklerinde görünür. Diğer düğme stiline ait ayarlar gri gösterilir.

### Düzeltmeler
- WoW’un tuş atamalarındaki değişiklikler ve silinen atamalar arayüz yeniden yüklendiğinde korunur.
- Sağ tıklama görev günlüğünü yalnızca savaş dışında açar. Harita ve hedef eşleştirmeleri daha güvenilirdir.

## 1.4.0 – 30.10.2026

### Yenilikler
- Ana düğme ve odak, klavye ve desteklenen oyun kumandaları için ikişer kısayol yuvasına sahiptir.

### İyileştirmeler
- Diğer kısayolu koruyarak bir atamayı değiştir veya sil. Atamayı iptal etmek için Escape’e bas.

## 1.3.0 – 29.10.2026

### İyileştirmeler
- 1.3.0 sürümü, 1.2.9’da sunulan ana düğme konum ayarlarını ve QuestieDB 1.0.9’u bir arada yayımlar.

## 1.2.9 – 28.10.2026

### Yenilikler
- **Ana düğmeyi taşı** ayarlara bir sürükleme tutamacı ekler. Kaydetmek için onayla, iptal etmek için Escape’e bas veya varsayılan konumu görmek için konumu sıfırla.

### İyileştirmeler
- Classic ve Forever paketleri her istemciye uygun QuestieDB 1.0.9’u içeriyordu.

## 1.2.8 – 16.10.2026

### Düzeltmeler
- Paketlerdeki QuestieDB 1.0.6, Questie 12.1.0 ile uyumluluğu geri getirdi.

## 1.2.7 – 15.10.2026

### Yenilikler
- Son hedef aramasının ayrıntılarını **/qt debug** ile gör.

### Düzeltmeler
- Eklenti seçenekleri değiştirildikten sonra WoW’un **eylem çubuğu** kullanılabilir kalır.

## 1.2.6 – 12.10.2026

### Düzeltmeler
- Bir rehber adımı sırasında görev hedeflerinin listesi kısalsa veya boşalsa da ana düğme ve RestedXP düğmesi çalışır.

## 1.2.5 – 09.10.2026

### Yenilikler
- Quest Targets veya Questie’de bir görev simgesine sağ tıklayarak göreve odaklan. Ayrı bir kısayol yalnızca o görevin hedeflerini arar.
- Kompakt WoW seçeneklerinden ana düğmenin metnini doğrudan değiştirebilirsin.

### İyileştirmeler
- Questie hedefleme düğmeleri otomatik görünür. RestedXP geçerli rehber adımının açık hedeflerini kullanır.
- Görev penceresi, kaydırma ve sürükleme daha güvenilirdir. Tamamlanan hedefler aramadan çıkarılır.

## 1.2.4 – 04.10.2026

### İyileştirmeler
- RestedXP uygun bir hedef sağlamazsa arama açık görevlere dönebilir.
- Uygun başka bir hedef görünmüyorsa tekrar tıklamak geçerli hedefi korur.

## 1.2.3 – 03.10.2026

### Yenilikler
- RestedXP, görevlerini kabul etmeden önce adı açıkça belirtilen görev veren NPC’leri arayabilir.
- Burning Crusade Classic ve Mists of Pandaria Classic desteği eklendi.

### İyileştirmeler
- Quest Targets, eklenti listesinde görevler kategorisinde yer alır. Classic Era’da Questie hedefleme düğmeleri pusula simgesini gösterir.

## 1.2.2 – 03.10.2026

### Yenilikler
- İsteğe bağlı RestedXP entegrasyonu etkin rehber adımındaki hedefleri arar. RestedXP’nin yanında bir Quest Targets düğmesi görünür.

## 1.2.1 – 02.10.2026

### Yenilikler
- Questie takipçisinde her görevin yanına isteğe bağlı bir hedefleme düğmesi eklendi.

### İyileştirmeler
- Forever arayüz desteği güncellendi, ana düğmenin boyutu ayarlandı ve mini harita düğmesi WoW çerçevesini kullanmaya başladı.
- Şeffaf görev penceresinin üzerine gelince sürükleme tutamacı ve görünüm düğmesi belirir. Ayarlar ve geri bildirim yan yanadır.

## 1.2.0 – 30.09.2026

### Yenilikler
- **Retail 12.1** desteklenir. Quest Targets, görev günlüğünü ve görünür isim plakalarını QuestieDB olmadan okur.

### Düzeltmeler
- Görev günlüğü okunamazsa pencere boş görünmek yerine bir uyarı gösterir.

## 1.1.0 – 28.09.2026

### Yenilikler
- **Şeffaf görünüm** yalnızca görev listesini gösterir. Görünümü göz simgesiyle değiştir. Simge kısa süre sonra kaybolur.

### İyileştirmeler
- Kapatma düğmesi ve kaydırma çubuğu yeni düzene uyarlandı.

## 1.0.22 – 28.09.2026

### İyileştirmeler
- QuestieDB bağlantısı güncellendi. Herkese açık eklenti paketi, ayrı kurulan uygun veri sağlayıcısını kullanmaya devam etti.

## 1.0.16 – 27.09.2026

### Yenilikler
- **Geri bildirim düğmesi** hata bildirmek veya öneri göndermek için kopyalanabilir bir bağlantı açar. GitHub hesabı gerekmez.

## 1.0.15 – 27.09.2026

### İyileştirmeler
- Sayfa oklarının yerine **fare tekerleği ve kaydırma çubuğu** kullanılır. Ayarlardaki kaydırıcıyla görev penceresinin boyutunu değiştir.
- Bilgi kutuları sadeleştirildi, kısayollara ayrı bölüm eklendi ve altı dildeki metinler güncellendi.

## 1.0.13 – 25.09.2026

### İyileştirmeler
- QuestieDB eksikse uyarı, Classic Era veya Forever için doğru paketi gösterir. Kopyalamak için penceredeki bağlantıyı seç.

## 1.0.12 – 25.09.2026

### Yenilikler
- Forever beta sürümünün yanı sıra **WoW Classic Era** 1.15.9 desteği eklendi.

### Düzeltmeler
- Classic görevleri, takibi ve tamamlanma durumu doğru okunur. Sağ tıklama görev günlüğünü açar ve Classic ortaya çıkma koordinatları korunur.

## 1.0.11 – 25.09.2026

### Yenilikler
- Forever beta için belgelenen ilk sürüm. Her görev için bir düğme ve bir **ana düğme**, açık görevlerdeki düşmanları veya görevi teslim alacak NPC’leri arar.
- QuestieDB; öldürme görevlerinin hedeflerini, ortak öldürme hedeflerini ve gerekli eşyaları düşüren düşmanları ekler. Okunabilir isim plakaları başka uygun hedefler sağlayabilir.
- Görev listesi ilerlemeyi gösterir, takip edilen görevleri filtreler ve sağ tıklamayla görev günlüğünü açar. /qt pencereyi açar veya kapatır.
- İşaretleri, kısayolları, bilgi kutularını ve altı dil seçeneğini WoW ayarlarından düzenle.
- Görev pusulası mini haritada görünür ve taşınabilir ana düğme olarak kullanılabilir. Klasik düğmenin metni değiştirilebilir.
