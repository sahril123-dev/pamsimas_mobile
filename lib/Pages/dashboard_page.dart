import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? idPelanggan;
  String? namaPelanggan;
  Map<String, dynamic>? tagihan;
  List<dynamic> history = [];
  double totalTunggakan = 0;
  int unreadNotifCount = 0;
  List<dynamic> notifikasiList = [];

  bool isLoading = true;

  Future<void> loadData({bool silent = false}) async {
    if (!silent && mounted) setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      idPelanggan = prefs.getString("id_pelanggan");
      namaPelanggan = prefs.getString("nama_pelanggan");

      if (idPelanggan == null) {
        if (!silent && mounted) setState(() => isLoading = false);
        return;
      }

      // Tagihan aktif
      final currentResult = await ApiService.getCurrentTagihan();
      final currentBody = currentResult["body"];

      // Riwayat tagihan
      final historyResult = await ApiService.getHistoryTagihan();
      final historyBody = historyResult["body"];

      // Count notifikasi unread
      final notifCountResult = await ApiService.getUnreadNotifikasiCount();
      final notifCountBody = notifCountResult["body"];

      if (!mounted) return;

      setState(() {
        tagihan = (currentBody != null && currentBody["success"] == true) ? currentBody["data"] : null;
        history = (historyBody != null && historyBody["success"] == true) ? (historyBody["data"] ?? []) : [];
        
        int count = 0;
        if (notifCountBody != null && notifCountBody["success"] == true) {
          count = int.tryParse(notifCountBody["data"]?.toString() ?? '0') ?? 0;
        }
        unreadNotifCount = count;
        
        // Hitung total tunggakan dari semua tagihan yang belum lunas
        totalTunggakan = 0;
        Set<String> processedPeriods = {};
        
        // Cek tagihan aktif
        if (tagihan != null && tagihan!["status"]?.toString().toLowerCase() != "lunas") {
          totalTunggakan += double.tryParse(tagihan!["total_tagihan"].toString()) ?? 0;
          processedPeriods.add(tagihan!["periode"]?.toString() ?? "");
        }
        
        // Cek riwayat tagihan
        for (var item in history) {
          String period = item["periode"]?.toString() ?? "";
          if (item["status"]?.toString().toLowerCase() != "lunas" && !processedPeriods.contains(period)) {
            totalTunggakan += double.tryParse(item["total_tagihan"].toString()) ?? 0;
            processedPeriods.add(period);
          }
        }
      });
    } catch (e) {
      debugPrint("Error on loadData: $e");
    } finally {
      if (!silent && mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background Gradient
                Positioned.fill(
                  child: Container(decoration: const BoxDecoration(color: Color(0xFF0f172a))),
                ),
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),

                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () => loadData(silent: true),
                    color: primaryColor,
                    backgroundColor: const Color(0xFF1e293b),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          // Header: Greeting & Profile
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Selamat Datang,",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    namaPelanggan ?? "Pelanggan",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "ID: ${idPelanggan ?? '-'}",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Notifikasi Icon
                                  _buildNotifikasiIcon(primaryColor),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                                    child: IconButton(
                                      icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.clear();
                                        if (!mounted) return;
                                        Navigator.pushReplacementNamed(context, "/login");
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Main Bill Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "TOTAL TUNGGAKAN",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Rp ${totalTunggakan.toInt()}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (tagihan != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Periode: ${tagihan!['periode'] ?? '-'}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Kartu Meteran Penggunaan
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.speed_rounded, color: primaryColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Pemakaian Bulan Ini",
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    Text(
                                      "${tagihan?['pemakaian'] ?? '0'} m³",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(Icons.trending_up_rounded, color: Colors.greenAccent.withValues(alpha: 0.5), size: 20),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Quick Actions Grid
                          const Text(
                            "Layanan Utama",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.2,
                            children: [
                              _buildUtilityAction(
                                icon: Icons.receipt_long_rounded,
                                label: "Tagihan",
                                color: primaryColor,
                                onTap: () => _showBillInfo(context),
                              ),
                              _buildUtilityAction(
                                icon: Icons.manage_accounts_rounded,
                                label: "Akun",
                                color: const Color(0xFF22d3ee),
                                onTap: () => _showProfileInfo(context),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // History List
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Riwayat Tagihan",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                "Lihat Semua",
                                style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          history.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      "Belum ada riwayat",
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: history.length > 3 ? 3 : history.length,
                                  itemBuilder: (context, index) {
                                    final item = history[index];
                                    final isLunas = item["status"]?.toString().toLowerCase() == "lunas";
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.water_drop, color: primaryColor.withValues(alpha: 0.3), size: 18),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item["periode"] ?? "-",
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(
                                            "Rp ${item["total_tagihan"]}",
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            isLunas ? Icons.check_circle_rounded : Icons.pending_rounded,
                                            color: isLunas ? Colors.greenAccent : Colors.orangeAccent,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUtilityAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showBillInfo(BuildContext context) {
    List<Map<String, dynamic>> unpaidBills = [];
    Set<String> seenPeriods = {};
    
    // Tambahkan tagihan aktif jika belum lunas
    if (tagihan != null && tagihan!["status"]?.toString().toLowerCase() != "lunas") {
      unpaidBills.add(Map<String, dynamic>.from(tagihan!));
      seenPeriods.add(tagihan!["periode"]?.toString() ?? "");
    }
    
    // Tambahkan dari history jika belum lunas dan belum ada
    for (var item in history) {
      String period = item["periode"]?.toString() ?? "";
      if (item["status"]?.toString().toLowerCase() != "lunas" && !seenPeriods.contains(period)) {
        unpaidBills.add(Map<String, dynamic>.from(item));
        seenPeriods.add(period);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: const Text(
          "Rincian Tunggakan",
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (unpaidBills.isEmpty)
                const Text("Tidak ada tunggakan", style: TextStyle(color: Colors.white70))
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: unpaidBills.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                    itemBuilder: (context, index) {
                      final bill = unpaidBills[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  bill["periode"] ?? "-",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Rp ${bill["total_tagihan"]}",
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pemakaian: ${bill["pemakaian"] ?? 0} m³",
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Divider(color: Colors.white, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Rp ${totalTunggakan.toInt()}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showProfileInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString("nama_pelanggan") ?? "-";
    
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: const Text(
          "Profil Pelanggan",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Nama", nama),
            _buildInfoRow("ID Pelanggan", idPelanggan?.toString() ?? "-"),
            _buildInfoRow("Status", "Aktif"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiIcon(Color primaryColor) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: IconButton(
            icon: const Icon(Icons.notifications_rounded, color: Colors.white70, size: 22),
            onPressed: () => _showNotifikasiDialog(context),
          ),
        ),
        if (unreadNotifCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0f172a), width: 2),
              ),
              child: Text(
                '$unreadNotifCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotifikasiDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final notifResult = await ApiService.getNotifikasi();
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (notifResult["body"]["success"] == true) {
      notifikasiList = notifResult["body"]["data"] ?? [];
      
      // Update badge if backend returned less unread
      int actualUnread = notifikasiList.where((n) => n["dibaca"] == 0 || n["dibaca"] == false).length;
      setState(() {
        unreadNotifCount = actualUnread;
      });
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16213e),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Peringatan", style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: notifikasiList.isEmpty
                    ? const Center(child: Text("Tidak ada pesan", style: TextStyle(color: Colors.white70)))
                    : ListView.separated(
                        itemCount: notifikasiList.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                        itemBuilder: (context, index) {
                          final notif = notifikasiList[index];
                          final isRead = notif["dibaca"] == 1 || notif["dibaca"] == true;
                          return ListTile(
                            onTap: isRead ? null : () async {
                              setStateDialog(() {
                                notif["dibaca"] = 1;
                              });
                              setState(() {
                                if (unreadNotifCount > 0) unreadNotifCount--;
                              });
                              await ApiService.markNotifikasiRead(notif["id"].toString());
                            },
                            leading: Icon(
                              isRead ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                              color: isRead ? Colors.white30 : Colors.redAccent,
                            ),
                            title: Text(
                              notif["judul"] ?? "Peringatan",
                              style: TextStyle(
                                color: isRead ? Colors.white54 : Colors.white,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notif["pesan"] ?? "",
                                  style: TextStyle(color: isRead ? Colors.white30 : Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif["created_at"] != null ? notif["created_at"].toString().substring(0, 10) : "",
                                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }
}         