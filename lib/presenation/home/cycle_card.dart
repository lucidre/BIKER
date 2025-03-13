import 'package:biker/common_libs.dart';
import 'package:biker/models/data.dart';

class CycleCard extends StatelessWidget {
  final CycleData data;

  const CycleCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: space6),
      shadowColor: Colors.black.withOpacity(.6),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(space16),
      ),
      child: buildBody(),
    );
  }

//test
  buildBody() {
    return Container(
      width: 400,
      height: 650,
      color: whiteColor,
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.authorName,
                  style: satoshi500S16.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: blackColor,
                  ),
                ),
                verticalSpacer4,
                Text(
                  data.authorWork,
                  style: satoshi500S12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buildImage() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        data.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        scale: 1.2,
      ),
    );
  }
}
