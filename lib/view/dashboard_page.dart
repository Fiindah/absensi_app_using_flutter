import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:aplikasi_absensi/copy_right.dart';
import 'package:aplikasi_absensi/models/attendance_model.dart';
import 'package:aplikasi_absensi/models/history_model.dart';
import 'package:aplikasi_absensi/view/check_in_page.dart';
import 'package:aplikasi_absensi/view/check_out_page.dart';
import 'package:aplikasi_absensi/view/history_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const String id = "/dashboard_page";

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  String? _username;
  String _currentDate = '';
  AttendanceData? _todayAttendance;
  bool _isLoadingAttendance = true;
  List<HistoryData> _recentHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _initializeLocaleAndLoadData();
    _fetchTodayAttendanceStatus();
    _fetchRecentHistory();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    setState(() {
      _username = username;
    });
  }

  Future<void> _initializeLocaleAndLoadData() async {
    await initializeDateFormatting('id_ID', null);
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    setState(() {
      _currentDate = formatter.format(now);
    });
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    setState(() => _isLoadingAttendance = true);
    try {
      final response = await _authService.fetchTodayAttendance();
      setState(() {
        _todayAttendance =
            response.data ??
            AttendanceData(
              id: 0,
              attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              status: 'Belum Absen',
              alasanIzin: response.message,
            );
      });
    } catch (e) {
      setState(() {
        _todayAttendance = AttendanceData(
          id: 0,
          attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'error_loading',
          alasanIzin: 'Gagal memuat status absensi: \$e',
        );
      });
    } finally {
      setState(() => _isLoadingAttendance = false);
    }
  }

  Future<void> _fetchRecentHistory() async {
    try {
      final data = await _authService.fetchHistory();
      setState(() {
        _recentHistory = data.take(3).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _recentHistory = [];
        _isLoadingHistory = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 18) return 'Selamat Siang';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: Container(
              width: isWideScreen ? 400 : double.infinity,
              decoration: isWideScreen
                  ? BoxDecoration(
                      color: Colors.white,
                      // borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Scaffold(
                backgroundColor: AppColor.neutral,
                appBar: AppBar(
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColor.myblue,
                  elevation: 0,
                  centerTitle: true,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.myblue, AppColor.myblue1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, ${_username ?? 'Pengguna'}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColor.myblue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentDate,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColor.gray88,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    CheckInPage.id,
                                  ).then((value) {
                                    if (value == true)
                                      _fetchTodayAttendanceStatus();
                                  });
                                },
                                label: const Text(
                                  "CHECK IN",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    CheckOutPage.id,
                                  ).then((value) {
                                    if (value == true)
                                      _fetchTodayAttendanceStatus();
                                  });
                                },
                                label: const Text(
                                  "CHECK OUT",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 8,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppColor.myblue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          shadowColor: AppColor.myblue.withOpacity(0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _isLoadingAttendance
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   'Status Hari Ini',
                                      //   style: TextStyle(
                                      //     fontSize: 18,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: AppColor.myblue,
                                      //   ),
                                      // ),
                                      // const Divider(
                                      //   height: 24,
                                      //   thickness: 1,
                                      //   color: Colors.grey,
                                      // ),
                                      if (_todayAttendance != null) ...[
                                        // Tampilkan status
                                        Text(
                                          'Status Kehadiran : ${_todayAttendance!.status}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.myblue,
                                          ),
                                        ),

                                        const Divider(
                                          height: 24,
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),

                                        // Header Check In & Out
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              'CHECK IN',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'CHECK OUT',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Value
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              _todayAttendance!.checkInTime ??
                                                  '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),

                                            Text(
                                              _todayAttendance!.checkOutTime ??
                                                  '-',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (_todayAttendance!.status
                                                .toLowerCase() ==
                                            'izin')
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              'Alasan: ${_todayAttendance!.alasanIzin ?? '-'}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                      ] else
                                        const Text(
                                          'Tidak ada data absensi hari ini.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'Riwayat Terkini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.myblue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isLoadingHistory
                            ? const Center(child: CircularProgressIndicator())
                            : _recentHistory.isEmpty
                            ? const Text(
                                'Belum ada data riwayat.',
                                style: TextStyle(color: Colors.grey),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: _recentHistory.map((item) {
                                    final dateFormatted =
                                        DateFormat(
                                          'EEEE, dd MMMM yyyy',
                                          'id_ID',
                                        ).format(
                                          DateTime.parse(item.attendanceDate),
                                        );
                                    return Container(
                                      // elevation: 2,
                                      // shape: RoundedRectangleBorder(
                                      //   borderRadius: BorderRadius.circular(12),
                                      // ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.blue.shade50,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        leading: Icon(
                                          item.status == 'masuk'
                                              ? Icons.check_circle
                                              : item.status == 'izin'
                                              ? Icons.info_outline
                                              : Icons.cancel,
                                          color: item.status == 'masuk'
                                              ? Colors.green
                                              : item.status == 'izin'
                                              ? Colors.orange
                                              : Colors.red,
                                        ),
                                        title: Text(
                                          dateFormatted,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),

                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    'CHECK IN',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    'CHECK OUT',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(item.checkInTime ?? '-'),
                                                  Text(
                                                    item.checkOutTime ?? '-',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, HistoryPage.id);
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: AppColor.myblue,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CopyrightWidget(),

                        // const CopyrightWidget(
                        //   devName: 'Si Absensi',
                        //   appName: 'Endah F N',
                        //   textColor: Colors.grey,
                        //   fontSize: 10.0,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //   Widget _buildInfoRow(String label, String value) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(width: 12),
  //           Text(
  //             '$label:',
  //             style: const TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 14,
  //               color: AppColor.myblue,
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               value,
  //               style: const TextStyle(fontSize: 14, color: AppColor.gray88),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}

// import 'package:aplikasi_absensi/api/api_service.dart';
// import 'package:aplikasi_absensi/constant/app_color.dart';
// import 'package:aplikasi_absensi/copy_right.dart';
// import 'package:aplikasi_absensi/models/attendance_model.dart';
// import 'package:aplikasi_absensi/models/history_model.dart';
// import 'package:aplikasi_absensi/view/check_in_page.dart';
// import 'package:aplikasi_absensi/view/check_out_page.dart';
// import 'package:aplikasi_absensi/view/history_page.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:intl/intl.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//   static const String id = "/dashboard_page";

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   final AuthService _authService = AuthService();
//   String? _username;
//   String _currentDate = '';
//   AttendanceData? _todayAttendance;
//   bool _isLoadingAttendance = true;
//   List<HistoryData> _recentHistory = [];
//   bool _isLoadingHistory = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocaleAndLoadData();
//     _fetchTodayAttendanceStatus();
//     _fetchRecentHistory();
//     _loadUsername();
//   }

//   Future<void> _loadUsername() async {
//     final username = await _authService.getUsername();
//     setState(() {
//       _username = username;
//     });
//   }

//   Future<void> _initializeLocaleAndLoadData() async {
//     await initializeDateFormatting('id_ID', null);
//     final now = DateTime.now();
//     final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
//     setState(() {
//       _currentDate = formatter.format(now);
//     });
//   }

//   Future<void> _fetchTodayAttendanceStatus() async {
//     setState(() => _isLoadingAttendance = true);
//     try {
//       final response = await _authService.fetchTodayAttendance();
//       setState(() {
//         _todayAttendance =
//             response.data ??
//             AttendanceData(
//               id: 0,
//               attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//               status: 'Belum Absen',
//               alasanIzin: response.message,
//             );
//       });
//     } catch (e) {
//       setState(() {
//         _todayAttendance = AttendanceData(
//           id: 0,
//           attendanceDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//           status: 'error_loading',
//           alasanIzin: 'Gagal memuat status absensi: \$e',
//         );
//       });
//     } finally {
//       setState(() => _isLoadingAttendance = false);
//     }
//   }

//   Future<void> _fetchRecentHistory() async {
//     try {
//       final data = await _authService.fetchHistory();
//       setState(() {
//         _recentHistory = data.take(3).toList();
//         _isLoadingHistory = false;
//       });
//     } catch (e) {
//       setState(() {
//         _recentHistory = [];
//         _isLoadingHistory = false;
//       });
//     }
//   }

//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Selamat Pagi';
//     if (hour < 18) return 'Selamat Siang';
//     return 'Selamat Malam';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.neutral,
//       appBar: AppBar(
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: AppColor.myblue,
//         elevation: 0,
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColor.myblue, AppColor.myblue1],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${_getGreeting()}, ${_username ?? 'Pengguna'}',
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.myblue,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 _currentDate,
//                 style: const TextStyle(fontSize: 16, color: AppColor.gray88),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, CheckInPage.id).then((
//                           value,
//                         ) {
//                           if (value == true) _fetchTodayAttendanceStatus();
//                         });
//                       },
//                       icon: const Icon(Icons.login),
//                       label: const Text(
//                         "CHECK IN",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.pushNamed(context, CheckOutPage.id).then((
//                           value,
//                         ) {
//                           if (value == true) _fetchTodayAttendanceStatus();
//                         });
//                       },
//                       icon: const Icon(Icons.logout),
//                       label: const Text(
//                         "CHECK OUT",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Card(
//                 elevation: 8,
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   side: BorderSide(
//                     color: AppColor.myblue.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 shadowColor: AppColor.myblue.withOpacity(0.4),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: _isLoadingAttendance
//                       ? const Center(child: CircularProgressIndicator())
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Status Hari Ini',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColor.myblue,
//                               ),
//                             ),
//                             const Divider(
//                               height: 24,
//                               thickness: 1,
//                               color: Colors.grey,
//                             ),
//                             if (_todayAttendance != null) ...[
//                               _buildInfoRow('Status', _todayAttendance!.status),
//                               if (_todayAttendance!.checkInTime != null)
//                                 _buildInfoRow(
//                                   'Check-in',
//                                   _todayAttendance!.checkInTime!,
//                                 ),
//                               if (_todayAttendance!.checkOutTime != null)
//                                 _buildInfoRow(
//                                   'Check-out',
//                                   _todayAttendance!.checkOutTime!,
//                                 ),
//                               if (_todayAttendance!.status.toLowerCase() ==
//                                   'izin')
//                                 _buildInfoRow(
//                                   'Alasan',
//                                   _todayAttendance!.alasanIzin ?? '-',
//                                 ),
//                             ] else
//                               const Text(
//                                 'Tidak ada data absensi hari ini.',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                           ],
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Riwayat Terkini',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.myblue,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _isLoadingHistory
//                   ? const Center(child: CircularProgressIndicator())
//                   : _recentHistory.isEmpty
//                   ? const Text(
//                       'Belum ada data riwayat.',
//                       style: TextStyle(color: Colors.grey),
//                     )
//                   : Column(
//                       children: _recentHistory.map((item) {
//                         final dateFormatted = DateFormat(
//                           'dd MMM yyyy',
//                           'id_ID',
//                         ).format(DateTime.parse(item.attendanceDate));
//                         return Card(
//                           elevation: 2,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           margin: const EdgeInsets.only(bottom: 10),
//                           child: ListTile(
//                             leading: Icon(
//                               item.status == 'masuk'
//                                   ? Icons.check_circle
//                                   : item.status == 'izin'
//                                   ? Icons.info_outline
//                                   : Icons.cancel,
//                               color: item.status == 'masuk'
//                                   ? Colors.green
//                                   : item.status == 'izin'
//                                   ? Colors.orange
//                                   : Colors.red,
//                             ),
//                             title: Text(dateFormatted),
//                             subtitle: item.status == 'izin'
//                                 ? Text('Izin: ${item.alasanIzin ?? '-'}')
//                                 : Text(
//                                     'Check In: ${item.checkInTime ?? '-'} | Check Out: ${item.checkOutTime ?? '-'}',
//                                   ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, HistoryPage.id);
//                   },
//                   child: Text(
//                     'Lihat Semua',
//                     style: TextStyle(color: AppColor.myblue, fontSize: 15),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const CopyrightWidget(
//                 appName: 'Endah F N',
//                 companyName: 'Si Absensi',
//                 textColor: Colors.grey,
//                 fontSize: 10.0,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(width: 12),
//           Text(
//             '$label:',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: AppColor.myblue,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14, color: AppColor.gray88),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
