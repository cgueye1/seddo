import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/home.dart';
import 'package:seddoapp/pages/publicationslist.dart';
import 'package:seddoapp/pages/setting.dart';
import 'package:seddoapp/pages/transit/TransportCommun.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/update_required_screen.dart';
import '../pages/splash/Splash.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentAppVersion = snapshot.data!.version;

        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.appParam == null) {
              return SplashPage();
            }
            if (state.appParam!.appVersion != currentAppVersion) {
              return UpdateRequiredScreen(
                androidLink: state.appParam!.androidLink,
                iosLink: state.appParam!.iosLink,
              );
            }
            return Scaffold(
              body: _getPage(state),
              bottomNavigationBar: CustomBottomNavigationBar(state: state),
            );
          },
        );
      },
    );
  }

  Widget _getPage(HomeState state) {
    final hideTransit = state.appParam!.hideTransit;
    final index = state.currentNavigationIndex;

    final pages = [
      HomePage(),
      Publicationslist(),
      if (!hideTransit) TransportCommun(appParam: state.appParam),
      SettingPage(),
    ];

    if (index >= pages.length) return HomePage();
    return pages[index];
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final HomeState state;

  const CustomBottomNavigationBar({Key? key, required this.state})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hideTransit = state.appParam!.hideTransit;

    final navItems = [
      _buildNavItem(context, 0, 'assets/icons/home.svg', 'Accueil'),
      _buildNavItem(context, 1, 'assets/icons/news.svg', 'Publications'),
      if (!hideTransit)
        _buildNavItem(context, 2, 'assets/icons/bus.svg', 'Transport'),
      _buildNavItem(
        context,
        hideTransit ? 2 : 3,
        'assets/icons/setting.svg',
        'Paramètres',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Colors.white,
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems,
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String svgPath,
    String label,
  ) {
    final isSelected = index == state.currentNavigationIndex;
    final iconSize = 28.0;
    final Color iconColor =
        isSelected
            ? HexColor("#D95C18")
            : const Color.fromARGB(255, 113, 113, 113);

    return InkWell(
      onTap: () {
        if (!isSelected) {
          context.read<HomeBloc>().add(
            NavigationIndexChanged(navigationIndex: index),
          );
        }
      },
      splashColor: const Color.fromARGB(90, 0, 0, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: iconColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
