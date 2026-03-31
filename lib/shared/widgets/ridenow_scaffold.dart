import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridenowappsss/core/utils/theme/app_colors.dart';

class RidenowScaffold extends StatelessWidget {
  final Widget? body;
  final Widget Function(Size size)? builder;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final bool showAppBar;
  final bool showFirstImage;
  final bool showBottomImage;
  final bool resizeToAvoidBottomInset;

  const RidenowScaffold({
    super.key,
    this.body,
    this.builder,
    this.appBarTitle,
    this.appBarActions,
    this.showAppBar = false,
    this.showFirstImage = true,
    this.showBottomImage = true,
    this.resizeToAvoidBottomInset = true,
  }) : assert(body != null || builder != null, '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgB0,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar:
          showAppBar
              ? AppBar(
                title:
                    appBarTitle != null
                        ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            appBarTitle!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : null,
                actions: appBarActions,
                centerTitle: true,
                elevation: 0,
                backgroundColor: AppColors.bgB0,
                foregroundColor: AppColors.textPrimary,
              )
              : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              if (showFirstImage)
                Positioned(
                  top: 150,
                  child: Image.asset(
                    'assets/background2.png',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                ),
              if (showBottomImage)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'assets/level1.svg',
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                ),
              SafeArea(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child:
                      body ??
                      builder!(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
