//----------------------------------------------------------------
class AuthPageText {
  final String va = "VA";
  final String l = "L";
  final String ineups = "INEUPS";

  final String googleAuth = "assets/images/googleAuth.png";
  final String mailAuth = "assets/images/mailAuth.png";
  final String anonimAuth = "assets/images/anonimAuth.png";

  final String loginGuestPageCover = "assets/images/valoAgent.gif";
  final String infoText = "Valorant Unofficial Fan App";

  final String google = "Google";
  final String mail = "Mail  ";
  final String anonim = "Anonim";
}

class OnBoardingScreen {
  final String skip = "Skip";
  final String next = "Next";
  final String start = "Start";

  final String agents = "assets/images/ajan.png";
  final String agentTitle = "Hoş Geldin, Ajan!";
  final String agentDesc =
      "Valaron Lineups ile oyun içindeki stratejini güçlendir! Beğendiğin lineupsları kaydet ve arkadaşlarınla paylaş. Hazır mısın? Hadi başlayalım!";

  final String lineups = "assets/images/bomba.png";
  final String lineupTitle = "Lineups Hazırlığı";
  final String lineupDesc =
      "Oyun sırasında hızlı ve etkili lineupslar keşfet. En sevdiğin stratejileri kaydet ve her zaman elinin altında olsun. Rakiplerini şaşırtmaya hazır ol!";

  final String discussions = "assets/images/discussions.png";
  final String discussionTitle = "Ortak Sohbet Alanı";
  final String discussionDesc =
      "Stratejilerini paylaş ve diğer oyuncularla sohbet et. Ortak sohbet alanımızda fikir alışverişi yap ve yeni arkadaşlar edin. Birlikte güçlüyüz!";
}

//----------------------------------------------------------------
class MapList {
  final List<String> entries = <String>[
    'BIND',
    'HAVEN',
    'SPLIT',
    'ASCENT',
    'ICEBOX',
    'BREEZE',
    'FRACTURE',
    'PEARL',
    'LOTUS',
    'SUNSET',
    'ABYSS',
  ];

  final List<String> map = <String>[
    'assets/images/maps/Bind.png',
    'assets/images/maps/Haven.png',
    'assets/images/maps/Split.png',
    'assets/images/maps/Ascent.png',
    'assets/images/maps/Icebox.png',
    'assets/images/maps/Breeze.png',
    'assets/images/maps/Fracture.png',
    'assets/images/maps/Pearl.png',
    'assets/images/maps/Lotus.png',
    'assets/images/maps/Sunset.png',
    'assets/images/maps/Abyss.png',
  ];
}

class AgentList {
  final List<String> entries = <String>[
    'BRIMSTONE',
    'VIPER',
    'OMEN',
    'KILLJOY',
    'CYPHER',
    'SOVA',
    'SAGE',
    'PHOENIX',
    'JETT',
    'REYNA',
    'RAZE',
    'BREACH',
    'SKYE',
    'YORU',
    'ASTRA',
    'KAY/O',
    'CHAMBER',
    'NEON',
    'FADE',
    'HARBOR',
    'GEKKO',
    'DEADLOCK',
    'ISO',
    'CLOVE',
  ];

  final List<String> agents = <String>[
    'assets/images/agents/Brimstone.png',
    'assets/images/agents/Viper.png',
    'assets/images/agents/Omen.png',
    'assets/images/agents/Killjoy.png',
    'assets/images/agents/Cypher.png',
    'assets/images/agents/Sova.png',
    'assets/images/agents/Sage.png',
    'assets/images/agents/Phoenix.png',
    'assets/images/agents/Jett.png',
    'assets/images/agents/Reyna.png',
    'assets/images/agents/Raze.png',
    'assets/images/agents/Breach.png',
    'assets/images/agents/Skye.png',
    'assets/images/agents/Yoru.png',
    'assets/images/agents/Astra.png',
    'assets/images/agents/KAYO.png',
    'assets/images/agents/Chamber.png',
    'assets/images/agents/Neon.png',
    'assets/images/agents/Fade.png',
    'assets/images/agents/Harbor.png',
    'assets/images/agents/Gekko.png',
    'assets/images/agents/Deadlock.png',
    'assets/images/agents/Iso.png',
    'assets/images/agents/Clove.png',
  ];
//----------------------------------------------------------------
  final Map<String, List<Map<String, dynamic>>> agentMaps = {
    'BRIMSTONE': [
      {
        'name': 'Bind',
        'side': 'A',
        'images': [
          'assets/images/maps/Bind.png',
          'assets/images/maps/Bind.png',
          'assets/images/maps/Bind.png'
        ]
      },
      {
        'name': 'Haven',
        'side': 'B',
        'images': [
          'assets/images/maps/Haven.png',
          'assets/images/maps/Haven.png',
          'assets/images/maps/Haven.png'
        ]
      },
      {
        'name': 'Split',
        'side': 'C',
        'images': [
          'assets/images/maps/Split.png',
          'assets/images/maps/Split.png',
          'assets/images/maps/Split.png'
        ]
      },
    ],
    'VIPER': [
      {
        'name': 'Bind',
        'side': 'A',
        'images': [
          'assets/images/maps/Bind.png',
          'assets/images/maps/Bind.png',
          'assets/images/maps/Bind.png'
        ]
      },
      {
        'name': 'Icebox',
        'side': 'B',
        'images': [
          'assets/images/maps/Icebox.png',
          'assets/images/maps/Icebox.png',
          'assets/images/maps/Icebox.png'
        ]
      },
      {
        'name': 'Breeze',
        'side': 'C',
        'images': [
          'assets/images/maps/Breeze.png',
          'assets/images/maps/Breeze.png',
          'assets/images/maps/Breeze.png'
        ]
      },
    ],
    // Diğer ajanlar için benzer şekilde ekleyebilirsiniz...
  };
}
//----------------------------------------------------------------
