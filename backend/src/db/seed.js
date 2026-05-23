require('dotenv').config();
const bcrypt = require('bcrypt');
const pool   = require('./pool');

// ─── Davlatlar ─────────────────────────────────────────────────────────────
const COUNTRIES = [
  { name: "O'zbekiston", code: 'UZ' },
  { name: 'Turkiya',     code: 'TR' },
  { name: 'Ozarbayjon',  code: 'AZ' },
  { name: "Qozog'iston", code: 'KZ' },
  { name: "Qirg'iziston",code: 'KG' },
];

// ─── Kategoriyalar ─────────────────────────────────────────────────────────
const CATEGORIES = [
  'Shoiralar',
  'Adibalar',
  'Yozuvchilar',
  'Dramaturglar',
  'Mutafakkirlar',
];

// ─── Foydalanuvchilar ──────────────────────────────────────────────────────
const USERS = [
  { name: 'Administrator', email: 'admin@gmail.com',      password: 'admin123',      role: 'admin' },
  { name: 'Specialist',    email: 'specialist@gmail.com', password: 'specialist123', role: 'specialist' },
  { name: 'Researcher',    email: 'researcher@gmail.com', password: 'researcher123', role: 'researcher' },
];

// ─── Ijodkorlar ────────────────────────────────────────────────────────────
const CREATORS = [

  // ━━━━━━━━━━━━━━━  O'ZBEKISTON  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {
    name: 'Mohlaroyim Nodira',
    born_year: 1792, died_year: 1842,
    country_code: 'UZ', category_name: 'Shoiralar',
    bio: `Mohlaroyim Nodira (to'liq ismi Mohlaroyim Maftuna, taxallusi Nodira va Kamola) — XIX asr o'zbek adabiyotining eng buyuk shoiralaridan biri, Qo'qon xonligining malikasi va davlat arbobi. 1792-yilda Andijon viloyatida tug'ilgan. Yoshligidan ilm-fanga qiziqib, fors va o'zbek tillarini mukammal o'zlashtirgан, arab tilini ham chuqur o'rgangan.

Nodiraning ijodi ghazal, muxammas, musaddas, ruboiy va marsiyalarni o'z ichiga oladi. U o'z she'rlarida sevgi, vatan, tabiat va insoniy munosabatlarni nozik his-tuyg'ular bilan tasvirlagan. Uning «Guliston» va «Devoni Nodira» asarlari o'zbek she'riyatining durdonalari hisoblanadi. Madali xon bilan turmush qurganidan so'ng saroyda katta nufuzga ega bo'lib, o'z atrofiga shoirlar, olimlar va san'atkorlarni to'plagan.

Siyosiy jihatdan ham kuchli bo'lgan Nodira, eriga maslahatchisi bo'lib, davlat ishlarida faol ishtirok etgan. Buxoro qo'shinlari Qo'qonni bosib olgach, 1842-yilda Madali xon bilan birga qatl etilgan. Uning o'limi butun Turkiston xalqini qayg'uga botirgan va ko'plab marsiyalarga mavzu bo'lgan.

Nodira merosi bugungi kunda ham jonli. Uning she'rlari maktab darsliklarida o'qitiladi, ko'plab musiqiy asarlarga asos bo'lgan va teatr sahnalarida ijro etiladi. Toshkentda uning nomidagi ko'cha va teatr mavjud. XX asrda Zulfiya va boshqa shoiralar Nodiraning ijodiy ruhini davom ettirishga intilgan.`
  },

  {
    name: 'Zulfiya Isroilova',
    born_year: 1915, died_year: 1996,
    country_code: 'UZ', category_name: 'Adibalar',
    bio: `Zulfiya Isroilova (taxallusi Zulfiya) — O'zbekistonning xalq shoirasi, sovet va mustaqillik davri o'zbek adabiyotining yirik vakili. 1915-yili Toshkentda tug'ilgan. O'n to'rt yoshida birinchi she'rini e'lon qilgan va tezda keng ommalashgan.

Zulfiyaning she'rlarida ona yurti, vatan, ayollar ozodligi, mehnat va insoniy qadriyatlar ulug'lanadi. U nafaqat lirik she'rlar, balki publitsistik maqolalar va tarjimalar bilan ham mashhur. Pushkin, Nekrasov va Taras Shevchenko asarlarini o'zbek tiliga tarjima qilgan. Uning «Bahorga maktub», «Maysa va tosh», «O'zbekiston ovozi» to'plamlari adabiyot muxlislari orasida katta shuhrat qozongan.

Zulfiya ko'plab davlat mukofotlariga sazovor bo'lgan: Lenin ordeni, Hamza nomidagi mukofot, O'zbekiston Davlat mukofoti. U O'zbekiston SSR xalq shoirasi unvonini olgan birinchi ayol bo'ldi. 1968-1990-yillar orasida O'zbekiston Yozuvchilar uyushmasi raisining o'rinbosari sifatida faoliyat yuritdi.

Mustaqillik yillarida ham ijodiy faoliyatini davom ettirgan Zulfiya, yangi mamlakatning ruhiy asoslarini mustahkamlashga o'z hissasini qo'shdi. 1996-yilda Toshkentda vafot etgan. Uning yodiga atab Toshkentdagi yirik shox ko'cha, kutubxona va maktab nomlanган. O'zbek ayol adabiyotining ramzi sifatida u avloddan avlodga ilhom beruvchi qolib kelmoqda.`
  },

  {
    name: 'Sabohat Ashrafova',
    born_year: 1927, died_year: 2012,
    country_code: 'UZ', category_name: 'Yozuvchilar',
    bio: `Sabohat Ashrafova — o'zbek adabiyotida dramaturgiya va nasrning yorqin vakili, O'zbekiston xalq yozuvchisi. 1927-yil Toshkentda tug'ilgan. Toshkent Davlat Universiteti filologiya fakultetini tamomlagan. Dastlab gazeta va jurnallarda muharrir bo'lib ishlagan, keyin to'liq ijodga bag'ishlangan.

Ashrafovaning dramaturgiyadagi asarlari o'zbek teatri repertuarini boyitdi. «Baxtli oila», «Quyoshli yurt», «Hayot kuyи» kabi sahna asarlari respublika teatrlarida samarali sahnalashtirildi. Uning qahramonlari — zamonaviy o'zbek ayollari: o'z huquqlari va muhabbati uchun kurashuvchilar. Asar tilining sodiqligi va psixologik chuqurligi bilan ajralib turadi.

Nasr sohasida ham sermahsul bo'lgan Ashrafova, «Yoshlik bahori», «Umid nuri», «Hayot chegarasida» romanlarini yozgan. Unda ayollar qismatiga, oilaviy munosabatlarga va sotsializm davrining murakkab ijtimoiy masalalariga keng o'rin beriladi.

O'zbekiston Yozuvchilar uyushmasining a'zosi sifatida yosh adiblarni tarbiyalashda katta rol o'ynagan. Hamza nomidagi Davlat mukofoti, «Mehnat shuhrati» ordeni va boshqa davlat mukofotlari bilan taqdirlangan. 2012-yilda Toshkentda vafot etib, o'zidan boy ijodiy meros qoldirdi.`
  },

  {
    name: 'Gavhar Matmusayeva',
    born_year: 1948, died_year: null,
    country_code: 'UZ', category_name: 'Mutafakkirlar',
    bio: `Gavhar Matmusayeva — zamonaviy o'zbek madaniyat va adabiyot faylasufi, shoir va essayist. 1948-yili Samarqandda tug'ilgan. Toshkent Davlat Pedagogika Universiteti va keyinchalik Moskva Davlat Universitetida falsafa va estetika bo'yicha tahsil olgan.

Matmusayeva o'z ijodida falsafa, she'riyat va madaniyatshunoslikni uyg'unlashtiradi. Uning «Ruh manzaralari» esse to'plami o'zbek falsafiy nasrining yangi sahifasini ochdi. U turk va forsiy tasavvuf an'analarini zamonaviy o'zbek nuqtai nazaridan talqin qiladi va ularning bugungi ruhiy hayotdagi ahamiyatini ko'rsatadi.

«Ona tili va milliy o'zlik», «Sharq madaniyatida ayol obrazi», «Globallashuv va milliy qadriyatlar» kabi maqola va ma'ruzalari ilmiy doiralarda katta muhokamaga sabab bo'lgan. U Toshkentda, Anqarada, Bakuda o'tkazilgan xalqaro ilmiy konferentsiyalarda O'zbekistonni vakollık qilgan.

Pedagogik faoliyat bilan parallel ravishda ilmiy tadqiqotlar olib borgan Matmusayeva, Toshkent Davlat Madaniyat Institutida katta o'qituvchi bo'lib ishlagan. Uning «Milliy estetika asoslari» o'quv qo'llanmasi universitetlarda darslik sifatida qo'llaniladi. O'zbekiston Madaniyat vazirligi va Yozuvchilar uyushmasining faol a'zosi.`
  },

  // ━━━━━━━━━━━━━━━  TURKIYA  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {
    name: 'Halide Edib Adıvar',
    born_year: 1884, died_year: 1964,
    country_code: 'TR', category_name: 'Yozuvchilar',
    bio: `Halide Edib Adıvar — turk adabiyotining eng buyuk ayol yozuvchisi, milliy qahramon, feminist va siyosatchi. 1884-yilda Istanbulda tug'ilgan. Amerika Qo'shma Shtatlarida ta'lim olib, o'sha davr uchun g'oyatda noyob bo'lgan chet el universitetida o'qigan birinchi turk ayollaridan biri bo'ldi.

Adıvarning ijodiyotida millat ozodligi, ayollar huquqi va Turkiyaning modernlashuvi markaziy mavzular hisoblanadi. Uning «Vurun Kahpeye» (Qurmasin zolimga), «Ateşten Gömlek» (Olovli ko'ylak), «Sinekli Bakkal» (Pashshaxona bakkal) romanlari turk adabiyotining klassik asarlariga aylangan. «Ateşten Gömlek» Milliy kurtuluş urushini bevosita tasvirlagan va katta vatanparvarlik ruhini uyg'otgan.

Mustaqillik urushi yillarida (1919–1923) u nafaqat qalam bilan, balki qurol bilan ham kurashdi. Mustafa Kamol Atatürk bilan birga ishlagan, askar bo'lib urushda qatnashgan, nutqlar so'zlagan. Urushdan keyin siyosiy ixtiloflar tufayli xorijga ketishga majbur bo'lib, Angliya va Fransiyada tahsil berdi. 1939-yilda vataniga qaytib, Istanbul universitetida professor bo'ldi.

Uning nomi uchun turk maktablari, ko'chalar va kutubxonalar nomlangan. 1964-yilda Istanbulda vafot etgan Adıvar, turk milliy ongining shakllanishiga beqiyos ta'sir ko'rsatgan ulkan shaxsiyat sifatida tarixga kirdi.`
  },

  {
    name: 'Fatma Aliye Topuz',
    born_year: 1862, died_year: 1936,
    country_code: 'TR', category_name: 'Adibalar',
    bio: `Fatma Aliye Topuz — turk adabiyotida birinchi ayol romanchisi, ayollar huquqlari kurashchisi va tarjimon. 1862-yilda Istanbulda mashhur davlat arbobi Ahmad Cevdet Pasha oilasida tug'ilgan. Yoshligidan arab, fors va fransuz tillarini o'rgangan.

Birinchi romani «Muhadderrat» (1892) turk adabiyotida ayol tomonidan yozilgan ilk asar sifatida tarixga kirdi. So'ngra «Refet» (1898) va «Udi» (1899) romanlari e'lon qilib, o'z davrining eng ko'p o'qiladigan adibasi bo'lib qoldi. Asarlarida u Usmonli jamiyatidagi ayollar ahvoli, ko'p xotinlik muammosi, ta'lim huquqi masalalarini jasorat bilan ko'tardi.

Tarjimonlik sohasida ham u katta ish qildi. Fransuz yozuvchisi Georgе Sand asarlarini turk tiliga o'girdi, shu orqali g'arbiy feminist adabiyotni turk o'quvchisiga tanishtirdi. 1892-yilda «Hanımlara Mahsus Gazete» (Ayollar gazetasi) uchun maqolalar yoza boshladi va ayollar ta'limi haqida o'tkir fikrlar bildirdi.

Fatma Aliye Topuz turk feminizmi tarixida alohida o'rin tutadi. U «Türk Millî Hanımları» harakatini tashkil etib, Birinchi Jahon urushi yillarida urushda jarohatlanganlar uchun yordamlar uyushtirdi. 1936-yilda Istanbulda vafot etdi. Mustafa Kamol Atatürk uning vafotiga qayg'u bildirgan. Uning nomi uchun muzey va ko'cha nomlangan.`
  },

  {
    name: 'Semiha Ayverdi',
    born_year: 1905, died_year: 1993,
    country_code: 'TR', category_name: 'Mutafakkirlar',
    bio: `Semiha Ayverdi — turk tasavvuf adabiyotining buyuk vakili, yozuvchi, mutafakkir va faylasuf. 1905-yilda Istanbulda tug'ilgan. Usmonli aristokratiyasiga mansub oilada ulg'ayib, mukammal islomiy va g'arbiy ta'lim olgan. Naqshbandiya tariqatiga a'zo bo'lib, pir Kenan Rifai'ning ruhiy tarbiyasida kamol topgan.

Uning asarlarida islomiy ma'naviyat, tasavvuf va Usmonli madaniyati g'arb ratsionalizmi bilan nozik muvozanatda ifodalanadi. «Mesihpaşa İmamı» (1948), «Yolcu Nereye Gidiyorsun» (1944), «Batmayan Gün» trilogiyasi — uning asosiy badiiy asarlari bo'lib, ularda din, ruh va jamiyat munosabatlari chuqur tahlil qilinadi.

Publitsistik asarlari va ma'ruzalarida Ayverdi sharq va g'arb tsivilizatsiyalari munosabatini, milliy kimlik va ma'naviy inqiroz masalalarini ko'targan. «Türkiye'nin Gerçeği» (Turkiyaning haqiqati) asarida u zamonaviy Turkiyaning madaniy muammolarini teran mulohaza qiladi.

Kenye Rifai Vakfini tashkil etib, tasavvuf musiqa va san'atini saqlab qolish yo'lida katta ishlar qildi. 1993-yilda Istanbulda vafot etdi. Uning asarlari bugungi kunda turk intellektual hayotida muhim manba hisoblanadi va turli tillarga tarjima qilingan.`
  },

  {
    name: 'Şükûfe Nihal Başar',
    born_year: 1896, died_year: 1973,
    country_code: 'TR', category_name: 'Shoiralar',
    bio: `Şükûfe Nihal Başar — turk she'riyatining taniqli vakili, romanchi, feminist va ijtimoiy faol. 1896-yilda Istanbulda tug'ilgan. Istanbul Universiteti tarjimonlik fakultetini bitirgan, shu davrda turk universitetiga kirgan dastlabki ayollardan biri bo'ldi.

Uning she'rlari va romanlari vatan sevgisi, ayollar erkinligi va insoniy qadr-qimmat mavzularida yozilgan. «Hazan Rüzgârları» (Kuz shamollari, 1927) ilk she'rlar to'plami nashr etilishi bilan tanildi. «Yıldızlar ve Gölgeler» (Yulduzlar va soyalar), «Sabah Kuşları» (Tong qushlari) kabi she'rlar to'plamlari turk lirikasining nodir namunalari. Sevgi, tabiat va millat taqdiri uning she'rlarining asosiy ohanglarini tashkil etadi.

Romanchilik sohasida «Renksiz Yaşar Bektaş» (1935) va «Domani» (1943) asarlari bilan o'z o'rnini yaratdi. Bu romanlarda u provincial Turkiyaning ijtimoiy hayotini va ayollarning real muammolarini jonli tasvirlagan.

Milliy kurtuluş harakatida faol ishtirok etgan Başar, keyinchalik diplomatik sohalarda ham xizmat qildi. Istanbul Universiteti va boshqa oliy o'quv yurtlarida turk adabiyotidan dars berdi. 1973-yilda Istanbulda vafot etdi. Uning ijodi feminizm va milliy ong birlashuvi sifatida turk adabiyotshunosligida alohida o'rin tutadi.`
  },

  // ━━━━━━━━━━━━━━━  OZARBAYJON  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {
    name: 'Nigar Rafibeyli',
    born_year: 1913, died_year: 1981,
    country_code: 'AZ', category_name: 'Shoiralar',
    bio: `Nigar Rafibeyli — Ozarbayjon sovet adabiyotining eng taniqli shoirasi, dramaturg va tarjimon. 1913-yilda Bakuda tug'ilgan. Ozarbayjon Davlat Pedagogika Universiteti va Moskva Adabiyot Institutini tamomlagan.

Rafibeylining she'rlari vatan sevgisi, insoniy muhabbat, urush fojiasi va tabiat go'zalligi mavzularini qamraydi. Ulug' Vatan urushi yillarida (1941–1945) yozilgan she'rlari ayni paytda jangchilar orasida tarqatilgan va vatanparvarlik ruhini oshirishga xizmat qilgan. «Anam», «Sevgi», «Vətən», «Şəhidlərə» kabi she'rlari ozarbayjon she'riyatining oltin fondiga kirgan.

Uning dramaturgiya sohasidagi asarlari Bakudagi teatrlarda uzoq yillar sahnalanib kelgan. «Sevinc», «Həyat», «İşıqlı yollar» pyesalari Ozarbayjon milliy teatrining klassikasiga aylangan. Ayollar huquqi, jamiyat rivojlanishi va oilaviy munosabatlar uning dramatik asarlarining asosiy mavzularini tashkil etadi.

Tarjimon sifatida Pushkin, Mayakovskiy va Lesya Ukrainkaning asarlarini ozarbayjon tiliga o'girgan. Ozarbayjon SSR xalq shoirasi unvonini olgan birinchi ayol sifatida tarixga kirgan Rafibeyli, Lenin ordeni va boshqa davlat mukofotlari bilan taqdirlangan. 1981-yilda Bakuda vafot etdi.`
  },

  {
    name: 'Mirvarid Dilbazoğlu',
    born_year: 1912, died_year: 2001,
    country_code: 'AZ', category_name: 'Adibalar',
    bio: `Mirvarid Dilbazoğlu — Ozarbayjоn nasrining taniqli vakili, yozuvchi va tarjimon. 1912-yilda Şuşada tug'ilgan. Bakuda tahsil olib, Ozarbayjon Davlat Universiteti filologiya fakultetini bitirgan. Dastlab muharrirlik va o'qituvchilik bilan shug'ullangan.

Dilbazoğlunining asarlarida ozarbayjon qishloq hayoti, ayollar qismati va ijtimoiy o'zgarishlar realistik yo'nalishda tasvirlangan. «Tanlı günlər», «Sevinci qorumaq», «Ürəyin sesi» hikoya to'plamlari va «Gün batanda» romani uning eng muhim asarlari hisoblanadi. Asarlarida u ozarbayjon ayollarining kechinmalarini, oilaviy munosabatlar va millat taqdirini nozik his-tuyg'ular bilan ifodalaydi.

Tarjimonlik sohasida L.N.Tolstoy, A.P.Chexov va M.Gorkiy asarlarini ozarbayjon tiliga o'girdi. Ozarbayjon Yozuvchilar uyushmasi boshqarma a'zosi sifatida adabiy hayotda faol ishtirok etdi. Ozarbayjon SSR Davlat mukofoti va «Şərəf nişanı» ordeni bilan taqdirlangan.

XX asr ozarbayjon ayol nasrining asoschilaridan biri sifatida Dilbazoğlu ijodiy merosi adabiyotshunoslik ilmida alohida o'rganiladi. 2001-yilda Bakuda vafot etib, ozarbayjon adabiyotiga boy meros qoldirdi.`
  },

  {
    name: 'Sara Ashurbayli',
    born_year: 1906, died_year: 2001,
    country_code: 'AZ', category_name: 'Mutafakkirlar',
    bio: `Sara Ashurbayli — Ozarbayjоn tarixchisi, arxeologi va davlat arbobi, Ozarbayjon Fanlar Akademiyasining muxbir a'zosi. 1906-yilda Bakuda taniqli savdogar oilasida tug'ilgan. Leningrad Davlat Universitetida sharqshunoslik bo'yicha ilmiy daraja olgan.

Ashurbayli ilmiy tadqiqotlarini asosan Ozarbayjon va Kavkaz tarixiga, ayniqsa o'rta asrlar Shirvan va Bakuiga bag'ishlagan. «Bakı şəhərinin tarixi» (Baku shahrining tarixi, 1964) fundamental asari sharqshunoslik ilmida muhim manba sifatida tan olingan. Bu asar Baku shahrining arxeologik, tarixiy va ijtimoiy-iqtisodiy rivojlanishini IX asrdan XX asrgacha kuzatadi.

Uning boshqa yirik asarlari — «Şirvan dövləti» (Shirvan davlati), «İlk orta əsrlərdə Azərbaycan şəhərlərinin iqtisadi tarixi» (Dastlabki o'rta asrlarda Ozarbayjon shaharlari iqtisodiy tarixi) va Zardusht diniga oid bir qator tadqiqotlar. Oz tekshirishlari uchun u Ozarbayjon, Rossiya, Angliya va Fransiyaning ko'plab arxivlarida ishlagan.

Ozarbayjon ilmiy hamjamiyatida hurmat qozongan Ashurbayli ko'plab xalqaro ilmiy anjumanlarda ishtirok etgan. Ozarbayjon SSR Davlat mukofoti, «Əmək Qırmızı Bayrağı» ordeni va boshqa unvonlar bilan taqdirlangan. 2001-yilda Bakuda 95 yoshida vafot etib, o'zidan boy ilmiy meros qoldirdi.`
  },

  {
    name: 'Şəfiqə Axundova',
    born_year: 1924, died_year: 2012,
    country_code: 'AZ', category_name: 'Yozuvchilar',
    bio: `Şəfiqə Axundova — Ozarbayjon adabiyotining yirik vakili, romanchisi, dramaturgi va stsenaristи. 1924-yilda Bakuda tug'ilgan. Ozarbayjon Davlat Universiteti filologiya fakultetini tamomlagan, keyin Moskvada Oliy adabiy kurslarda tahsil olgan.

Axundovaning romanları ozarbayjon ayollari hayotining turli jihatlarini ishonchli va ta'sirchan tasvirlaydi. «İşığa doğru» (Nurga tomon, 1952), «Günəşli gecə» (Quyoshli tun, 1963), «Seçilmiş əsərlər» (Tanlangan asarlar, 1980) asarlari ozarbayjon nasr tarixida muhim o'rin tutadi. Uning qahramonlari - sovet davri va undan keyingi davrda o'z o'rnini izlayotgan ozarbayjon ayollari: kuchli, irodali va hissiyotli.

Dramaturgiya sohasida ham bir qator pyesalar yozgan Axundova, ularning bir nechtasi Ozarbayjon Akademik Milliy Teatrida sahnalashtirildi. Kino ssenariylari ham yozib, ayrim filmlar muvaffaqiyat qozondi.

Ozarbayjon Yozuvchilar uyushmasining faol a'zosi va boshqarma raisi o'rinbosari bo'lgan Axundova, yosh adiblarni tarbiyalashda katta rol o'ynadi. Ozarbayjon SSR Xalq yozuvchisi unvoni bilan taqdirlangan. 2012-yilda Bakuda vafot etdi.`
  },

  // ━━━━━━━━━━━━━━━  QOZOG'ISTON  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {
    name: 'Sara Tlepbergenova',
    born_year: 1929, died_year: 1994,
    country_code: 'KZ', category_name: 'Shoiralar',
    bio: `Sara Tlepbergenova — Qozog'iston xalq shoirasi, «Sara» nomi bilan mashhur bo'lgan, qozoq she'riyatining eng sevimli ovozlaridan biri. 1929-yilda Qizilorda viloyatida tug'ilgan. Almata Davlat Universitetida filologiya bo'yicha tahsil olgan.

Sara Tlepbergenova she'rlarini qozoq she'riyatining eng nozik lirik an'analarida yozdi. Ona tabiat, qozoq dasht manzaralari, sevgi va yo'qotish uning ijodining asosiy mavzulari. Uning she'rlari qirqdan ortiq she'riy to'plamlarda to'plangan va ulardan ko'pchiligi qo'shiqqa aylantirilgan. «Жүрек жылуы» (Yurak issiqligi), «Алтын бидай» (Oltin bug'doy), «Анамның жыры» (Onamning qo'shig'i) to'plamlari Qozog'istonda juda mashhur.

U qozoq xalq og'zaki ijodi — epik dostonlar va lirik kuylardan ilhomlanib, ularni zamonaviy she'r formasiga ko'chirdi. Shu orqali milliy an'ana bilan zamonaviy adabiyotning ko'priklarini qurdi. Qozoq radiosi va televideniyesi uchun ham ko'plab she'rlar yozdi.

Qozog'iston SSR xalq shoirasi unvoni, Davlat mukofoti va boshqa ko'plab mukofotlar sohibi Sara Tlepbergenova 1994-yilda Almatada vafot etdi. Uning yodiga atab mamlakat bo'ylab festivalllar va she'riy kechalar o'tkaziladi.`
  },

  {
    name: 'Fatima Gabdullina',
    born_year: 1935, died_year: null,
    country_code: 'KZ', category_name: 'Adibalar',
    bio: `Fatima Gabdullina — Qozog'istoning taniqli adibasi, esseychisi va madaniyat arbobi. 1935-yilda Semey shahri yaqinida tug'ilgan. Almata Davlat Pedagogika Institutini tamomlagan, keyinchalik Moskva Yozuvchilar Institutida malaka oshirgan.

Gabdullinaning asarlarida qozoq qishloq hayoti, an'anaviy turmush tarzining zamonaviylik bilan to'qnashuvi va qozoq ayollarining ma'naviy dunyosi realistik va sezgir tarzda tasvirlangan. «Қыз-ана» (Qiz-ona), «Жусан иісі» (Yusuf hidi), «Байтақ дала» (Keng dala) kabi hikoya va qissa to'plamlari Qozog'iston adabiyoti kitobxonlari orasida sevib o'qilgan.

Qozoq milliy ong va an'analari haqida yozilgan esselari matbuotda keng e'lon qilindi. Shirin tili, milliy kolorit va psixologik chuqurligi bilan ajralib turuvchi Gabdullina, 1970-1990-yillar qozoq nasrini boyitishga katta hissa qo'shdi.

Qozog'iston Yozuvchilar uyushmasining faol a'zosi va bir necha yillar davomida uni boshqaruvchi kengash a'zosi bo'lgan Gabdullina, bir necha davlat mukofotlari va faxriy unvonlarga sazovor bo'ldi. U hozir ham faol ijodkor sifatida tanilgan.`
  },

  {
    name: 'Makpal Qunanbayeva',
    born_year: 1950, died_year: null,
    country_code: 'KZ', category_name: 'Yozuvchilar',
    bio: `Makpal Qunanbayeva — zamonaviy qozoq proza adabiyotining yirik vakili, romanchisi va jamoat arbobi. 1950-yilda Almata viloyatida tug'ilgan. Almata Davlat Universitetida filologiya bo'yicha tahsil olib, keyinchalik Moskvada Oliy adabiy kurslarda malaka oshirgan.

Qunanbayevaning romanlari qozoq zamonaviy hayotining keng manzarasini, tarixiy o'zgarishlar va shaxs taqdiri munosabatlarini tadqiq etadi. «Жер-ана» (Er-ona), «Таң жарығы» (Tonggi nur), «Қайтадан туу» (Qayta tug'ilish) romanlari tanqidchilar va kitobxonlar tomonidan yuqori baholangan.

Uning asarlarida qozoq ayollarining kuchi, chidami va ma'naviy go'zalligi alohida ta'kidlanadi. Zamonaviy Qozog'istonning ijtimoiy va madaniy muammolarini chuqur tahlil qiluvchi Qunanbayeva, adabiy-badiiy tanqid sohasida ham faol. Bir necha adabiyot jurnallarida muharrir va muallif sifatida ishtirok etgan.

Xalqaro adabiy anjumanlarda Qozog'istonni vakollık qilgan Qunanbayeva, turk va o'zbek hamkasblari bilan hamkorlik qilib keladi. Qozog'iston Yozuvchilar uyushmasi mukofoti va «Qozog'iston xalq yozuvchisi» unvoni bilan taqdirlangan.`
  },

  {
    name: 'Küläsh Bayserkenova',
    born_year: 1928, died_year: 2015,
    country_code: 'KZ', category_name: 'Dramaturglar',
    bio: `Küläsh Bayserkenova — qozoq dramaturgiyasi va teatr san'atining zabardast vakili, dramaturg va pedagog. 1928-yilda Pavlodar viloyatida tug'ilgan. Almata Davlat Teatr va San'at Institutini tamomlagan. Yillar davomida Qozog'iston Davlat Akademik Mukhtar Auezov nomidagi Drama teatrida dramaturg va adabiy mudir bo'lib ishlagan.

Bayserkenova qozoq dramaturgiyasiga o'nlab original pyesalar in'om etdi. «Таң шолпаны» (Tong yulduzi), «Биле-биле» (Biling-biling), «Той баста» (Toʻy boshla), «Ескі дос» (Eski do'st) pyesalari qozoq teatrining repertuar asosini tashkil etdi. Uning asarlarida milliy an'analar, zamonaviy hayot va inson qadr-qimmati asosiy mavzular sifatida ko'tariladi.

Dramaturgiyadagi texnik mahorati — dialog yozish san'ati, sahnaviy vaziyatlar qurishning ustasi sifatida Bayserkenova qozoq sahna san'atiga yangi nafas olib kirdi. Uning pyesalari nafaqat Qozog'istonda, balki O'rta Osiyo respublikalari teatrlarida ham sahnalantirildi.

Pedagogik faoliyatda ham iz qoldirgan Bayserkenova, Almata Teatr Institutida dramaturgiya fanlarini o'qitdi. Ko'plab shogirdlari qozoq teatri va adabiyotida salmoqli o'rinlar egallagan. Qozog'iston SSR Xalq artisti unvoni va «Parasat» ordeni bilan taqdirlangan. 2015-yilda Almatada vafot etdi.`
  },

  // ━━━━━━━━━━━━━━━  QIRGʻIZISTON  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  {
    name: "Toktogul qızı Satılganova",
    born_year: 1864, died_year: 1933,
    country_code: 'KG', category_name: 'Shoiralar',
    bio: `Toktogul qızı Satılganova — qirg'iz og'zaki adabiyoti an'anasining asoschi siymolaridan biri, akin (baxshi) va improvizator shoira. 1864-yilda Talas viloyatida tug'ilgan. Qirg'iz og'zaki she'riyati an'analarida tarbiyalangan, yosh yoshidan komuz (milliy cholg'u) chalishni va she'r to'qishni o'rgangan.

Uning asarlari qirg'iz xalq lirikasining eng noyob namunal sifatida tan olinadi. Tabiat go'zalligi, inson sevgisi, ona yurti, jamiyatdagi adolatsizliklar — bular Satılganovaning asosiy mavzulari. Uning qo'shiqlari avloddan-avlodga og'izdan-og'izga o'tib, qirg'iz milliy xazinasiga aylangan.

XX asr boshida Rossiya imperiyasi hokimiyati tomonidan quvilib, bir necha yil Sibirda qolgan. Sovet davrida vataniga qaytib, milliy adabiy harakatning jonlanishiga katta hissa qo'shgan. Uning asarlari sovet qirg'iz olimlar tomonidan yozib olinib, nashr etilgan.

Qirg'iz xalqining ruhiy va madaniy hayotini ifodalaydigan she'r va qo'shiqlarining soni to'rtdan ortiq mingga yetadi. «Toktogul qızı» nomi bugungi kunda Qirg'izistonda maktab, kutubxona va ko'chalar nomida yashaydi. Bishkek shahrida uning haykal-portreti o'rnatilgan.`
  },

  {
    name: 'Şugula Bayaliyeva',
    born_year: 1938, died_year: null,
    country_code: 'KG', category_name: 'Yozuvchilar',
    bio: `Şugula Bayaliyeva — qirg'iz zamonaviy nasrining taniqli vakili, romanchisi va qissachi. 1938-yilda Osh viloyatida tug'ilgan. Qirg'iz Davlat Universitetining filologiya fakultetini bitirgan, keyinchalik Moskvada Oliy adabiy kurslarda tahsil olgan.

Bayaliyevaning asarlarida qirg'iz qishloq hayoti, Farg'ona vodiysi tabiatи va urf-odatlari, zamonaviy şahar hayotining muammolari jonli va ta'sirchan tarzda aks ettirilgan. «Тоо жаңырыгы» (Tog' aksi), «Айгүл» (Aygul), «Бириккен жүрөктөр» (Birlashgan yuraklar) romanlari va ko'plab qissalar va hikoyalar uning asosiy asarlari.

Uning asarlarida ayollar roli va kuchi alohida ko'tariladi. Zamonaviy qirg'iz ayolining ichki dunyosi va tashqi muammolari Bayaliyeva qalamidan teran va hissiyotli tarzda chiqadi. Qirg'iz adabiyotida ayol nasrining rivojlanishiga katta hissa qo'shdi.

Qirg'iziston Yozuvchilar uyushmasining faol a'zosi bo'lgan Bayaliyeva, bir necha davr davomida boshqarma a'zosi bo'lib xizmat qildi. Qirg'iziston Respublikasi Davlat mukofoti va «Manas» ordeni bilan taqdirlangan.`
  },

  {
    name: 'Zamira Sydykova',
    born_year: 1953, died_year: null,
    country_code: 'KG', category_name: 'Adibalar',
    bio: `Zamira Sydykova — qirg'iz jurnalisti, adibasi, siyosatshunos va diplomat. 1953-yilda Bishkekda tug'ilgan. Moskva Davlat Universiteti jurnalistika fakultetini tamomlagan, doktorlik dissertatsiyasini siyosat fanlari bo'yicha himoya qilgan.

Sydykova mustaqil matbuotning Qirg'izistondagi jonlanishi uchun kurashchisi sifatida tanilgan. «Res Publica» gazetasini asoschilardan biri bo'lgan va uzoq yillar bosh muharrir bo'lib ishlagan. Matbuot erkinligi va demokratlashtirish uchun kurashda bir necha marta hibsga olingan, lekin har safar kurashni davom ettirgan.

Adabiyot sohasida o'zining jurnalistik va publitsistik asarlari bilan tanilgan Sydykova: «Qirg'izistonda matbuot ozodligi», «Demokratiya va Markaziy Osiyo», «Ayol va siyosat» kabi tahliliy kitoblari mavjud. Ularning bir qismi ingliz va rus tillarida ham nashr etilgan.

Qirg'izistonda Slovakiya elchisi bo'lib ham xizmat qilgan Sydykova, xalqaro demokratiya tashkilotlari faoliyatida keng ishtirok etadi. UNESCO va Xalqaro Matbuot Instituti tomonidan mukofotlangan. Qirg'iz fuqarolik jamiyatining shakllanishida alohida o'rni bor.`
  },

  {
    name: 'Aliya Tokombaeva',
    born_year: 1955, died_year: null,
    country_code: 'KG', category_name: 'Mutafakkirlar',
    bio: `Aliya Tokombaeva — qirg'iz faylasufi, pedagogi va madaniyat arbobi. 1955-yilda Issiqko'l viloyatida tug'ilgan. Leningrad Davlat Universitetida falsafa bo'yicha oliy ma'lumot olgan va dissertatsiyasini «Sharq falsafasida ma'naviyat va kimlik» mavzusida himoya qilgan.

Tokombaevaning ilmiy va publitsistik asarlari qirg'iz milliy falsafasi, Manaschi (epos ijodchilari) an'anasi va bugungi globallashuv davrida Markaziy Osiyo xalqlarining identiteti masalalarini qamraydi. «Мурас жана Заман» (Meros va Davr), «Кыргыз руху» (Qirg'iz ruhi) ilmiy-ommabop asarlari keng kitobxonlar ommasiga mo'ljallangan.

U «Manas» eposi va qirg'iz xalq donishmandligini falsafiy nuqtai nazardan talqin qiladi, shu orqali milliy ma'naviyatni zamonaviy ilm bilan boyitadi. Uning ma'ruzalari nafaqat Qirg'izistonda, balki Qozog'iston, O'zbekiston va Turkiyada ham tinglovchilarni jalb etdi.

Qirg'iz Milliy Universitetida falsafa kafedrasi mudiri sifatida yillar davomida faoliyat yuritgan Tokombaeva, bir necha dissertatsiyalarning ilmiy rahbari bo'lgan. UNESCO «Madaniyatlararo muloqot» dasturida qatnashgan. Qirg'iziston Fanlar akademiyasining muxbir a'zosi.`
  },
];

