import 'dart:math';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:biker/common_libs.dart';
import 'package:biker/models/data.dart';
import 'package:biker/presenation/home/cycle_card.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final sizeKey = GlobalKey();
  double rotationAngleInRad = 0;
  double previousMousePosition = 0;
  int currentCardIndex = -1;

  AnimationController? snapController;
  CancelableOperation? cancelableOp;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setCurrentIndex();
      setState(() {});
    });
  }

  /// this calculates the opacity of the card
  /// it initially converts the normalized angle to degree
  /// and checks if the angle is in the range specfied.
  /// if it is not in the range the distance is taken and the opactiy is found.
  double calclualateOpacity(double angle) {
    // for example 370 degree is the same as 10 degree. though this is not needed again as the angle would now be within 0 to 360 degree.
    final normalizedAngle = angle % (2 * pi);
    final angleInDegree = normalizedAngle * 180 / pi;

    double opacity = 0;

    if (angleInDegree > 85 && angleInDegree < 95) {
      opacity = 1; //card is the current visible item;
    } else if (angleInDegree > 180) {
      opacity = 0; // if outside of view then set to 0;
    } else {
      // checks if the card is on the left hand or right hand side and subtract by the lower and greater opacity bound.
      final distanceFromRange =
          angleInDegree < 85 ? 85 - angleInDegree : angleInDegree - 95;

      //clipping the opacity between 0 and 0.4 if it is not currently visible
      // division by 85 to give a fade effect where 85 is the value from 0 - minimum range
      opacity = 0.4 - (distanceFromRange * 0.4 / 85);
    }

    return opacity.abs().clamp(0, 1);
  }

  Widget buildCycleCard(int index) {
    // the angle between each cards.
    final cardAngleSegment = pi / cycleData.length;
    //position bottom.
    final bottom = -context.screenHeight;
    // the radius of the card circle.
    final cardCircleRadius = (context.screenWidth / 2) + 700;
    //the expected angle of this card from 0 degree to the current location
    final percentageAngle = index * 2 * cardAngleSegment;
    // the total angle of the card since the wheel can be rotated by x and the old card angle y has to now be y+x.
    final circleAngle = rotationAngleInRad + percentageAngle;
    // reversing the card rotation by 90degree so it can stand straight and not fall flat.
    final cardCurveAngle = circleAngle - (pi / 2);

    final matrix = Matrix4.identity();
    final data = cycleData[index];
    final opacity = calclualateOpacity(circleAngle);

    matrix.translate(
      -cardCircleRadius * cos(circleAngle),
      -cardCircleRadius * sin(circleAngle),
    );

    return Positioned(
      bottom: bottom,
      child: AnimatedOpacity(
        duration: fastDuration,
        opacity: opacity,
        child: Transform(
          transform: matrix,
          child: Transform.rotate(
            angle: cardCurveAngle,
            child: CycleCard(data: data),
          ),
        ),
      ).fadeInAndMoveFromBottom(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bgColor: whiteColor,
      body: buildBody(),
    );
  }

  buildBody() {
    return GestureDetector(
      onPanStart: (details) =>
          previousMousePosition = details.globalPosition.dx,
      onPanEnd: (_) => startCount(),
      onPanUpdate: (details) => rotateWheel(details),
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: [
          buildBackground(),
          for (var i = 0; i < cycleData.length; i++) buildCycleCard(i),
          Positioned(
            bottom: -3 * context.screenHeight / 4,
            key: sizeKey,
            child: buildWheel(),
          ),
          buildTexts(),
          buildHeader(),
        ],
      ),
    );
  }

  buildHeader() {
    return Positioned(
      top: 20,
      left: 40,
      right: 40,
      child: Row(
        children: [
          Image.asset(
            logo,
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu_rounded,
              size: 40,
            ),
          )
        ],
      ).fadeInAndMoveFromBottom(),
    );
  }

  buildTexts() {
    if (currentCardIndex == -1) return const SizedBox();

    CycleData data = cycleData[currentCardIndex];
    final halfWidth = context.screenWidth / 2;
    //250 is the half of the width of the cycle card.
    final left = 250 + halfWidth;
    // the radius of the card circle.
    final cardCircleRadius = halfWidth + 700;
    final bottom = -context.screenHeight;
    final textContainerWidth = halfWidth - 500;
    return Positioned(
      left: left,
      bottom: bottom + cardCircleRadius,
      child: Container(
        height: 650, //height of the cycle card.
        margin: const EdgeInsets.only(left: space24),
        width: textContainerWidth,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.6),
                borderRadius: BorderRadius.circular(space16),
              ),
            ),
            verticalSpacer12,
            Text(
              data.title.toUpperCase(),
              style: satoshi700S24.copyWith(
                fontSize: 90,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpacer12,
            Text(
              data.description,
              style: satoshi500S16.copyWith(color: blackColor.withOpacity(.9)),
            ),
          ],
        ),
      ).fadeInAndMoveFromBottom(
        animationDuration: fastDuration,
        delay: medDuration,
      ),
    );
  }

  buildBackground() {
    return Transform.scale(
      scale: 1.3,
      child: Image.asset(
        backgroundImage,
        width: context.screenWidth,
        height: context.screenHeight,
        opacity: const AlwaysStoppedAnimation(0.6),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildWheel() {
    final width = context.screenWidth / 1.5;
    return Transform.rotate(
      angle: rotationAngleInRad,
      child: Image.asset(
        wheel,
        width: width,
        height: width,
        fit: BoxFit.contain,
      ),
    ).fadeInAndMoveFromBottom();
  }

  rotateWheel(details) {
    final box = sizeKey.currentContext!.findRenderObject() as RenderBox;
    final centerOffset = box.size.center(Offset.zero);
    final widgetCenter =
        box.localToGlobal(centerOffset).dx; //center dx of the wheel ;

    final mouseCurrentPosition = details.globalPosition.dx;

    // distance difference between current mouse location and previous mouse location. i.e from where drag started to now
    final differenceInMouse = mouseCurrentPosition - previousMousePosition;

    // a game of ratio. if the widget center is at 90 degree then the current angle is what compared to that.
    final angleDifference = differenceInMouse * 90 / widgetCenter;
    final angleDifferenceInRad =
        angleDifference * pi / 180; //convert angle difference to rad

    rotationAngleInRad = rotationAngleInRad +
        angleDifferenceInRad; // increase the old angle by the difference.
    rotationAngleInRad = rotationAngleInRad %
        (2 * pi); //normalize the angle to be between 0 and 360 degreee

    previousMousePosition = mouseCurrentPosition;
    setCurrentIndex();
    setState(() {});
  }

  setCurrentIndex() {
    int newIndex = -1;
    final cardSegmentFraction =
        2 * pi / cycleData.length; //angle between each cards.

    const piMultiplication = 2 * pi;
    const radiansToDegreeConversion = 180 / pi;

    final normalizedAngle = rotationAngleInRad %
        piMultiplication; //normalizing it to be between 0 and 360 degree.

    for (var index = 0; index < cycleData.length; index++) {
      final cardFractionAngle = index * cardSegmentFraction;
      final cardTotalAngle = normalizedAngle + cardFractionAngle;

      final normalizedCardAngle = cardTotalAngle % piMultiplication;
      final cardAngleInDegree = normalizedCardAngle * radiansToDegreeConversion;

      if (cardAngleInDegree > 85 && cardAngleInDegree < 95) {
        newIndex = index;
      }
    }
    currentCardIndex = newIndex;
  }

  startCount() {
    cancelableOp?.cancel();
    cancelableOp = CancelableOperation.fromFuture(snapToAngle());
  }

  Future<void> snapToAngle() async {
    await Future.delayed(fastDuration);

    final newAngle = getNearestSnapMultiple(rotationAngleInRad);

    if (rotationAngleInRad != newAngle) {
      snapController?.stop();
      snapController = AnimationController(
        vsync: this,
        duration: fastDuration,
      );
      snapController?.addListener(() {
        rotationAngleInRad = lerpDouble(
              rotationAngleInRad,
              newAngle,
              snapController?.value ?? 0,
            ) ??
            rotationAngleInRad;
        setCurrentIndex();
        setState(() {});
      });
      snapController?.forward();
    }
  }

  //to get if the card should snap up or down based on its position.
  getNearestSnapMultiple(double angle) {
    final segment = pi * 2 / cycleData.length;
    double newAngle = (angle / segment).round() * segment;

    //to see if is closer to the left or right side and snap there.
    if (angle - newAngle > segment / 2) {
      newAngle += segment;
    }
    return newAngle;
  }
}
