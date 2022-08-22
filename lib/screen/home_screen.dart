import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  static final LatLng companyLatLng = LatLng(
    37.5233273,
    126.921252,
  );
  static final Marker marker = Marker(
    // 회사위치 마커 선언
    markerId: MarkerId('company'),
    position: companyLatLng,
  );
  static final Circle circle = Circle(
    circleId: CircleId('choolC heckCircle'),
    center: companyLatLng,
    // 원의 중심이되는 위치. LatLng값을 제공합니다.
    fillColor: Colors.blue.withOpacity(0.5),
    // 원의 색상
    radius: 100,
    // 원의 반지름 (미터단위)
    strokeColor: Colors.blue,
    // 원의 테두리 색
    strokeWidth: 1, // 원의 테두리 두께
  );

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (context, snapshot) {
          // 로딩상태
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == '위치 권한이 허가 되었습니다.') {
            print('hello');
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: companyLatLng,
                      zoom: 16,
                    ),
                    myLocationEnabled: true,
                    markers: Set.from([marker]), // Set로 Marker 제공
                    circles: Set.from([circle]), // Set로 Circle 제공
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timelapse_outlined,
                        color: Colors.blue,
                        size: 50.0,
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          final curPosition =
                              await Geolocator.getCurrentPosition();

                          final distance = Geolocator.distanceBetween(
                            curPosition.latitude,
                            curPosition.longitude,
                            companyLatLng.latitude,
                            companyLatLng.longitude,
                          );

                          bool canCheck = distance < 100;

                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('출근하기'),
                                content: Text(canCheck
                                    ? '출근을 하시겠습니까?'
                                    : '출근할수 없는 위치입니다.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('취소'),
                                  ),
                                  if (canCheck)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text('출근하기'),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('출근하기!'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              snapshot.data.toString(),
            ),
          );
        },
      ),
    );
  }

  AppBar renderAppBar() {
    return AppBar(
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화 해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }

    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 세팅에서 허가해주세요.';
    }

    return '위치 권한이 허가 되었습니다.';
  }
}
