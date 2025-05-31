import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/home.dart';
import 'package:seddoapp/pages/publicationslist.dart';
import 'package:seddoapp/pages/setting.dart';
import 'package:seddoapp/pages/splash/Splash.dart';
import 'package:seddoapp/pages/transit/TransportCommun.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/widgets/update_required_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/services/api_service.dart';
import 'package:seddoapp/services/publication_service.dart';
import 'package:seddoapp/repositories/publication_repository.dart';

class MainScreen extends StatelessWidget {
  final int? initialIndex;
  final int? reservedPublicationId;
  final bool? off;

  const MainScreen({super.key, this.initialIndex, this.reservedPublicationId, this.off});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final publicationService = PublicationService(apiService.dio);
    final publicationRepository = PublicationRepository(
      publicationService: publicationService,
    );

    return BlocProvider(
      create: (context) => HomeBloc(publicationRepository)
        ..add(LoadCurrentUser())
        ..add(LoadCategories())
        ..add(const LoadCurrentLocation()),
      child: _MainScreenContent(
        initialIndex: initialIndex,
        reservedPublicationId: reservedPublicationId,
        off: off,
      ),
    );
  }
}

class _MainScreenContent extends StatelessWidget {
  final int? initialIndex;
  final int? reservedPublicationId;
  final bool? off;

  const _MainScreenContent({
    required this.initialIndex,
    required this.reservedPublicationId,
    required this.off,
  });

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
              return   SplashPage(off: off,);
            }

            if (currentAppVersion.isNotEmpty &&
                state.appParam!.appVersion != currentAppVersion &&
                !(state.appParam!.appVersionList?.contains(currentAppVersion) ?? false)) {
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
    final index = initialIndex ?? state.currentNavigationIndex;
    final bool isLoggedIn = state.currentUser != null;

    final pages = [
      HomePage(),
      if (!hideTransit)
        TransportCommun(
          appParam: state.appParam,
          winners: state.campaignToWinners,
        ),
      if (!isLoggedIn)
        _buildLoginRequiredPlaceholder()
      else
        Publicationslist(authorId: state.currentUser!.id),
      SettingPage(),
    ];

    if (index >= pages.length) return HomePage();
    return pages[index];
  }

  Widget _buildLoginRequiredPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Veuillez vous connecter pour accéder aux publications.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// [Conservez votre classe CustomBottomNavigationBar telle quelle]
class CustomBottomNavigationBar extends StatelessWidget {
  final HomeState state;

  const CustomBottomNavigationBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hideTransit = state.appParam!.hideTransit;

    final navItems = [
      _buildNavItem(context, 0, 'assets/icons/home.svg', 'Accueil'),
      if (!hideTransit)
        _buildNavItem(context, 1, 'assets/icons/bus.svg', 'Transport'),
      _buildNavItem(context, 2, 'assets/icons/news.svg', 'Publications'),
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
        border: Border.all(color: Colors.grey, width: 0.2),
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
    final iconSize = 20.0;
    final Color iconColor =
        isSelected
            ? HexColor(APIConstants.primaryColorValue)
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
