import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const OvoApp());

// ───────────────────────── THEME & CONSTANTS ─────────────────────────

class AppColors {
  static const purple = Color(0xFF4F2BC8);
  static const deepPurple = Color(0xFF3B1FA8);
  static const grey = Color(0xFF8E8E98);
  static const text = Color(0xFF1E1B2E);
  static const line = Color(0xFFE6E6EC);
  static const red = Color(0xFFE8213C);
}

const double kNavBarHeight = 62;
const double kNavOverhang = 30; // bagian tombol Pay yang menonjol

void showDemo(BuildContext context, String msg) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1200),
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).padding.bottom + kNavBarHeight + 20,
      ),
    ),
  );
}

// ───────────────────────── ROOT APP (SATU MaterialApp) ─────────────────────────

class OvoApp extends StatelessWidget {
  const OvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OVO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FinancePage(),
    PayPage(),
    InboxPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool darkPage = _index == 2;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkPage ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                layoutBuilder: (Widget? current, List<Widget> previous) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [...previous, if (current != null) current],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_index),
                  child: _pages[_index],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: OvoBottomNav(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── BOTTOM NAV ─────────────────────────

class OvoBottomNav extends StatelessWidget {
  const OvoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  Color _c(int i) => currentIndex == i ? AppColors.deepPurple : AppColors.grey;

  Widget _item(int i, String label, Widget icon) {
    final bool sel = currentIndex == i;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: _c(i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: kNavOverhang + kNavBarHeight + inset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kNavBarHeight + inset,
            child: Container(
              padding: EdgeInsets.only(bottom: inset),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.line)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _item(
                    0,
                    'Home',
                    Icon(Icons.home_rounded, size: 28, color: _c(0)),
                  ),
                  _item(
                    1,
                    'Finance',
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _c(1),
                      ),
                      child: const Text(
                        'Rp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  _item(2, 'Pay', const SizedBox(height: 28)),
                  _item(
                    3,
                    'Inbox',
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications, size: 28, color: _c(3)),
                          Positioned(
                            top: -5,
                            right: -10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Text(
                                '36',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _item(
                    4,
                    'Profile',
                    Icon(Icons.account_circle, size: 28, color: _c(4)),
                  ),
                ],
              ),
            ),
          ),
          // Tombol Pay (QRIS) yang menonjol
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 62,
                  height: 62,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8A5CF0), Color(0xFF3A1FA8)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'QRIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── HOME ─────────────────────────

class _Service {
  const _Service(this.label, this.icon, this.color, this.bg, {this.badge});
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String? badge;
}

const List<String> _homeTabs = [
  'Favorit',
  'Finansial',
  'Hiburan',
  'Pilihan Lain',
];

const List<List<_Service>> _serviceTabs = [
  [
    _Service(
      'Nabung by Superbank',
      Icons.savings,
      Color(0xFF5A3DD8),
      Color(0xFFEDE7FB),
      badge: 'BARU',
    ),
    _Service(
      'Pinjaman',
      Icons.payments,
      Color(0xFF5A3DD8),
      Color(0xFFEDE7FB),
      badge: '100JT',
    ),
    _Service(
      'Uang Elektronik',
      Icons.credit_card,
      Color(0xFFF4742B),
      Color(0xFFFDEEE3),
      badge: 'Rp 1',
    ),
    _Service(
      'Angsuran Kredit',
      Icons.receipt_long,
      Color(0xFFE5365C),
      Color(0xFFFCE6EC),
    ),
    _Service(
      'Pulsa/Paket Data',
      Icons.smartphone,
      Color(0xFF2F6BE0),
      Color(0xFFE6EFFC),
      badge: 'PROMO',
    ),
    _Service(
      'PLN',
      Icons.bolt,
      Color(0xFFF5A623),
      Color(0xFFFEF3E0),
      badge: 'PROMO',
    ),
    _Service(
      'Air PDAM',
      Icons.water_drop,
      Color(0xFF1E9BE8),
      Color(0xFFE3F3FD),
    ),
    _Service(
      'Internet & TV Kabel',
      Icons.live_tv,
      Color(0xFFF4592B),
      Color(0xFFFDEBE5),
    ),
  ],
  [
    _Service(
      'Investasi',
      Icons.trending_up,
      Color(0xFF1E9B6B),
      Color(0xFFE3F5EC),
    ),
    _Service('Asuransi', Icons.shield, Color(0xFF2F6BE0), Color(0xFFE6EFFC)),
    _Service(
      'BPJS',
      Icons.health_and_safety,
      Color(0xFF1E9B6B),
      Color(0xFFE3F5EC),
    ),
    _Service(
      'Tagihan Kartu Kredit',
      Icons.credit_card,
      Color(0xFFE5365C),
      Color(0xFFFCE6EC),
    ),
    _Service(
      'Emas',
      Icons.workspace_premium,
      Color(0xFFF5A623),
      Color(0xFFFEF3E0),
    ),
    _Service(
      'Reksa Dana',
      Icons.pie_chart,
      Color(0xFF5A3DD8),
      Color(0xFFEDE7FB),
    ),
    _Service(
      'Pajak',
      Icons.account_balance,
      Color(0xFF2F6BE0),
      Color(0xFFE6EFFC),
    ),
    _Service(
      'Zakat',
      Icons.volunteer_activism,
      Color(0xFF1E9B6B),
      Color(0xFFE3F5EC),
    ),
  ],
  [
    _Service(
      'Voucher Game',
      Icons.sports_esports,
      Color(0xFF5A3DD8),
      Color(0xFFEDE7FB),
    ),
    _Service('Streaming', Icons.movie, Color(0xFFE5365C), Color(0xFFFCE6EC)),
    _Service(
      'Tiket Bioskop',
      Icons.local_movies,
      Color(0xFFF5A623),
      Color(0xFFFEF3E0),
      badge: 'PROMO',
    ),
    _Service('Musik', Icons.music_note, Color(0xFF1E9BE8), Color(0xFFE3F3FD)),
    _Service(
      'Top Up Game',
      Icons.videogame_asset,
      Color(0xFF2F6BE0),
      Color(0xFFE6EFFC),
    ),
    _Service(
      'Event',
      Icons.confirmation_number,
      Color(0xFFF4742B),
      Color(0xFFFDEEE3),
    ),
    _Service(
      'Wisata',
      Icons.beach_access,
      Color(0xFF1E9B6B),
      Color(0xFFE3F5EC),
    ),
    _Service('Buku', Icons.menu_book, Color(0xFF5A3DD8), Color(0xFFEDE7FB)),
  ],
  [
    _Service('Pesawat', Icons.flight, Color(0xFF2F6BE0), Color(0xFFE6EFFC)),
    _Service('Kereta', Icons.train, Color(0xFFF4742B), Color(0xFFFDEEE3)),
    _Service('Hotel', Icons.hotel, Color(0xFF5A3DD8), Color(0xFFEDE7FB)),
    _Service('Donasi', Icons.favorite, Color(0xFFE5365C), Color(0xFFFCE6EC)),
    _Service('Pendidikan', Icons.school, Color(0xFF1E9BE8), Color(0xFFE3F3FD)),
    _Service('Properti', Icons.apartment, Color(0xFF1E9B6B), Color(0xFFE3F5EC)),
    _Service(
      'Transportasi',
      Icons.directions_bus,
      Color(0xFFF5A623),
      Color(0xFFFEF3E0),
    ),
    _Service('Lainnya', Icons.apps, Color(0xFF8E8E98), Color(0xFFF0F0F4)),
  ],
];

class _PromoData {
  const _PromoData(this.text, this.button);
  final String text;
  final String button;
}

const List<_PromoData> _promos = [
  _PromoData(
    'Cek data kamu demi kelancaran pemakaian akun OVO Premier kamu',
    'Cek',
  ),
  _PromoData(
    'Naikkan limit saldo OVO kamu dengan upgrade ke OVO Premier',
    'Upgrade',
  ),
  _PromoData('Dapatkan cashback spesial untuk transaksi pertamamu', 'Lihat'),
];

class _BannerData {
  const _BannerData(this.brand, this.title, this.colors);
  final String brand;
  final String title;
  final List<Color> colors;
}

const List<_BannerData> _banners = [
  _BannerData('KrediOne', 'Limit Pinjaman Hingga 100 Juta', [
    Color(0xFF5A2FD0),
    Color(0xFF8A4DE8),
  ]),
  _BannerData('EASYCASH × OVO', 'Cairan Dana Hingga 20 Juta', [
    Color(0xFF14352B),
    Color(0xFF1E6B4F),
  ]),
  _BannerData('Superbank', 'Bunga Tabungan Hingga 4% p.a.', [
    Color(0xFF2F4FD6),
    Color(0xFF5B7BF0),
  ]),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  bool _showBalance = false;
  late final PageController _promoController = PageController(
    viewportFraction: 0.92,
  );

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).padding.bottom +
        kNavBarHeight +
        kNavOverhang +
        16;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC6B8F1), Color(0xFFE4DDF8)],
          stops: [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildBalanceCard(context),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildPromoCarousel(context),
                    const SizedBox(height: 8),
                    _buildTabs(),
                    const SizedBox(height: 8),
                    _buildGrid(context),
                    const SizedBox(height: 8),
                    Container(height: 12, color: const Color(0xFFF4F4F7)),
                    const SizedBox(height: 16),
                    _buildBanners(context),
                    SizedBox(height: bottomPad),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Row(
        children: [
          const Text(
            'OVO',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.purple,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Material(
            color: const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => showDemo(context, 'Promo (demo)'),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.discount, size: 22, color: AppColors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Promo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B3CD9), Color(0xFF4A3FCB), Color(0xFF3F66D8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'OVO ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: 'Cash',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _showBalance = !_showBalance),
            child: Row(
              children: [
                const Text(
                  'Total Saldo',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showBalance
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showBalance = !_showBalance),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _showBalance ? 'Rp 1.250.000' : 'Tap untuk lihat',
                        key: ValueKey<bool>(_showBalance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => showDemo(context, 'OVO Points (demo)'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _BlackCircle(
                          size: 18,
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'OVO Points',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.purple,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _cardAction(context, Icons.add, 'Top Up'),
              _cardAction(context, Icons.arrow_upward, 'Transfer'),
              _cardAction(context, Icons.south, 'Tarik Tunai'),
              _cardAction(context, Icons.menu, 'History'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAction(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => showDemo(context, '$label (demo)'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.purple),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCarousel(BuildContext context) {
    return SizedBox(
      height: 166,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PageView.builder(
            controller: _promoController,
            padEnds: false,
            itemCount: _promos.length,
            itemBuilder: (context, i) {
              final p = _promos[i];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 0, 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE9B8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: AppColors.purple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: Text(
                              p.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 140,
                        height: 36,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            shape: const StadiumBorder(),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () =>
                              showDemo(context, '${p.button} (demo)'),
                          child: Text(
                            p.button,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Badge STAMP (placeholder, bukan aset asli)
          Positioned(
            top: -12,
            right: 6,
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB02E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'OVO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepPurple,
                          ),
                        ),
                        Text(
                          'STAMP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Color(0xFF7A2BD0), blurRadius: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14A044),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Text(
                        'Mulai Misi!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _homeTabs.length,
        itemBuilder: (context, i) {
          final bool sel = _tab == i;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFF1F1F4) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _homeTabs[i],
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: sel ? AppColors.purple : const Color(0xFFA0A0AB),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final items = _serviceTabs[_tab];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: GridView.builder(
          key: ValueKey<int>(_tab),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 112,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, i) {
            final s = items[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showDemo(context, '${s.label} (demo)'),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 64,
                    height: 58,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: s.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.icon, color: s.color, size: 26),
                        ),
                        if (s.badge != null)
                          Positioned(
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8213C),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                s.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanners(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final b = _banners[i];
          return GestureDetector(
            onTap: () => showDemo(context, '${b.brand} (demo)'),
            child: Container(
              width: 290,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: b.colors,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned(
                    right: -4,
                    bottom: -14,
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Color(0x33FFFFFF),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.brand,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 170,
                          child: Text(
                            b.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── PROFILE ─────────────────────────

class _BlackCircle extends StatelessWidget {
  const _BlackCircle({required this.child, this.size = 26});
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1B1B1F),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title, {this.color = AppColors.text});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).padding.bottom +
        kNavBarHeight +
        kNavOverhang +
        16;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 36, bottom: 16, left: 0),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            // Kartu user
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: _outlined(),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9CCF7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.purple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tatiana Beauty Octavia Rahayu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '0851-2666-2367',
                          style: TextStyle(fontSize: 13, color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showDemo(context, 'Ubah profil (demo)'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Ubah',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Loyalty Code
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => showDemo(context, 'Loyalty Code (demo)'),
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: _outlined(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Barcode(),
                    SizedBox(width: 12),
                    Text(
                      'Loyalty Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _SectionHeader('Akun'),
            _MenuRow(
              leading: const Icon(
                Icons.radio_button_checked,
                color: AppColors.deepPurple,
                size: 26,
              ),
              title: 'OVO Premier',
              trailing: SizedBox(
                height: 38,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: () => showDemo(context, 'Upgrade (demo)'),
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
              onTap: () => showDemo(context, 'OVO Premier (demo)'),
            ),
            _MenuRow(
              leading: const _BlackCircle(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              title: 'OVO Points',
              onTap: () => showDemo(context, 'OVO Points (demo)'),
            ),
            _MenuRow(
              leading: const _BlackCircle(
                child: Icon(Icons.star, color: Colors.white, size: 15),
              ),
              title: 'OVO Stamp',
              onTap: () => showDemo(context, 'OVO Stamp (demo)'),
            ),
            _MenuRow(
              leading: const Icon(Icons.link, color: AppColors.text, size: 26),
              title: 'Aplikasi Terhubung',
              showNew: true,
              onTap: () => showDemo(context, 'Aplikasi Terhubung (demo)'),
            ),
            const _SectionHeader('Bantuan'),
            _MenuRow(
              leading: const _BlackCircle(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              title: 'Pusat Bantuan',
              onTap: () => showDemo(context, 'Pusat Bantuan (demo)'),
            ),
            const _SectionHeader('Keamanan'),
            _MenuRow(
              leading: const Icon(
                Icons.lock_outline,
                color: AppColors.text,
                size: 26,
              ),
              title: 'Ubah PIN',
              onTap: () => showDemo(context, 'Ubah PIN (demo)'),
            ),
            _MenuRow(
              leading: const Icon(
                Icons.fingerprint,
                color: AppColors.text,
                size: 26,
              ),
              title: 'Biometrik',
              onTap: () => showDemo(context, 'Biometrik (demo)'),
            ),
            _MenuRow(
              leading: const Icon(
                Icons.devices,
                color: AppColors.text,
                size: 26,
              ),
              title: 'Perangkat Terdaftar',
              onTap: () => showDemo(context, 'Perangkat Terdaftar (demo)'),
            ),
            const _SectionHeader('Tentang'),
            _MenuRow(
              leading: const Icon(
                Icons.description_outlined,
                color: AppColors.text,
                size: 26,
              ),
              title: 'Syarat & Ketentuan',
              onTap: () => showDemo(context, 'Syarat & Ketentuan (demo)'),
            ),
            _MenuRow(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.text,
                size: 26,
              ),
              title: 'Kebijakan Privasi',
              onTap: () => showDemo(context, 'Kebijakan Privasi (demo)'),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _outlined() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0xFFDCDCE4)),
  );
}

class _Barcode extends StatelessWidget {
  const _Barcode();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final w in const [2.0, 1.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0])
          Padding(
            padding: const EdgeInsets.only(right: 2.5),
            child: Container(width: w, height: 24, color: Colors.black),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.leading,
    required this.title,
    this.trailing,
    this.showNew = false,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final Widget? trailing;
  final bool showNew;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              children: [
                SizedBox(width: 28, child: Center(child: leading)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (showNew)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      size: 26,
                      color: AppColors.text,
                    ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.line),
      ],
    );
  }
}

// ───────────────────────── FINANCE ─────────────────────────

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).padding.bottom +
        kNavBarHeight +
        kNavOverhang +
        16;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageTitle('Finance'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5B3CD9), Color(0xFF3F66D8)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Aset',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp 4.820.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Layanan Keuangan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            _tile(
              context,
              Icons.savings,
              'Nabung by Superbank',
              'Bunga hingga 4% p.a.',
              const Color(0xFF5A3DD8),
              const Color(0xFFEDE7FB),
            ),
            _tile(
              context,
              Icons.trending_up,
              'OVO Invest',
              'Reksa dana mulai Rp 10.000',
              const Color(0xFF1E9B6B),
              const Color(0xFFE3F5EC),
            ),
            _tile(
              context,
              Icons.payments,
              'Pinjaman',
              'Limit hingga Rp 100 juta',
              const Color(0xFF2F6BE0),
              const Color(0xFFE6EFFC),
            ),
            _tile(
              context,
              Icons.shield,
              'Asuransi',
              'Proteksi mulai Rp 1.000/hari',
              const Color(0xFFF4742B),
              const Color(0xFFFDEEE3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color c,
    Color bg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCDCE4)),
      ),
      child: ListTile(
        onTap: () => showDemo(context, '$title (demo)'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: c),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.text),
      ),
    );
  }
}

// ───────────────────────── PAY (QRIS) ─────────────────────────

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  bool _flash = false;

  Widget _corner(Alignment a) {
    const side = BorderSide(color: Colors.white, width: 4);
    return Align(
      alignment: a,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border(
            top: a.y < 0 ? side : BorderSide.none,
            bottom: a.y > 0 ? side : BorderSide.none,
            left: a.x < 0 ? side : BorderSide.none,
            right: a.x > 0 ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).padding.bottom +
        kNavBarHeight +
        kNavOverhang +
        16;

    return Container(
      color: const Color(0xFF14111F),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _PageTitle('Scan QRIS', color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _flash = !_flash),
                    icon: Icon(
                      _flash ? Icons.flash_on : Icons.flash_off,
                      color: _flash ? const Color(0xFFFFD54F) : Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  children: [
                    _corner(Alignment.topLeft),
                    _corner(Alignment.topRight),
                    _corner(Alignment.bottomLeft),
                    _corner(Alignment.bottomRight),
                    const Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 96,
                        color: Color(0x33FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Arahkan kamera ke kode QRIS',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => showDemo(context, 'Galeri (demo)'),
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('Galeri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => showDemo(context, 'Kode QR Saya (demo)'),
                      icon: const Icon(Icons.qr_code_2, size: 18),
                      label: const Text('Kode QR Saya'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── INBOX ─────────────────────────

class _InboxItem {
  const _InboxItem(
    this.category,
    this.icon,
    this.title,
    this.body,
    this.time,
    this.unread,
  );
  final String category;
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  int _filter = 0;

  static const List<String> _filters = ['Semua', 'Transaksi', 'Promo', 'Info'];

  static const List<_InboxItem> _items = [
    _InboxItem(
      'Transaksi',
      Icons.arrow_upward,
      'Transfer berhasil',
      'Kamu berhasil transfer Rp 50.000 ke Budi Santoso.',
      '09.12',
      true,
    ),
    _InboxItem(
      'Promo',
      Icons.discount,
      'Cashback 50% PLN',
      'Bayar token listrik hari ini dan dapatkan cashback.',
      '08.40',
      true,
    ),
    _InboxItem(
      'Info',
      Icons.verified_user,
      'Upgrade OVO Premier',
      'Lengkapi data kamu untuk limit saldo lebih besar.',
      'Kemarin',
      true,
    ),
    _InboxItem(
      'Transaksi',
      Icons.add,
      'Top Up berhasil',
      'Saldo OVO Cash kamu bertambah Rp 200.000.',
      'Kemarin',
      false,
    ),
    _InboxItem(
      'Promo',
      Icons.local_offer,
      'Voucher makan siang',
      'Diskon Rp 15.000 untuk pesanan pertamamu.',
      '2 hari lalu',
      false,
    ),
    _InboxItem(
      'Info',
      Icons.info_outline,
      'Pembaruan aplikasi',
      'Fitur baru OVO Stamp sudah tersedia.',
      '3 hari lalu',
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomPad =
        MediaQuery.of(context).padding.bottom +
        kNavBarHeight +
        kNavOverhang +
        16;
    final list = _filter == 0
        ? _items
        : _items.where((e) => e.category == _filters[_filter]).toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PageTitle('Inbox'),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final bool sel = _filter == i;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.purple : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.purple : const Color(0xFFDCDCE4),
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : AppColors.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.line),
              itemBuilder: (context, i) {
                final e = list[i];
                return InkWell(
                  onTap: () => showDemo(context, '${e.title} (demo)'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDE7FB),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            e.icon,
                            color: AppColors.purple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                e.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF55556A),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              e.time,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (e.unread)
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
