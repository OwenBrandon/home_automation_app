import 'package:flutter/material.dart';
import 'package:home_automation_app/features/landing/presentation/responsiveness/landing_page_responsive.config.dart';
import 'package:home_automation_app/features/landing/presentation/widgets/energy_consumption_panel.dart';
import 'package:home_automation_app/features/landing/presentation/widgets/home_page_header.dart';
import 'package:home_automation_app/features/landing/presentation/widgets/home_tile_options_panel.dart';
import 'package:home_automation_app/styles/styles.dart';

class HomePage extends StatelessWidget {

  static const String route = '/home';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final config = LandingPageResponsiveConfig.landingPageConfig(context);

    return Flex(
      direction: Axis.vertical,
      children: [
        if (config.homeTopDirection == Axis.horizontal)
          Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Expanded(
                child: HomePageHeader()
              ),
              HomeAutomationStyles.smallHGap,
              Expanded(
                child: HomeTileOptionsPanel()
              ),
            ],
          )
        else ...[
          const HomePageHeader(),
          HomeAutomationStyles.smallVGap,
          const HomeTileOptionsPanel(),
        ],
        const EnergyConsumptionPanel()
      ],
    );
  }
}