// ─── Asarlar ───────────────────────────────────────────────────────────────
const WORKS = [
  // ── Mohlaroyim Nodira ──
  {
    creatorName: 'Mohlaroyim Nodira',
    title: 'Ulkim edi (Ghazal)',
    description: "Nodiraning sevgi va yo'qotish haqidagi mashhur ghazali. Ulkim edi — ulug' o'zbek she'riyatining durdonalaridan biri.",
    content_text: `Ulkim edi bu ko'nglumning malohi, ulkim edi,
Hayoti dilim, quvvati ruhim, ulkim edi.

Ko'zum nuri, dilim sururin ol taqdir etti,
Ko'ylak bag'rimdagi tikan — o'tli dog'im, ulkim edi.

Har kecha yig'ladim yoru do'stlardan yiroq,
Sarvinozim, gul chamanim, bog'im — ulkim edi.

Ko'zi qora, kiprik uzun, lab la'l misoli,
Sochim ta'bi, mehribonim, tog'im — ulkim edi.

Nodira ko'zing yoshini, ko'ngling g'amini bil,
Dardingga darmon bo'lgan javonmard — ulkim edi.`,
  },
  {
    creatorName: 'Mohlaroyim Nodira',
    title: 'Sog\'indim (Ghazal)',
    description: "Vatan va sevgilidan ayrilish hasratida yozilgan lirik ghazal.",
    content_text: `Sog'indim dilbaru yoru diyoru xonumonimni,
Sog'indim zulfi mushkin, qaddi sarv-i-ravonimni.

Ko'zum tushsa gul-u rayhonga — yod etar bag'imni,
Ko'z yoshi sel bo'lib oqar — sog'indim ko'zing qonimni.

Bulbul sayrasa chamanda sevinch to'lmaz ko'nglima,
Chunki yo'q yonim da bo'lsang — sog'indim mehribonim.

Davron vafosiz erur, baxt qo'llamas har kimni,
Nodira aytsin yana bir bor — sog'indim hayotimni.`,
  },

  // ── Zulfiya Isroilova ──
  {
    creatorName: 'Zulfiya Isroilova',
    title: 'Bahorga maktub',
    description: "Zulfiyaning tabiатga bag'ishlangan lirik she'ri — bahor va yangilanish haqida.",
    content_text: `Bahor, sen yana keldingmi,
Qorni eritib yerlardan?
Lolalar ochildi tog'da,
Suvlar oqdi sel bo'lib.

Men senga maktub yozardim
Qish uzun tunda yolg'iz,
Izladim seni har erta,
Ko'zimda yosh, ko'nglimda so'z.

Endi kelib qolding bahor,
Ko'cha-ko'yda kulgular.
Yashil libos, gul chambar,
Tong saharlab shivirlar.

Yurtim go'zal, yurtim aziz,
Sen bor ekan — men borman.
Bahor sevinci, bahor izi —
Umrim, orzum — shunday.`,
  },
  {
    creatorName: 'Zulfiya Isroilova',
    title: 'Ona (She\'r)',
    description: "Ona va farzandlik muhabbatiga bag'ishlangan lirik she'r.",
    content_text: `Onam qo'llari — issiq non,
Onam ko'zlari — tiniq tong.
Har shabnam sizib yosh bo'lib,
U menga yo'l ko'rsatgan.

Uyqusiz o'tkazgan tunlar,
Mening baxtim uchun kurash.
Onam menga bergan umid —
Eng katta boylik, eng katta.

Endi men ham ulg'aydim,
Ko'raman dunyo va hayot.
Lekin onam qo'llari —
Menга меhr bergan, bergan.`,
  },

  // ── Sabohat Ashrafova ──
  {
    creatorName: 'Sabohat Ashrafova',
    title: 'Hayot kechasi (Qissa parchasi)',
    description: "Sabohat Ashrafovaning 'Hayot chegarasida' romanidan parcha — zamonaviy o'zbek ayolining kechinmalari.",
    content_text: `Maftuna ertalab uyg'ondi va ko'zi darhol derazadan ko'rindi. Tashqarida yana bir kuz kelgan edi. Daraxt barglar sariq va qizil rangga boyidi, shamol ularni olib ketardi. Xuddi o'zining yillar davomida to'plagan xotiralari kabi.

U o'tgan yigirma yilni esladi. Zavodda ishlagan, bolalarini o'qitgan, erining to'rt yil kasalxonada yotishiga sabr etgan yillar. Hech kim unga «yashash qiyin» demadi. Chunki u hech kimga shikoyat qilmadi. Ichida kuydi, lekin yuzi doim ochiq edi.

Bugun kenja o'g'li universitetga topshirdi. Eng yaxshi baholar bilan. Maftuna o'zini tutolmadi — ko'zi yoshlandi. Ammo bu safar baxtdan yig'ladi. Hayot chegarasida ko'p marta darz ketgan bo'lsa-da, u hech qachon sinmagan edi.`,
  },
  {
    creatorName: 'Sabohat Ashrafova',
    title: 'Ikkita yo\'l (Pyesa parchasi)',
    description: "Ashrafovaning 'Baxtli oila' pyesasidan parcha — ikki avlod va ikki tafakkur to'qnashuvi.",
    content_text: `LOLA: Ona, men tushunmayapman. Nega men xohlagan narsani qila olmayman?

ONA: (sekin) Chunki hayot shunday, qizim. Ba'zan xohlaganing bilan qilmog'ing o'rtasida to'siq bo'ladi. O'sha to'siqni engib o'tish uchun sabr kerak.

LOLA: Lekin sen doim sabr deysan! Men sabr qilishni bilaman. Lekin hayotni ham yashashni istayman!

ONA: (unga qarab) Sen hali yoshsan, Lola. Hayot — bu faqat intilish emas. U — kechirish, sevish va... ba'zan kutish ham.

LOLA: (jimib qoladi, keyin) Men o'z yo'lim bilan ketsamchi?

ONA: (uzoq jim turadi, keyin asta) Agar yo'ling to'g'ri bo'lsa — ket. Men doim orqangdaman.`,
  },

  // ── Gavhar Matmusayeva ──
  {
    creatorName: 'Gavhar Matmusayeva',
    title: 'Ruh manzarasi (Esse parchasi)',
    description: "Gavhar Matmusayevaning 'Ruh manzaralari' esse to'plamidan — ona tili va milliy kimlik haqida.",
    content_text: `Til — bu faqat so'zlar majmui emas. U — xalqning ko'zgusi, avlodlar xotirasi va hozirning nafasi. O'zbek tilida birgina «ko'ngil» so'zi bor — uni hech bir tilda to'liq tarjima qilib bo'lmaydi. Ko'ngil — bu yurak ham, aql ham, ruh ham, his ham. Bu so'z — bizning dunyoni qanday his qilishimizning ifodasi.

Men ko'p yillar falsafiy izlanishlarda shu savolga qaytib keldim: Kimligimizni nima belgilaydi? Tilimizmi? Dinimizmi? Tariximizmi? Javob oddiy emas. Lekin aniq bilamanki — kim o'z tilidan bezib ketsa, o'zidan ham uzoqlashadi.

Ona tilni unutish — xotira yo'qotishga o'xshaydi. Kishi o'zining qaerdan kelganini, nima uchun bu yerda ekanini bilmaydi. An'ana va zamonaviylik o'rtasidagi ko'prik — shu ona tilidir. Uni saqlash — nafaqat madaniy burch, balki ruhiy zaruriyat.`,
  },
  {
    creatorName: 'Gavhar Matmusayeva',
    title: 'Samarqand bahori (She\'r)',
    description: "Samarqandning bahor go'zalligiga bag'ishlangan lirik she'r.",
    content_text: `Samarqand bahori keldi yana,
Registon olmosday yarqirar.
Ko'k gumbaz, tillо minora —
Tarixning ko'klami bo'lar.

Shu ko'chadan Amir o'tgan,
Bu suvda Ulug'bek ko'rgan.
Men bosgan yo'lda ming-ming ta
Avlodlar izini ko'raman.

Qadimiy shahrim, aziz shahrim,
Sening havong — she'r menga.
Bahor kelsa, yuragim to'liq —
Seni sevaman, Samarqand.`,
  },

  // ── Halide Edib Adıvar ──
  {
    creatorName: 'Halide Edib Adıvar',
    title: 'Qizil Olma (Roman parchasi)',
    description: "Halide Edibning Milliy Kurtuluş urushi ruhidagi mashhur 'Ateşten Gömlek' romanidan parcha.",
    content_text: `Ayşe şehrin sokaklarında yürürken, duvarlar üzerindeki işaretleri gördü. Düşman henüz şehre girmemişti ama korkusu çoktan gelmişti. Evlerin kapıları kapalıydı, çarşı sessizdi. Yalnızca uzaktan top sesleri duyuluyordu.

"Bu vatan," dedi kendi kendine, "bu toprak bizim." Elleri titriyordu ama gözleri parlıyordu. Düşünüyordu: eğer herkes çekip giderse, bu taşlar, bu duvarlar, bu gökyüzü kimin olacak?

Sokağın köşesinde bir ihtiyar kadın oturuyordu. Ayşe ona baktı. Kadın hiçbir şey söylemeden başını kaldırdı ve gülümsedi. O gülümseme, bütün konuşmalardan daha güçlüydü.

Ayşe yürümeye devam etti. Adımları daha kararlıydı artık.`,
  },
  {
    creatorName: 'Halide Edib Adıvar',
    title: 'Özgürlük Üzerine (Nutq parchasi)',
    description: "Halide Edibning 1919-yil Sultanahmet meydoni mitingidagi mashhur nutqidan parcha.",
    content_text: `Kardeşlerim, bu topraklar bizimdir. Bizi buradan kim çıkarabilir? Silahlar mı? Hayır. Zira biz bu toprakla bütünleştik. Her karış toprağın altında atalarımızın nefesi var.

Bugün burada bir şeye yemin ediyoruz: Bu vatan ya hür yaşayacak, ya hür ölecek. İnsan özgürlüğü, bir milletin özgürlüğü — bunlar alınamaz, satılamaz. Tarih bize bunu öğretti.

Kadın olarak, Türk kadını olarak söylüyorum: Vatan sevgisi cinsiyetten üstündür. Silah tutamasak da, kalemiyle, sesiyle, varlığıyla her Türk kadını bu mücadelede yerini alacaktır.

Yaşasın hürriyet! Yaşasın Türkiye!`,
  },

  // ── Fatma Aliye Topuz ──
  {
    creatorName: 'Fatma Aliye Topuz',
    title: 'Muhadderrat (Roman parchasi)',
    description: "Turk adabiyotidagi birinchi ayol romani 'Muhadderrat'dan parcha — ayollar va ta'lim haqida.",
    content_text: `Fatıma hanım pencereden dışarıyı seyrediyordu. Sokakta çocuklar oynuyordu. Erkek çocuklar mektebe gidiyordu, kızlar ise evde kalıyordu.

"Neden?" diye sordu kendi kendine, kaçıncı kez bu soruyu soruyordu. Neden kızlar da okuyamasın? Neden bilgi yalnızca erkeklere ait olsun?

Kitabı eline aldı. Bu kitabı gizlice getirtmişti. Fransızca öğrenmişti, ama bunu kimseye söyleyemiyordu. Bir kadının yabancı dil öğrenmesi... insanlar ne derdi?

Ama o artık korkmaya karar vermemişti. Bilgi — özgürlüktü. Ve o özgür olmayı seçmişti.`,
  },
  {
    creatorName: 'Fatma Aliye Topuz',
    title: 'Kadın ve İlim (Esse)',
    description: "Fatma Aliye Topuzning ayollar ta'limi haqidagi mashhur essedan parcha.",
    content_text: `Bir millet yarısını kullanmadan tam anlamıyla ilerleyebilir mi? Kadınlarımız — toplumun yarısı, belki daha fazlası. Onlara verilmiş yetenekler, kapatılmış kapılar ardında solup gitmektedir.

İlim, bir cinsiyetin tekeli olamaz. Tarihimize baktığımızda görürüz ki, İslam medeniyetinin en parlak dönemlerinde kadın âlimler, şairler, hekimler mevcuttu. O gelenekten neden uzaklaştık?

Bir annenin eğitimli olması, onun çocuklarının da aydın yetişmesi demektir. Bu — bir ailenin değil, bir milletin meselesidir. Kadınlarımıza ilim kapılarını açalım. Bu yalnızca adalet değil — zarurettir.`,
  },

  // ── Semiha Ayverdi ──
  {
    creatorName: 'Semiha Ayverdi',
    title: "Yolcu Nereye Gidiyorsun (Roman parchasi)",
    description: "Semiha Ayverdi'nin tasavvuf ruhli romanidan parcha — ruhiy axtarish va ma'no haqida.",
    content_text: `"Nereye gidiyorsun?" diye sordu ihtiyar derviş.

Adam durdu. Kimse ona böyle sormamıştı. Herkes nereye gittiğini, ne kadar süreceğini sorardı. Ama nereye gittiğini...

"Bilmiyorum," dedi dürüstçe.

Derviş güldü. "İşte doğru cevap bu. Yolculuğun başlangıcı ancak böyle olur. Nereye gittiğini bilenler, genellikle yolda kaybolurlar. Çünkü onlar haritaya bakarlar, manzaraya değil."

Adam bir süre düşündü. "Peki sen nereye gidiyorsun?"

"Ben mi? Ben buradayım. Yol dışarıda değil, içinde."`,
  },
  {
    creatorName: 'Semiha Ayverdi',
    title: "Türk Medeniyeti Üzerine (Esse parchasi)",
    description: "Semiha Ayverdi'nin Türk-İslam medeniyeti hakkındaki derin düşüncelerinden parcha.",
    content_text: `Bizim medeniyetimiz, salt maddi değerlerin üzerine inşa edilmemiştir. Onun temeli, insanın iç âlemini işlemek, kalbi tamir etmek üzerine kurulmuştur.

Mevlana'nın "Gel, gel, ne olursan ol, yine gel" demesi tesadüf değildir. Bu davet — yalnızca Müslümana değil, bütün insanlığadır. Çünkü Türk-İslam medeniyetinin özü, kapsayıcılıktır, birleştiricidir.

Batı medeniyeti tekniği geliştirdi. Biz bunu inkâr etmiyoruz. Lakin insanın iç huzurunu, ahlaki derinliği, komşuya saygıyı, misafiri Allah'ın emaneti olarak görmeyi — bunlar onlarda ne ölçüde var?

Bize düşen, ne körü körüne Batı'ya öykünmek, ne de kendi içimize kapanmak. Kendi kökümüzden beslenip, insanlığa sunabileceğimiz meyveler yetiştirmektir.`,
  },

  // ── Şükûfe Nihal Başar ──
  {
    creatorName: 'Şükûfe Nihal Başar',
    title: "Hazan Rüzgârları (She'r)",
    description: "Şükûfe Nihal Başar'ın kuz va o'tkinchilik haqidagi mashhur she'ri.",
    content_text: `Hazan rüzgârları geldi yine,
Sarardı yapraklar, büküldü dal.
Ne kaldı geçen bahardan geriye?
Soluk bir anı, uzak bir masal.

Ama sen gitme, kal yanımda biraz,
Gözlerim arıyor seni dumanda.
Hazan gelir gelir, bir gün geçer —
Bahar döner, sevgi kalır bu yanda.

Yıllar geçer, ömür tükenir yavaş,
Ama şu an — seninle, burada —
Bu rüzgâr bile sevgi gibi çıkar,
Hazan rüzgârı bile bir armağan bana.`,
  },
  {
    creatorName: 'Şükûfe Nihal Başar',
    title: "Türk Kadınına (She'r)",
    description: "Türk kadınının kuchiga bag'ishlangan vatanparvarlik she'ri.",
    content_text: `Türk kadını — sabah yeli gibi,
Yurdu için yakar içini.
Mektepte öğrendi, tarlada çalıştı,
Cephede koştu, yavrusunu büyüttü.

Söz hakkı yoktu uzun yıllar,
Sesini kıstılar, yolunu kestiler.
Ama o susmadı, vazgeçmedi —
Her zulme karşı dimdik durdu.

Bugün özgür, bugün güçlü,
Kalemle, sesle, düşünceyle silahlanmış.
Türk kadını — bu ülkenin yarısı,
Bu milletin onuru, bu toprağın canı.`,
  },

  // ── Nigar Rafibeyli ──
  {
    creatorName: 'Nigar Rafibeyli',
    title: "Anam (She'r)",
    description: "Nigar Rafibeylining ozarbayjon she'riyatining nodir namunasi — ona sevgisi haqida.",
    content_text: `Anam, sənin gözlərindən oxudum
Ömrün ağrısını, işığını bir yerdə.
Əllərin — əkmək kimi isti,
Gülüşün — baharın nəfəsi.

Gecələr yatmadın mənim üçün,
Gündüzlər çalışdın yorulmadan.
Mən böyüdüm, sən kiçildin sanki —
Ömrünü verdın mənə, bilmədim.

İndi uzaqda, illər keçib,
Gözlərimi yumanda görürəm səni.
Anam, dünyada bir sevgi var ki —
O — analar sevgisi, əbədi.`,
  },
  {
    creatorName: 'Nigar Rafibeyli',
    title: "Vətən (She'r)",
    description: "Ulug' Vatan urushi yillarida yozilgan vatanparvarlik she'ri — Ozarbayjon xalqiga bag'ishlangan.",
    content_text: `Vətən, sənin torpağın altında
Atalarım yatır, nənələrim.
Sənin üçün döyüşdü onlar,
Canlarını verdilər — sevdilər.

Bu torpaq bizimdir — nə güllə,
Nə qılınc ala bilər bizdən.
Döyüşərik, müdafiə edərik —
Azərbaycan — canımızdır, canımız.

Torpaqda çiçək açar yazda,
Çay axar dağlardan dənizə.
Bu gözəllik — bizim mirasımız,
Onu qoruyacağıq — elə and içirik.`,
  },

  // ── Mirvarid Dilbazoğlu ──
  {
    creatorName: 'Mirvarid Dilbazoğlu',
    title: "Tanlı günlər (Hikoya parchasi)",
    description: "Mirvarid Dilbazoğlunun Ozarbayjon qishlog'i hayotini tasvirlovchi hikoyasidan parcha.",
    content_text: `Gün enirdi. Kənd sakitləşirdi. Uşaqlar evə qayıtmışdı, inəklər damları doldurmuşdu. Günəş dağların arxasına çəkilərkən bütün kəndi narıncı bir işığa bürüdü.

Xanim həyətdə oturmuşdu. Əlindəki iş görünürdü amma o işini unutmuşdu. Düşünürdü. Bugün qızı şəhərə getdi. İndi ev böyük, susqun görünürdü.

"Böyümək bu deməkdir," dedi özünə. "Uçurlar. Onları saxlaya bilməzsən."

Qonşunun körpəsi ağladı uzaqdan. Bir ana qaçdı ona tərəf. Həyat davam edirdi — bu kənddə, bu insanlarda, bu axşam işığında.`,
  },
  {
    creatorName: 'Mirvarid Dilbazoğlu',
    title: "Gün batanda (Esse parchasi)",
    description: "Ozarbayjon tabiatining g'aroyib go'zalligi haqida lirik esse.",
    content_text: `Xəzər sahilindəki axşamlar — heç bir tabloya sığmaz. Günəş dənizə batanda su qızıla boyanır, göy isə narıncıdan bənövşəyə keçir. Sanki bütün rənglər son dəfə görüşür, vidalaşır.

Bu mənzərəyə baxanda insan kiçilir, sonra böyüyür. Kiçilir — çünki Xəzər sonsuz, insan isə bir qum dənəsi kimidir. Böyüyür — çünki bu gözəlliyi görə bildiyi üçün.

Azərbaycanlı qadın bu torpaqla birgə böyüyüb. Dağ havası, dəniz nəfəsi, bağ qoxusu — bunlar onu şəkilləndirdi. Onun şeirləri, hekayələri — bu torpaqdan süzülüb gəlir.`,
  },

  // ── Sara Ashurbayli ──
  {
    creatorName: 'Sara Ashurbayli',
    title: "Bakı şəhərinin tarixi (Elmiy esse parchasi)",
    description: "Sara Ashurbayli'ning fundamental Boku tarixi asaridan parcha — IX-XII asrlar.",
    content_text: `Bakı — Xəzər sahilindəki bu qədim şəhər — VIII-IX əsrlərdən etibarən mənbələrdə xatırlanmaqdadır. Ərəb coğrafiyaçıları onu "Baku" yaxud "Bakuyih" adı ilə qeyd etmişlər. Şəhər neftin yanmasından əmələ gələn "əbədi alov"ları ilə məşhur idi.

Şirvanşahlar dövlətinin tərəqqisi dövründə, xüsusən XI-XII əsrlərdə Bakı böyük siyasi və ticari əhəmiyyət kəsb etdi. Şəhər ətrafında tikilən qala divarları, Qız Qalası, Şirvanşahlar sarayı kompleksi — bunlar həmin dövrün memarlıq abidələridir.

Arxeoloji tədqiqatlar göstərir ki, Bakı əhalisinin əsas hissəsi sənətkarlar, balıqçılar və tacirlərdan ibarət idi. Şəhər Böyük İpək Yolunun mühüm qovşağında yerləşirdi və buradan keçən karvanlar Bakının iqtisadi inkişafına böyük töhfə vermişlər.`,
  },
  {
    creatorName: 'Sara Ashurbayli',
    title: "Qadın tarixçi niyə lazımdır? (Esse)",
    description: "Tarix fanida ayollarning roli haqida ilmiy esse.",
    content_text: `Tarix kitabları çox zaman kişilərin hərəkətlərini, döyüşlərini, siyasi qərarlarını anlatır. Bəs qadınlar? Onlar yox idilər? Əlbəttə yox idi.

Qadınlar tarixi yaşadılar, istehsal etdilər, ötürdülər. Nəsillərin yadında qalan hekayətlər, nağıllar, adətlər — bunların çoxunu qadınlar saxladı. Şifahi tarix — bu, əksər hallarda qadın tarixi deməkdir.

Mən tarixçi kimi çalışarkən hər dəfə bu həqiqəti gördüm: rəsmi sənədlərin arxasında görünməz bir qadın əli var. Evlər qurulur, uşaqlar yetişdirilir, bilik ötürülürdü — bütün bunlar sənədsiz, adsız, tarixsiz qalırdı.

Qadın tarixçilər bu boşluğu doldurmaq üçün lazımdır. Tarixi yenidən oxumaq, gizli qalmış hekayələri üzə çıxarmaq — bu bizim borcumuzdur.`,
  },

  // ── Şəfiqə Axundova ──
  {
    creatorName: 'Şəfiqə Axundova',
    title: "İşığa doğru (Roman parchasi)",
    description: "Şəfiqə Axundovaning 'İşığa doğru' romanidan parcha — zamonaviy Ozarbayjon ayoli qismatи.",
    content_text: `Nərmin iyirmi yeddi yaşında idi. Zavodda çalışır, axşamlar isə universitetdə oxuyurdu. Yorulurdu — bunu bilirdi. Amma durub dayanmırdı.

"Niyə bu qədər çalışırsan?" dedi bir dəfə qonşusu.

"Çünki istəyirəm," dedi Nərmin.

Bu — hamı üçün aydın olan bir cavab deyildi. Çünki o vaxt çoxları, xüsusilə qadınlar, istəmələri mümkün olduğunu bilmirdilər. "İstəmək" özü bir isyan sayılırdı.

Amma Nərmin isyan etmir, sadəcə yaşayırdı. Öz istədiyi kimi.`,
  },
  {
    creatorName: 'Şəfiqə Axundova',
    title: "Ana dil (She'r)",
    description: "Ozarbayjon tiliga va milliy kimlikka bag'ishlangan she'r.",
    content_text: `Azərbaycan dili — ilk sözüm,
Anam dilindən öyrəndim seni.
Hər söz — bir tarix, hər cümlə — bir iz,
Bu dildə düşünürəm, sevir, ağlayıram.

Dünya dəyişər, zaman keçər,
Amma bu dil qalacaq — həmişəlik.
Torpaqdan kök kimi çıxır bu dil,
Bizi birləşdirir — hər birimizi.

Azərbaycan dili — mənim kimliyim,
Bu dildə şeir — ürəyimdən gəlir.
Nə itirərsəm itirəyim dünyada —
Amma bu dili — heç vaxt.`,
  },

  // ── Sara Tlepbergenova ──
  {
    creatorName: 'Sara Tlepbergenova',
    title: "Жүрек жылуы (Yurak issiqligi) — She'r",
    description: "Sara Tlepbergenovanıng mashhur she'ri — qozoq qizi va uning yashash hayotiga muhabbati.",
    content_text: `Жүрегімде жылылық бар —
Анамнан алған мирас.
Далада жүргенде сезем,
Жердің жылуын — жаным.

Қыр аптабы, тау желі,
Менің бойымда сақталған.
Қазақ қызы — мен едім,
Жүрек жылуын — сездіңіз бе?

Ана тілім — жүрек тілі,
Оны ұмытсам — адасам.
Шексіз даланың ішінде —
Мен туылдым, мен тірімін.`,
  },
  {
    creatorName: 'Sara Tlepbergenova',
    title: "Анамның жыры (Onamning qo'shig'i) — Qissa",
    description: "Qozoq ayoli va uning onasi haqida lirik qissa.",
    content_text: `Апам маған жыр айтатын. Кешкісін, шырақ жанып, сыртта жел ескенде. Дауысы жай еді, бірақ сол жайлықта бір тереңдік болатын — мұхиттың терең жері сияқты.

«Бұл жыр — сенің апаңнан, апаң жыр айтатын» дер еді. Оны апасынан, апасы — одан да алыстан алыпты. Жыр ұрпақтан ұрпаққа, дала желіндей өтіп келеді.

Мен ол жырды жаттаппын. Балаларыма айттым. Олар да жаттаса керек. Ең ескі де, ең жаңа да нәрсе осы жырда: ана мен бала, жер мен аспан, кеше мен бүгін.

Апамның жыры — менің де жырым. Сарқырамалы өмірдің мәңгі жырларының бірі.`,
  },

  // ── Fatima Gabdullina ──
  {
    creatorName: 'Fatima Gabdullina',
    title: "Байтақ дала (Keng dala) — Hikoya",
    description: "Fatima Gabdullinaning qozoq qishloq hayotini tasvirlovchi hikoyasidan parcha.",
    content_text: `Гүлнар жазды сүйер еді. Егін далалары жасыл болып, аспан биікте жуылғандай ашылып кететін кезді.

Бірақ биылғы жаз өзгеше болды. Ауылда жаңалық бар: жаңа мектеп салынады. Гүлнар — мұғалім болады. Мектептен оқу бітірген кезден арманы осы еді.

«Мұғалім болу — үлкен жауапкершілік» деді анасы.

«Білем» деді Гүлнар. — Бірақ сол жауапкершілікті алуға дайынмын.

Байтақ далада жел соқты. Бидай масақтары иілді, қайтадан тіктелді. Гүлнар соны көрді — жел де мықтыны иіп, мықтыны қайта тіктейді деп ойлады.`,
  },
  {
    creatorName: 'Fatima Gabdullina',
    title: "Жусан иісі (Yusuf hidi) — Esse",
    description: "Qozoq dasht tabiatining hidi va xotiraga bog'liqligi haqida lirik esse.",
    content_text: `Жусан иісі — далалық бала өскен баршаға таныс. Тек бір рет сезсеңіз де, ол иіс мәңгі жадыңызда қалады.

Мен Алматыда тұрсам да, далаға барған кезде — жусан иіс мені балалыққа алып кетеді. Жалаң аяқ жүгіргенімді, шөптің жасылдығын, аспанның шексіздігін — барлығын сезем.

Иіс — жадтың ең мықты кілті. Суреттер өшеді, дауыстар ұмытылады, бірақ иіс — сол сезімді ояту үшін бір секундтың өзі жетеді.

Жусан иісі — ол менің туған жерім, менің халқым, менің балалығым. Ол — қазақ даласының мөрі.`,
  },

  // ── Makpal Qunanbayeva ──
  {
    creatorName: 'Makpal Qunanbayeva',
    title: "Таң жарығы (Tonggi nur) — She'r",
    description: "Makpal Qunanbayevaning qozoq shoirasi sifatida eng yorqin she'riy namunalaridan biri.",
    content_text: `Таң жарығы келе жатыр —
Қызғылт шапақ, кең аспан.
Тіршілік тағы оянып,
Жер жанады — тыныш, жан.

Мен тұрамын — сеземін
Жарықтың жылуын жүрегімде.
Бір күн өте де болса,
Ол жарық — жанымда, ішімде.

Таң жарығы — үміт белгісі,
Жаңа күнді жарқырататын.
Қазақ даласы — кең, биік —
Таңмен бірге тіршілік атады.`,
  },
  {
    creatorName: 'Makpal Qunanbayeva',
    title: "Қайтадан туу (Qayta tug'ilish) — Roman parchasi",
    description: "Makpal Qunanbayevaning asosiy romani 'Qayta tug'ilish'dan parcha.",
    content_text: `Асель бәрін жоғалтқан сияқты сезінді. Күйеуі жоқ. Балалары шет жақта. Ауыл таныстары — өздерінің тіршілігінде.

Бір күні ол кітапхана жанынан өтті. Жарнамада жазулы: «Жазу мектебі. Барлығына ашық.»

Ол кірді. Неге екенін өзі де білмейді.

Алғашқы кезде жайсыз болды. Барлығы жас, барлығы оқыған. Ал ол — қырықтан асқан, тіпті мектепте қалем ұстамаған.

— Мүмкін, кешігіп қалдым, — деді мұғалімге.

— Жазу үшін ешқашан кеш емес, — деді мұғалім. — Тек бастау керек.

Асель жазды. Алғаш рет. Сол күн — оның жаңа туған күні болды.`,
  },

  // ── Küläsh Bayserkenova ──
  {
    creatorName: 'Küläsh Bayserkenova',
    title: "Таң шолпаны (Tong yulduzi) — Pyesa parchasi",
    description: "Küläsh Bayserkenovanıng mashhur pyesasidan parcha — qozoq milliy an'analari va zamonaviylik.",
    content_text: `АЛТЫН: (Пайдаланып) Апа, мен кетем дедім ғой!

АПА: (Үнсіз тұрады. Сонсоң баяу) Қайда кетесің?

АЛТЫН: Алматыға. Университетке. Оқуым бар.

АПА: Оқуың... (Сонсоң) Ата-баңның жері, мына ауыл...

АЛТЫН: Апа, мен бұл жерді жақсы көрем. Бірақ менің жолым — ілімде.

АПА: (Ұзақ үнсіздік. Содан кейін) Атаң да сені жіберер еді. Ол оқыған адамды сыйлайтын. (Пауза) Жіберемін. Бірақ...

АЛТЫН: Қайтамын, апа. Міндетті түрде.

АПА: (Гүлнарды жақын тартып) Қайтарсың ба?

АЛТЫН: (Анасының иығына тіреліп) Қайтамын. Уәде беремін.`,
  },
  {
    creatorName: 'Küläsh Bayserkenova',
    title: "Ескі дос (Eski do'st) — Pyesa parchasi",
    description: "Küläsh Bayserkenovanıng ikkinchi mashhur pyesasidan parcha — do'stlik va sadoqat mavzusida.",
    content_text: `БОЛАТ: Отыз жыл өттің-ау, Серік.

СЕРІК: (Күледі) Отыз жыл... Есіңде ме — сол жазда?

БОЛАТ: Қалай ұмытамын. Сен маған кітап берген. «Оқы» деген.

СЕРІК: Оқыдың ба?

БОЛАТ: Оқыдым. Екі рет. (Пауза) Сол кітаппен өмірім өзгерді.

СЕРІК: Кітаппен бе?

БОЛАТ: Сенімен. Кітабыңмен. Досыңмен. (Қолын созады) Ескі дос — ең мықты дос.

СЕРІК: (Қол алысып) Ескі дос — жаңа бастаудың тірегі. (Екеуі де үнсіз, мазмұнды қарасады)`,
  },

  // ── Toktogul qızı Satılganova ──
  {
    creatorName: 'Toktogul qızı Satılganova',
    title: "Жерим менин (Yerim mening) — She'r",
    description: "Toktogul qızı Satılganovaning qirg'iz og'zaki an'anasida saqlanib qolgan she'ri.",
    content_text: `Жерим менин — кенч жайлоо,
Тоолор, суулар, жашыл чөп.
Ак жааган кар, жаш булактар,
Мен өстүм ушул жерде.

Ата журтум — Ала-Тоо,
Асмандан тийген нур сен.
Кыргыз кызы жашайт дейт,
Сенин кучагыңда, жерим.

Жаш эдим — жатып уктадым,
Ошол чөп бойдо, ошол суу жакын.
Эми кары болдум, бирок
Жерим менин — дагы эле жакын.`,
  },
  {
    creatorName: 'Toktogul qızı Satılganova',
    title: "Комузум (Komuzim) — She'r-qo'shiq",
    description: "Qirg'iz milliy cholg'u asbobi komuzga bag'ishlangan she'r.",
    content_text: `Комузум — жаным менин,
Ырдайм сага, комузум.
Жиптерин чертсем — жер дирилдейт,
Ырдайт ата журтум.

Кыргыз ырын ырдайм —
Бабамдан калган ыр.
Комузум — сен жана мен —
Бир жандан чыккан ыр.

Суу да ырдайт, желде ырдайт,
Тоо да ырдайт мага.
Кыргыз ырчысы — мен эдим —
Комузум менен дайым.`,
  },

  // ── Şugula Bayaliyeva ──
  {
    creatorName: 'Şugula Bayaliyeva',
    title: "Тоо жаңырыгы (Tog' aksi) — Roman parchasi",
    description: "Şugula Bayaliyevaning asosiy romani 'Tog' aksi'dan parcha — qirg'iz oilasi hayoti.",
    content_text: `Айгүл аймактагы мектепке жаш мугалим болуп барды. Жолу узун болчу, тоо аша өтүүгө туура келди.

Жолдо бир карыя отурат. «Кайда барасың, кызым?» деди.

«Мугалим болом дедим».

«Жакшы», — деди карыя. — «Мугалим болсоң — мектепте окутасың. Бирок чыныгы мугалим — жашоонун өзүнөн үйрөнөт».

Айгүл ойлонду. Бул сөздү ал мектепке жеткенде да, класска кирип, балдар менен жолуккан күнү да унутмады. Тоо жаңырыгы андан кийин да угулуп турду — мугалимдин акылдуу сөзүндөй.`,
  },
  {
    creatorName: 'Şugula Bayaliyeva',
    title: "Айгүл (She'r)",
    description: "Qirg'iz qizining tabiat bilan uyg'unligini tasvirlovchi lirik she'r.",
    content_text: `Айгүл — гүлдүн аты,
Кыргыздын жериндеги.
Жайлоодо өсөт, жел менен ойнойт —
Таза, нурлуу, акылдуу.

Гүлдүн аты — менин атым,
Анам берди мага.
Тоо аша жүгүрдүм балалыкта —
Айгүл болуп, азаттыкта.

Эми чоңойдум, бирок
Айгүл — дагы деле жаным ичинде.
Кыргыз жери, Кыргыз кызы —
Айгүл мисал — гүл болуп жашайт.`,
  },

  // ── Zamira Sydykova ──
  {
    creatorName: 'Zamira Sydykova',
    title: "Erkin so'z (Özgür söz) — Esse",
    description: "Zamira Sydykovanıng matbuot erkinligi va demokratiya haqidagi mashhur essedan parcha.",
    content_text: `Эркин сөз — демократиянын жүрөгү. Аны жокко чыгарсак — демократияны жокко чыгарабыз.

Журналист болуп иштеп жатканда, бир нечеден ашык жолу камакка алынганымды билем. Сот ишлерин башымдан кечирдим. Бирок эч качан үнүмдү чыгарбай коюуну ойлонгон эмесмин.

Эмне үчүн? Анткени мен ишендим: чындыкты айтуу — журналисттин гана эмес, ар бир адамдын милдети. Сөз эркиндиги — ыйык нерсе. Аны коргобосок — эртеңки авторитаризм бизди таң калтырат.

Кыргызстан жаш демократия. Жолу татаал. Бирок биз кетпейбиз. Эркин сөз — биздеги.`,
  },
  {
    creatorName: 'Zamira Sydykova',
    title: "Кыргыз аялы (Qirg'iz ayoli) — Esse",
    description: "Qirg'iz ayolining tarixiy roli va kelajagi haqida refleksiya.",
    content_text: `Кыргыз аялы тарых бою эки жумуш бир убакта аткарды: үй-бүлөсүн карап, коомун тирап.

Ал Манас эпосундагы Каниключасы эрине бийлик берди, ал эми өзү акыл менен башкарды. Ал Куrmanbek dastanındakı Akalay kimi эр жигиттен да батыр болуп корунду. Кыргыз аялынын сүрөттөрү — күч жана мейкиндик жана сагыныч менен толгон.

Бүгүнкү кыргыз аялы — юрист, дипломат, мугалим, жазуучу. Ал эски традицияны да, жаңы заманды да камтыйт. Бул — баскыч эмес, синтез.

Биз кандайбыз деп сурасаңыздар: биз кыргызбыз. Аял кыргызбыз. Бул — куаныч жана жоопкерчилик экөөнү бирдей билдирет.`,
  },

  // ── Aliya Tokombaeva ──
  {
    creatorName: 'Aliya Tokombaeva',
    title: "Манас эпосу жана кыргыз философиясы (Esse parchasi)",
    description: "Aliya Tokombaevaning Manas eposi va qirg'iz milliy falsafasi haqidagi ilmiy essedan parcha.",
    content_text: `Манас эпосу — жөн гана эпикалык поэма эмес. Ал — дүйнөнүн кыргызча моделинин философиялык сырткы кийими.

Манаста каармандар кыймылда. Алар жолдо, сапарда. Бул кыймыл — жаш жана чоңоюунун, азаптын жана жеңиштин, жоготуунун жана кайра табуунун метафорасы.

Кыргыз философиясы — стационарлык эмес, номаддык. Биз бир жерге жабышпайбыз — биз сапарда. Бул — кандайдыр бир жолсуздук эмес. Бул — ар бир жерде, ар бир учурда жашоонун маңызын издөө.

Ааламды Манастын көзү менен карасаңыз — бирдиктин, бирлештиктин, бири-бирин сыйлоонун мааниси ачылат. Бул — кыргыз адамынын дүйнөгө насаат сөзү.`,
  },
  {
    creatorName: 'Aliya Tokombaeva',
    title: "Улуу Ата журт (She'r)",
    description: "Qirg'iziston tabiatiga va milliy ruhiga bag'ishlangan falsafiy she'r.",
    content_text: `Ала-Тоо — менин ата журтум,
Мөнгү кар кийген тоолор.
Суусу таза, абасы бийик —
Кудурет жаткан бул жерде.

Мен бу жерде жаралдым,
Тоонун нурунан тамдым.
Кыргыз аялы, кыргыз жаны —
Ала-Тоодон алдым куватты.

Дүйнө кеткен жерим бар,
Бирок жүрөгүм — мунда.
Улуу Ата журт — мен сени
Ырларымда жашатам, дайым.`,
  },
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
async function seed() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Barcha mavjud ma'lumotlarni tozalash
    console.log('Ma\'lumotlar tozalanmoqda...');
    await client.query('TRUNCATE works    RESTART IDENTITY CASCADE');
    await client.query('TRUNCATE creators RESTART IDENTITY CASCADE');
    await client.query('DELETE FROM refresh_tokens');
    await client.query('DELETE FROM users');
    console.log('Eski ma\'lumotlar tozalandi.');

    // 2. Davlatlar
    for (const { name, code } of COUNTRIES) {
      await client.query(
        'INSERT INTO countries (name, code) VALUES ($1,$2) ON CONFLICT (code) DO NOTHING',
        [name, code],
      );
    }
    console.log(`Davlatlar: ${COUNTRIES.length} ta`);

    // 3. Kategoriyalar
    for (const name of CATEGORIES) {
      await client.query(
        'INSERT INTO categories (name) VALUES ($1) ON CONFLICT (name) DO NOTHING',
        [name],
      );
    }
    console.log(`Kategoriyalar: ${CATEGORIES.length} ta`);

    // 4. Foydalanuvchilar
    const SALT_ROUNDS = 10;
    const userIds = {};
    for (const u of USERS) {
      const hash = await bcrypt.hash(u.password, SALT_ROUNDS);
      const { rows } = await client.query(
        `INSERT INTO users (name, email, password_hash, role)
         VALUES ($1,$2,$3,$4) RETURNING id`,
        [u.name, u.email, hash, u.role],
      );
      userIds[u.email] = rows[0].id;
      console.log(`  Foydalanuvchi: ${u.email} (${u.role})`);
    }
    console.log(`Foydalanuvchilar: ${USERS.length} ta`);
    const adminId = userIds['admin@gmail.com'];

    // 5. Ijodkorlar
    const creatorIds = {};
    for (const c of CREATORS) {
      const cRes = await client.query('SELECT id FROM countries  WHERE code=$1', [c.country_code]);
      const kRes = await client.query('SELECT id FROM categories WHERE name=$1', [c.category_name]);
      const { rows } = await client.query(
        `INSERT INTO creators (name,born_year,died_year,country_id,category_id,bio)
         VALUES ($1,$2,$3,$4,$5,$6) RETURNING id`,
        [c.name, c.born_year, c.died_year ?? null, cRes.rows[0].id, kRes.rows[0].id, c.bio],
      );
      creatorIds[c.name] = rows[0].id;
    }
    console.log(`Ijodkorlar: ${CREATORS.length} ta`);

    // 6. Asarlar
    let workCount = 0;
    for (const w of WORKS) {
      const cid = creatorIds[w.creatorName];
      if (!cid) { console.warn(`  Ijodkor topilmadi: ${w.creatorName}`); continue; }
      await client.query(
        `INSERT INTO works
           (creator_id,title,description,content_text,
            media_url,file_key,media_type,file_size,status,uploaded_by)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'approved',$9)`,
        [
          cid,
          w.title,
          w.description,
          w.content_text,
          '',            // media_url (matn asari — fayl yo'q)
          '',            // file_key
          'text',        // media_type
          w.content_text ? w.content_text.length : 0,
          adminId,
        ],
      );
      workCount++;
    }
    console.log(`Asarlar: ${workCount} ta`);

    await client.query('COMMIT');
    console.log('\n✅ Seed muvaffaqiyatli yakunlandi!');
    console.log(`   ${COUNTRIES.length} davlat | ${CATEGORIES.length} kategoriya`);
    console.log(`   ${USERS.length} foydalanuvchi | ${CREATORS.length} ijodkor | ${workCount} asar`);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Seed xatosi:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
