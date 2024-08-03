import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter/material.dart';
import 'package:resiease/screens/introduction_page.dart';
import 'on_boarding_model.dart';

class OnBoardingWidget extends StatelessWidget {
  const OnBoardingWidget({
    super.key,
    required this.model,
  });

  final OnBoardingModel model;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [model.bgColor.withOpacity(1), model.bgColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            model.image,
            height: model.height * 0.4,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  model.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  model.subTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            model.counterText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

final pages = [
  OnBoardingWidget(
    model: OnBoardingModel(
      image: 'images/man.png',
      title: 'Managing Residencies is a Hassle?',
      subTitle: 'We provide the best solutions.',
      counterText: '1/3',
      bgColor: const Color.fromARGB(255, 161, 151, 108),
      height: 850,
    ),
  ),
  OnBoardingWidget(
    model: OnBoardingModel(
      image: 'images/recoupe.jpg',
      title: 'How to centralize regular and special fees?',
      subTitle: 'Our system makes it easy and efficient.',
      counterText: '2/3',
      bgColor: const Color.fromARGB(255, 161, 151, 108),
      height: 500,
    ),
  ),
  OnBoardingWidget(
    model: OnBoardingModel(
      image: 'images/complaints.png',
      title: 'How to handle different sorts of complaints from members?',
      subTitle: 'Streamlined processes for better management.',
      counterText: '3/3',
      bgColor: const Color.fromARGB(255, 161, 151, 108),
      height: 500,
    ),
  ),
  const IntroPage(),
];

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            liquidController: LiquidController(),
            positionSlideIcon: 0.50,
            pages: pages,
            waveType: WaveType.liquidReveal,
            slideIconWidget: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            enableLoop: false,
            fullTransitionValue: 500,
            enableSideReveal: true,
          ),
        ],
      ),
    );
  }
}
