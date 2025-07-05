import 'package:flutter/material.dart';
import 'package:tugas_front_end_nicolas/utils/index.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final Object value;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;

  const DetailRow({
    Key? key,
    this.color,
    required this.label,
    required this.value,
    this.fontWeight,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize ?? 15,
                    color: color ?? Colors.grey,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
              value is String
                  ? Expanded(
                    child: Text(
                      value as String,
                      style: TextStyle(
                        fontSize: fontSize ?? 15,
                        color: color ?? Colors.black,
                        fontWeight: fontWeight,
                      ),
                      textAlign: TextAlign.end,
                      softWrap: true,
                    ),
                  )
                  : Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: value as Widget,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailItem {
  final String label;
  final String? value;
  final Widget? child;
  final Color? color;
  final bool bottomBorder;
  final FontWeight? fontWeight;

  DetailItem({
    required this.label,
    this.value,
    this.child,
    this.color,
    this.fontWeight,
    this.bottomBorder = false,
  }) : assert(
         value == null || child == null,
         'Cannot provide both value and child.',
       );
}

class DataCard extends StatelessWidget {
  final List<DetailItem>? listData;
  final String? title;
  final List<DetailItem>? listInput;

  const DataCard({super.key, this.listData, this.title, this.listInput});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final FontWeight fontWeight = FontWeight.w600;
    final double fontSize = isSmall ? 13 : 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: isSmall ? 18 : 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: title == null ? 0 : 8,
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (listData != null && listData!.isNotEmpty) ...[
                    ...List.generate(listData!.length * 2 - 1, (index) {
                      final i = index ~/ 2;
                      final item = listData![i];
                      if (index.isEven) {
                        return DetailRow(
                          label: item.label,
                          value: (item.value ?? item.child)!,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          color: item.color,
                        );
                      } else {
                        if (item.bottomBorder) {
                          return Divider(thickness: 2, height: 30);
                        }
                        return SizedBox(height: 10);
                      }
                    }),
                    if (listInput != null && listInput!.isNotEmpty)
                      const SizedBox(height: 10),
                  ],
                  if (listInput != null && listInput!.isNotEmpty) ...[
                    ...List.generate(listInput!.length * 2 - 1, (index) {
                      if (index.isEven) {
                        final i = index ~/ 2;
                        final item = listInput![i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: (item.fontWeight ?? fontWeight),
                              ),
                            ),
                            const SizedBox(height: 4),
                            item.child!,
                          ],
                        );
                      } else {
                        return const SizedBox(height: 10);
                      }
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DetailCard extends StatelessWidget {
  final List<DetailItem>? listData;
  final String? title;

  const DetailCard({super.key, this.listData, this.title});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final double fontSize = isSmall ? 13 : 16;

    return Card(
      elevation: 4,
      shadowColor: const Color.fromRGBO(0, 0, 0, 1),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBFBFBF)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: isSmall ? 15 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Center(
                child: Text(
                  title!,
                  style: TextStyle(fontSize: isSmall ? 18 : 20),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (listData != null && listData!.isNotEmpty)
              ...List.generate(listData!.length, (index) {
                final item = listData![index];
                return DetailRow(
                  label: item.label,
                  value: (item.value ?? item.child)!,
                  fontSize: fontSize,
                  color: item.color,
                  fontWeight: item.fontWeight,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class StrikeThroughPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  StrikeThroughPainter({this.color = Colors.red, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiscountDisplay extends StatelessWidget {
  const DiscountDisplay(this.originalPrice, this.dicsountPrice);
  final double originalPrice;
  final double dicsountPrice;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    return Row(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text(
              formatCurrency(nominal: originalPrice),
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmall ? 13 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: StrikeThroughPainter(
                  color: Colors.red,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          formatCurrency(nominal: dicsountPrice),
          style: TextStyle(
            color: Colors.red,
            fontSize: isSmall ? 13 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
