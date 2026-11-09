// lib/db/toc_data.dart
class TOCEntry {
  final String number;
  final String title;
  final String? translation;
  final String category;
  final String lyrics;
  final String? page; // Added for page mapping

  TOCEntry({
    required this.number,
    required this.title,
    this.translation,
    required this.category,
    this.lyrics = '',
    this.page, // Optional page assignment
  });

  Map<String, dynamic> toMap() => {
    'number': number,
    'title': title,
    'translation': translation,
    'category': category,
    'lyrics': lyrics,
    'page': page, // Include page in map
  };

  static TOCEntry fromMap(Map<String, dynamic> map) => TOCEntry(
    number: map['number'] as String,
    title: map['title'] as String,
    translation: map['translation'] as String?,
    category: map['category'] as String,
    lyrics: map['lyrics'] as String? ?? '',
    page: map['page'] as String?, // Handle page from map
  );
}

final List<TOCEntry> tocEntries = [
  // Page 1: Hymn 1
  TOCEntry(number: "1", title: "Naauwuni Bia fi'payi ri yuli", translation: "Onyame ba yeyiway da", category: "Praise", page: "1", lyrics: "1. Naauwuni Bia fi'payi ri yuli...\n2. Onyame ba yeyiway da..."),
  // Page 2: Hymns 2 and 3
  TOCEntry(number: "2", title: "Wuunsughu mali yiko pam", translation: "Mpaebo futu abonisam", category: "Prayer", page: "2", lyrics: "1. Wuunsughu mali yiko pam...\n2. Mpaebo futu abonisam..."),
  TOCEntry(number: "3", title: "Wummiya Yisa", translation: "Tie tie Yesu", category: "Prayer", page: "2", lyrics: "1. Wummiya Yisa...\n2. Tie tie Yesu..."),
  // Page 3: Hymn 4
  TOCEntry(number: "4", title: "Malahkanni yi'i yuisuma", translation: "Soro abofra to dwom dee", category: "Praise", page: "3", lyrics: "1. Malahkanni yi'i yuisuma...\n2. Soro abofra to dwom dee..."),
  // Additional entries (duplicates flagged)
  TOCEntry(number: "8", title: "Yisa, Yisa obenli sahakan", translation: "Jesus losim hem ba dai", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "9", title: "Kamna, kamna na-mabiya kamna", translation: "Brao brao Nyame-tumi sen turni nyifinaas", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "12", title: "Ti lihiri na bayaani", translation: "Worship God", category: "Praise", page: null, lyrics: ''), // First occurrence
  TOCEntry(number: "16", title: "Ti sahimi ka panyimi Naawuni", translation: "Praise the Lord", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "35", title: "Nawunni vilda Naawuni galisiya", translation: "Onyame ye Nyame Kie", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "26", title: "Ti puhura", translation: "We Praise God", category: "Praise", page: null, lyrics: ''),
  // Prayer category
  TOCEntry(number: "12", title: "Duniya zaa kapamitya yimaya", translation: "Try to believe", category: "Prayer", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "13", title: "Ti dini teni kani zaaha", translation: "Yennan koj bana", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "18", title: "Yesu Masia sim mali yiko pam", translation: "Power in the blood of Jesus", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "23", title: "Cheylika ka ti yill yemlami", translation: "Let's say God is good", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "24", title: "Nawunni vicla", translation: "Me Nyame ye", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "28", title: "Ti zaai kan i ba'i sa-aani Naawuni", translation: "Aseda meendo Onyame", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "30", title: "Ti kana ni inti subii Yisa", translation: "We have come to ask", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "31", title: "Nivyoil bani Edi", translation: "There is life in Jesus", category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "32", title: "Nozo maliba", translation: "Life is a gift from God", category: "Prayer", page: null, lyrics: ''), // First occurrence
  TOCEntry(number: "32", title: "Tiglsina nyila Naawuni pimli", translation: "Salvation is a gift from God", category: "Prayer", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "45", title: "Nya Yisa ka", translation: "See Jesus", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "46", title: "Yisa ni yibu", translation: "Jesus is good", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "47", title: "Ti jermmiya Yisa Ka", translation: "Let us worship Jesus", category: "Birth", page: null, lyrics: ''),
  TOCEntry(number: "50", title: "Yisa ya ha Ndouma chap", translation: "My Lord was born", category: "Birth", page: null, lyrics: ''),
  TOCEntry(number: "51", title: "Yisa Kum", translation: "Jesus died", category: "Death", page: null, lyrics: ''),
  TOCEntry(number: "52", title: "Yisa Kum ni yibu", translation: "Jesus died for us", category: "Death", page: null, lyrics: ''),
  TOCEntry(number: "53", title: "Yisa Kum neebu", translation: "Jesus rose again", category: "Resurrection", page: null, lyrics: ''),
  TOCEntry(number: "54", title: "Yisa Kum neebu ni yibu", translation: "Jesus rose and is good", category: "Resurrection", page: null, lyrics: ''),
  TOCEntry(number: "48", title: "Yisa labuna maili sa chibuya", translation: "Jesus' second coming makes me happy", category: "Second Coming", page: null, lyrics: ''),
  TOCEntry(number: "49", title: "Yisa labuna", translation: "Jesus is coming back", category: "Second Coming", page: null, lyrics: ''),
  TOCEntry(number: "1", title: "Yisu Yelisu Nawuni", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "2", title: "Tumpaani ti Dumuni Nawuni", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "3", title: "Nawuni yelisu", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "4", title: "Yisu kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "5", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "6", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "7", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "8", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "9", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "10", title: "Halleluya ti Nawuni so", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "11", title: "Halleluya ti Nawuni so", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "12", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "13", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "14", title: "Nawuni kpam kpam", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "15", title: "Saha kpam kpam", translation: "O for a thousand tongues to sing", category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "62", title: "Saha Kuni yelisu yuli Nawuni", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "63", title: "Saha payimi Nawuni", translation: null, category: "Praise", page: null, lyrics: ''),
  TOCEntry(number: "64", title: "O Yisa Masia kamina", translation: null, category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "65", title: "Ti Dumuni Nawuni", translation: null, category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "66", title: "Nawuni nyini ti dalibirika", translation: null, category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "67", title: "Nduma teema ni yuli", translation: null, category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "68", title: "Nku che Yisa abada", translation: null, category: "Prayer", page: null, lyrics: ''),
  TOCEntry(number: "21", title: "N nyɛ yili a ti li Duuma Naawuni", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "22", title: "Naawuni yuli mani ababilibu", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "23", title: "Ghuguma bam che daa yibu na", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "24", title: "Naawuni kpiɛna din dabibil' gi", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "25", title: "N yili yili yibu ka lanŋi asani na", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "26", title: "Naaŋ' sheli' simo asani", translation: null, category: "Word of God", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "27", title: "Yɛrɛ yibu' simo asani", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "28", title: "Naawuni yuli ti di dabibilrika", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "29", title: "Yibu' za Kuduru", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "30", title: "N yili yili yibu ka lanŋi asani na", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "31", title: "Halleleluya yuhum dabibil'", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "32", title: "Duuma suŋ ti laymila asani na", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "33", title: "Yisa halabasi mani", translation: null, category: "Word of God", page: null, lyrics: ''),
  TOCEntry(number: "35", title: "Yisa Masia niŋ ti Kasi", translation: null, category: "Lord's Supper", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "37", title: "N Duuma n-zap n ti asani", translation: null, category: "Lord's Supper", page: null, lyrics: ''),
  TOCEntry(number: "38", title: "N-nyɛla yilin dsa", translation: null, category: "Lord's Supper", page: null, lyrics: ''),
  TOCEntry(number: "39", title: "Kamiya Yisa dibu shee", translation: null, category: "Lord's Supper", page: null, lyrics: ''),
  TOCEntry(number: "26", title: "Nawunwi tuma nasara", translation: null, category: "Work", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "33", title: "Nawunwi nam shee mi", translation: null, category: "Second Coming", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "43", title: "Ayi libi dapuli ma", translation: null, category: "Suffering", page: null, lyrics: ''),
  TOCEntry(number: "6", title: "Yisa nyandoliba", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "9", title: "Nyandoliba zunyin mi", translation: null, category: "Baptism", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "13", title: "Nawunwi be tii Duuma", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "22", title: "Nawunwi be tii zan", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "23", title: "Yisan nyandoliba be zan", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "24", title: "Rukara n-nye n guala", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "25", title: "Mitali tii sunapili bi", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "28", title: "Nawunwi tii sunapili bi", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "29", title: "Nsuho pildi baptaizibu", translation: null, category: "Baptism", page: null, lyrics: ''),
  TOCEntry(number: "61", title: "Nyaane' ama bi nya' yeeli", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "62", title: "Nyaane' yei di chuli amaga nyaane' yei", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "63", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "64", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "65", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "66", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "67", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "68", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "69", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "70", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "71", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "72", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "73", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "74", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "75", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "76", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "77", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "78", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''), // First occurrence
  TOCEntry(number: "78", title: "O Jerusalem tie su", translation: null, category: "Salvation", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "79", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "80", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "81", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "82", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "83", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "84", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "85", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "86", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "87", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "88", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "89", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "90", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "91", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "92", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "93", title: "Nusuma nya' bela Nusuma ni", translation: null, category: "Life in Christ", page: null, lyrics: ''),
  TOCEntry(number: "94", title: "Wula ka nyaen puha", translation: null, category: "Palm Sunday", page: null, lyrics: ''),
  TOCEntry(number: "95", title: "Zion bi puyipa", translation: null, category: "Palm Sunday", page: null, lyrics: ''),
  TOCEntry(number: "96", title: "Yisa ka bi che' ka ye", translation: null, category: "Palm Sunday", page: null, lyrics: ''),
  TOCEntry(number: "27", title: "Naawuni yurilim", translation: null, category: "Salvation", page: null, lyrics: ''),
  TOCEntry(number: "44", title: "Abisichilin n-nyɛ ma", translation: null, category: "Salvation", page: null, lyrics: ''),
  TOCEntry(number: "47", title: "Yesu a saya ma na", translation: null, category: "Salvation", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "73", title: "Naawuni yɛla (Onyame ye pe)", translation: null, category: "Salvation", page: null, lyrics: ''),
  TOCEntry(number: "78", title: "Yisa ba omaga n-ti ni chɛ", translation: null, category: "Salvation", page: null, lyrics: ''), // Duplicate (flag)
  TOCEntry(number: "79", title: "Ziya gaa ba yɛn ogo", translation: null, category: "Salvation", page: null, lyrics: ''),
  TOCEntry(number: "83", title: "Sahinsichi Kudura ni yɛn deɛ", translation: null, category: "Salvation", page: null, lyrics: ''),
  TOCEntry(number: "101", title: "Yilimanjɛ Naawuni dalibarika (Ampara Nyankopɔn na dom ara kwa)", translation: null, category: "God's Love", page: null, lyrics: ''),
];