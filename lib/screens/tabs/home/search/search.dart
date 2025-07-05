import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas_front_end_nicolas/components/text_input.dart';
import 'package:tugas_front_end_nicolas/model/parking_lot.dart';
import 'package:tugas_front_end_nicolas/model/user.dart';
import 'package:tugas_front_end_nicolas/provider/user_provider.dart';
import 'package:tugas_front_end_nicolas/screens/tabs/home/parking_lot/lot_detail.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';
import 'package:tugas_front_end_nicolas/provider/parking_lot_provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final controller = TextEditingController();
  bool isSubmited = false;
  bool isLoading = false;
  List<ParkingLot>? resultLots;

  Future<void> searchMall(
    ParkingLotProvider provider,
    String query,
    User user,
  ) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 800));

    final lots = provider.searchLot(user, query);

    setState(() {
      resultLots = lots;
      isLoading = false;
      isSubmited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final lotProvider = Provider.of<ParkingLotProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.currentUser!;
    final malls =
        (controller.text.isEmpty) ? lotProvider.lots : resultLots ?? [];
    final history = lotProvider.loadHistory(user)?.searchHistory ?? [];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (isLoading) {
                          return;
                        }
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, size: isSmall ? 25 : 30),
                    ),
                    Text(
                      translate(
                        context,
                        'Where To Park ?',
                        'Parkir Dimana?',
                        '在哪里停车？',
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 25 : 30,
                      ),
                    ),
                  ],
                ),
              ),
              ResponsiveTextInput(
                autoFocus: true,
                controller: controller,
                leading: Icons.search,
                hint: translate(context, 'Search', 'Telusuri', '搜索'),
                isLoading: isLoading,
                clearButton: true,
                onClear: () {
                  setState(() {
                    isSubmited = false;
                    resultLots = null;
                  });
                },
                onChanged: (value) {
                  if (controller.text.isEmpty) {
                    setState(() {
                      isSubmited = false;
                      resultLots = null;
                    });
                  }
                },
                onSubmitted: (value) async {
                  if (controller.text.isNotEmpty && !isLoading) {
                    await searchMall(lotProvider, value, user);
                  }
                },
              ),

              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: const Color(0xFF1F1E5B),
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 2));
                  },
                  child:
                      isLoading
                          ? _buildLoadingState(context)
                          : isSubmited
                          ? _buildSearchResults(malls, context)
                          : _buildSearchHistory(
                            history,
                            lotProvider,
                            user,
                            context,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F1E5B)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            translate(context, 'Searching...', 'Mencari...', '搜索中...'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F1E5B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translate(
              context,
              'Please wait a moment',
              'Mohon tunggu sebentar',
              '请稍等',
            ),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<ParkingLot> malls, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    if (malls.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty/search_where.png',
                width: isSmall ? 240 : 300,
                height: isSmall ? 240 : 300,
              ),
              const SizedBox(height: 16),
              Text(
                translate(
                  context,
                  'Search not found',
                  'Pencarian tidak ditemukan',
                  '搜索没找到',
                ),
                style: TextStyle(
                  color: Color(0xFFD3D3D3),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate(
                  context,
                  'Try searching with different keywords',
                  'Coba cari dengan kata kunci lain',
                  '尝试使用不同的关键词搜索',
                ),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                translate(context, 'Search Result', 'Hasil Pencarian', '搜索结果'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 20 : 30,
                ),
              ),
            ),
          ),
          ...malls.map((mall) {
            return GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LotDetail(mall: mall),
                    ),
                  ),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gambar tetap kotak
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(mall.image, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Konten text di samping gambar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris nama dan badge slot
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  mall.name,
                                  style: TextStyle(
                                    color: Color(0xFF1F1E5B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0x46DC5F00),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  mall.spotCount <= 0
                                      ? translate(
                                        context,
                                        'All Full',
                                        'Penuh',
                                        '全部满了',
                                      )
                                      : translate(
                                        context,
                                        mall.spotCount == 1
                                            ? '${mall.spotCount} Slot'
                                            : '${mall.spotCount} Slots',
                                        '${mall.spotCount} Slot',
                                        '${mall.spotCount} 个插槽',
                                      ),
                                  style: TextStyle(
                                    color: Color(0xFFDC5F00),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            mall.address,
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                formatCurrency(
                                  nominal:
                                      mall.starterPrice ?? mall.hourlyPrice,
                                ),
                                style: TextStyle(
                                  color: Color(0xFFDC5F00),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '/${translate(context, "Hour", "Jam", "小时")}',
                                style: TextStyle(
                                  color: Color(0xFFDC5F00),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(
    List<String> history,
    ParkingLotProvider provider,
    User user,
    BuildContext context,
  ) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    if (history.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: isSmall ? 100 : 150,
                color: Color(0xFFD3D3D3),
              ),
              const SizedBox(height: 16),
              Text(
                translate(
                  context,
                  'No search history',
                  'Tidak ada riwayat pencarian',
                  '没有搜索历史',
                ),
                style: TextStyle(
                  color: Color(0xFFD3D3D3),
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 18 : 25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate(
                  context,
                  'Start searching to see your history',
                  'Mulai mencari untuk melihat riwayat',
                  '开始搜索以查看您的历史记录',
                ),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isSmall ? 14 : 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                translate(context, 'Recent', 'Terkini', '最近'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 20 : 30,
                ),
              ),
            ),
          ),
          ...history.map((item) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: isSmall ? 0 : 4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    provider.deleteHistory(user, item);
                  },
                  child: Container(
                    width: isSmall ? 24 : 28,
                    height: isSmall ? 24 : 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: isSmall ? 15 : 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                onTap: () async {
                  if (!isLoading) {
                    controller.text = item;
                    await searchMall(provider, item, user);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
